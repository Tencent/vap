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

import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import com.tencent.qgame.animplayer.Constant


enum class ScaleType {
    FIT_XY, // 完整填充整个布局 default
    FIT_CENTER, // 按视频比例在布局中间完整显示
    CENTER_CROP, // 按视频比例完整填充布局（多余部分不显示）
}

interface IScaleType {

    fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams

    fun getRealSize(): Pair<Int, Int>
}

class ScaleTypeFitXY : IScaleType {

    private var realWidth = 0
    private var realHeight = 0

    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
        realWidth = layoutWidth
        realHeight = layoutHeight
        return layoutParams
    }

    override fun getRealSize(): Pair<Int, Int> {
        return Pair(realWidth, realHeight)
    }
}

class ScaleTypeFitCenter : IScaleType {

    private var realWidth = 0
    private var realHeight = 0

    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        val (w, h) = getFitCenterSize(layoutWidth, layoutHeight, videoWidth, videoHeight)
        if (w <= 0 && h <= 0) return layoutParams
        realWidth = w
        realHeight = h
        layoutParams.width = w
        layoutParams.height = h
        layoutParams.gravity = Gravity.CENTER
        return layoutParams
    }

    override fun getRealSize(): Pair<Int, Int> {
        return Pair(realWidth, realHeight)
    }

    private fun getFitCenterSize(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int
    ): Pair<Int, Int> {

        val layoutRatio = layoutWidth.toFloat() / layoutHeight
        val videoRatio = videoWidth.toFloat() / videoHeight

        val realWidth: Int
        val realHeight: Int
        if (layoutRatio > videoRatio) {
            realHeight = layoutHeight
            realWidth = (videoRatio * realHeight).toInt()
        } else {
            realWidth = layoutWidth
            realHeight = (realWidth / videoRatio).toInt()
        }

        return Pair(realWidth, realHeight)
    }
}

class ScaleTypeCenterCrop : IScaleType {

    private var realWidth = 0
    private var realHeight = 0

    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        val (w, h) = getCenterCropSize(layoutWidth, layoutHeight, videoWidth, videoHeight)
        if (w <= 0 && h <= 0) return layoutParams
        realWidth = w
        realHeight = h
        layoutParams.width = w
        layoutParams.height = h
        layoutParams.gravity = Gravity.CENTER
        return layoutParams
    }

    override fun getRealSize(): Pair<Int, Int> {
        return Pair(realWidth, realHeight)
    }

    private fun getCenterCropSize(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int
    ): Pair<Int, Int> {

        val layoutRatio = layoutWidth.toFloat() / layoutHeight
        val videoRatio = videoWidth.toFloat() / videoHeight

        val realWidth: Int
        val realHeight: Int
        if (layoutRatio > videoRatio) {
            realWidth = layoutWidth
            realHeight = (realWidth / videoRatio).toInt()
        } else {
            realHeight = layoutHeight
            realWidth = (videoRatio * realHeight).toInt()
        }

        return Pair(realWidth, realHeight)
    }
}


class ScaleTypeUtil {

    companion object {
        private const val TAG = "${Constant.TAG}.ScaleTypeUtil"
    }

    private val scaleTypeFitXY by lazy { ScaleTypeFitXY() }
    private val scaleTypeFitCenter by lazy { ScaleTypeFitCenter() }
    private val scaleTypeCenterCrop by lazy { ScaleTypeCenterCrop() }
    private var layoutWidth = 0
    private var layoutHeight = 0
    private var videoWidth = 0
    private var videoHeight = 0

    var currentScaleType = ScaleType.FIT_XY
    var scaleTypeImpl: IScaleType? = null

    fun setLayoutSize(w: Int, h: Int) {
        layoutWidth = w
        layoutHeight = h
    }

    fun setVideoSize(w: Int, h: Int) {
        videoWidth = w
        videoHeight = h
    }

    /**
     * 获取实际视频容器宽高
     * @return w h
     */
    fun getRealSize(): Pair<Int, Int> {
        val size = getCurrentScaleType().getRealSize()
        ALog.i(TAG, "get real size (${size.first}, ${size.second})")
        return size
    }

    fun getLayoutParam(view: View?): FrameLayout.LayoutParams {
        val layoutParams = (view?.layoutParams as? FrameLayout.LayoutParams)
            ?: FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        if (!checkParams()) {
            ALog.e(
                TAG,
                "params error: layoutWidth=$layoutWidth, layoutHeight=$layoutHeight, videoWidth=$videoWidth, videoHeight=$videoHeight"
            )
            return layoutParams
        }

        return getCurrentScaleType().getLayoutParam(
            layoutWidth,
            layoutHeight,
            videoWidth,
            videoHeight,
            layoutParams
        )
    }

    private fun getCurrentScaleType(): IScaleType {
        val tmpScaleType = scaleTypeImpl
        return if (tmpScaleType != null) {
            ALog.i(TAG, "custom scaleType")
            tmpScaleType
        } else {
            ALog.i(TAG, "scaleType=$currentScaleType")
            when (currentScaleType) {
                ScaleType.FIT_XY -> scaleTypeFitXY
                ScaleType.FIT_CENTER -> scaleTypeFitCenter
                ScaleType.CENTER_CROP -> scaleTypeCenterCrop
            }
        }
    }


    private fun checkParams(): Boolean {
        return layoutWidth > 0
                && layoutHeight > 0
                && videoWidth > 0
                && videoHeight > 0
    }

}