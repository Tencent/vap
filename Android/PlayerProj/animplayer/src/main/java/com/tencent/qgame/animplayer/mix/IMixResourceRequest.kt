package com.tencent.qgame.animplayer.mix

interface IMixResourceRequest {
    fun fetchResource(): Int
    fun destroy()
}