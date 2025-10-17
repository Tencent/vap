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

#include "resource_request.h"

#include <multimedia/image_framework/image/image_source_native.h>
#include <native_drawing/drawing_bitmap.h>
#include <native_drawing/drawing_canvas.h>
#include <native_drawing/drawing_color.h>
#include <native_drawing/drawing_font_collection.h>
#include <native_drawing/drawing_text_declaration.h>
#include <native_drawing/drawing_text_typography.h>
#include <string>

#include "log.h"
#include "common_const.h"

using namespace CommonConst;

void ResourceRequest::SetWidth(uint64_t width) { width_ = width; }

void ResourceRequest::SetHeight(uint64_t height) { height_ = height; }

void ResourceRequest::Create()
{
    cBitmap_ = OH_Drawing_BitmapCreate();
    // 定义bitmap的像素格式
    OH_Drawing_BitmapFormat cFormat{COLOR_FORMAT_RGBA_8888, ALPHA_FORMAT_UNPREMUL};
    // 构造对应格式的bitmap
    OH_Drawing_BitmapBuild(cBitmap_, width_, height_, &cFormat);

    // 创建一个canvas对象
    cCanvas_ = OH_Drawing_CanvasCreate();
    // 将画布与bitmap绑定，画布画的内容会输出到绑定的bitmap内存中
    OH_Drawing_CanvasBind(cCanvas_, cBitmap_);
    // 使用白色清除画布内容
    OH_Drawing_CanvasClear(cCanvas_, OH_Drawing_ColorSetArgb(0x00, 0xFF, 0xFF, 0xAA));
    if (!cBitmap_ || !cCanvas_) {
        LOGE("Create error");
    }
}

void ResourceRequest::DrawText(TextOption &txtOpt)
{
    // 选择从左到右/左对齐等排版属性
    OH_Drawing_TypographyStyle *typoStyle = OH_Drawing_CreateTypographyStyle();
    OH_Drawing_SetTypographyTextDirection(typoStyle, TEXT_DIRECTION_LTR);
    OH_Drawing_SetTypographyTextAlign(typoStyle, txtOpt.textAlign);
    
    // 设置文字颜色，
    OH_Drawing_TextStyle *txtStyle = OH_Drawing_CreateTextStyle();
    ColorARGB color = txtOpt.color;
    LOGD("DrawText color argb: %{public}02x-%{public}02x-%{public}02x-%{public}02x",
        color.alpha, color.red, color.green, color.blue);
    LOGD("DrawText ta fw: %{public}d-%{public}d",
        txtOpt.fontWeight, txtOpt.textAlign);
    
    OH_Drawing_SetTextStyleColor(txtStyle, OH_Drawing_ColorSetArgb(color.alpha, color.red, color.green, color.blue));
    // 设置文字大小、字重等属性
    double fontSize = DEFAULT_FONT_SIZE;
    LOGD("strlen(text): %{public}zu, fontSize: %{public}f", strlen(txtOpt.text), fontSize);
    OH_Drawing_SetTextStyleFontSize(txtStyle, fontSize);
    OH_Drawing_SetTextStyleFontWeight(txtStyle, txtOpt.fontWeight);
    OH_Drawing_SetTextStyleBaseLine(txtStyle, TEXT_BASELINE_ALPHABETIC);
    OH_Drawing_SetTextStyleFontHeight(txtStyle, 1);
    OH_Drawing_FontCollection* fontCollection = OH_Drawing_CreateSharedFontCollection();
    // 设置字体类型等
    OH_Drawing_SetTextStyleFontStyle(txtStyle, FONT_STYLE_NORMAL);
    OH_Drawing_SetTextStyleLocale(txtStyle, "zh");
    OH_Drawing_TypographyCreate *handler =
        OH_Drawing_CreateTypographyHandler(typoStyle, fontCollection);
    OH_Drawing_TypographyHandlerPushTextStyle(handler, txtStyle);
    // 设置文字内容
    OH_Drawing_TypographyHandlerAddText(handler, txtOpt.text);
    OH_Drawing_TypographyHandlerPopTextStyle(handler);
    OH_Drawing_Typography *typography = OH_Drawing_CreateTypography(handler);
    // 设置页面最大宽度
    double maxWidth = width_;
    OH_Drawing_TypographyLayout(typography, maxWidth);
    // 设置文本在画布上绘制的起始位置
    double position[2] = {0, (height_ - fontSize) / 2.0};
    // 将文本绘制到画布上
    OH_Drawing_TypographyPaint(typography, cCanvas_, position[0], position[1]);
    
    OH_Drawing_DestroyTypography(typography);
    OH_Drawing_DestroyTypographyHandler(handler);
    OH_Drawing_DestroyFontCollection(fontCollection);
    OH_Drawing_DestroyTextStyle(txtStyle);
    OH_Drawing_DestroyTypographyStyle(typoStyle);
}

void ResourceRequest::GetData(std::vector<uint8_t> &data)
{
    void *bitmapAddr = OH_Drawing_BitmapGetPixels(cBitmap_);

    OH_Drawing_Image_Info info;
    OH_Drawing_BitmapGetImageInfo(cBitmap_, &info);

    uint8_t *value = static_cast<uint8_t *>(bitmapAddr);
    LOGD("GetData data:%{public}d, %{public}ld * %{public}ld %{public}d ** %{public}d", value == nullptr, width_,
         height_, info.width, info.height);
    if (value && width_ > 0 && height_ > 0) {
        LOGD("GetData ok");
    } else {
        LOGE("GetData invalid data");
        return;
    }
    data.assign(value, value + width_ * height_ * FOUR);
}

void ResourceRequest::Release()
{
    if (cCanvas_) {
        // 销毁canvas对象
        OH_Drawing_CanvasDestroy(cCanvas_);
        cCanvas_ = nullptr;
    }
    if (cBitmap_) {
        // 销毁bitmap对象
        OH_Drawing_BitmapDestroy(cBitmap_);
        cBitmap_ = nullptr;
    }
}

static void GetSourceInfo(OH_ImageSourceNative *source, uint32_t &width, uint32_t &height)
{
    OH_ImageSource_Info *imageSrcInfo = nullptr;
    OH_ImageSourceInfo_Create(&imageSrcInfo);
    Image_ErrorCode errCode = OH_ImageSourceNative_GetImageInfo(source, 0, imageSrcInfo);
    if (errCode != IMAGE_SUCCESS) {
        LOGE("FetchImg OH_ImageSourceNative_GetImageInfo failed, errCode: %{public}d.", errCode);
        return;
    }
    OH_ImageSourceInfo_GetWidth(imageSrcInfo, &width);
    OH_ImageSourceInfo_GetHeight(imageSrcInfo, &height);
    LOGD("Open imageSrcInfo:  %{public}d * %{public}d", width, height);
    OH_ImageSourceInfo_Release(imageSrcInfo);
}

static void GetPixelMapInfo(OH_PixelmapNative *resPixMap, uint32_t &height, uint32_t &rowStride)
{
    OH_Pixelmap_ImageInfo *imgInfo = nullptr;
    OH_PixelmapImageInfo_Create(&imgInfo);
    Image_ErrorCode errCode = OH_PixelmapNative_GetImageInfo(resPixMap, imgInfo);
    if (errCode != IMAGE_SUCCESS) {
        LOGE("FetchImg OH_PixelmapNative_GetImageInfo failed, errCode: %{public}d", errCode);
        return;
    }

    int32_t alphaType;
    uint32_t width;
    int32_t pixelFormat;
    OH_PixelmapImageInfo_GetWidth(imgInfo, &width);
    OH_PixelmapImageInfo_GetHeight(imgInfo, &height);
    OH_PixelmapImageInfo_GetRowStride(imgInfo, &rowStride);
    OH_PixelmapImageInfo_GetPixelFormat(imgInfo, &pixelFormat);
    OH_PixelmapImageInfo_GetAlphaType(imgInfo, &alphaType);
    OH_PixelmapImageInfo_Release(imgInfo);
    LOGD("ImagePixelmap GetImageInfo success, width: %{public}d, height: %{public}d, rowStride: "
         "%{public}d, pixelFormat: %{public}d",
         width, height, rowStride, pixelFormat);
}

void ResourceRequest::FetchImg(std::vector<uint8_t> &data, ImageOption &imgOpt)
{
    std::string uri = imgOpt.uri;
    if (uri.empty()) {
        LOGE("FetchImg uri empty");
        return;
    }

    LOGD("FetchImg OH_ImageSourceNative_CreateFromUri,: %{public}s. %{public}p", uri.c_str(), source_);
    Image_ErrorCode errCode = OH_ImageSourceNative_CreateFromUri(const_cast<char *>(uri.c_str()), uri.size(), &source_);
    if (errCode != IMAGE_SUCCESS) {
        LOGE("FetchImg OH_ImageSourceNative_CreateFromUri failed, errCode: %{public}d.", errCode);
        return;
    }

    uint32_t width;
    uint32_t height;
    GetSourceInfo(source_, width, height);

    // 通过图片解码参数创建PixelMap列表
    OH_DecodingOptions *opts = nullptr;
    OH_DecodingOptions_Create(&opts);
    int32_t pixelFormat = PIXEL_FORMAT_RGBA_8888;
    OH_DecodingOptions_SetPixelFormat(opts, pixelFormat);

    errCode = OH_ImageSourceNative_CreatePixelmap(source_, opts, &resPixMap_);
    OH_DecodingOptions_Release(opts);
    if (errCode != IMAGE_SUCCESS) {
        LOGE("FetchImg OH_ImageSourceNative_CreatePixelmap failed, errCode: %{public}d.", errCode);
        return;
    }

    float scaleX = imgOpt.width / static_cast<float>(width);
    float scaleY = imgOpt.height / static_cast<float>(height);
    errCode = OH_PixelmapNative_Scale(resPixMap_, scaleX, scaleY);

    OH_Pixelmap_ImageInfo *imgInfo = nullptr;
    OH_PixelmapImageInfo_Create(&imgInfo);
    errCode = OH_PixelmapNative_GetImageInfo(resPixMap_, imgInfo);
    if (errCode != IMAGE_SUCCESS) {
        LOGE("FetchImg OH_PixelmapNative_GetImageInfo failed, errCode: %{public}d", errCode);
        return;
    }
    
    uint32_t pixelMapHeight;
    uint32_t rowStride;
    GetPixelMapInfo(resPixMap_, pixelMapHeight, rowStride);
    size_t bufferSize = pixelMapHeight * rowStride;
    std::vector<uint8_t> buffer(bufferSize);

    errCode = OH_PixelmapNative_ReadPixels(resPixMap_, buffer.data(), &bufferSize);
    data.assign(buffer.data(), buffer.data() + bufferSize);
    LOGD("OH_PixelmapNative_ReadPixels %{public}lu --- %{public}lu", data.size(), buffer.size());
    
    OH_PixelmapNative_Release(resPixMap_);
    OH_ImageSourceNative_Release(source_);
    source_ = nullptr;
    resPixMap_ = nullptr;
}

void ResourceRequest::FetchText(std::vector<uint8_t> &data, TextOption &txtOpt)
{
    if (!(txtOpt.text) || txtOpt.height <= 0 || txtOpt.width <= 0) {
        LOGE("FetchText error param");
        return;
    }
    SetWidth(txtOpt.width);
    SetHeight(txtOpt.height);
    Create();
    DrawText(txtOpt);
    GetData(data);
}