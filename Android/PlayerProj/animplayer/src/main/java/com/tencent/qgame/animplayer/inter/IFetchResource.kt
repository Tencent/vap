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

import android.graphics.Bitmap
import com.tencent.qgame.animplayer.mix.Resource

/**
 * 获取资源
 */
interface IFetchResource {
    // 获取图片 (暂时不支持Bitmap.Config.ALPHA_8 主要是因为一些机型opengl兼容问题)
    fun fetchImage(resource: Resource, result:(Bitmap?) -> Unit)

    // 获取文字
    fun fetchText(resource: Resource, result:(String?) -> Unit)

    // 资源释放通知
    fun releaseResource(resources: List<Resource>)
}