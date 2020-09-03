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
package com.tencent.qgame.animplayer.mask

import android.opengl.GLES20
import android.util.Log
import com.tencent.qgame.animplayer.util.ShaderUtil

class MaskShader(edgeBlurBoolean : Boolean) {
    companion object {

        private const val VERTEX =
            "attribute vec4 vPosition;\n" +
                    "attribute vec4 vTexCoordinateAlphaMask;\n" +
                    "varying vec2 v_TexCoordinateAlphaMask;\n" +
                    "\n" +
                    "void main() {\n" +
                    "    v_TexCoordinateAlphaMask = vec2(vTexCoordinateAlphaMask.x, vTexCoordinateAlphaMask.y);\n" +
                    "    gl_Position = vPosition;\n" +
                    "}"
        //边缘做高斯模糊
        private const val FRAGMENT_BLUR_EDGE =
                    "precision mediump float;\n" +
                    "uniform sampler2D uTextureAlphaMask;\n" +
                    "varying vec2 v_TexCoordinateAlphaMask;\n" +
                    "mat3 weight = mat3(0.0625,0.125,0.0625,0.125,0.25,0.125,0.0625,0.125,0.0625);\n " +
                    "int coreSize=3;\n" +
                    "float texelOffset = .01;\n" +
                    "\n" +
                    "void main() {\n" +
                    "   float alphaResult = 0.;\n" +
                    "   for(int y = 0; y < coreSize; y++) {\n" +
                    "       for(int x = 0;x < coreSize; x++) {\n" +
                    "           alphaResult += texture2D(uTextureAlphaMask, vec2(v_TexCoordinateAlphaMask.x + (-1.0 + float(x)) * texelOffset,v_TexCoordinateAlphaMask.y + (-1.0 + float(y)) * texelOffset)).a * weight[x][y];\n" +
                    "       }\n" +
                    "    }\n" +
                    "    gl_FragColor = vec4(0, 0, 0, alphaResult);\n" +
                    "}"

        private const val FRAGMENT_NO_BLUR_EDGE =
            "precision mediump float;\n" +
                    "uniform sampler2D uTextureAlphaMask;\n" +
                    "varying vec2 v_TexCoordinateAlphaMask;\n" +
                    "\n" +
                    "void main () {\n" +
                    "    vec4 alphaMaskColor = texture2D(uTextureAlphaMask, v_TexCoordinateAlphaMask);\n" +
                    "    gl_FragColor = vec4(0, 0, 0, alphaMaskColor.a);\n" +
                    "}"

        private const val FRAGMENT_ROW =
            "precision mediump float;\n" +
                    "uniform sampler2D uTextureAlphaMask;\n" +
                    "varying vec2 v_TexCoordinateAlphaMask;\n" +
                    "vec3 weight = vec3(0.4026,0.2442,0.0545);\n " +
                    "\n" +
                    "void main() {\n" +
                    "   float texelOffset = .01;\n" +
                    "   vec2 uv[5];\n" +
                    "   uv[0]= v_TexCoordinateAlphaMask;\n" +
                    "   uv[1]=vec2(uv[0].x+texelOffset*1.0,  uv[0].y);\n" +
                    "   uv[2]=vec2(uv[0].x-texelOffset*1.0,  uv[0].y);\n" +
                    "   uv[3]=vec2(uv[0].x+texelOffset*2.0,  uv[0].y);\n" +
                    "   uv[4]=vec2(uv[0].x-texelOffset*2.0,  uv[0].y);\n" +
                    "   float alphaResult = texture2D(uTextureAlphaMask, uv[0]).a * weight[0];\n" +
                    "   for(int i = 1; i < 3; ++i) {\n" +
                    "       alphaResult += texture2D(uTextureAlphaMask, uv[2*i-1]).a * weight[i];\n" +
                    "       alphaResult += texture2D(uTextureAlphaMask, uv[2*i]).a * weight[i];\n" +
                    "    }\n" +
                    "    gl_FragColor = vec4(0, 0, 0, alphaResult);\n" +
                    "}"

        // Uniform constants
        private const val U_TEXTURE_ALPHA_MASK_UNIT = "uTextureAlphaMask"

        // Attribute constants
        private const val A_POSITION = "vPosition"
        private const val A_TEXTURE_MASK_COORDINATES = "vTexCoordinateAlphaMask"
    }

    // Shader program
    private val program: Int

    // Uniform locations
    val uTextureMaskUnitLocation: Int
    // Attribute locations
    val aPositionLocation: Int
    val aTextureMaskCoordinatesLocation: Int

    init {
        program = if(edgeBlurBoolean) ShaderUtil.createProgram(VERTEX, FRAGMENT_BLUR_EDGE) else ShaderUtil.createProgram(VERTEX, FRAGMENT_NO_BLUR_EDGE)
        uTextureMaskUnitLocation = GLES20.glGetUniformLocation(program, U_TEXTURE_ALPHA_MASK_UNIT)

        aPositionLocation = GLES20.glGetAttribLocation(program, A_POSITION)
        aTextureMaskCoordinatesLocation = GLES20.glGetAttribLocation(program, A_TEXTURE_MASK_COORDINATES)
    }

    fun useProgram() {
        GLES20.glUseProgram(program)
    }

}