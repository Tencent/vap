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
}

class ScaleTypeFixXY : IScaleType {
    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
        layoutParams.height = ViewGroup.LayoutParams.MATCH_PARENT
        return layoutParams
    }
}

class ScaleTypeFixCenter : IScaleType {
    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        val (w, h) = getFixCenterSize(layoutWidth, layoutHeight, videoWidth, videoHeight)
        if (w <= 0 && h <= 0) return layoutParams
        layoutParams.width = w
        layoutParams.height = h
        layoutParams.gravity = Gravity.CENTER
        return layoutParams
    }

    private fun getFixCenterSize(
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
    override fun getLayoutParam(
        layoutWidth: Int,
        layoutHeight: Int,
        videoWidth: Int,
        videoHeight: Int,
        layoutParams: FrameLayout.LayoutParams
    ): FrameLayout.LayoutParams {
        val (w, h) = getCenterCropSize(layoutWidth, layoutHeight, videoWidth, videoHeight)
        if (w <= 0 && h <= 0) return layoutParams
        layoutParams.width = w
        layoutParams.height = h
        layoutParams.gravity = Gravity.CENTER
        return layoutParams
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

    private val scaleTypeFitXY by lazy { ScaleTypeFixXY() }
    private val scaleTypeFitCenter by lazy { ScaleTypeFixCenter() }
    private val scaleTypeCenterCrop by lazy { ScaleTypeCenterCrop() }

    var currentScaleType = ScaleType.FIT_XY
    var scaleTypeImpl: IScaleType? = null

    var layoutWidth = 0
    var layoutHeight = 0

    var videoWidth = 0
    var videoHeight = 0


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

        var tmpScaleType = scaleTypeImpl
        if (tmpScaleType != null) {
            ALog.i(TAG, "custom scaleType")
            return tmpScaleType.getLayoutParam(
                layoutWidth,
                layoutHeight,
                videoWidth,
                videoHeight,
                layoutParams
            )
        }
        ALog.i(TAG, "scaleType=$currentScaleType")
        tmpScaleType = when (currentScaleType) {
            ScaleType.FIT_XY -> scaleTypeFitXY
            ScaleType.FIT_CENTER -> scaleTypeFitCenter
            ScaleType.CENTER_CROP -> scaleTypeCenterCrop
        }
        tmpScaleType.getLayoutParam(
            layoutWidth,
            layoutHeight,
            videoWidth,
            videoHeight,
            layoutParams
        )
        return layoutParams
    }


    private fun checkParams(): Boolean {
        return layoutWidth > 0
                && layoutHeight > 0
                && videoWidth > 0
                && videoHeight > 0
    }

}