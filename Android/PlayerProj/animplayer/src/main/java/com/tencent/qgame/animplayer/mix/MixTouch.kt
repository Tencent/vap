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

import android.view.MotionEvent
import com.tencent.qgame.animplayer.PointRect

/**
 * 触摸事件
 */
class MixTouch(private val mixAnimPlugin: MixAnimPlugin) {

    fun onTouchEvent(ev: MotionEvent): Resource? {
        val (viewWith, viewHeight) = mixAnimPlugin.player.animView.getRealSize()
        val videoWith = mixAnimPlugin.player.configManager.config?.width ?: return null
        val videoHeight = mixAnimPlugin.player.configManager.config?.height ?: return null

        if (viewWith == 0 || viewHeight == 0) return null

        when(ev.action) {
            MotionEvent.ACTION_UP -> {
                val x = ev.x * videoWith / viewWith.toFloat()
                val y = ev.y * videoHeight / viewHeight.toFloat()
                val list = mixAnimPlugin.frameAll?.map?.get(mixAnimPlugin.curFrameIndex)?.list
                list?.forEach {frame ->
                    val src = mixAnimPlugin.srcMap?.map?.get(frame.srcId) ?: return@forEach
                    if (calClick(x.toInt(), y.toInt(), frame.frame)) {
                        return Resource(src).apply {
                            curPoint = frame.frame
                        }
                    }
                }
            }
        }
        return null
    }


    private fun calClick(x: Int, y: Int, frame: PointRect): Boolean {
        return x >= frame.x && x <= (frame.x + frame.w)
                && y >= frame.y && y <= (frame.y + frame.h)
    }
}