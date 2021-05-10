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

    fun setYUVData(width: Int, height: Int, y: ByteArray?, uv: ByteArray?) {}
}