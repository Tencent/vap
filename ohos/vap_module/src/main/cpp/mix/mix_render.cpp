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

#include "mix_render.h"

#include "tex_coords_util.h"
#include "resource_request.h"
#include "anim_config.h"
#include "texture_load_util.h"

#include <GLES2/gl2ext.h>
#include <algorithm>
#include <memory>
#include "common_const.h"

using namespace CommonConst;

static void transColor(int32_t color, std::vector<float> &argb)
{
    uint8_t alpha = (color >> THREE_TIME_EIGHT) & 0xFF;
    uint8_t red = (color >> TWO_TIME_EIGHT) & 0xFF;
    uint8_t green = (color >> EIGHT) & 0xFF;
    uint8_t blue = color & 0xFF;
    argb.push_back(1.0 * alpha / 0xFF);
    argb.push_back(1.0 * red / 0xFF);
    argb.push_back(1.0 * green / 0xFF);
    argb.push_back(1.0 * blue / 0xFF);
}

MixRender::MixRender(std::map<std::string, MixInputData> iptData)
{
    m_mixData = iptData;
}

void MixRender::GenSrcTexture(Src src, BitMap &bitmap, const MixInputData mixData)
{
    std::unique_ptr<ResourceRequest> reqPtr = std::make_unique<ResourceRequest>();
    if (src.srcType == SrcType::TXT) {
        TextOption txtOpt;
        txtOpt.text = mixData.txt.c_str();
        txtOpt.width = src.w;
        txtOpt.height = src.h;
        txtOpt.color = {(src.color & 0xff000000) >> THREE_TIME_EIGHT,
            static_cast<uint32_t>((src.color & 0xff0000) >> TWO_TIME_EIGHT),
            static_cast<uint32_t>((src.color & 0xff00) >> EIGHT), static_cast<uint32_t>(src.color & 0xff)};
        txtOpt.textAlign = src.fitType == FitType::FIT_XY ? TEXT_ALIGN_JUSTIFY : TEXT_ALIGN_CENTER;
        txtOpt.fontWeight = src.style == Style::DEFAULT ? FONT_WEIGHT_400 : FONT_WEIGHT_700;

        if (mixData.isSet & SET_COLOR) {
            txtOpt.color = mixData.color;
        }
        if (mixData.isSet & SET_TEXT_ALIGN) {
            txtOpt.textAlign = mixData.textAlign;
        }
        if (mixData.isSet & SET_FONT_WEIGHT) {
            txtOpt.fontWeight = mixData.fontWeight;
        }
        LOGD("GenSrcTexture tag %{public}s ta ta: %{public}d-%{public}d", src.srcTag.c_str(),
            txtOpt.textAlign, mixData.textAlign);

        reqPtr->FetchText(bitmap.pixelsData, txtOpt);
    } else if (src.srcType == SrcType::IMG) {
        ImageOption imgOpt;
        imgOpt.uri = mixData.imgUri.c_str();
        imgOpt.width = src.w;
        imgOpt.height = src.h;
        imgOpt.fixType = src.fitType;
        reqPtr->FetchImg(bitmap.pixelsData, imgOpt);
        if (bitmap.pixelsData.empty()) {
            LOGD("MixRender FetchImg error");
            bitmap.pixelsData.resize(src.w * src.h * FOUR);
            fill(bitmap.pixelsData.begin(), bitmap.pixelsData.end(), 0xaa);
        }
    }
}

void MixRender::Init()
{
    glDisable(GL_DEPTH_TEST);
    if (!m_animConfig || !m_animConfig->srcMapPtr) {
        LOGE("MixRender nullptr no need mix");
        return;
    }
    haveSrc = true;
    int idx = ZERO;
    bool isEnough = true;
    std::shared_ptr<SrcMap> srcPtr = m_animConfig->srcMapPtr;
    m_textureIds.resize(srcPtr->srcSMap.size());
    for (auto it = srcPtr->srcSMap.begin(); it != srcPtr->srcSMap.end(); ++it) {
        std::string key = it->first; // id
        Src src = it->second;
        BitMap bitmap;
        
        if (m_mixData.find(it->second.srcTag) == m_mixData.end()) {
            LOGW("MixRender Data tag: %{public}s not find.", it->second.srcTag.c_str());
            isEnough = false;
            bitmap.pixelsData.resize(src.w * src.h * FOUR);
            fill(bitmap.pixelsData.begin(), bitmap.pixelsData.end(), 0xaa);
        } else {
            MixInputData mixData = m_mixData.at(it->second.srcTag);
            LOGD("Init tag %{public}s fw ta: %{public}d-%{public}d", it->second.srcTag.c_str(),
                mixData.fontWeight, mixData.textAlign);
            if (src.srcType == SrcType::TXT && (mixData.isSet & SET_COLOR)) {
                ColorARGB color = mixData.color;
                it->second.color =
                    ((color.alpha & 0xff) << THREE_TIME_EIGHT) | ((color.red & 0xff) << TWO_TIME_EIGHT) |
                    ((color.green & 0xff) << EIGHT) | (color.blue & 0xff);
            }
            GenSrcTexture(src, bitmap, mixData);
        }
            
        GLuint textureId;
        bitmap.imgWidth = src.w;
        bitmap.imgHeight = src.h;
        TextureLoadUtil::GetInstance().loadTexture(bitmap, &textureId);
        it->second.srcTextureId = textureId;
        it->second.drawWidth = it->second.w;
        it->second.drawHeight = it->second.h;
        
        m_textureIds[idx] = textureId;
        idx++;
        LOGD("MixRender srcTextureId :%{public}d", textureId);
    }
    
    m_shader = std::make_unique<MixShader>();
}

MixRender::~MixRender()
{
    for (auto textureId : m_textureIds) {
        if (textureId != 0) {
            GLuint textureArray[ONE] = {textureId};
            glDeleteTextures(ONE, textureArray);
        }
    }
}

void MixRender::RenderFrame(MixConfigSize config, Frame frame, Src src)
{
    if (!haveSrc) {
        LOGE("MixRender RenderFrame not have src");
        return;
    }
    if (videoTextureId <= ZERO) {
        LOGE("MixRender RenderFrame externalTexture error");
        return;
    }
    m_shader->UseProgram();
    m_vertexArray.Create(config.width, config.height, frame.frame, m_vertexArray.array.get());
    m_vertexArray.SetArray(m_vertexArray.array.get());
    m_vertexArray.EnableVertexAttrib(m_shader->m_aPositionLocation);
    
    GenSrcCoordsArray(m_srcArray, frame.frame.w, frame.frame.h, src.drawWidth, src.drawHeight, src.fitType);
    
    m_srcArray.SetArray(m_srcArray.array.get());
    m_srcArray.EnableVertexAttrib(m_shader->m_aTextureSrcCoordinatesLocation);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, src.srcTextureId);
    glUniform1i(m_shader->m_uTextureSrcUnitLocation, ZERO);

    TexCoordsUtil::Create(config.videoWidth, config.videoHeight, frame.mFrame, m_maskArray.array.get());
    m_maskArray.SetArray(m_maskArray.array.get());
    if (frame.mt == NINETY_DEGREES) {
        TexCoordsUtil::Rotate90(m_maskArray.array.get());
        m_maskArray.SetArray(m_maskArray.array.get());
    }
    m_maskArray.EnableVertexAttrib(m_shader->m_aTextureMaskCoordinatesLocation);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, videoTextureId);
    glUniform1i(m_shader->m_uTextureMaskUnitLocation, ONE);
    
    if (src.srcType == SrcType::TXT) {
        glUniform1i(m_shader->m_uIsFillLocation, ONE);
        std::vector<float> argb;
        transColor(src.color, argb);
        glUniform4f(m_shader->m_uColorLocation, argb[ONE], argb[TWO], argb[THREE], argb[ZERO]);
    } else {
        glUniform1i(m_shader->m_uIsFillLocation,  ZERO);
        glUniform4f(m_shader->m_uColorLocation, 0.0f, 0.0f, 0.0f, 0.0f);
    }
    
    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glDrawArrays(GL_TRIANGLE_STRIP, ZERO, FOUR);
    glDisable(GL_BLEND);
}

void MixRender::SetVideoTextureId(GLuint id)
{
    videoTextureId = id;
}

void MixRender::GenSrcCoordsArray(VertexUtil &array, int32_t fw, int32_t fh, int32_t sw, int32_t sh, FitType fitType)
{
    if (fitType == FitType::CENTER_FULL) {
        if (fw <= sw && fh <= sh) {
            // 中心对齐，不拉伸
            int32_t gw = (sw - fw) / TWO;
            int32_t gh = (sh - fh) / TWO;
            TexCoordsUtil::Create(sw, sh, PointRect(gw, gh, fw, fh), array.array.get());
        } else { // centerCrop
            if (fh == 0 || sh == 0) {
                return;
            }
            auto fScale = fw * 1.0f / fh;
            auto sScale = sw * 1.0f / sh;
            PointRect srcRect;
            if (fScale > sScale) {
                auto w = sw;
                auto x = ZERO;
                auto h = (int32_t)(sw / fScale);
                auto y = (sh - h) / TWO;

                srcRect = std::move(PointRect(x, y, w, h));
            } else {
                auto h = sh;
                auto y = ZERO;
                auto w = (int32_t)(sh * fScale);
                auto x = (sw - w) / TWO;

                srcRect = std::move(PointRect(x, y, w, h));
            }
            TexCoordsUtil::Create(sw, sh, srcRect, array.array.get());
        }
    } else { // 默认 fitXY
        TexCoordsUtil::Create(fw, fh, PointRect(ZERO, ZERO, fw, fh), array.array.get());
    }
}
