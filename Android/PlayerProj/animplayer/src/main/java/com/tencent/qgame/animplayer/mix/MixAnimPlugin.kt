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

import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.AnimPlayer
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.inter.IFetchResource
import com.tencent.qgame.animplayer.inter.OnResourceClickListener
import com.tencent.qgame.animplayer.plugin.IAnimPlugin
import com.tencent.qgame.animplayer.util.ALog

class MixAnimPlugin(val player: AnimPlayer): IAnimPlugin {

    companion object {
        private const val TAG = "${Constant.TAG}.MixAnimPlugin"
    }
    var resourceRequest: IFetchResource? = null
    var resourceClickListener: OnResourceClickListener? = null
    var srcMap: SrcMap? = null
    var frameAll: FrameAll? = null
    var curFrameIndex = -1 // 当前帧
    private var mixRender:MixRender? = null
    private val mixTouch by lazy { MixTouch(this) }
    var autoTxtColorFill = true // 是否启动自动文字填充 默认开启

    var async: Boolean = false
    private var mixResourceRequest: IMixResourceRequest? = null

    override fun onConfigCreate(config: AnimConfig): Int {
        if (!config.isMix) return Constant.OK
        if (resourceRequest == null) {
            ALog.e(TAG, "IFetchResource is empty")
            // 没有设置IFetchResource 当成普通视频播放
            return Constant.OK
        }
        // step 1 parse src
        parseSrc(config)

        // step 2 parse frame
        parseFrame(config)

        mixResourceRequest = createMixResourceRequest()
        return mixResourceRequest?.fetchResource() ?: Constant.OK
    }

    private fun createMixResourceRequest(): IMixResourceRequest {
        return if (async) {
            MixResourceRequestASync(resourceRequest, srcMap)
        } else {
            MixResourceRequestSync(resourceRequest, srcMap)
        }
    }

    override fun onRenderCreate() {
        if (player.configManager.config?.isMix == false) return
        ALog.i(TAG, "mix render init")
        mixRender = MixRender(this)
        mixRender?.init()
    }

    override fun onRendering(frameIndex: Int) {
        val config = player.configManager.config ?: return
        if (!config.isMix) return
        curFrameIndex = frameIndex
        val list = frameAll?.map?.get(frameIndex)?.list ?: return
        list.forEach {frame ->
            val src = srcMap?.map?.get(frame.srcId) ?: return@forEach
            mixRender?.renderFrame(config, frame, src)
        }
    }


    override fun onRelease() {
        destroy()
    }

    override fun onDestroy() {
        destroy()
    }

    override fun onDispatchTouchEvent(ev: MotionEvent): Boolean {
        if (player.configManager.config?.isMix == false || resourceClickListener == null) {
            return super.onDispatchTouchEvent(ev)
        }
        mixTouch.onTouchEvent(ev)?.let {resource ->
            Handler(Looper.getMainLooper()).post {
                resourceClickListener?.onClick(resource)
            }
        }
        // 只要注册监听则拦截所有事件
        return true
    }

    private fun destroy() {
        mixResourceRequest?.destroy()
        if (player.configManager.config?.isMix == false) return
        val resources = ArrayList<Resource>()
        srcMap?.map?.values?.forEach {src ->
            mixRender?.release(src.srcTextureId)
            when(src.srcType) {
                Src.SrcType.IMG -> resources.add(Resource(src))
                Src.SrcType.TXT -> src.bitmap?.recycle()
                else -> {}
            }
        }
        resourceRequest?.releaseResource(resources)

        // 清理
        curFrameIndex = -1
        srcMap?.map?.clear()
        frameAll?.map?.clear()
    }

    private fun parseSrc(config: AnimConfig) {
        config.jsonConfig?.apply {
            srcMap = SrcMap(this)
        }
    }


    private fun parseFrame(config: AnimConfig) {
        config.jsonConfig?.apply {
            frameAll = FrameAll(this)
        }
    }

}