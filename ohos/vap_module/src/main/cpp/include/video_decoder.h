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

#ifndef VAP_DECODER_H
#define VAP_DECODER_H

#include "data_info.h"

class VideoDecoder {
public:
    VideoDecoder() = default;
    ~VideoDecoder();

    int32_t CreateVideoDecoder(const std::string &codecMime);
    int32_t ConfigureVideoDecoder(const VAPInfo &info);
    int32_t Config(const VAPInfo &info, VDecSignal *signal);
    int32_t StartVideoDecoder();
    int32_t PushInputData(CodecBufferInfo &info);
    int32_t FreeOutputData(uint32_t bufferIndex, bool render);
    int32_t Release();

private:
    int32_t SetCallback(VDecSignal *signal);

    bool isAVBufferMode_ = false;
    OH_AVCodec *decoder_ = nullptr;
};
#endif // VAP_DECODER_H