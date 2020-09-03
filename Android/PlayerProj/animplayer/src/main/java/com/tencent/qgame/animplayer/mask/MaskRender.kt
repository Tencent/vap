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

import android.opengl.GLES11Ext
import android.opengl.GLES20
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.PointRect
import com.tencent.qgame.animplayer.RefVec2
import com.tencent.qgame.animplayer.util.GlFloatArray
import com.tencent.qgame.animplayer.util.TexCoordsUtil
import com.tencent.qgame.animplayer.util.VertexUtil

/**
 * vapx 渲染
 */
class MaskRender(private val maskAnimPlugin: MaskAnimPlugin) {
    companion object {
        private const val TAG = "${Constant.TAG}.MaskRender"
    }

    var maskShader: MaskShader? = null
    var vertexArray = GlFloatArray()
    private var maskArray = GlFloatArray()
    /**
     * shader 与 texture初始化
     */
    fun initMaskShader(edgeBlur: Boolean) {
        // shader 初始化
        maskShader = MaskShader(edgeBlur)
        GLES20.glDisable(GLES20.GL_DEPTH_TEST) // 关闭深度测试
    }

    fun renderFrame(config: AnimConfig) {
        val videoTextureId = maskAnimPlugin.player.decoder?.render?.getExternalTexture() ?: return
        if (videoTextureId <= 0) return
        val shader = this.maskShader ?: return
        var maskTexId: Int = config.maskConfig?.getMaskTexId() ?: return
        val maskBitmap = config.maskConfig?.alphaMaskBitmap ?: return
        val maskTexRect = config.maskConfig?.maskTexPair?.first ?: return
        val maskTexRefVec2 = config.maskConfig?.maskTexPair?.second ?: return
        val maskPositionRect = config.maskConfig?.maskPositionPair?.first ?: PointRect(
            0,
            0,
            config.width,
            config.height
        )
        val maskPositionRefVec2 =
            config.maskConfig?.maskPositionPair?.second ?: RefVec2(config.width, config.height)
        shader.useProgram()
        // 顶点坐标
        vertexArray.setArray(
            VertexUtil.create(
                maskPositionRefVec2.w,
                maskPositionRefVec2.h,
                maskPositionRect,
                vertexArray.array
            )
        )
        vertexArray.setVertexAttribPointer(shader.aPositionLocation)

        if (maskTexId <= 0 && !maskBitmap.isRecycled) {
            maskTexId = config.maskConfig?.updateMaskTex() ?: 0
        }
        if (maskTexId > 0) {
            maskArray.setArray(
                TexCoordsUtil.create(
                    maskTexRefVec2.w,
                    maskTexRefVec2.h,
                    maskTexRect,
                    maskArray.array
                )
            )
            maskArray.setVertexAttribPointer(shader.aTextureMaskCoordinatesLocation)
            // 绑定alpha纹理
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
            GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, maskTexId)
            GLES20.glTexParameterf(
                GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MIN_FILTER,
                GLES20.GL_NEAREST.toFloat()
            )
            GLES20.glTexParameterf(
                GLES20.GL_TEXTURE_2D,
                GLES20.GL_TEXTURE_MAG_FILTER,
                GLES20.GL_LINEAR.toFloat()
            )
            GLES20.glTexParameteri(
                GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_WRAP_S,
                GLES20.GL_CLAMP_TO_EDGE
            )
            GLES20.glTexParameteri(
                GLES11Ext.GL_TEXTURE_EXTERNAL_OES,
                GLES20.GL_TEXTURE_WRAP_T,
                GLES20.GL_CLAMP_TO_EDGE
            )
            GLES20.glUniform1i(shader.uTextureMaskUnitLocation, 0)

            GLES20.glEnable(GLES20.GL_BLEND)
            // 基于源象素alpha通道值的半透明混合函数
            GLES20.glBlendFuncSeparate(
                GLES20.GL_ONE,
                GLES20.GL_SRC_ALPHA,
                GLES20.GL_ZERO,
                GLES20.GL_SRC_ALPHA
            )
            // draw
            GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)

            GLES20.glDisable(GLES20.GL_BLEND)
        }

    }

}