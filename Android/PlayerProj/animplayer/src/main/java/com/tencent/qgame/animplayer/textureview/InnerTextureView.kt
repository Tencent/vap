package com.tencent.qgame.animplayer.textureview

import android.content.Context
import android.util.AttributeSet
import android.view.MotionEvent
import android.view.TextureView
import com.tencent.qgame.animplayer.AnimPlayer

class InnerTextureView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : TextureView(context, attrs, defStyleAttr) {

    var player: AnimPlayer? = null

    override fun dispatchTouchEvent(ev: MotionEvent?): Boolean {
        val res = player?.isRunning() == true
                && ev != null
                && player?.pluginManager?.onDispatchTouchEvent(ev) == true
        return if (!res) super.dispatchTouchEvent(ev) else true
    }
}