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
package com.tencent.qgame.animplayer.util

import com.tencent.qgame.animplayer.PointRect

/**
 * 纹理坐标工具
 * 坐标顺序是倒N
 */
object TexCoordsUtil {

    /**
     * @param width 纹理的宽高
     * @param height
     */
    fun create(width: Int, height: Int, rect: PointRect, array: FloatArray): FloatArray {

        // x0
        array[0] = rect.x.toFloat() / width
        // y0
        array[1] = rect.y.toFloat() / height

        // x1
        array[2] = rect.x.toFloat() / width
        // y1
        array[3] = (rect.y.toFloat() + rect.h) / height

        // x2
        array[4] = (rect.x.toFloat() + rect.w) / width
        // y2
        array[5] = rect.y.toFloat() / height

        // x3
        array[6] = (rect.x.toFloat() + rect.w) / width
        // y3
        array[7] = (rect.y.toFloat() + rect.h) / height

        return array
    }




    /**
     * 顺时针90度
     */
    fun rotate90(array: FloatArray): FloatArray {
        // 0->2 1->0 3->1 2->3
        val tx = array[0]
        val ty = array[1]

        // 1->0
        array[0] = array[2]
        array[1] = array[3]

        // 3->1
        array[2] = array[6]
        array[3] = array[7]

        // 2->3
        array[6] = array[4]
        array[7] = array[5]

        // 0->2
        array[4] = tx
        array[5] = ty
        return array
    }

}