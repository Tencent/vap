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

#include "yuv_render.h"

#include <vector>

#include "common_const.h"
#include "tex_coords_util.h"
#include "shader_util.h"
#include "log.h"

using namespace CommonConst;

void YuvRender::InitRender(std::string uri)
{
    LOGD("enter YuvRender::InitRender");
    shaderProgram_ = ShaderUtil::CreateProgram(g_vertexShader, g_fragmentShader);
    avPosition_ = glGetAttribLocation(shaderProgram_, "v_Position");
    rgbPosition_ = glGetAttribLocation(shaderProgram_, "vTexCoordinateRgb");
    alphaPosition_ = glGetAttribLocation(shaderProgram_, "vTexCoordinateAlpha");
    
    samplerY_ = glGetUniformLocation(shaderProgram_, "sampler_y");
    samplerU_ = glGetUniformLocation(shaderProgram_, "sampler_u");
    samplerV_ = glGetUniformLocation(shaderProgram_, "sampler_v");
    
    convertMatrixUniform_ = glGetUniformLocation(shaderProgram_, "convertMatrix");
    convertOffsetUniform_ = glGetUniformLocation(shaderProgram_, "offset");

    glGenVertexArrays(ONE, &VAO_);
    glBindVertexArray(VAO_);
    
    glGenTextures(THREE, textureId_);
    for (auto &it : textureId_) {
        glBindTexture(GL_TEXTURE_2D, it);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    }
    LOGD("end YuvRender::InitRender");
}

void YuvRender::SetYUVData(int32_t width, int32_t height, const std::vector<unsigned char> &y,
    const std::vector<unsigned char> &u, const std::vector<unsigned char> &v)
{
    widthYUV_ = width;
    heightYUV_ = height;
    this->y_ = std::move(y);
    this->u_ = std::move(u);
    this->v_ = std::move(v);
    if ((widthYUV_ / TWO) % FOUR != ZERO) {
        this->unpackAlign_ = (widthYUV_ / TWO) % TWO == ZERO? TWO : ONE;
    }
}

void YuvRender::RenderFrame()
{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    Draw();
}

void YuvRender::ClearFrame()
{
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(ZERO, ZERO, ZERO, ZERO);
}

void YuvRender::Draw()
{
    if (widthYUV_ > ZERO && heightYUV_ > ZERO && !y_.empty() && !u_.empty() && !v_.empty()) {
        glUseProgram(shaderProgram_);
        vertex_.EnableVertexAttrib(avPosition_);
        alpha_.EnableVertexAttrib(alphaPosition_);
        rgb_.EnableVertexAttrib(rgbPosition_);

        glPixelStorei(GL_UNPACK_ALIGNMENT, unpackAlign_);
        
        // 激活纹理0来绑定y数据
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, textureId_[ZERO]);
        glTexImage2D(GL_TEXTURE_2D, ZERO, GL_LUMINANCE,
            widthYUV_, heightYUV_, ZERO, GL_LUMINANCE, GL_UNSIGNED_BYTE, y_.data());

        // 激活纹理1来绑定u数据
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, textureId_[ONE]);
        glTexImage2D(GL_TEXTURE_2D, ZERO, GL_LUMINANCE,
            widthYUV_ / TWO, heightYUV_ / TWO, ZERO, GL_LUMINANCE, GL_UNSIGNED_BYTE, u_.data());

        // 激活纹理2来绑定v数据
        glActiveTexture(GL_TEXTURE2);
        glBindTexture(GL_TEXTURE_2D, textureId_[TWO]);
        glTexImage2D(GL_TEXTURE_2D, ZERO, GL_LUMINANCE,
            widthYUV_ / TWO, heightYUV_ / TWO, ZERO, GL_LUMINANCE, GL_UNSIGNED_BYTE, v_.data());

        // 给fragment_shader里面yuv变量设置值   0 1 标识纹理x
        glUniform1i(samplerY_, ZERO);
        glUniform1i(samplerU_, ONE);
        glUniform1i(samplerV_, TWO);
        
        glUniform3fv(convertOffsetUniform_, ONE, YUV_OFFSET);
        glUniformMatrix3fv(convertMatrixUniform_, ONE, false, YUV_MATRIX);

        // 绘制
        glBindVertexArray(VAO_);
        glDrawArrays(GL_TRIANGLE_STRIP, ZERO, FOUR);
        y_.erase(y_.begin(), y_.end());
        u_.erase(u_.begin(), u_.end());
        v_.erase(v_.begin(), v_.end());
        glDisableVertexAttribArray(avPosition_);
        glDisableVertexAttribArray(rgbPosition_);
        glDisableVertexAttribArray(alphaPosition_);
    } else {
        LOGE("YuvRender::Draw error");
    }
}

void YuvRender::ReleaseTexture()
{
    glDeleteTextures(THREE, textureId_);
}

GLuint YuvRender::GetExternalTexture()
{
    return textureId_[ZERO];
}

void YuvRender::SetAnimConfig(std::shared_ptr<AnimConfig> animConfig)
{
    LOGD("enter YuvRender::SetAnimConfig");
    if (!animConfig) {
        LOGE("YuvRender animConfig nullptr");
        return;
    }
    PointRect pointRect(ZERO, ZERO, animConfig->width, animConfig->height);
    vertex_.Create(animConfig->width, animConfig->height, pointRect, vertex_.array.get());
    vertex_.SetArray(vertex_.array.get());
    TexCoordsUtil::Create(animConfig->videoWidth, animConfig->videoHeight,
        animConfig->alphaPointRect, alpha_.array.get());
    TexCoordsUtil::Create(animConfig->videoWidth, animConfig->videoHeight,
        animConfig->rgbPointRect, rgb_.array.get());
    alpha_.SetArray(alpha_.array.get());
    rgb_.SetArray(rgb_.array.get());
    LOGD("end YuvRender::SetAnimConfig");
}