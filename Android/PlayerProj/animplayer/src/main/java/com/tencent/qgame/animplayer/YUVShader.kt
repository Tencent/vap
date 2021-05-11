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
            "uniform sampler2D sampler_uv;\n" +
            "varying vec2 v_TexCoordinateAlpha;\n" +
            "varying vec2 v_TexCoordinateRgb;\n" +
            "\n" +
            "void main() {\n" +
            "   float y1,u1,v1;\n" +
            "   float y2,u2,v2;\n" +
            "   y2 = texture2D(sampler_y,v_TexCoordinateAlpha).r;\n" +
            "   u2 = texture2D(sampler_uv,v_TexCoordinateAlpha).r- 0.5;\n" +
            "   v2 = texture2D(sampler_uv,v_TexCoordinateAlpha).a - 0.5;\n" +
            "   y1 = texture2D(sampler_y,v_TexCoordinateRgb).r;\n" +
            "   u1 = texture2D(sampler_uv,v_TexCoordinateRgb).r- 0.5;\n" +
            "   v1 = texture2D(sampler_uv,v_TexCoordinateRgb).a - 0.5;\n" +
            "   vec3 rgb1;\n" +
            "   vec3 rgb2;\n" +
            "   rgb1.r = y1 + 1.403 * v1;\n" +
            "   rgb1.g = y1 - 0.344 * u1 - 0.714 * v1;\n" +
            "   rgb1.b = y1 + 1.770 * u1;\n" +
            "   rgb2.r = y2 + 1.403 * v2;\n" +
            "   rgb2.g = y2 - 0.344 * u2 - 0.714 * v2;\n" +
            "   rgb2.b = y2 + 1.770 * u2;\n" +
            "   gl_FragColor=vec4(rgb1, rgb2.r);\n" +
            "}"
    // RGB2*Alpha+RGB1*(1-Alpha)
}