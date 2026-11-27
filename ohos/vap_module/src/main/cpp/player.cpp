/*
 * Copyright (C) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "player.h"

#include <chrono>
#include <cstdint>
#include <memory>
#include <multimedia/player_framework/native_averrors.h>
#include <fcntl.h>
#include <mutex>
#include <sys/stat.h>
#include <vector>
#include "log.h"
#include "vap_callback.h"

#undef LOG_TAG
#define LOG_TAG "player"

namespace {
using namespace std::chrono_literals;
}

Player::~Player()
{
    Stop();
}

static int32_t OpenFile(VAPInfo &info)
{
    const char *file = info.uri.c_str();
    info.inputFd = -1;
    info.inputFileSize = 0;
    info.inputFileOffset = 0;
    info.inputFd = open(file, O_RDONLY);
    LOGD("Open file: fd = %{public}d", info.inputFd);
    if (info.inputFd == -1) {
        LOGE("cont open file");
        return AV_ERR_UNKNOWN;
    }

    struct stat fileStatus {};
    if (stat(file, &fileStatus) == 0) {
        info.inputFileSize = static_cast<size_t>(fileStatus.st_size);
        LOGD("Get stat:%{public}zu", info.inputFileSize);
        return AV_ERR_OK;
    } else {
        LOGE("Get stat file size error");
        return AV_ERR_UNKNOWN;
    }
}

int32_t Player::InitAudio()
{
    audioDecoder_ = std::make_unique<AudioDecoder>();
    int32_t ret = audioDecoder_->CreateAudioDecoder(sampleInfo_.audioCodecMime);
    if (ret != AV_ERR_OK) {
        LOGE("Create audio decoder failed");
        return AV_ERR_UNKNOWN;
    }
    audioSignal_ = new ADecSignal;
    ret = audioDecoder_->Config(sampleInfo_, audioSignal_);
    if (ret != AV_ERR_OK) {
        LOGE("audio Decoder config failed");
        return AV_ERR_UNKNOWN;
    }
    AudioInitData audioInitData;
    audioInitData.channelCount = sampleInfo_.channelCount;
    audioInitData.samplingRate = sampleInfo_.sampleRate;
    InitAudioPlayer(audioInitData);
    return AV_ERR_OK;
}

void Player::InitControlSignal()
{
    if (sampleInfo_.frameRate <= 0) {
        sampleInfo_.frameRate = DEFAULT_FRAME_RATE;
    }
    sampleInfo_.frameInterval = MICROSECOND / int64_t(sampleInfo_.frameRate);
    isReleased_ = false;
    isAudioEnd_ = false;
    isVideoEnd_ = false;
    isStop_ = false;
    isPause_ = false;
    isVideoEndOfFile_ = false;
}

int32_t Player::Init(VAPInfo &info)
{
    std::lock_guard<std::mutex> lock(mutex_);
    CallBackJS(VapState::READY);
    if (isStarted_) {
        LOGE("Already started.");
        return AV_ERR_UNKNOWN;
    }
    
    if (OpenFile(info) != AV_ERR_OK) {
        CallBackJS(VapState::FAILED, AV_ERR_UNKNOWN);
        return AV_ERR_UNKNOWN;
    }
    
    sampleInfo_ = info;
    videoDecoder_ = std::make_unique<VideoDecoder>();
    if (!videoDecoder_) {
        LOGE("Create videoDecoder_ failed");
        CallBackJS(VapState::FAILED, AV_ERR_UNKNOWN);
        return AV_ERR_UNKNOWN;
    }

    demuxer_ = std::make_unique<Demuxer>();
    int32_t ret = demuxer_->CreateDemuxer(sampleInfo_);
    if (ret != AV_ERR_OK) {
        LOGE("Create demuxer failed");
        CallBackJS(VapState::FAILED, ret);
        return AV_ERR_UNKNOWN;
    }
    
    ret = videoDecoder_->CreateVideoDecoder(sampleInfo_.codecMime);
    if (ret != AV_ERR_OK) {
        LOGE("Create video decoder failed");
        CallBackJS(VapState::FAILED, ret);
        return AV_ERR_UNKNOWN;
    }

    if (demuxer_->hasAudio()) {
        ret = InitAudio();
        if (ret != AV_ERR_OK) {
            CallBackJS(VapState::FAILED, ret);
            return ret;
        }
    }
    
    signal_ = new VDecSignal;
    ret = videoDecoder_->Config(sampleInfo_, signal_);
    if (ret != AV_ERR_OK) {
        LOGE("Decoder config failed");
        return AV_ERR_UNKNOWN;
    }
    
    InitControlSignal();
    return Start();
}

void Player::CallBackJS(VapState state, int32_t err)
{
    if (callback_) {
        LOGD("enter callback_ ");
        CallbackContext *context = (CallbackContext *)callbackData_;
        context->vapState = state;
        context->err = err;
        jsAnimConfig_.currentFrame = renderFrameCurIdx_;
        context->jsAnimConfig = jsAnimConfig_;
        callback_(callbackData_);
    }
}

int32_t Player::Start()
{
    if (isStarted_) {
        LOGE("Already started.");
        return AV_ERR_UNKNOWN;
    }
    if (!videoDecoder_ || !demuxer_) {
        LOGE("Please Init first.");
        return AV_ERR_UNKNOWN;
    }
    isStarted_ = true;
    int32_t ret = videoDecoder_->StartVideoDecoder();
    if (ret != AV_ERR_OK) {
        LOGE("Decoder start failed");
        return AV_ERR_UNKNOWN;
    }
    if (demuxer_->hasAudio()) {
        LOGW("video has audio");
        ret = audioDecoder_->StartAudioDecoder();
        if (ret != AV_ERR_OK) {
            LOGE("audio Decoder start failed");
            return AV_ERR_UNKNOWN;
        }
        
        decAudioInputThread_ = std::make_unique<std::thread>(&Player::DecAudioInputThread, this);
        decAudioOutputThread_ = std::make_unique<std::thread>(&Player::DecAudioOutputThread, this);
        if (decAudioInputThread_ == nullptr || decAudioOutputThread_ == nullptr) {
            LOGE("Create thread failed");
            ReleaseAudio();
            return AV_ERR_UNKNOWN;
        }
    } else {
        isAudioEnd_ = true;
    }
    
    decInputThread_ = std::make_unique<std::thread>(&Player::DecInputThread, this);
    decOutputThread_ = std::make_unique<std::thread>(&Player::DecOutputThread, this);
    renderThread_ = std::make_unique<std::thread>(&Player::RenderThread, this);
    if (decInputThread_ == nullptr || decOutputThread_ == nullptr || renderThread_ == nullptr) {
        LOGE("Create thread failed");
        StartRelease();
        return AV_ERR_UNKNOWN;
    }
    CallBackJS(VapState::START);
    return AV_ERR_OK;
}

void Player::StartRelease()
{
    LOGD("StartRelease %{public}d  %{public}d", isVideoEnd_.load(), isAudioEnd_.load());
    
    // 获取锁
    std::unique_lock<std::mutex> lock(mutex_);
    if (isReleased_) return;
    
    if (!isVideoEnd_ || !isAudioEnd_) return;

    // 确保只释放一次
    if (!isReleased_) {
        // 执行释放操作
        CallBackJS(VapState::COMPLETE);
        ReleaseAudio();
        Release();
    }
}

void Player::ReleaseAudio()
{
    if (audioRenderer_) {
        OH_AudioRenderer_Flush(audioRenderer_);   // 释放缓存数据
        OH_AudioRenderer_Release(audioRenderer_); //	释放播放实例
        audioRenderer_ = nullptr;
    }
    if (builder_) {
        OH_AudioStreamBuilder_Destroy(builder_);
        builder_ = nullptr;
    }
    if (decAudioInputThread_ && decAudioInputThread_->joinable()) {
        decAudioInputThread_->join();
        decAudioInputThread_.reset();
    }
    
    if (decAudioOutputThread_ && decAudioOutputThread_->joinable()) {
        decAudioOutputThread_->detach();
        decAudioOutputThread_.reset();
    }

    if (audioDecoder_ != nullptr) {
        audioDecoder_->Release();
        audioDecoder_.reset();
    }
    if (audioSignal_ != nullptr) {
        delete audioSignal_;
        audioSignal_ = nullptr;
    }
    LOGE("Player: audio release end");
}

void Player::Release()
{
    if (decInputThread_ && decInputThread_->joinable()) {
        decInputThread_->join();
    }
    decInputThread_.reset();

    if (decOutputThread_ && decOutputThread_->joinable()) {
        decOutputThread_->join();
    }
    decOutputThread_.reset();

    if (renderThread_ && renderThread_->joinable()) {
        renderThread_->detach();
        renderThread_.reset();
    }
    
    if (videoDecoder_ != nullptr) {
        videoDecoder_->Release();
        videoDecoder_.reset();
    }
    if (demuxer_ != nullptr) {
        demuxer_->Release();
        demuxer_.reset();
    }
    
    if (sampleInfo_.inputFd != -1) {
        close(sampleInfo_.inputFd);
        sampleInfo_.inputFd = -1;
    }
    if (eglCore_ != nullptr) {
        eglCore_->Release();
        eglCore_.reset();
    }
    auto emptyQueue = std::queue<std::vector<uint8_t>>();
    renderQueue_.swap(emptyQueue);
    if (signal_ != nullptr) {
        delete signal_;
        signal_ = nullptr;
    }
    
    isStop_ = false;
    isStarted_ = false;
    isReleased_ = true;
    isPause_ = false;
    isVideoEndOfFile_ = false;
    renderFrameCurIdx_ = 0;
    isSetVideoMode_ = false;
    CallBackJS(VapState::DESTROY);
    if (sampleInfo_.playDoneCallback) {
        sampleInfo_.playDoneCallback(sampleInfo_.playDoneCallbackData);
        LOGD("play end callback");
    }
    LOGE("Player: release end: %{public}d", loops_);
}

void Player::InitJSAnimConfig()
{
    if (eglCore_->m_animConfig) {
        jsAnimConfig_.version = eglCore_->m_animConfig->version;
        jsAnimConfig_.totalFrames = eglCore_->m_animConfig->totalFrames;
        jsAnimConfig_.width = eglCore_->m_animConfig->width;
        jsAnimConfig_.height = eglCore_->m_animConfig->height;
        jsAnimConfig_.videoWidth = eglCore_->m_animConfig->videoWidth;
        jsAnimConfig_.videoHeight = eglCore_->m_animConfig->videoHeight;
        jsAnimConfig_.orien = eglCore_->m_animConfig->orien;
        jsAnimConfig_.fps = eglCore_->m_animConfig->fps;
        jsAnimConfig_.isMix = eglCore_->m_animConfig->isMix;
        jsAnimConfig_.alphaPointRect = eglCore_->m_animConfig->alphaPointRect;
        jsAnimConfig_.rgbPointRect = eglCore_->m_animConfig->rgbPointRect;
        jsAnimConfig_.currentFrame = 0;
    } else {
        LOGE("InitJSAnimConfig  eglCore_->m_animConfig nullptr");
    }
}

void Player::RenderThread()
{
    eglCore_ = std::make_unique<EGLCore>();
    LOGE("Player: RenderThread eglContext %{public}p %{public}d, %{public}d", sampleInfo_.window,
        sampleInfo_.width, sampleInfo_.height);
    if (isSetVideoMode_) {
        eglCore_->SetVideoMode(defaultVideoMode_);
    }
    eglCore_->SetVideoSize(sampleInfo_.videoWidth, sampleInfo_.videoHeight, sampleInfo_.codecMime);
    eglCore_->SetFitType(fitType_);
    if (!eglCore_->EglContextInit(sampleInfo_.window, sampleInfo_.width, sampleInfo_.height, sampleInfo_.uri,
        sampleInfo_.iptData)) {
        LOGE("Player: Unable to init eglContext");
    }
    InitJSAnimConfig();
    
    while (!isStop_ && isStarted_) {
        thread_local auto lastPushTime = std::chrono::system_clock::now();
        if (isVideoEndOfFile_) {
            LOGE("Decoder render end.");
            break;
        }
        std::unique_lock<std::mutex> lock(renderMutex_);
        bool condRet = renderCond_.wait_for(
            lock, 300ms, [this]() { return !renderQueue_.empty(); });
        if (renderQueue_.empty()) {
            LOGE("RenderThread no data");
            continue;
        }
        std::vector<uint8_t> buffer = renderQueue_.front();
        renderQueue_.pop();
        lock.unlock();
        
        if (eglCore_) {
            renderFrameCurIdx_++;
            LOGD("renderFrameCurIdx_: %{public}d frameCurIdx_: %{public}d", renderFrameCurIdx_, frameCurIdx_);
            
            if (renderFrameCurIdx_ < frameCurIdx_) {
                continue;
            }
            RenderData renderData = {buffer, stride_, sliceHeight_, frameCurIdx_};
            eglCore_->Render(renderData);
            CallBackJS(VapState::RENDER);
        }
    }
    LOGE("RenderThread thread out");
    isVideoEnd_ = true;
    if (eglCore_ != nullptr) {
        eglCore_->Release();
        eglCore_.reset();
    }
    StartRelease();
}

void Player::DecInputThread()
{
    while (!isStop_ && isStarted_) {
        std::unique_lock<std::mutex> lock(signal_->inputMutex);
        bool condRet = signal_->inputCond.wait_for(
            lock, 300ms, [this]() { return !isStarted_ || !signal_->inputBufferInfoQueue.empty();});
        if (!isStarted_) {
            LOGE("Work done, thread out");
            break;
        }
        if (signal_->inputBufferInfoQueue.empty()) {
            LOGE("DecInputThread Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }

        CodecBufferInfo bufferInfo = signal_->inputBufferInfoQueue.front();
        signal_->inputBufferInfoQueue.pop();
        signal_->inputFrameCount++;
        lock.unlock();

        if (!bufferInfo.buffer) {
            LOGE("DecInputThread bufferInfo buffer empty, continue");
            continue;
        }
        demuxer_->ReadSample(reinterpret_cast<OH_AVBuffer *>(bufferInfo.buffer), bufferInfo.attr);
        int32_t ret = videoDecoder_->PushInputData(bufferInfo);
        if (ret != AV_ERR_OK) {
            LOGE("Push data failed, thread out");
            break;
        }
        
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            LOGE("Catch EOS, in thread out");
            break;
        }
    }
    LOGE("DecInputThread thread out");
}

void Player::GetBufferData(CodecBufferInfo bufferInfo)
{
    std::vector<uint8_t> buffer;
    OH_AVFormat *temFormat = OH_VideoDecoder_GetOutputDescription(bufferInfo.codec);
    OH_AVFormat_GetIntValue(temFormat, OH_MD_KEY_VIDEO_STRIDE, &stride_);
    OH_AVFormat_GetIntValue(temFormat, OH_MD_KEY_VIDEO_SLICE_HEIGHT, &sliceHeight_);
    LOGD("GetBufferData %{public}d %{public}d", stride_, sliceHeight_);
    OH_AVFormat_Destroy(temFormat);
    if (!bufferInfo.bufferOrigin)
        return;
    uint8_t *dataPtr = reinterpret_cast<uint8_t *>(OH_AVBuffer_GetAddr(bufferInfo.bufferOrigin));
    buffer.assign(dataPtr, dataPtr + bufferInfo.attr.size);
    std::unique_lock<std::mutex> pauseLock(pauseMutex_);
    pauseCond_.wait(pauseLock, [this]() { return !isPause_;});
    pauseLock.unlock();
    std::unique_lock<std::mutex> lock(renderMutex_);
    renderQueue_.push(buffer);
    renderCond_.notify_all();
}

void Player::DecOutputThread()
{
    LOGE("sampleInfo_.frameInterval:  %{public}ld", sampleInfo_.frameInterval);
    while (!isStop_ && isStarted_) {
        thread_local auto lastPushTime = std::chrono::system_clock::now();
        std::unique_lock<std::mutex> lock(signal_->outputMutex);
        bool condRet = signal_->outputCond.wait_for(
            lock, 300ms, [this]() { return !isStarted_ || !signal_->outputBufferInfoQueue.empty(); });
        if (!isStarted_) {
            LOGE("Decoder output thread done out");
            break;
        }
        if (signal_->outputBufferInfoQueue.empty()) {
            LOGE("DecOutputThread Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }

        CodecBufferInfo bufferInfo = signal_->outputBufferInfoQueue.front();
        signal_->outputBufferInfoQueue.pop();
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            LOGE("Catch EOS, out thread out");
            isVideoEndOfFile_ = true;
            break;
        }
        
        signal_->outputFrameCount++;
        LOGD("Out buffer count: %{public}d, size: %{public}d, flag: %{public}u, pts: %{public}ld",
            signal_->outputFrameCount, bufferInfo.attr.size, bufferInfo.attr.flags, bufferInfo.attr.pts);
        frameCurIdx_ = signal_->outputFrameCount;
        lock.unlock();
        GetBufferData(bufferInfo);

        int32_t ret = videoDecoder_->FreeOutputData(bufferInfo.bufferIndex, false);
        if (ret != AV_ERR_OK) {
            LOGE("Decoder output thread out free");
            break;
        }

        std::this_thread::sleep_until(lastPushTime + std::chrono::microseconds(sampleInfo_.frameInterval));
        lastPushTime = std::chrono::system_clock::now();
    }
    LOGE("Exit, frame count: %{public}u", signal_->outputFrameCount);
}

void Player::DecAudioInputThread()
{
    while (!isStop_ && isStarted_) {
        std::unique_lock<std::mutex> lock(audioSignal_->audioInputMutex);
        bool condRet = audioSignal_->audioInputCond.wait_for(
            lock, 300ms, [this]() { return !isStarted_ || !audioSignal_->audioInputBufferInfoQueue.empty(); });
        if (!isStarted_) {
            LOGE("audio Work done, thread out");
            break;
        }
        if (audioSignal_->audioInputBufferInfoQueue.empty()) {
            LOGE("audio Buffer queue is empty, continue, cond ret: %{public}d", condRet);
            continue;
        }

        AudioCodecBufferInfo bufferInfo = audioSignal_->audioInputBufferInfoQueue.front();
        audioSignal_->audioInputBufferInfoQueue.pop();
        lock.unlock();

        demuxer_->ReadAudioSample(bufferInfo.bufferOrigin, bufferInfo.attr);

        int32_t ret = audioDecoder_->PushInputData(bufferInfo);
        if (ret != AV_ERR_OK) {
            LOGE("audio Push data failed, thread out");
            break;
        }

        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            LOGE("audio Catch EOS, in thread out");
            break;
        }
    }
    LOGE("DecAudioInputThread thread out");
}

void Player::GetPCMData(AudioCodecBufferInfo bufferInfo)
{
    uint8_t *source = reinterpret_cast<uint8_t *>(OH_AVBuffer_GetAddr(bufferInfo.bufferOrigin));
    for (int i = 0; i < bufferInfo.attr.size; i++) {
        audioSignal_->renderQueue.push(*(source + i));
    }
}

void Player::DecAudioOutputThread()
{
    if (audioRenderer_) {
        OH_AudioRenderer_Start(audioRenderer_);
    }
    while (!isStop_ && isStarted_) {
        if (audioSignal_->isInterrupt) {
            LOGW("audio render interrupt. play stop");
            isStop_ = true;
            break;
        }
        std::unique_lock<std::mutex> pauseLock(pauseMutex_);
        if (isPause_) {
            OH_AudioRenderer_Pause(audioRenderer_);
            pauseCond_.wait(pauseLock, [this]() { return !isPause_;});
            OH_AudioRenderer_Start(audioRenderer_);
        }
        pauseLock.unlock();
        std::unique_lock<std::mutex> lock(audioSignal_->audioOutputMutex);
        bool condRet = audioSignal_->audioOutputCond.wait_for(
            lock, 300ms, [this]() { return !isStarted_ || !audioSignal_->audioOutputBufferInfoQueue.empty(); });
        if (!isStarted_) {
            break;
        }
        if (audioSignal_->audioOutputBufferInfoQueue.empty()) {
            continue;
        }
        AudioCodecBufferInfo bufferInfo = audioSignal_->audioOutputBufferInfoQueue.front();
        audioSignal_->audioOutputBufferInfoQueue.pop();
        if (bufferInfo.attr.flags & AVCODEC_BUFFER_FLAGS_EOS) {
            LOGE("Catch EOS, audio out thread out");
            break;
        }
        GetPCMData(bufferInfo);
        lock.unlock();
        int32_t ret = audioDecoder_->FreeOutputData(bufferInfo.bufferIndex, false);
        if (ret != AV_ERR_OK) {
            break;
        }
        std::unique_lock<std::mutex> lockRender(audioSignal_->renderMutex);
        audioSignal_->renderCond.wait_for(lockRender, 20ms, [this, bufferInfo]() {
            return audioSignal_->renderQueue.size() < AUDIO_CACHE * bufferInfo.attr.size;
        });
    }
    isAudioEnd_ = true;
    OH_AudioRenderer_Stop(audioRenderer_);
    StartRelease();
}

void Player::InitAudioPlayer(AudioInitData audioInitData)
{
    LOGD("AudioPlayer enter init");
    OH_AudioStreamBuilder_Create(&builder_, audioInitData.type);
    // 设置音频采样率
    OH_AudioStreamBuilder_SetSamplingRate(builder_, audioInitData.samplingRate);
    // 设置音频声道
    OH_AudioStreamBuilder_SetChannelCount(builder_, audioInitData.channelCount);
    // 设置音频采样格式
    OH_AudioStreamBuilder_SetSampleFormat(builder_, audioInitData.format);
    // 设置音频流的编码类型
    OH_AudioStreamBuilder_SetEncodingType(builder_, audioInitData.encodingType);
    // 设置输出音频流的工作场景
    OH_AudioStreamBuilder_SetRendererInfo(builder_, audioInitData.usage);

    OH_AudioRenderer_Callbacks callbacks;
    // 配置回调函数
    callbacks.OH_AudioRenderer_OnWriteData = VAPCallback::OnRenderWriteData;
    callbacks.OH_AudioRenderer_OnStreamEvent = VAPCallback::OnRenderStreamEvent;
    callbacks.OH_AudioRenderer_OnInterruptEvent = VAPCallback::OnRenderInterruptEvent;
    callbacks.OH_AudioRenderer_OnError = VAPCallback::OnRenderError;

    // 设置输出音频流的回调
    OH_AudioStreamBuilder_SetRendererCallback(builder_, callbacks, audioSignal_);
    OH_AudioStreamBuilder_GenerateRenderer(builder_, &audioRenderer_);
}
