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

#include "mask_render.h"

#include "log.h"

#include <GLES2/gl2ext.h>
#include "common_const.h"

using namespace CommonConst;

void MaskRender::RenderFrame(MaskConfig maskConfig)
{
    auto maskTexId = maskConfig.GetMaskTexId();
    if (maskTexId <= 0) {
        LOGE("maskTexId not ready, cont Rendered");
    }
    
    auto texTuple = maskConfig.maskTexPair_;
    auto maskTexRect = std::get<0>(texTuple);
    auto maskTexRefVec2 = std::get<1>(texTuple);
    
    auto positionTuple = maskConfig.maskPositionPair_;
    PointRect maskPositionRect;
    if (std::get<0>(positionTuple).w != 0 && std::get<0>(positionTuple).h != 0) {
        maskPositionRect = std::get<0>(positionTuple);
    } else {
        maskPositionRect = PointRect(0, 0, maskConfig.width_, maskConfig.height_);
    }

    RefVec2 maskPositionRefVec2;
    if (std::get<1>(positionTuple).w != 0 && std::get<1>(positionTuple).h !=0) {
        maskPositionRefVec2 = std::get<1>(positionTuple);
    } else {
        maskPositionRefVec2 = RefVec2(maskConfig.width_, maskConfig.height_);
    }
    
    m_maskShader->UseProgram();
    m_vertexArray.Create(maskPositionRefVec2.w, maskPositionRefVec2.h, maskPositionRect, m_vertexArray.array.get());
    m_vertexArray.SetArray(m_vertexArray.array.get());
    m_vertexArray.EnableVertexAttrib(m_maskShader->m_aPositionLocation);
    
    m_maskArray.Create(
        maskTexRefVec2.w,
        maskTexRefVec2.h,
        maskTexRect,
        m_maskArray.array.get()
    );
    m_maskArray.SetArray(m_maskArray.array.get());
    m_maskArray.EnableVertexAttrib(m_maskShader->m_aTextureMaskCoordinatesLocation);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, maskTexId);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glUniform1i(m_maskShader->m_uTextureMaskUnitLocation, 0);

    glEnable(GL_BLEND);
    glBlendFuncSeparate(GL_ONE, GL_SRC_ALPHA, GL_ZERO, GL_SRC_ALPHA);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, FOUR);
    glDisable(GL_BLEND);
}

MaskRender::MaskRender(bool edgeBlur)
{
    m_maskShader = std::make_unique<class MaskShader>(edgeBlur);
    glDisable(GL_DEPTH_TEST);
}