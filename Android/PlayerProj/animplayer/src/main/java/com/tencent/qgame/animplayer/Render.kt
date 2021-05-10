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
import android.opengl.GLES11Ext
import android.opengl.GLES20
import com.tencent.qgame.animplayer.util.GlFloatArray
import com.tencent.qgame.animplayer.util.ShaderUtil
import com.tencent.qgame.animplayer.util.TexCoordsUtil
import com.tencent.qgame.animplayer.util.VertexUtil
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.ShortBuffer

class Render(surfaceTexture: SurfaceTexture): IRenderListener {

    companion object {
        private const val TAG = "${Constant.TAG}.Render"
    }

    private val vertexArray = GlFloatArray()
    private val alphaArray = GlFloatArray()
    private val rgbArray = GlFloatArray()
    private var surfaceSizeChanged = false
    private var surfaceWidth = 0
    private var surfaceHeight = 0
    private val eglUtil: EGLUtil = EGLUtil()
    private var shaderProgram = 0
    private var genTexture = IntArray(1)
    private var uTextureLocation: Int = 0
    private var aPositionLocation: Int = 0
    private var aTextureAlphaLocation: Int = 0
    private var aTextureRgbLocation: Int = 0

    init {
        eglUtil.start(surfaceTexture)
        initRender()
    }

    private fun setVertexBuf(config: AnimConfig) {
        vertexArray.setArray(VertexUtil.create(config.width, config.height, PointRect(0, 0, config.width, config.height), vertexArray.array))
    }

    private fun setTexCoords(config: AnimConfig) {
        val alpha = TexCoordsUtil.create(config.videoWidth, config.videoHeight, config.alphaPointRect, alphaArray.array)
        val rgb = TexCoordsUtil.create(config.videoWidth, config.videoHeight, config.rgbPointRect, rgbArray.array)
        alphaArray.setArray(alpha)
        rgbArray.setArray(rgb)
    }

    override fun initRender() {
        shaderProgram = ShaderUtil.createProgram(RenderConstant.VERTEX_SHADER, RenderConstant.FRAGMENT_SHADER)
        uTextureLocation = GLES20.glGetUniformLocation(shaderProgram, "texture")
        aPositionLocation = GLES20.glGetAttribLocation(shaderProgram, "vPosition")
        aTextureAlphaLocation = GLES20.glGetAttribLocation(shaderProgram, "vTexCoordinateAlpha")
        aTextureRgbLocation = GLES20.glGetAttribLocation(shaderProgram, "vTexCoordinateRgb")

        GLES20.glGenTextures(genTexture.size, genTexture, 0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, genTexture[0])
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST.toFloat())
        GLES20.glTexParameterf(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_MAG_FILTER, GLES20.GL_LINEAR.toFloat())
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_S, GLES20.GL_CLAMP_TO_EDGE)
        GLES20.glTexParameteri(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_TEXTURE_WRAP_T, GLES20.GL_CLAMP_TO_EDGE)
    }

    override fun renderFrame() {
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        if (surfaceSizeChanged && surfaceWidth>0 && surfaceHeight>0) {
            surfaceSizeChanged = false
            GLES20.glViewport(0,0, surfaceWidth, surfaceHeight)
        }
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

    override fun releaseTexture() {
        GLES20.glDeleteTextures(genTexture.size, genTexture, 0)
    }

    /**
     * 设置视频配置
     */
    override fun setAnimConfig(config: AnimConfig) {
        setVertexBuf(config)
        setTexCoords(config)
    }

    /**
     * 显示区域大小变化
     */
    override fun updateViewPort(width: Int, height: Int) {
        if (width <=0 || height <=0) return
        surfaceSizeChanged = true
        surfaceWidth = width
        surfaceHeight = height
    }

    override fun swapBuffers() {
        eglUtil.swapBuffers()
    }

    /**
     * mediaCodec渲染使用的
     */
    override fun getExternalTexture(): Int {
        return genTexture[0]
    }

    private fun draw() {
        GLES20.glUseProgram(shaderProgram)
        // 设置顶点坐标
        vertexArray.setVertexAttribPointer(aPositionLocation)
        // 绑定纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, genTexture[0])
        GLES20.glUniform1i(uTextureLocation, 0)

        // 设置纹理坐标
        // alpha 通道坐标
        alphaArray.setVertexAttribPointer(aTextureAlphaLocation)
        // rgb 通道坐标
        rgbArray.setVertexAttribPointer(aTextureRgbLocation)

        // draw
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
    }

}