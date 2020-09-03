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
package com.tencent.qgame.animplayer.mix

import android.opengl.GLES20
import com.tencent.qgame.animplayer.util.ShaderUtil

class MixShader {
    companion object {
        private const val VERTEX = "attribute vec4 a_Position;  \n" +
                "attribute vec2 a_TextureSrcCoordinates;\n" +
                "attribute vec2 a_TextureMaskCoordinates;\n" +
                "varying vec2 v_TextureSrcCoordinates;\n" +
                "varying vec2 v_TextureMaskCoordinates;\n" +
                "void main()\n" +
                "{\n" +
                "    v_TextureSrcCoordinates = a_TextureSrcCoordinates;\n" +
                "    v_TextureMaskCoordinates = a_TextureMaskCoordinates;\n" +
                "    gl_Position = a_Position;\n" +
                "}"

        private const val FRAGMENT = "#extension GL_OES_EGL_image_external : require\n" +
                "precision mediump float; \n" +
                "uniform sampler2D u_TextureSrcUnit;\n" +
                "uniform samplerExternalOES u_TextureMaskUnit;\n" +
                "uniform int u_isFill;\n" +
                "uniform vec4 u_Color;\n" +
                "varying vec2 v_TextureSrcCoordinates;\n" +
                "varying vec2 v_TextureMaskCoordinates;\n" +
                "void main()\n" +
                "{\n" +
                "    vec4 srcRgba = texture2D(u_TextureSrcUnit, v_TextureSrcCoordinates);\n" +
                "    vec4 maskRgba = texture2D(u_TextureMaskUnit, v_TextureMaskCoordinates);\n" +
                "    float isFill = step(0.5, float(u_isFill));\n" +
                "    vec4 srcRgbaCal = isFill * vec4(u_Color.r, u_Color.g, u_Color.b, srcRgba.a) + (1.0 - isFill) * srcRgba;\n" +
                "    gl_FragColor = vec4(srcRgbaCal.r, srcRgbaCal.g, srcRgbaCal.b, srcRgba.a * maskRgba.r);\n" +
                "}"

        // Uniform constants
        private const val U_TEXTURE_SRC_UNIT = "u_TextureSrcUnit"
        private const val U_TEXTURE_MASK_UNIT = "u_TextureMaskUnit"
        private const val U_IS_FILL = "u_isFill"
        private const val U_COLOR = "u_Color"

        // Attribute constants
        private const val A_POSITION = "a_Position"
        private const val A_TEXTURE_SRC_COORDINATES = "a_TextureSrcCoordinates"
        private const val A_TEXTURE_MASK_COORDINATES = "a_TextureMaskCoordinates"
    }

    // Shader program
    val program: Int

    // Uniform locations
    val uTextureSrcUnitLocation: Int
    val uTextureMaskUnitLocation: Int
    val uIsFillLocation: Int
    val uColorLocation: Int

    // Attribute locations
    val aPositionLocation: Int
    val aTextureSrcCoordinatesLocation: Int
    val aTextureMaskCoordinatesLocation: Int

    init {
        program = ShaderUtil.createProgram(VERTEX, FRAGMENT)
        uTextureSrcUnitLocation = GLES20.glGetUniformLocation(program, U_TEXTURE_SRC_UNIT)
        uTextureMaskUnitLocation = GLES20.glGetUniformLocation(program, U_TEXTURE_MASK_UNIT)
        uIsFillLocation = GLES20.glGetUniformLocation(program, U_IS_FILL)
        uColorLocation = GLES20.glGetUniformLocation(program, U_COLOR)

        aPositionLocation = GLES20.glGetAttribLocation(program, A_POSITION)
        aTextureSrcCoordinatesLocation = GLES20.glGetAttribLocation(program, A_TEXTURE_SRC_COORDINATES)
        aTextureMaskCoordinatesLocation = GLES20.glGetAttribLocation(program, A_TEXTURE_MASK_COORDINATES)
    }

    fun useProgram() {
        GLES20.glUseProgram(program)
    }

}