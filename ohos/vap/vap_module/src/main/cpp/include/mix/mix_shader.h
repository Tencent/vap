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

#ifndef VAP_MIX_SHADER_H
#define VAP_MIX_SHADER_H

#include <stdint.h>

#include "shader_util.h"

static constexpr char VERTEX[] =
    "attribute vec4 a_Position;\n"
     "attribute vec2 a_TextureSrcCoordinates;\n"
     "attribute vec2 a_TextureMaskCoordinates;\n"
     "varying vec2 v_TextureSrcCoordinates;\n"
     "varying vec2 v_TextureMaskCoordinates;\n"
     "void main()\n"
     "{\n"
     "    v_TextureSrcCoordinates = a_TextureSrcCoordinates;\n"
     "    v_TextureMaskCoordinates = a_TextureMaskCoordinates;\n"
     "    gl_Position = a_Position;\n"
     "}\n\0";

static constexpr char FRAGMENT[] =
    "#extension GL_OES_EGL_image_external : require\n"
    "precision mediump float; \n"
    "uniform sampler2D u_TextureSrcUnit;\n"
    "uniform sampler2D u_TextureMaskUnit;\n"
    "uniform int u_isFill;\n"
    "uniform vec4 u_Color;\n"
    "varying vec2 v_TextureSrcCoordinates;\n"
    "varying vec2 v_TextureMaskCoordinates;\n"
    "void main()\n"
    "{\n"
    "    vec4 srcRgba = texture2D(u_TextureSrcUnit, v_TextureSrcCoordinates);\n"
    "    vec4 maskRgba = texture2D(u_TextureMaskUnit, v_TextureMaskCoordinates);\n"
    "    float isFill = step(0.5, float(u_isFill));\n"
    "    vec4 srcRgbaCal = isFill * vec4(u_Color.r, u_Color.g, u_Color.b, srcRgba.a) + (1.0 - isFill) * srcRgba;\n"
    "    gl_FragColor = vec4(srcRgbaCal.r, srcRgbaCal.g, srcRgbaCal.b, srcRgba.a * maskRgba.r);\n"
    "}\n\0";

class MixShader {
public:
    MixShader();
    void UseProgram();
    
public:
    // Shader program
    int32_t m_program;

    // Uniform locations
    int32_t m_uTextureSrcUnitLocation;
    int32_t m_uTextureMaskUnitLocation;
    int32_t m_uIsFillLocation;
    int32_t m_uColorLocation;

    // Attribute locations
    int32_t m_aPositionLocation;
    int32_t m_aTextureSrcCoordinatesLocation;
    int32_t m_aTextureMaskCoordinatesLocation;
    
private:
    const char *U_TEXTURE_SRC_UNIT = "u_TextureSrcUnit";
    const char *U_TEXTURE_MASK_UNIT = "u_TextureMaskUnit";
    const char *U_IS_FILL = "u_isFill";
    const char *U_COLOR = "u_Color";
    
    const char *A_POSITION = "a_Position";
    const char *A_TEXTURE_SRC_COORDINATES = "a_TextureSrcCoordinates";
    const char *A_TEXTURE_MASK_COORDINATES = "a_TextureMaskCoordinates";
};

#endif // VAP_MIX_SHADER_H
