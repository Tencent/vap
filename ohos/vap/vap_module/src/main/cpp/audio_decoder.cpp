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

#include "audio_decoder.h"

#include <multimedia/player_framework/native_avcodec_audiocodec.h>
#include <multimedia/player_framework/native_avcodec_audiodecoder.h>

#include "log.h"

#undef LOG_TAG
#define LOG_TAG "AudioDecoder"

namespace {
void OnCodecError(OH_AVCodec *codec, int32_t errorCode, void *userData)
{
    (void)codec;
    (void)errorCode;
    (void)userData;
    LOGE("On codec error, error code: %{public}d", errorCode);
}

void OnCodecFormatChange(OH_AVCodec *codec, OH_AVFormat *format, void *userData)
{
    LOGI("On codec format change");
}

void OnNeedInputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData)
{
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    ADecSignal *m_signal = static_cast<ADecSignal *>(userData);
    std::unique_lock<std::mutex> lock(m_signal->audioInputMutex);
    m_signal->audioInputBufferInfoQueue.emplace(index, buffer, codec);
    m_signal->audioInputCond.notify_all();
}

void OnNewOutputBuffer(OH_AVCodec *codec, uint32_t index, OH_AVBuffer *buffer, void *userData)
{
    if (userData == nullptr) {
        return;
    }
    (void)codec;
    ADecSignal *m_signal = static_cast<ADecSignal *>(userData);
    std::unique_lock<std::mutex> lock(m_signal->audioOutputMutex);
    m_signal->audioOutputBufferInfoQueue.emplace(index, buffer, codec);
    m_signal->audioOutputCond.notify_all();
}
}

AudioDecoder::~AudioDecoder()
{
    Release();
}

int32_t AudioDecoder::CreateAudioDecoder(const std::string &codecMime)
{
    decoder_ = OH_AudioCodec_CreateByMime(codecMime.c_str(), false);
    if (decoder_ == nullptr) {
        LOGE("create audio decoder_ failed");
        return AV_ERR_UNKNOWN;
    }
    return AV_ERR_OK;
}

int32_t AudioDecoder::SetCallback(ADecSignal *signal)
{
    int32_t ret = AV_ERR_OK;
    ret = OH_AudioCodec_RegisterCallback(decoder_, {OnCodecError, OnCodecFormatChange,
                                            OnNeedInputBuffer, OnNewOutputBuffer}, signal);
    if (ret != AV_ERR_OK) {
        LOGE("Set callback failed, ret: %{public}d", ret);
        return AV_ERR_UNKNOWN;
    }
    return AV_ERR_OK;
}

int32_t AudioDecoder::ConfigureAudioDecoder(const VAPInfo &sampleInfo)
{
    OH_AVFormat *format = OH_AVFormat_Create();
    if (format == nullptr) {
        LOGE("AVFormat create failed");
        return AV_ERR_UNKNOWN;
    }
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_SAMPLE_RATE, sampleInfo.sampleRate);
    OH_AVFormat_SetLongValue(format, OH_MD_KEY_BITRATE, sampleInfo.audioBitrate);
    OH_AVFormat_SetIntValue(format, OH_MD_KEY_AUD_CHANNEL_COUNT, sampleInfo.channelCount);
    if (strcmp(sampleInfo.audioCodecMime.c_str(), "audio/mp4a-latm") == 0) {
        OH_AVFormat_SetIntValue(format, OH_MD_KEY_AAC_IS_ADTS, 1);
        LOGD("audio mime is aac");
    } else {
        LOGD("audio mime is not aac");
    }
    LOGD("AudioDecoder config: %{public}d - %{public}ld = %{public}d", sampleInfo.sampleRate,
        sampleInfo.audioBitrate, sampleInfo.channelCount);
    int ret = OH_AudioCodec_Configure(decoder_, format);
    if (ret != AV_ERR_OK) {
        LOGE("Config failed, ret: %{public}d", ret);
        return AV_ERR_UNKNOWN;
    }
    OH_AVFormat_Destroy(format);
    format = nullptr;

    return AV_ERR_OK;
}

int32_t AudioDecoder::Config(const VAPInfo &sampleInfo, ADecSignal *signal)
{
    if (decoder_ == nullptr) {
        LOGE("Decoder is null");
        return AV_ERR_UNKNOWN;
    }
    if (signal == nullptr) {
        LOGE("Invalid param: codecUserData");
        return AV_ERR_UNKNOWN;
    }

    int32_t ret = ConfigureAudioDecoder(sampleInfo);
    if (ret != AV_ERR_OK) {
        LOGE("Configure failed");
        return AV_ERR_UNKNOWN;
    }
    
    ret = SetCallback(signal);
    if (ret != AV_ERR_OK) {
        LOGE("Set callback failed, ret: %{public}d", ret);
        return AV_ERR_UNKNOWN;
    }
    
    ret = OH_AudioCodec_Prepare(decoder_);
    if (ret != AV_ERR_OK) {
        LOGE("audio Prepare failed, ret: %{public}d", ret);
        return AV_ERR_UNKNOWN;
    }
    return AV_ERR_OK;
}

int32_t AudioDecoder::StartAudioDecoder()
{
    if (decoder_ == nullptr) {
        LOGE("Decoder is null");
        return AV_ERR_UNKNOWN;
    }

    int ret = OH_AudioCodec_Start(decoder_);
    if (ret != AV_ERR_OK) {
        LOGE("audio Start failed, ret: %{public}d", ret);
        return AV_ERR_UNKNOWN;
    }
    return AV_ERR_OK;
}

int32_t AudioDecoder::PushInputData(AudioCodecBufferInfo &info)
{
    if (decoder_ == nullptr) {
        LOGE("Decoder is null");
        return AV_ERR_UNKNOWN;
    }
    int32_t ret = OH_AVBuffer_SetBufferAttr(info.bufferOrigin, &info.attr);
    if (ret != AV_ERR_OK) {
        LOGE("Set avbuffer attr failed");
        return AV_ERR_UNKNOWN;
    }
    ret = OH_AudioCodec_PushInputBuffer(decoder_, info.bufferIndex);
    if (ret != AV_ERR_OK) {
        LOGE("Push input data failed");
        return AV_ERR_UNKNOWN;
    }
    return AV_ERR_OK;
}

int32_t AudioDecoder::FreeOutputData(uint32_t bufferIndex, bool render)
{
    if (decoder_ == nullptr) {
        LOGE("Decoder is null");
        return AV_ERR_UNKNOWN;
    }

    int32_t ret = AV_ERR_OK;
    ret = OH_AudioCodec_FreeOutputBuffer(decoder_, bufferIndex);
    if (ret != AV_ERR_OK) {
        LOGE("audio Free output data failed");
        return AV_ERR_UNKNOWN;
    }
    return AV_ERR_OK;
}

int32_t AudioDecoder::Release()
{
    if (decoder_ != nullptr) {
        OH_AudioCodec_Flush(decoder_);
        OH_AudioCodec_Stop(decoder_);
        OH_AudioCodec_Destroy(decoder_);
        decoder_ = nullptr;
    }
    return AV_ERR_OK;
}