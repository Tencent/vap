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
package com.tencent.qgame.animplayer.plugin

import android.view.MotionEvent
import com.tencent.qgame.animplayer.AnimConfig
import com.tencent.qgame.animplayer.Constant

interface IAnimPlugin {

    // 配置生成
    fun onConfigCreate(config: AnimConfig): Int {
        return Constant.OK
    }

    // 渲染初始化
    fun onRenderCreate() {}

    // 解码通知
    fun onDecoding(decodeIndex: Int) {}

    // 每一帧渲染
    fun onRendering(frameIndex: Int) {}

    // 每次播放完毕
    fun onRelease() {}

    // 销毁
    fun onDestroy() {}

    /** 触摸事件
     * @return false 不拦截 true 拦截
     */
    fun onDispatchTouchEvent(ev: MotionEvent): Boolean {return false}
}