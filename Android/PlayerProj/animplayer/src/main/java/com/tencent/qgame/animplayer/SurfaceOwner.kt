package com.tencent.qgame.animplayer

import android.graphics.SurfaceTexture

interface SurfaceOwner {
    val width: Int
    val height: Int

    fun getSurfaceTexture(): SurfaceTexture?
    fun prepareTextureView()
}