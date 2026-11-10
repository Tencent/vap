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

#ifndef VAP_DEMUXER_H
#define VAP_DEMUXER_H

#include <bits/alltypes.h>
#include "multimedia/player_framework/native_avdemuxer.h"
#include "data_info.h"

static constexpr int32_t ONE_K = 1024;

class Demuxer {
public:
    ~Demuxer();
    int32_t CreateDemuxer(VAPInfo &sampleInfo);
    int32_t GetTrackInfo(std::shared_ptr<OH_AVFormat> sourceFormat, VAPInfo &info);
    int32_t ReadSample(OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr);
    int32_t ReadAudioSample(OH_AVBuffer *buffer, OH_AVCodecBufferAttr &attr);
    int32_t Release();

    bool hasAudio() { return audioTrackId_ != -1; }
    bool hasVideo() { return videoTrackId_ != -1; }

private:
    OH_AVSource *source_ = nullptr;
    OH_AVDemuxer *demuxer_ = nullptr;
    int32_t videoTrackId_ = -1;
    int32_t audioTrackId_ = -1;
};

#endif // VAP_DEMUXER_H