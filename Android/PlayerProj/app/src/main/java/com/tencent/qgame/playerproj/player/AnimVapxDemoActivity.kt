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
import android.graphics.BitmapFactory
import android.os.Bundle
import android.os.Environment
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.Toast
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.AnimView
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.inter.IFetchResource
import com.tencent.qgame.animplayer.inter.OnResourceClickListener
import com.tencent.qgame.animplayer.mix.Resource
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.IALog
import com.tencent.qgame.animplayer.util.ScaleType
import com.tencent.qgame.playerproj.R
import kotlinx.android.synthetic.main.activity_anim_simple_demo.*
import java.io.File
import java.util.*


/**
 * VAPX demo (融合特效Demo)
 * 必须使用组件里提供的工具才能生成VAPX动画
 */
class AnimVapxDemoActivity : Activity(), IAnimListener {

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

    private val videoInfo = VideoInfo("vapx.mp4", "f981e0f094ead842ad5ae99f1ffaa1a1")

    // 动画View
    private lateinit var animView: AnimView

    private val uiHandler by lazy {
        Handler(Looper.getMainLooper())
    }

    private var lastToast: Toast? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_anim_simple_demo)
        // 文件加载完成后会调用init方法
        loadFile()
    }

    private fun init() {
        // 初始化日志
        initLog()
        // 初始化调试开关
        initTestView()
        // 获取动画view
        animView = playerView
        // 居中（根据父布局按比例居中并裁剪）
        animView.setScaleType(ScaleType.CENTER_CROP)
        /**
         * 注册资源获取类
         */
        animView.setFetchResource(object : IFetchResource {
            /**
             * 获取图片资源
             * 无论图片是否获取成功都必须回调 result 否则会无限等待资源
             */
            override fun fetchImage(resource: Resource, result: (Bitmap?) -> Unit) {
                /**
                 * srcTag是素材中的一个标记，在制作素材时定义
                 * 解析时由业务读取tag决定需要播放的内容是什么
                 * 比如：一个素材里需要显示多个头像，则需要定义多个不同的tag，表示不同位置，需要显示不同的头像，文字类似
                 */
                val srcTag = resource.tag
                if (srcTag.isNotEmpty()) {
                    val drawableId = if (head1Img) R.drawable.head1 else R.drawable.head2
                    head1Img = !head1Img
                    val options = BitmapFactory.Options()
                    options.inScaled = false
                    result(BitmapFactory.decodeResource(resources, drawableId, options))
                } else {
                    result(null)
                }
            }

            /**
             * 获取文字资源
             */
            override fun fetchText(resource: Resource, result: (String?) -> Unit) {
                val str = "恭喜 No.${1000 + Random().nextInt(8999)}用户 升神"
                val srcTag = resource.tag
                if (srcTag.isNotEmpty()) { // 此tag是已经写入到动画配置中的tag
                    result(str)
                } else {
                    result(null)
                }
            }

            /**
             * 播放完毕后的资源回收
             */
            override fun releaseResource(resources: List<Resource>) {
                resources.forEach {
                    it.bitmap?.recycle()
                }
            }
        })

        // 注册点击事件监听
        animView.setOnResourceClickListener(object : OnResourceClickListener {
            override fun onClick(resource: Resource) {
                lastToast?.cancel()
                lastToast = Toast.makeText(
                    this@AnimVapxDemoActivity,
                    "srcTag=${resource.tag} onClick ${resource.curPoint}",
                    Toast.LENGTH_LONG
                )
                lastToast?.show()
            }
        })

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


    private fun initTestView() {
        btnLayout.visibility = View.VISIBLE
        /**
         * 开始播放按钮
         */
        btnPlay.setOnClickListener {
            play(videoInfo)
        }
        /**
         * 结束视频按钮
         */
        btnStop.setOnClickListener {
            animView.stopPlay()
        }
    }

    private fun loadFile() {
        val files = Array(1) {
            videoInfo.fileName
        }
        FileUtil.copyAssetsToStorage(this, dir, files) {
            uiHandler.post {
                init()
            }
        }
    }


    private fun dp2px(context: Context, dp: Float): Float {
        val scale = context.resources.displayMetrics.density
        return dp * scale + 0.5f
    }
}

