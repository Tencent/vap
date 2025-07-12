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
package com.tencent.qgame.playerproj.player

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.AnimView
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.IALog
import com.tencent.qgame.animplayer.util.ScaleType
import com.tencent.qgame.playerproj.databinding.ActivityAnimSimpleDemoBinding
import java.io.File

/**
 * 播放宽高不是16的倍数的特殊尺寸的动画demo，这里以special_size_750.mp4为例，size = 750 x 814
 */
class AnimSpecialSizeDemoActivity : Activity(), IAnimListener {

    companion object {
        private const val TAG = "AnimSpecialSizeActivity"
    }

    private val dir by lazy {
        // 存放在sdcard应用缓存文件中
        getExternalFilesDir(null)?.absolutePath ?: Environment.getExternalStorageDirectory().path
    }

    // 视频信息
    data class VideoInfo(val fileName: String, val md5: String)

    // ps：每次修改mp4文件，但文件名不变，记得先卸载app，因为assets同名文件不会进行替换
    private val videoInfo = VideoInfo("special_size_750.mp4", "2acde1639ad74b8bd843083246902e23")

    // 动画View
    private lateinit var animView: AnimView

    private val uiHandler by lazy {
        Handler(Looper.getMainLooper())
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val inflate = ActivityAnimSimpleDemoBinding.inflate(layoutInflater, null, false)
        setContentView(inflate.root)
        // 文件加载完成后会调用init方法
        loadFile(inflate)
    }

    private fun init(inflate: ActivityAnimSimpleDemoBinding) {
        // 初始化日志
        initLog()
        // 初始化调试开关
        initTestView(inflate)
        // 获取动画view
        animView = inflate.playerView
        // 视频左右对齐（rgb左\alpha右）
        animView.setVideoMode(Constant.VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE)
        // 兼容老版本视频资源
        animView.enableVersion1(true)
        // 居中（根据父布局按比例居中并全部显示，默认fitXY）
        animView.setScaleType(ScaleType.FIT_CENTER)
        // 注册动画监听
        animView.setAnimListener(this)
        /**
         * 开始播放主流程
         * ps: 主要流程都是对AnimView的操作，其它比如队列，或改变窗口大小等操作都不是必须的
         */
        play(videoInfo)
    }


    private fun play(videoInfo: VideoInfo) {
        // 播放前强烈建议检查文件的md5是否有改变
        // 因为下载或文件存储过程中会出现文件损坏，导致无法播放
        Thread {
            val file = File(dir + "/" + videoInfo.fileName)
            val md5 = FileUtil.getFileMD5(file)
            if (videoInfo.md5 == md5) {
                // 开始播放动画文件
                animView.startPlay(file)
            } else {
                Log.e(TAG, "md5 is not match, error md5=$md5")
            }
        }.start()
    }


    /**
     * 视频信息准备好后的回调，用于检查视频准备好后是否继续播放
     * @return true 继续播放 false 停止播放
     */
    override fun onVideoConfigReady(config: AnimConfig): Boolean {

        uiHandler.post {
            val w = dp2px(this, 400f).toInt()
            val lp = animView.layoutParams
            lp.width = w
            lp.height = (w * config.height * 1f / config.width).toInt()
            animView.layoutParams = lp
        }
        return true
    }

    /**
     * 视频开始回调
     */
    override fun onVideoStart() {
        Log.i(TAG, "onVideoStart")
    }

    /**
     * 视频渲染每一帧时的回调
     * @param frameIndex 帧索引
     */
    override fun onVideoRender(frameIndex: Int, config: AnimConfig?) {
    }

    /**
     * 视频播放结束(失败也会回调onComplete)
     */
    override fun onVideoComplete() {
        Log.i(TAG, "onVideoComplete")
    }

    /**
     * 播放器被销毁情况下会调用onVideoDestroy
     */
    override fun onVideoDestroy() {
        Log.i(TAG, "onVideoDestroy")
    }

    /**
     * 失败回调
     * 一次播放时可能会调用多次，建议onFailed只做错误上报
     * @param errorType 错误类型
     * @param errorMsg 错误消息
     */
    override fun onFailed(errorType: Int, errorMsg: String?) {
        Log.i(TAG, "onFailed errorType=$errorType errorMsg=$errorMsg")
    }


    override fun onPause() {
        super.onPause()
        // 页面切换是停止播放
        animView.stopPlay()
    }


    private fun initLog() {
        ALog.isDebug = false
        ALog.log = object : IALog {
            override fun i(tag: String, msg: String) {
                Log.i(tag, msg)
            }

            override fun d(tag: String, msg: String) {
                Log.d(tag, msg)
            }

            override fun e(tag: String, msg: String) {
                Log.e(tag, msg)
            }

            override fun e(tag: String, msg: String, tr: Throwable) {
                Log.e(tag, msg, tr)
            }
        }
    }


    private fun initTestView(inflate: ActivityAnimSimpleDemoBinding) {
        inflate.btnLayout.visibility = View.VISIBLE
        /**
         * 开始播放按钮
         */
        inflate.btnPlay.setOnClickListener {
            play(videoInfo)
        }
        /**
         * 结束视频按钮
         */
        inflate.btnStop.setOnClickListener {
            animView.stopPlay()
        }
    }

    private fun loadFile(inflate: ActivityAnimSimpleDemoBinding) {
        val files = Array(1) {
            videoInfo.fileName
        }
        FileUtil.copyAssetsToStorage(this, dir, files) {
            uiHandler.post {
                init(inflate)
            }
        }
    }


    private fun dp2px(context: Context, dp: Float): Float {
        val scale = context.resources.displayMetrics.density
        return dp * scale + 0.5f
    }
}

