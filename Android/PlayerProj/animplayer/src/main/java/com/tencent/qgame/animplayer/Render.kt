/*
 * Tencent is pleased to support the open source community by making vap available.
 *
 * Copyright (C) 2020 Tencent.  All rights reserved.
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

    // SurfaceTexture 变换矩阵（仅应用 x 分量，y 保持原采样约定）：
    // 部分平台解码 buffer 的水平 stride 大于视频宽（如 RK3568 MPP 解码 720 宽视频
    // 输出 768 stride，右缘 48px dma-buf 填充，YUV(0,0,0) 渲染为绿色），OES 纹理
    // 有效区需靠该矩阵补偿。原版不应用矩阵，UV 越界采样填充区，表现为动画右缘
    // 半透明绿条 + 内容水平压缩。矩阵列主序，x 分量 x' = m[0]*x + m[4]*y + m[12]
    // 正是 stride/crop 补偿的载体；y 分量不动——vap 顶点序（switchY 已翻转）在
    // 原采样约定下垂直方向正确，应用矩阵 y 分量的 flipY 反而会颠倒画面；且垂直
    // stride 通常无 padding（v_str == height）无需补偿。
    private val texMatrix = floatArrayOf(
            1f, 0f, 0f, 0f,
            0f, 1f, 0f, 0f,
            0f, 0f, 1f, 0f,
            0f, 0f, 0f, 1f
    )
    private val mappedAlphaArray = GlFloatArray()
    private val mappedRgbArray = GlFloatArray()

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

    /**
     * SurfaceTexture 变换矩阵，见 texMatrix 注释
     */
    override fun setTexMatrix(matrix: FloatArray) {
        System.arraycopy(matrix, 0, texMatrix, 0, 16)
    }

    private fun applyTexMatrixX(src: FloatArray, dest: GlFloatArray) {
        val m = texMatrix
        val out = dest.array
        for (i in 0 until 4) {
            val x = src[i * 2]
            val y = src[i * 2 + 1]
            out[i * 2] = m[0] * x + m[4] * y + m[12]
            out[i * 2 + 1] = y
        }
        dest.setArray(out)
    }

    private fun draw() {
        GLES20.glUseProgram(shaderProgram)
        // 设置顶点坐标
        vertexArray.setVertexAttribPointer(aPositionLocation)
        // 绑定纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, genTexture[0])
        GLES20.glUniform1i(uTextureLocation, 0)

        // 设置纹理坐标（经变换矩阵的 x 分量映射，补偿解码 buffer 水平 stride）
        // alpha 通道坐标
        applyTexMatrixX(alphaArray.array, mappedAlphaArray)
        mappedAlphaArray.setVertexAttribPointer(aTextureAlphaLocation)
        // rgb 通道坐标
        applyTexMatrixX(rgbArray.array, mappedRgbArray)
        mappedRgbArray.setVertexAttribPointer(aTextureRgbLocation)

        // draw
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
    }

}