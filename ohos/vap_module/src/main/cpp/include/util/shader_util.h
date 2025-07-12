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

#ifndef VAP_SHADER_UTIL_H
#define VAP_SHADER_UTIL_H

#include <GLES3/gl3.h>
#include <EGL/egl.h>

static char g_vertexShader[] =
    "attribute vec4 v_Position;\n"
    "attribute vec2 vTexCoordinateAlpha;\n"
    "attribute vec2 vTexCoordinateRgb;\n"
    "varying vec2 v_TexCoordinateAlpha;\n"
    "varying vec2 v_TexCoordinateRgb;\n"
    "\n"
    "void main() {\n"
    "    v_TexCoordinateAlpha = vTexCoordinateAlpha;\n"
    "    v_TexCoordinateRgb = vTexCoordinateRgb;\n"
    "    gl_Position = v_Position;\n"
    "}\n\0";

static char g_fragmentShader[] =
    "precision mediump float;\n"
    "uniform sampler2D sampler_y;\n"
    "uniform sampler2D sampler_u;\n"
    "uniform sampler2D sampler_v;\n"
    "varying vec2 v_TexCoordinateAlpha;\n"
    "varying vec2 v_TexCoordinateRgb;\n"
    "uniform mat3 convertMatrix;\n"
    "uniform vec3 offset;\n"
    "\n"
    "void main() {\n"
    "   highp vec3 yuvColorAlpha;\n"
    "   highp vec3 yuvColorRGB;\n"
    "   highp vec3 rgbColorAlpha;\n"
    "   highp vec3 rgbColorRGB;\n"
    "   yuvColorAlpha.x = texture2D(sampler_y,v_TexCoordinateAlpha).r;\n"
    "   yuvColorRGB.x = texture2D(sampler_y,v_TexCoordinateRgb).r;\n"
    "   yuvColorAlpha.y = texture2D(sampler_u,v_TexCoordinateAlpha).r;\n"
    "   yuvColorAlpha.z = texture2D(sampler_v,v_TexCoordinateAlpha).r;\n"
    "   yuvColorRGB.y = texture2D(sampler_u,v_TexCoordinateRgb).r;\n"
    "   yuvColorRGB.z = texture2D(sampler_v,v_TexCoordinateRgb).r;\n"
    "   yuvColorAlpha += offset;\n"
    "   yuvColorRGB += offset;\n"
    "   rgbColorAlpha = convertMatrix * yuvColorAlpha; \n"
    "   rgbColorRGB = convertMatrix * yuvColorRGB; \n"
    "   gl_FragColor=vec4(rgbColorRGB, rgbColorAlpha.r);\n"
    "}\n\0";

class ShaderUtil {
public:
    static GLuint CreateProgram(const char *vertexSource, const char *fragmentSource);

private:
    static GLuint CompileShader(GLenum shaderType, const char *shaderSource);
    static GLuint CreateAndLinkProgram(GLuint vertexShaderHandle, GLuint fragmentShaderHandle);
};

#endif // VAP_SHADER_UTIL_H
