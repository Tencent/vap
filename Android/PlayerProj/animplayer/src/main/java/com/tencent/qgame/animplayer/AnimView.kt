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

import android.content.Context
import android.content.res.AssetManager
import android.graphics.SurfaceTexture
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.TextureView
import android.view.View
import android.widget.FrameLayout
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.inter.IFetchResource
import com.tencent.qgame.animplayer.inter.OnResourceClickListener
import com.tencent.qgame.animplayer.mask.MaskConfig
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.IScaleType
import com.tencent.qgame.animplayer.util.ScaleType
import com.tencent.qgame.animplayer.util.ScaleTypeUtil
import java.io.File

open class AnimView @JvmOverloads constructor(context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0):
    FrameLayout(context, attrs, defStyleAttr),
    TextureView.SurfaceTextureListener {

    companion object {
        private const val TAG = "${Constant.TAG}.AnimView"
    }
    private val uiHandler by lazy { Handler(Looper.getMainLooper()) }
    private var surface: SurfaceTexture? = null
    private var player: AnimPlayer? = null
    private var animListener: IAnimListener? = null
    private var innerTextureView: TextureView? = null
    private var lastFile: FileContainer? = null
    private val scaleTypeUtil = ScaleTypeUtil()

    // 代理监听
    private val animProxyListener by lazy {
        object : IAnimListener {

            override fun onVideoConfigReady(config: AnimConfig): Boolean {
                scaleTypeUtil.videoWidth = config.width
                scaleTypeUtil.videoHeight = config.height
                return animListener?.onVideoConfigReady(config) ?: super.onVideoConfigReady(config)
            }

            override fun onVideoStart() {
                animListener?.onVideoStart()
            }

            override fun onVideoRender(frameIndex: Int, config: AnimConfig?) {
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


    init {
        hide()
        player = AnimPlayer(this)
        player?.animListener = animProxyListener
    }


    fun prepareTextureView() {
        uiHandler.post {
            removeAllViews()
            innerTextureView = TextureView(context).apply {
                isOpaque = false
                surfaceTextureListener = this@AnimView
                layoutParams = scaleTypeUtil.getLayoutParam(this)
            }
            addView(innerTextureView)
        }
    }

    fun getSurfaceTexture(): SurfaceTexture? {
        return innerTextureView?.surfaceTexture ?: surface
    }

    override fun onSurfaceTextureSizeChanged(surface: SurfaceTexture, width: Int, height: Int) {
        ALog.i(TAG, "onSurfaceTextureSizeChanged $width x $height")
        player?.onSurfaceTextureSizeChanged(width, height)
    }

    override fun onSurfaceTextureUpdated(surface: SurfaceTexture) {
    }

    override fun onSurfaceTextureDestroyed(surface: SurfaceTexture): Boolean {
        ALog.i(TAG, "onSurfaceTextureDestroyed")
        player?.onSurfaceTextureDestroyed()
        uiHandler.post {
            innerTextureView?.surfaceTextureListener = null
            innerTextureView = null
            removeAllViews()
        }
        return !belowKitKat()
    }

    override fun onSurfaceTextureAvailable(surface: SurfaceTexture, width: Int, height: Int) {
        ALog.i(TAG, "onSurfaceTextureAvailable")
        this.surface = surface
        player?.onSurfaceTextureAvailable(width, height)
    }

    override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
        super.onSizeChanged(w, h, oldw, oldh)
        scaleTypeUtil.layoutWidth = w
        scaleTypeUtil.layoutHeight = h
    }

    override fun onAttachedToWindow() {
        ALog.i(TAG, "onAttachedToWindow")
        super.onAttachedToWindow()
        player?.isDetachedFromWindow = false
        // 自动恢复播放
        if ((player?.playLoop ?: 0) > 0) {
            lastFile?.apply {
                startPlay(this)
            }
        }
    }

    override fun onDetachedFromWindow() {
        ALog.i(TAG, "onDetachedFromWindow")
        super.onDetachedFromWindow()
        if (belowKitKat()) {
            release()
        }
        player?.isDetachedFromWindow = true
        player?.onSurfaceTextureDestroyed()
    }

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        val res = isRunning() && ev != null && player?.pluginManager?.onDispatchTouchEvent(ev) == true
        return if (!res) super.dispatchTouchEvent(ev) else true
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

    fun supportMask(isSupport : Boolean, isEdgeBlur : Boolean) {
        player?.supportMaskBoolean = isSupport
        player?.maskEdgeBlurBoolean = isEdgeBlur
    }

    fun updateMaskConfig(maskConfig: MaskConfig?) {
        player?.updateMaskConfig(maskConfig)
    }


    @Deprecated("Compatible older version mp4, default false")
    fun enableVersion1(enable: Boolean) {
        player?.enableVersion1 = enable
    }

    // 兼容老版本视频模式
    @Deprecated("Compatible older version mp4")
    fun setVideoMode(mode: Int) {
        player?.videoMode = mode
    }

    fun setFps(fps: Int) {
        player?.fps = fps
    }

    fun setScaleType(type : ScaleType) {
        scaleTypeUtil.currentScaleType = type
    }

    fun setScaleType(scaleType: IScaleType) {
        scaleTypeUtil.scaleTypeImpl = scaleType
    }

    fun startPlay(file: File) {
        try {
            val fileContainer = FileContainer(file)
            startPlay(fileContainer)
        } catch (e: Throwable) {
            animProxyListener.onFailed(Constant.REPORT_ERROR_TYPE_FILE_ERROR, Constant.ERROR_MSG_FILE_ERROR)
        }
    }

    fun startPlay(assetManager: AssetManager, assetsPath: String) {
        try {
            val fileContainer = FileContainer(assetManager, assetsPath)
            startPlay(fileContainer)
        } catch (e: Throwable) {
            animProxyListener.onFailed(Constant.REPORT_ERROR_TYPE_FILE_ERROR, Constant.ERROR_MSG_FILE_ERROR)
        }
    }


    fun startPlay(fileContainer: FileContainer) {
        ui {
            if (visibility != View.VISIBLE) {
                ALog.e(TAG, "AnimView is GONE, can't play")
                return@ui
            }
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
        ui {
            removeAllViews()
        }
    }

    private fun ui(f:()->Unit) {
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