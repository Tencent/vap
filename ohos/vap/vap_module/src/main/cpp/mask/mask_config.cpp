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

#include "mask_config.h"

MaskConfig::MaskConfig(int32_t width, int32_t height)
{
    width_ = width;
    maskTexId_ = height;
}

MaskConfig::~MaskConfig()
{
    if (maskTexId_) {
        glDeleteTextures(1, &maskTexId_);
    }
}

int32_t MaskConfig::GetMaskTexId()
{
    return maskTexId_;
}

int32_t MaskConfig::UpdateMaskTex(BitMap alphaMaskBitmap)
{
    TextureLoadUtil::GetInstance().loadTexture(alphaMaskBitmap, &maskTexId_);
    return maskTexId_;
}