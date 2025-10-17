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

#ifndef VAP_RESOURCE_REQUEST_H
#define VAP_RESOURCE_REQUEST_H

#include <bits/alltypes.h>
#include <multimedia/image_framework/image/image_source_native.h>
#include <native_drawing/drawing_text_typography.h>
#include <native_drawing/drawing_types.h>
#include <vector>

#include "src.h"

struct ColorARGB {
    uint32_t alpha = 0xff;
    uint32_t red = 0xff;
    uint32_t green = 0xf1;
    uint32_t blue = 0xae;
};

struct TextOption {
    const char *text;
    int32_t height;
    int32_t width;
    
    ColorARGB color;
    OH_Drawing_TextAlign textAlign;
    OH_Drawing_FontWeight fontWeight;
};
struct ImageOption {
    const char *uri;
    int32_t height;
    int32_t width;
    FitType fixType;
};
class ResourceRequest {
public:
    ResourceRequest() = default;
    ~ResourceRequest() { Release();};
    void Create();
    void DrawText(TextOption &txtOpt);
    void SetWidth(uint64_t width = 300);
    void SetHeight(uint64_t height = 50);
    void GetData(std::vector<uint8_t> &data);
    void Release();
    
    void FetchText(std::vector<uint8_t> &data, TextOption &txtOpt);
    void FetchImg(std::vector<uint8_t> &data, ImageOption &imgOpt);
private:
    uint64_t width_ = 300;
    uint64_t height_ = 50;

    OH_Drawing_Bitmap *cBitmap_ = nullptr;
    OH_Drawing_Canvas *cCanvas_ = nullptr;

    OH_ImageSourceNative *source_ = nullptr;
    OH_PixelmapNative *resPixMap_ = nullptr;

    static constexpr double DEFAULT_FONT_SIZE = 31.0;
};
#endif // VAP_RESOURCE_REQUEST_H
