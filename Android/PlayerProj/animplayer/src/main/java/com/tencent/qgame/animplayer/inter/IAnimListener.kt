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
package com.tencent.qgame.animplayer.inter

import com.tencent.qgame.animplayer.AnimConfig

interface IAnimListener {

    /**
     * 配置准备好后回调
     * ps:如果是默认配置(没有发现vapc配置)，因为信息不完整onVideoConfigReady不会被调用，默认播放
     * @return true 继续播放 false 结束播放
     */
    fun onVideoConfigReady(config: AnimConfig): Boolean {
        return true // 默认继续播放
    }

    /**
     * 开始播放
     */
    fun onVideoStart()


    /**
     * 视频渲染每一帧时的回调
     * @param frameIndex 帧索引
     */
    fun onVideoRender(frameIndex: Int, config: AnimConfig?)

    /**
     * 视频播放结束
     */
    fun onVideoComplete()

    /**
     * 视频被销毁
     */
    fun onVideoDestroy()

    /**
     * 失败回调
     * @param errorType 错误类型
     * @param errorMsg 错误消息
     */
    fun onFailed(errorType: Int, errorMsg: String?)
}