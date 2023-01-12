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

import android.opengl.GLES11Ext
import android.opengl.GLES20
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.PointRect
import com.tencent.qgame.animplayer.util.*

/**
 * vapx 渲染
 */
class MixRender(private val mixAnimPlugin: MixAnimPlugin) {
    companion object {
        private const val TAG = "${Constant.TAG}.MixRender"
    }
    var shader: MixShader? = null
    var vertexArray = GlFloatArray()
    var srcArray = GlFloatArray()
    var maskArray = GlFloatArray()

    /**
     * shader 与 texture初始化
     */
    fun init() {
        // shader 初始化
        shader = MixShader()
        GLES20.glDisable(GLES20.GL_DEPTH_TEST) // 关闭深度测试

        mixAnimPlugin.srcMap?.map?.values?.forEach {src->
            ALog.i(TAG, "init srcId=${src.srcId}")
            src.srcTextureId = TextureLoadUtil.loadTexture(src.bitmap)
            ALog.i(TAG, "textureProgram=${shader?.program},textureId=${src.srcTextureId}")
        }

    }

    fun renderFrame(config:AnimConfig, frame:Frame, src: Src) {
        val videoTextureId = mixAnimPlugin.player.decoder?.render?.getExternalTexture() ?: return
        if (videoTextureId <= 0) return
        val shader = this.shader ?: return
        shader.useProgram()
        // 定点坐标
        vertexArray.setArray(VertexUtil.create(config.width, config.height, frame.frame, vertexArray.array))
        vertexArray.setVertexAttribPointer(shader.aPositionLocation)

        // src 纹理坐标
        srcArray.setArray(genSrcCoordsArray(srcArray.array, frame.frame.w, frame.frame.h, src.drawWidth, src.drawHeight, src.fitType))
        srcArray.setVertexAttribPointer(shader.aTextureSrcCoordinatesLocation)
        // 绑定 src纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, src.srcTextureId)
        GLES20.glUniform1i(shader.uTextureSrcUnitLocation, 0)

        // mask 纹理
        maskArray.setArray(TexCoordsUtil.create(config.videoWidth, config.videoHeight, frame.mFrame, maskArray.array))
        if (frame.mt == 90) {
            maskArray.setArray(TexCoordsUtil.rotate90(maskArray.array))
        }
        maskArray.setVertexAttribPointer(shader.aTextureMaskCoordinatesLocation)
        // 绑定 mask纹理
        GLES20.glActiveTexture(GLES20.GL_TEXTURE1)
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, videoTextureId)
        GLES20.glUniform1i(shader.uTextureMaskUnitLocation, 1)

        // 属性处理
        if (src.srcType == Src.SrcType.TXT && mixAnimPlugin.autoTxtColorFill) { // // 文字需要颜色填充
            GLES20.glUniform1i(shader.uIsFillLocation,  1)
            val argb = transColor(src.color)
            GLES20.glUniform4f(shader.uColorLocation, argb[1], argb[2], argb[3], argb[0])
        } else {
            GLES20.glUniform1i(shader.uIsFillLocation,  0)
            GLES20.glUniform4f(shader.uColorLocation, 0f, 0f, 0f, 0f)
        }

        GLES20.glEnable(GLES20.GL_BLEND)
        // 基于源象素alpha通道值的半透明混合函数
        GLES20.glBlendFuncSeparate(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA, GLES20.GL_ONE, GLES20.GL_ONE_MINUS_SRC_ALPHA)
        // draw
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

        GLES20.glDisable(GLES20.GL_BLEND)

    }

    fun release(textureId: Int) {
        if (textureId != 0) {
            GLES20.glDeleteTextures(1, intArrayOf(textureId), 0)
        }
    }

    /**
     * CENTER_FULL 并不是严格的centerCrop(centerCrop已经前置处理)，此处主要是为防抖动做处理，复杂遮罩情况下需要固定src大小进行绘制防止抖动
     */
    private fun genSrcCoordsArray(array: FloatArray, fw: Int, fh: Int, sw: Int, sh: Int, fitType: Src.FitType): FloatArray {
        return if (fitType == Src.FitType.CENTER_FULL) {
            if (fw <= sw && fh <= sh) {
                // 中心对齐，不拉伸
                val gw = (sw - fw) / 2
                val gh = (sh - fh) / 2
                TexCoordsUtil.create(sw, sh, PointRect(gw, gh, fw, fh), array)
            } else { // centerCrop
                val fScale = fw * 1.0f / fh
                val sScale = sw * 1.0f / sh
                val srcRect = if (fScale > sScale) {
                    val w = sw
                    val x = 0
                    val h = (sw / fScale).toInt()
                    val y = (sh - h) / 2

                    PointRect(x, y, w, h)
                } else {
                    val h = sh
                    val y = 0
                    val w = (sh * fScale).toInt()
                    val x = (sw - w) / 2
                    PointRect(x, y, w, h)
                }
                TexCoordsUtil.create(sw, sh, srcRect, array)
            }
        } else { // 默认 fitXY
            TexCoordsUtil.create(fw, fh, PointRect(0, 0, fw, fh), array)
        }
    }

    private fun transColor(color: Int): FloatArray {
        val argb = FloatArray(4)
        argb[0] = (color.ushr(24) and 0x000000ff) / 255f
        argb[1] = (color.ushr(16) and 0x000000ff) / 255f
        argb[2] = (color.ushr(8) and 0x000000ff) / 255f
        argb[3] = (color and 0x000000ff) / 255f
        return argb
    }


}