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

interface IRenderListener {

    /**
     * 初始化渲染环境，获取shader字段，创建绑定纹理
     */
    fun initRender()

    /**
     * 渲染上屏
     */
    fun renderFrame()

    fun clearFrame()

    /**
     * 释放纹理
     */
    fun destroyRender()

    /**
     * 设置视频配置
     */
    fun setAnimConfig(config: AnimConfig)

    /**
     * 显示区域大小变化
     */
    fun updateViewPort(width: Int, height: Int) {}

    fun getExternalTexture(): Int

    fun releaseTexture()

    fun swapBuffers()

    fun setYUVData(width: Int, height: Int, y: ByteArray?, u: ByteArray?, v: ByteArray?) {}
}