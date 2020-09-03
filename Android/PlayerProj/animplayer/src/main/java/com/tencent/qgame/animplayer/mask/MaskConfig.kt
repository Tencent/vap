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
package com.tencent.qgame.animplayer.mask

import android.graphics.Bitmap
import com.tencent.qgame.animplayer.PointRect
import com.tencent.qgame.animplayer.RefVec2
import com.tencent.qgame.animplayer.util.TextureLoadUtil

class MaskConfig() {
    var maskTexPair: Pair<PointRect, RefVec2>? = null //遮罩坐标矩形
    var maskPositionPair: Pair<PointRect, RefVec2>? = null //内容坐标矩形

    constructor(bitmap: Bitmap?, positionPair :Pair<PointRect, RefVec2>?, texPair: Pair<PointRect, RefVec2>?) : this() {
        maskPositionPair = positionPair
        maskTexPair = texPair
        alphaMaskBitmap = bitmap
    }

    private var maskTexId = 0
    fun getMaskTexId() : Int {
        return maskTexId
    }
    fun updateMaskTex() : Int {
        maskTexId = TextureLoadUtil.loadTexture(alphaMaskBitmap)
        return  maskTexId
    }

    var alphaMaskBitmap: Bitmap? = null //遮罩
        private set(value) {
            field = value
        }
    
    fun safeSetMaskBitmapAndReleasePre(bitmap: Bitmap?) {
        if (maskTexId > 0)  { //释放
            TextureLoadUtil.releaseTexure(maskTexId)
            maskTexId = 0
        }
        alphaMaskBitmap = bitmap
    }
    

    fun release() {
        alphaMaskBitmap = null
        maskTexPair = null
        maskPositionPair = null
    }

    override fun equals(other: Any?): Boolean {
        return other is MaskConfig && this.alphaMaskBitmap != other.alphaMaskBitmap
                && this.maskTexPair?.first != other.maskTexPair?.first && this.maskTexPair?.second != other.maskTexPair?.second
                && this.maskPositionPair?.first != other.maskPositionPair?.first && this.maskPositionPair?.second != other.maskPositionPair?.second
    }

    override fun hashCode(): Int {
        var result = alphaMaskBitmap?.hashCode() ?: 0
        result = 31 * result + (maskTexPair?.hashCode() ?: 0)
        result = 31 * result + (maskPositionPair?.hashCode() ?: 0)
        return result
    }
}