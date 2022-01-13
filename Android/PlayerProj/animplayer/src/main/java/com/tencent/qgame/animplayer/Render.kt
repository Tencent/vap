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
import android.util.Log
import com.tencent.qgame.animplayer.util.*

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

    private var catchTextureId = -1

    // 是否使用fbo缓冲
    private var useFbo = true

    private val catchBuf by lazy { CacheBuffer() }

    private val mTextureCoors by lazy { floatArrayOf(
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f
    ) }

    init {
        eglUtil.start(surfaceTexture)
        initRender()
    }

    private fun setVertexBuf(config: AnimConfig) {
        val fArr = VertexUtil.create(config.width, config.height, PointRect(0, 0, config.width, config.height), vertexArray.array)
        ALog.d(TAG, "setVertexArr: ${fArr.toList()}")

        if (useFbo) {
            catchBuf.setVertexArr(fArr)
        }
        vertexArray.setArray(fArr)
    }

    private fun setTexCoords(config: AnimConfig) {
        val rgb = TexCoordsUtil.create(config.videoWidth, config.videoHeight, config.rgbPointRect, rgbArray.array)
        val alpha = TexCoordsUtil.create(config.videoWidth, config.videoHeight, config.alphaPointRect, alphaArray.array)
        ALog.d(TAG, "setTexArr: texRgbArray: ${rgb.toList()}")
        ALog.d(TAG, "setTexArr: texAlphaArray: ${alpha.toList()}")

        if (useFbo) {
            catchBuf.setTexArr(rgb, alpha)
            rgbArray.setArray(mTextureCoors)
            alphaArray.setArray(mTextureCoors)
        } else {
            rgbArray.setArray(rgb)
            alphaArray.setArray(alpha)
        }
    }

    override fun initRender() {
        shaderProgram = ShaderUtil.createProgram(RenderConstant.VERTEX_SHADER, if (useFbo) RenderConstant.FRAGMENT_SHADER else RenderConstant.FRAGMENT_SHADER_OES)
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
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_NONE)

        if (useFbo) {
            catchTextureId = catchBuf.init(genTexture[0])
        }
    }

    override fun renderFrame() {
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f)
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT)
        if (surfaceSizeChanged && surfaceWidth>0 && surfaceHeight>0) {
            ALog.d("renderFrame","surfaceWidth : $surfaceWidth, surfaceHeight : $surfaceHeight")
            surfaceSizeChanged = false
            GLES20.glViewport(0,0, surfaceWidth, surfaceHeight)
            if (useFbo) {
                catchBuf.genCatch(surfaceWidth, surfaceHeight)
            }
        }

        // todo 测试用，记得删
        updateSave2BitmapIndex()

        if (useFbo) {
            catchBuf.draw()
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

        // todo 测试用，记得删
        resetSave2Bitmap()
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
        if (width <= 0 || height <= 0) return
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
        // 绑定纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        if (useFbo) {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, catchTextureId)
        } else {
            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, genTexture[0])
        }
        GLES20.glUniform1i(uTextureLocation, 0)

        // 设置顶点坐标
        vertexArray.setVertexAttribPointer(aPositionLocation)
        // 设置纹理坐标
        // alpha 通道坐标
        alphaArray.setVertexAttribPointer(aTextureAlphaLocation)
        // rgb 通道坐标
        rgbArray.setVertexAttribPointer(aTextureRgbLocation)

        // draw
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        // todo : 测试用，记得删
//        saveRgb2Bitmap(intArrayOf(230), surfaceWidth, surfaceHeight, "def")

        if (useFbo) {
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, GLES20.GL_NONE)
        } else {
            GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, GLES20.GL_NONE)
        }
    }

}