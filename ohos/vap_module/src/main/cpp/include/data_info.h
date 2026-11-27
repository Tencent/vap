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

#ifndef VAP_DATATYPE_INFO_H
#define VAP_DATATYPE_INFO_H

#include <EGL/eglplatform.h>
#include <bits/alltypes.h>
#include <cstdint>
#include <js_native_api_types.h>
#include <multimedia/player_framework/native_avcodec_videoencoder.h>
#include <ohaudio/native_audiostream_base.h>
#include <string>
#include <condition_variable>
#include <queue>
#include <native_buffer/native_buffer.h>
#include "mix_render.h"
#include "multimedia/player_framework/native_avcodec_base.h"
#include "multimedia/player_framework/native_avbuffer.h"

#define ANNEXB_INPUT_ONLY 1

const std::string_view MIME_VIDEO_AVC = "video/avc";
const std::string_view MIME_VIDEO_HEVC = "video/hevc";

constexpr int32_t BITRATE_10M = 10 * 1024 * 1024; // 10Mbps
constexpr int32_t BITRATE_20M = 20 * 1024 * 1024; // 20Mbps
constexpr int32_t BITRATE_30M = 30 * 1024 * 1024; // 30Mbps

struct AudioInitData {
    OH_AudioStream_Type type = AUDIOSTREAM_TYPE_RENDERER;
    int32_t samplingRate = 48000;
    int32_t channelCount = 2;
    OH_AudioStream_SampleFormat format = AUDIOSTREAM_SAMPLE_S16LE;
    OH_AudioStream_EncodingType encodingType = AUDIOSTREAM_ENCODING_TYPE_RAW;
    OH_AudioStream_Usage usage = AUDIOSTREAM_USAGE_MUSIC;
};

struct VAPInfo {
    int32_t sampleId = 0;
    int32_t inputFd = -1;
    int32_t outFd = -1;
    int64_t inputFileOffset = 0;
    int64_t inputFileSize = 0;
    std::string inputFilePath;
    std::string outputFilePath;
    std::string codecMime = MIME_VIDEO_AVC.data();
    int32_t videoWidth = 0;
    int32_t videoHeight = 0;
    double frameRate = 0.0;
    int64_t bitrate = 10 * 1024 * 1024; // 10Mbps;

    int64_t audioBitrate;
    uint32_t sampleRate;
    uint32_t channelCount;
    std::string audioCodecMime;

    int64_t frameInterval = 0;
    int32_t perfmode = 0;
    int64_t durationTime = 0;
    uint32_t maxFrames = UINT32_MAX;
    int32_t isHDRVivid = 0;
    uint32_t repeatTimes = 1;
    OH_AVPixelFormat pixelFormat = AV_PIXEL_FORMAT_NV12; // AV_PIXEL_FORMAT_YUVI420;
    bool needDumpOutput = false;
    uint32_t bitrateMode = CBR;
    int32_t hevcProfile = HEVC_PROFILE_MAIN;
    int32_t rotation = 0;
    NativeWindow* window = nullptr;

    uint32_t bufferSize = 0;
    double readTime = 0;
    double memcpyTime = 0;
    double writeTime = 0;
    
    void (*playDoneCallback)(void *context) = nullptr;
    void *playDoneCallbackData = nullptr;
    
    int32_t width;
    int32_t height;
    std::string uri;
    std::map<std::string, MixInputData> iptData;
};

struct CodecBufferInfo {
    uint32_t bufferIndex = 0;
    uintptr_t *buffer = nullptr;
    uint8_t *bufferAddr = nullptr;
    OH_AVCodec *codec = nullptr;
    OH_AVBuffer *bufferOrigin = nullptr;
    OH_AVCodecBufferAttr attr = {0, 0, 0, AVCODEC_BUFFER_FLAGS_NONE};

    CodecBufferInfo(uint8_t *addr) : bufferAddr(addr){};
    CodecBufferInfo(uint8_t *addr, int32_t bufferSize)
        : bufferAddr(addr), attr({0, bufferSize, 0, AVCODEC_BUFFER_FLAGS_NONE}){};
    CodecBufferInfo(uint32_t argBufferIndex, OH_AVMemory *argBuffer, OH_AVCodecBufferAttr argAttr)
        : bufferIndex(argBufferIndex), buffer(reinterpret_cast<uintptr_t *>(argBuffer)), attr(argAttr){};
    CodecBufferInfo(uint32_t argBufferIndex, OH_AVMemory *argBuffer)
        : bufferIndex(argBufferIndex), buffer(reinterpret_cast<uintptr_t *>(argBuffer)){};
    CodecBufferInfo(uint32_t argBufferIndex, OH_AVBuffer *argBuffer)
        : bufferIndex(argBufferIndex), buffer(reinterpret_cast<uintptr_t *>(argBuffer))
    {
        OH_AVBuffer_GetBufferAttr(argBuffer, &attr);
    };

    CodecBufferInfo(uint32_t argBufferIndex, OH_AVBuffer *argBuffer, OH_AVCodec *argCodec)
        : bufferIndex(argBufferIndex), bufferOrigin(argBuffer), codec(argCodec)
    {
        OH_AVBuffer_GetBufferAttr(argBuffer, &attr);
    };
};

struct AudioCodecBufferInfo {
    uint32_t bufferIndex = 0;
    uint8_t *bufferAddr = nullptr;
    OH_AVCodec *codec = nullptr;
    OH_AVBuffer *bufferOrigin = nullptr;
    OH_AVCodecBufferAttr attr = {0, 0, 0, AVCODEC_BUFFER_FLAGS_NONE};

    AudioCodecBufferInfo(uint32_t argBufferIndex, OH_AVBuffer *argBuffer, OH_AVCodec *argCodec)
        : bufferIndex(argBufferIndex), bufferOrigin(argBuffer), codec(argCodec)
    {
        OH_AVBuffer_GetBufferAttr(argBuffer, &attr);
    };
};

class ADecSignal {
public:
    std::mutex audioInputMutex;
    std::condition_variable audioInputCond;
    std::queue<AudioCodecBufferInfo> audioInputBufferInfoQueue;
    std::mutex audioOutputMutex;
    std::condition_variable audioOutputCond;
    std::queue<AudioCodecBufferInfo> audioOutputBufferInfoQueue;
    std::mutex renderMutex;
    std::condition_variable renderCond;
    std::queue<uint8_t> renderQueue;
    bool isInterrupt = false;

    void ClearQueue()
    {
        {
            std::unique_lock<std::mutex> lock(audioInputMutex);
            auto emptyQueue = std::queue<AudioCodecBufferInfo>();
            audioInputBufferInfoQueue.swap(emptyQueue);
        }
        {
            std::unique_lock<std::mutex> lock(audioOutputMutex);
            auto emptyQueue = std::queue<AudioCodecBufferInfo>();
            audioOutputBufferInfoQueue.swap(emptyQueue);
        }
    }
};

class VDecSignal {
public:
    uint32_t inputFrameCount = 0;
    std::mutex inputMutex;
    std::condition_variable inputCond;
    std::queue<CodecBufferInfo> inputBufferInfoQueue;

    uint32_t outputFrameCount = 0;
    std::mutex outputMutex;
    std::condition_variable outputCond;
    std::queue<CodecBufferInfo> outputBufferInfoQueue;

    void ClearQueue()
    {
        {
            std::unique_lock<std::mutex> lock(inputMutex);
            auto emptyQueue = std::queue<CodecBufferInfo>();
            inputBufferInfoQueue.swap(emptyQueue);
        }
        {
            std::unique_lock<std::mutex> lock(outputMutex);
            auto emptyQueue = std::queue<CodecBufferInfo>();
            outputBufferInfoQueue.swap(emptyQueue);
        }
    }
};

enum VapState {
    UNKNOWN,
    READY,
    START,
    RENDER,
    COMPLETE,
    DESTROY,
    FAILED
};

struct JSAnimConfig {
    int32_t version;
    int32_t totalFrames;
    int32_t width;
    int32_t height;
    int32_t videoWidth;
    int32_t videoHeight;
    Orien orien;
    int32_t fps;
    bool isMix;
    PointRect alphaPointRect;
    PointRect rgbPointRect;
    int32_t currentFrame;
};

enum class VideoFitType {
    FIT_XY,
    FIT_CENTER,
    CENTER_CROP
};

typedef struct CallbackContext {
    napi_env env = nullptr;
    napi_ref callbackRef = nullptr;
    VapState vapState = VapState::UNKNOWN;
    int32_t err;
    JSAnimConfig jsAnimConfig;
} CallbackContext;

#endif // VAP_DATATYPE_INFO_H