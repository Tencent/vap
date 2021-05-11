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

import android.graphics.SurfaceTexture
import android.opengl.GLES20
import com.tencent.qgame.animplayer.util.GlFloatArray
import com.tencent.qgame.animplayer.util.ShaderUtil.createProgram
import com.tencent.qgame.animplayer.util.TexCoordsUtil
import com.tencent.qgame.animplayer.util.VertexUtil
import java.nio.ByteBuffer

class YUVRender (surfaceTexture: SurfaceTexture): IRenderListener {

    private val vertexArray = GlFloatArray()
    private val alphaArray = GlFloatArray()
    private val rgbArray = GlFloatArray()

    private var shaderProgram = 0

    //顶点位置
    private var avPosition = 0

    //rgb纹理位置
    private var rgbPosition = 0

    //alpha纹理位置
    private var alphaPosition = 0

    //shader  yuv变量
    private var samplerY = 0
    private var samplerUV = 0
    private var textureId = IntArray(2)

    //YUV数据
    private var widthYUV = 0
    private var heightYUV = 0
    private var y: ByteBuffer? = null
    private var uv: ByteBuffer? = null

    private val eglUtil: EGLUtil = EGLUtil()

    init {
        eglUtil.start(surfaceTexture)
        initRender()
    }

    override fun initRender() {
        shaderProgram = createProgram(YUVShader.VERTEX_SHADER, YUVShader.FRAGMENT_SHADER)
        //获取顶点坐标字段
        avPosition = GLES20.glGetAttribLocation(shaderProgram, "v_Position")
        //获取纹理坐标字段
        rgbPosition = GLES20.glGetAttribLocation(shaderProgram, "vTexCoordinateRgb")
        alphaPosition = GLES20.glGetAttribLocation(shaderProgram, "vTexCoordinateAlpha")

        //获取yuv字段
        samplerY = GLES20.glGetUniformLocation(shaderProgram, "sampler_y")
        samplerUV = GLES20.glGetUniformLocation(shaderProgram, "sampler_uv")
        //创建2个纹理
        GLES20.glGenTextures(textureId.size, textureId, 0)

        //绑定纹理
        for (id in textureId) {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, id)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_REPEAT)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_REPEAT)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_LINEAR)
            GLES20.glTexParameteri(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR)
        }
    }

    override fun renderFrame() {
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        draw()
    }

    override fun clearFrame() {
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        eglUtil.swapBuffers()
    }

    override fun destroyRender() {
        releaseTexture()
        eglUtil.release()
    }

    override fun setAnimConfig(config: AnimConfig) {
        vertexArray.setArray(VertexUtil.create(config.width, config.height, PointRect(0, 0, config.width, config.height), vertexArray.array))
        val alpha = TexCoordsUtil.create(config.videoWidth, config.videoHeight, config.alphaPointRect, alphaArray.array)
        val rgb = TexCoordsUtil.create(config.videoWidth, config.videoHeight, config.rgbPointRect, rgbArray.array)
        alphaArray.setArray(alpha)
        rgbArray.setArray(rgb)
    }

    override fun getExternalTexture(): Int {
        return textureId[0]
    }

    override fun releaseTexture() {
        GLES20.glDeleteTextures(textureId.size, textureId, 0)
    }

    override fun swapBuffers() {
        eglUtil.swapBuffers()
    }

    override fun setYUVData(width: Int, height: Int, y: ByteArray?, uv: ByteArray?) {
        widthYUV = width
        heightYUV = height
        this.y = ByteBuffer.wrap(y)
        this.uv = ByteBuffer.wrap(uv)
    }

    private fun draw() {
        if (widthYUV > 0 && heightYUV > 0 && y != null && uv != null) {
            GLES20.glUseProgram(shaderProgram)
            vertexArray.setVertexAttribPointer(avPosition)
            alphaArray.setVertexAttribPointer(alphaPosition)
            rgbArray.setVertexAttribPointer(rgbPosition)

            //激活纹理0来绑定y数据
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId[0])
            GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE, widthYUV, heightYUV, 0, GLES20.GL_LUMINANCE, GLES20.GL_UNSIGNED_BYTE, y)

            //激活纹理1来绑定uv数据
            GLES20.glActiveTexture(GLES20.GL_TEXTURE1)
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, textureId[1])
            GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_LUMINANCE_ALPHA, widthYUV / 2, heightYUV / 2, 0, GLES20.GL_LUMINANCE_ALPHA, GLES20.GL_UNSIGNED_BYTE, uv)

            //给fragment_shader里面yuv变量设置值   0 1 标识纹理x
            GLES20.glUniform1i(samplerY, 0)
            GLES20.glUniform1i(samplerUV, 1)

            //绘制
            GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
            y?.clear()
            uv?.clear()
            y = null
            uv = null
            GLES20.glDisableVertexAttribArray(avPosition)
            GLES20.glDisableVertexAttribArray(rgbPosition)
            GLES20.glDisableVertexAttribArray(alphaPosition)
        }
    }
}