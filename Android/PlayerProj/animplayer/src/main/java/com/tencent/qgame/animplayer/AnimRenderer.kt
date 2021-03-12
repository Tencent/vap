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

import android.content.res.AssetManager
import android.graphics.SurfaceTexture
import android.opengl.GLES20
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.inter.IFetchResource
import com.tencent.qgame.animplayer.inter.OnResourceClickListener
import com.tencent.qgame.animplayer.mask.MaskConfig
import com.tencent.qgame.animplayer.util.ALog
import java.io.File

/**
 * GL 渲染实现，操作方法与 AnimView 一致
 * glInit：gl 初始化
 * glRelease：gl 释放
 * glProcess：获取 OES Texture Id
 */
open class AnimRenderer {

    companion object {
        private const val TAG = "${Constant.TAG}.AnimRenderer"
    }

    private val uiHandler by lazy { Handler(Looper.getMainLooper()) }
    private val textureId = intArrayOf(0)
    private var surface: SurfaceTexture? = null
    private var player: AnimPlayer? = null
    private var animListener: IAnimListener? = null
    private var lastFile: FileContainer? = null
    private var hasData: Boolean = false
    private var lastWidth = 0
    private var lastHeight = 0

    // 代理监听
    private val animProxyListener by lazy {
        object : IAnimListener {

            override fun onVideoConfigReady(config: AnimConfig): Boolean {
                return animListener?.onVideoConfigReady(config) ?: super.onVideoConfigReady(config)
            }

            override fun onVideoStart() {
                animListener?.onVideoStart()
            }

            override fun onVideoRender(frameIndex: Int, config: AnimConfig?) {
                hasData = true
                animListener?.onVideoRender(frameIndex, config)
            }

            override fun onVideoComplete() {
                hide()
                animListener?.onVideoComplete()
            }

            override fun onVideoDestroy() {
                hide()
                animListener?.onVideoDestroy()
            }

            override fun onFailed(errorType: Int, errorMsg: String?) {
                animListener?.onFailed(errorType, errorMsg)
            }

        }
    }

    private val surfaceOwner = object: SurfaceOwner {
        override val width: Int
            get() = lastWidth

        override val height: Int
            get() = lastHeight

        override fun getSurfaceTexture() = surface

        override fun prepareTextureView() = Unit
    }

    init {
        hide()
        player = AnimPlayer(surfaceOwner)
        player?.animListener = animProxyListener
    }

    fun glInit() {
        GLES20.glGenTextures(textureId.size, textureId, 0)
        surface = SurfaceTexture(textureId[0])
    }

    fun glRelease() {
        GLES20.glDeleteTextures(textureId.size, textureId, 0)
        surface?.release()
        player?.onSurfaceTextureDestroyed()
    }

    fun glProcess(width: Int, height: Int, texMat: FloatArray): Int {
        handleSizeChange(width, height)

        if (!hasData) {
            return -1
        }

        surface?.run {
            updateTexImage()
            getTransformMatrix(texMat)
        }
        return textureId[0]
    }

    private fun handleSizeChange(width: Int, height: Int) {
        if (lastWidth != width && lastHeight != height) {
            surface?.setDefaultBufferSize(width, height)

            if (lastWidth == 0 && lastHeight == 0) {
                player?.onSurfaceTextureAvailable(width, height)
            }
            player?.onSurfaceTextureSizeChanged(width, height)
            lastWidth = width
            lastHeight = height
        }
    }

    fun resume() {
        ALog.i(TAG, "resume")
        player?.isDetachedFromWindow = false
        // 自动恢复播放
        if ((player?.playLoop ?: 0) > 0) {
            lastFile?.apply {
                startPlay(this)
            }
        }
    }

    fun pause() {
        ALog.i(TAG, "pause")
        if (belowKitKat()) {
            release()
        }
        player?.isDetachedFromWindow = true
        player?.onSurfaceTextureDestroyed()
    }

    open fun setAnimListener(animListener: IAnimListener?) {
        this.animListener = animListener
    }

    open fun setFetchResource(fetchResource: IFetchResource?) {
        player?.pluginManager?.getMixAnimPlugin()?.resourceRequest = fetchResource
    }

    open fun setOnResourceClickListener(resourceClickListener: OnResourceClickListener?) {
        player?.pluginManager?.getMixAnimPlugin()?.resourceClickListener = resourceClickListener
    }

    /**
     * 兼容方案，优先保证表情显示
     */
    open fun enableAutoTxtColorFill(enable: Boolean) {
        player?.pluginManager?.getMixAnimPlugin()?.autoTxtColorFill = enable
    }

    fun setLoop(playLoop: Int) {
        player?.playLoop = playLoop
    }

    fun supportMask(isSupport: Boolean, isEdgeBlur: Boolean) {
        player?.supportMaskBoolean = isSupport
        player?.maskEdgeBlurBoolean = isEdgeBlur
    }

    fun updateMaskConfig(maskConfig: MaskConfig?) {
        player?.updateMaskConfig(maskConfig)
    }

    // 兼容老版本视频模式
    @Deprecated("Compatible older version mp4")
    fun setVideoMode(mode: Int) {
        player?.videoMode = mode
    }

    fun setFps(fps: Int) {
        player?.fps = fps
    }

    fun startPlay(file: File) {
        try {
            val fileContainer = FileContainer(file)
            startPlay(fileContainer)
        } catch (e: Throwable) {
            animProxyListener.onFailed(
                    Constant.REPORT_ERROR_TYPE_FILE_ERROR,
                    Constant.ERROR_MSG_FILE_ERROR
            )
        }
    }

    fun startPlay(assetManager: AssetManager, assetsPath: String) {
        try {
            val fileContainer = FileContainer(assetManager, assetsPath)
            startPlay(fileContainer)
        } catch (e: Throwable) {
            animProxyListener.onFailed(
                    Constant.REPORT_ERROR_TYPE_FILE_ERROR,
                    Constant.ERROR_MSG_FILE_ERROR
            )
        }
    }


    fun startPlay(fileContainer: FileContainer) {
        ui {
            if (player?.isRunning() == false) {
                lastFile = fileContainer
                player?.startPlay(fileContainer)
            } else {
                ALog.i(TAG, "is running can not start")
            }
        }
    }


    fun stopPlay() {
        player?.stopPlay()
    }

    fun isRunning(): Boolean {
        return player?.isRunning() ?: false
    }

    private fun hide() {
        lastFile?.close()
    }

    private fun ui(f: () -> Unit) {
        if (Looper.myLooper() == Looper.getMainLooper()) f() else uiHandler.post { f() }
    }

    /**
     * fix Error detachFromGLContext crash
     */
    private fun belowKitKat(): Boolean {
        return Build.VERSION.SDK_INT <= 19
    }

    private fun release() {
        try {
            surface?.release()
        } catch (error: Throwable) {
            ALog.e(TAG, "failed to release mSurfaceTexture= $surface: ${error.message}", error)
        }
        surface = null
    }
}