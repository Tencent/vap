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
 * 顶点坐标工具
 * 坐标顺序是倒N
 */
object VertexUtil {

    /**
     * @param width 画布大大小
     * @param height
     */
    fun create(width: Int, height: Int, rect: PointRect, array: FloatArray): FloatArray {

        // x0
        array[0] = switchX(rect.x.toFloat() / width)
        // y0
        array[1] = switchY(rect.y.toFloat() / height)

        // x1
        array[2] = switchX(rect.x.toFloat() / width)
        // y1
        array[3] = switchY((rect.y.toFloat() + rect.h) / height)

        // x2
        array[4] = switchX((rect.x.toFloat() + rect.w) / width)
        // y2
        array[5] = switchY(rect.y.toFloat() / height)

        // x3
        array[6] = switchX((rect.x.toFloat() + rect.w) / width)
        // y3
        array[7] = switchY((rect.y.toFloat() + rect.h) / height)

        return array
    }


    private fun switchX(x: Float): Float {
        return x * 2f -1f
    }

    private fun switchY(y: Float): Float {
        return ((y * 2f - 2f) * -1f) - 1f
    }

}