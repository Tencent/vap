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
package com.tencent.qgame.playerproj.player

import android.app.Activity
import android.content.Context
import android.graphics.Bitmap
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.util.Base64
import android.util.Log
import android.view.View
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.AnimView
import com.tencent.qgame.animplayer.PointRect
import com.tencent.qgame.animplayer.RefVec2
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.mask.MaskConfig
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.IALog
import com.tencent.qgame.animplayer.util.ScaleType
import com.tencent.qgame.playerproj.R
import kotlinx.android.synthetic.main.activity_anim_simple_demo.*
import java.io.File
import java.nio.ByteBuffer
import java.util.zip.Inflater
import kotlin.experimental.and
import kotlin.math.sqrt


/**
 * VAPX demo (融合特效Demo)
 * 必须使用组件里提供的工具才能生成VAPX动画
 */
class AnimActiveDemoActivity : Activity(), IAnimListener {

    companion object {
        private const val TAG = "AnimSimpleDemoActivity"
    }

    private val dir by lazy {
        // 存放在sdcard应用缓存文件中
        getExternalFilesDir(null)?.absolutePath ?: Environment.getExternalStorageDirectory().path
    }

    private var head1Img = true

    // 视频信息
    data class VideoInfo(val fileName: String, val md5: String)

    private val videoInfo = VideoInfo("mask_trunk_demo.mp4", "74d24e6235304e3c56b12d4867ea7d30")


    // 动画View
    private lateinit var animView: AnimView
    var maskBitmap: Bitmap? = null


    private val uiHandler by lazy {
        Handler(Looper.getMainLooper())
    }

    override fun onStop() {
        maskBitmap?.recycle()
        maskBitmap = null
        super.onStop()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_anim_simple_demo)
        // 文件加载完成后会调用init方法
        val files = Array(1) {
            videoInfo.fileName
        }
        FileUtil.copyAssetsToStorage(this, dir, files) {
            uiHandler.post {
                init()
            }
        }
    }

    private fun init() {
        // 初始化日志
        initLog()
        // 初始化调试开关
        initTestView()
        // 获取动画view
        animView = playerView
        // 居中（根据父布局按比例居中并全部显示s）
        animView.setScaleType(ScaleType.FIT_CENTER)
        // 启动过滤遮罩s
        animView.supportMask(true, true)
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
        updateTestMask()
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

    private fun updateTestMask() {
        val bitmap = handleDepthMaskData("eNrt1cFtxSAMBuAgDhwZIZuU0WCTjlJGyQgckYpwn57U6kGInYQQkPq4foeAHf+epvf5P+eDcDAoM1hQ5+BQlxBQVxBR1wD49XFnDzfo9QEs4VgBxA53aHlo9xU+Pzw0dPXwWOmAt7+9m/MOe9x2c/b0pbO7bs53ue/sobPHzg6juxncbS8XgAfAIO7OurzGfWcPZ32+x+NZV2M49PatgNAX+VYAAO7y1xe0vZv++/mNAeOAuyD873obAzQTrnZ7wJ9X7fGUw2UOLZzd6KaBv77PDu5LpbvG7is9VHps7IDG2zkXd7q53uURt1h8l11X+iuXBqS36yPu3o56IWBUpeuRPKDrreSccHHAvwj/LASovNEl6YC6aO8Ga1/BBeEz4Spze9A14cnfw+s8Us7WAXmpTytn6XCsAihzTbo/5jx1RXpAfSYdKDeYy7yBPA03mRd47W67Pk/3NS7yhLvZ+SphV+4JdzXOhnOdLj/al9y/U7d5vk2vro/6DEZhLlNX6/WYeGF9G1H2H2Jpic4=")
        val maskConfig = MaskConfig()
        maskConfig.safeSetMaskBitmapAndReleasePre(bitmap)
        maskConfig.maskTexPair = Pair(PointRect(0, 0, 1080, 607), RefVec2(1080, 607))
        maskConfig.maskPositionPair = Pair(PointRect(64, 64, 128, 128), RefVec2(256, 256))
        animView.updateMaskConfig(maskConfig)
    }


    private fun initTestView() {
        btnLayout.visibility = View.VISIBLE
        /**
         * 开始播放按钮
         */
        btnPlay.setOnClickListener {
            updateTestMask()
            play(videoInfo)
        }
        /**
         * 结束视频按钮
         */
        btnStop.setOnClickListener {
            animView.stopPlay()
        }
    }

    /**
     * 将Base64的bitmap转换为真正的bitmap
     */
    private fun handleDepthMaskData(compressedBase64Data: String) : Bitmap? {
        var zipInflater : Inflater?= null
        try {
            val base64Bytes = Base64.decode(compressedBase64Data, Base64.DEFAULT)
            zipInflater = Inflater()
            zipInflater.setInput(base64Bytes, 0, base64Bytes.size)
            val zlibBytes = ByteArray(128 * 128)
            val zlibByteLength = zipInflater.inflate(zlibBytes)
            if(zlibByteLength > 0) {
                val resultBytes = ByteArray(zlibByteLength * 8 * 4)
                for (outLoop in 0 until zlibByteLength) { //位展开操作
                    for(inLoop in 0 until 8) {
                        if (zlibBytes[outLoop] and (1 shl inLoop).toByte() == 0.toByte()) {
                            resultBytes[outLoop * 8 * 4 + (7- inLoop) * 4] = 255.toByte()
                            resultBytes[outLoop * 8 * 4 + (7- inLoop) * 4 + 1] = 255.toByte()
                            resultBytes[outLoop * 8 * 4 + (7- inLoop) * 4 + 2] = 255.toByte()
                            resultBytes[outLoop * 8 * 4 + (7- inLoop) * 4 + 3] = 255.toByte()
                        }
                    }
                }
                val width = sqrt((zlibByteLength * 8).toDouble())
                if(maskBitmap == null || maskBitmap?.isRecycled != false || (maskBitmap?.width ?: 0) < width) {
                    maskBitmap = Bitmap.createBitmap(width.toInt(), width.toInt(), Bitmap.Config.ARGB_8888)
                }
                maskBitmap?.copyPixelsFromBuffer( ByteBuffer.wrap(resultBytes))

            }
        } catch (e: Exception) {
            Log.e(TAG, "base64ToBitmap error:" + e.message)
        } finally {
            zipInflater?.end()
        }
        return maskBitmap
    }


    private fun dp2px(context: Context, dp: Float): Float {
        val scale = context.resources.displayMetrics.density
        return dp * scale + 0.5f
    }
}

