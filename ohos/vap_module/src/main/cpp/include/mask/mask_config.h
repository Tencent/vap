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

#ifndef VAP_MASK_CONFIG_H
#define VAP_MASK_CONFIG_H

#include <multimedia/image_framework/image/pixelmap_native.h>
#include <tuple>

#include "texture_load_util.h"
#include "vertex_util.h"

class MaskConfig {
public:
    MaskConfig(int32_t width, int32_t height);
    ~MaskConfig();
    
    int32_t GetMaskTexId();
    int32_t UpdateMaskTex(BitMap alphaMaskBitmap);

public:
    std::tuple<PointRect, RefVec2> maskTexPair_ =
        std::move(std::make_tuple(PointRect(0, 0, 0, 0), RefVec2(0, 0)));

    std::tuple<PointRect, RefVec2> maskPositionPair_ =
        std::move(std::make_tuple(PointRect(0, 0, 0, 0), RefVec2(0, 0)));

    int32_t width_; // animConfig width
    int32_t height_;
private:
    GLuint maskTexId_ = 0;
};

#endif // VAP_MASK_CONFIG_H
