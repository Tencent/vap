/*
 * Tencent is pleased to support the open source community by making vap available.
 *
 * Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * Licensed under the MIT License (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 *
 * http://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.tencent.qgame.animplayer

object YUVShader {

    const val VERTEX_SHADER = "attribute vec4 v_Position;\n" +
            "attribute vec2 vTexCoordinateAlpha;\n" +
            "attribute vec2 vTexCoordinateRgb;\n" +
            "varying vec2 v_TexCoordinateAlpha;\n" +
            "varying vec2 v_TexCoordinateRgb;\n" +
            "\n" +
            "void main() {\n" +
            "    v_TexCoordinateAlpha = vTexCoordinateAlpha;\n" +
            "    v_TexCoordinateRgb = vTexCoordinateRgb;\n" +
            "    gl_Position = v_Position;\n" +
            "}"

    const val FRAGMENT_SHADER = "precision mediump float;\n" +
            "uniform sampler2D sampler_y;\n" +
            "uniform sampler2D sampler_u;\n" +
            "uniform sampler2D sampler_v;\n" +
            "varying vec2 v_TexCoordinateAlpha;\n" +
            "varying vec2 v_TexCoordinateRgb;\n" +
            "uniform mat3 convertMatrix;\n" +
            "uniform vec3 offset;\n" +
            "\n" +
            "void main() {\n" +
            "   highp vec3 yuvColorAlpha;\n" +
            "   highp vec3 yuvColorRGB;\n" +
            "   highp vec3 rgbColorAlpha;\n" +
            "   highp vec3 rgbColorRGB;\n" +
            "   yuvColorAlpha.x = texture2D(sampler_y,v_TexCoordinateAlpha).r;\n" +
            "   yuvColorRGB.x = texture2D(sampler_y,v_TexCoordinateRgb).r;\n" +
            "   yuvColorAlpha.y = texture2D(sampler_u,v_TexCoordinateAlpha).r;\n" +
            "   yuvColorAlpha.z = texture2D(sampler_v,v_TexCoordinateAlpha).r;\n" +
            "   yuvColorRGB.y = texture2D(sampler_u,v_TexCoordinateRgb).r;\n" +
            "   yuvColorRGB.z = texture2D(sampler_v,v_TexCoordinateRgb).r;\n" +
            "   yuvColorAlpha += offset;\n" +
            "   yuvColorRGB += offset;\n" +
            "   rgbColorAlpha = convertMatrix * yuvColorAlpha; \n" +
            "   rgbColorRGB = convertMatrix * yuvColorRGB; \n" +
            "   gl_FragColor=vec4(rgbColorRGB, rgbColorAlpha.r);\n" +
            "}"

    // RGB2*Alpha+RGB1*(1-Alpha)
}