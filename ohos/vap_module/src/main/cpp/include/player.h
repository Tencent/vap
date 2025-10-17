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

#ifndef VAP_PLAYER_H
#define VAP_PLAYER_H

#include <js_native_api.h>
#include <mutex>
#include <memory>
#include <atomic>
#include <thread>
#include <unistd.h>
#include "audio_decoder.h"
#include "video_decoder.h"
#include "demuxer.h"
#include "egl_core.h"
#include "data_info.h"

class Player {
public:
    Player() {};
    ~Player();

    int32_t Init(VAPInfo &info);
    int32_t Start();
    void XComponentClick(int32_t eventX, int32_t eventY)
    {
        LOGD("play get XComponentClick event %{public}d -- %{public}d", eventX, eventY);
        std::string clickRes;
        if (eglCore_) {
            eglCore_->GetCurrentClickTxt(eventX, eventY, clickRes);
        }
        if (clickCallback_) {
            CallbackContext *context = (CallbackContext *)clickCallbackData_;
            napi_value jsCallback = nullptr;
            napi_get_reference_value(context->env, context->callbackRef, &jsCallback);
            napi_value resTxt;
            napi_create_string_utf8(context->env, clickRes.c_str(), clickRes.size(), &resTxt);
            napi_call_function(context->env, nullptr, jsCallback, 1, &resTxt, nullptr);
        }
    }
    void SetClickCallBack(void (*clickCallback)(void *context), void *clickCallbackData)
    {
        clickCallback_ = clickCallback;
        clickCallbackData_ = clickCallbackData;
    }

    void PauseAndResume()
    {
        if (!isStarted_) {
            LOGD("PauseAndResume player is not start");
            return;
        }
        std::lock_guard<std::mutex> lock(pauseMutex_);
        isPause_ = !isPause_;
        pauseCond_.notify_all();
    }
    void Stop()
    {
        if (!isStarted_) {
            LOGD("Stop player is not start");
            return;
        }
        isStop_ = true;
        loops_ = 1;
        std::lock_guard<std::mutex> lock(pauseMutex_);
        if (isPause_) {
            isPause_ = false;
            pauseCond_.notify_all();
        }
    }
    void SetLoop(int32_t loops = 1) { loops_ = loops; }

    void SetCallBack(void (*callback)(void *context), void *callbackData)
    {
        callback_ = callback;
        callbackData_ = callbackData;
    }
    
    void SetFitType(VideoFitType fitType) { fitType_ = fitType; }
    void SetVideoMode(VideoMode videoMode)
    {
        isSetVideoMode_ = true;
        defaultVideoMode_ = videoMode;
    }
    
    bool IsRunning() { return isStarted_; }
    
    void CallBackJS(VapState state, int32_t err = 1);
    void StartRelease();
    std::unique_ptr<EGLCore> eglCore_ = nullptr;
private:
    bool isSetVideoMode_ = false;
    VideoMode defaultVideoMode_ = VIDEO_MODE_SPLIT_HORIZONTAL;
    JSAnimConfig jsAnimConfig_;
    void InitJSAnimConfig();
    int32_t loops_ = 1;
    void (*callback_)(void *context) = nullptr;
    void *callbackData_ = nullptr;
    
    void (*clickCallback_)(void *context) = nullptr;
    void *clickCallbackData_ = nullptr;

    std::mutex pauseMutex_;
    std::condition_variable pauseCond_;
    bool isPause_{false};
    
    void InitAudioPlayer(AudioInitData audioInitData);
    OH_AudioRenderer *audioRenderer_ = nullptr;
    OH_AudioStreamBuilder *builder_ = nullptr;
    
    void Release();
    void ReleaseAudio();
    void DecInputThread();
    void DecOutputThread();
    void DecAudioInputThread();
    void DecAudioOutputThread();
    void RenderThread();

    int32_t InitAudio();
    void InitControlSignal();
    void GetBufferData(CodecBufferInfo bufferInfo);
    void GetPCMData(AudioCodecBufferInfo bufferInfo);

    std::mutex renderMutex_;
    std::queue<std::vector<uint8_t>> renderQueue_;
    std::unique_ptr<std::thread> renderThread_ = nullptr;
    std::condition_variable renderCond_;

    std::unique_ptr<Demuxer> demuxer_ = nullptr;
    std::unique_ptr<VideoDecoder> videoDecoder_ = nullptr;
    std::unique_ptr<AudioDecoder> audioDecoder_ = nullptr;
    ADecSignal *audioSignal_ = nullptr;
    VDecSignal *signal_ = nullptr;

    std::atomic<bool> isStop_{false};
    std::atomic<bool> isVideoEnd_{false};
    std::atomic<bool> isAudioEnd_{false};
    std::atomic<bool> isStarted_{false};
    std::atomic<bool> isReleased_{false};
    std::atomic<bool> isVideoEndOfFile_{false};

    std::unique_ptr<std::thread> decAudioInputThread_ = nullptr;
    std::unique_ptr<std::thread> decAudioOutputThread_ = nullptr;

    std::mutex mutex_;
    std::unique_ptr<std::thread> decInputThread_ = nullptr;
    std::unique_ptr<std::thread> decOutputThread_ = nullptr;
    VAPInfo sampleInfo_;

    static constexpr int64_t MICROSECOND = 1000000;
    static constexpr int32_t DEFAULT_FRAME_RATE = 30;
    static constexpr int32_t ONE_K = 1024;
    static constexpr int32_t AUDIO_SLEEP_TIME = 100;
    static constexpr int32_t AUDIO_CACHE = 5;
    
    int32_t stride_ = 0;
    int32_t sliceHeight_ = 0;
    int32_t frameCurIdx_ = 0;
    
    int32_t renderFrameCurIdx_ = 0;
    VideoFitType fitType_ = VideoFitType::FIT_XY;
};

#endif // VAP_PLAYER_H