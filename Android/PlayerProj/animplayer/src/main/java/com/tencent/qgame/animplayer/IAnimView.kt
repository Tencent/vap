package com.tencent.qgame.animplayer

import android.content.res.AssetManager
import android.graphics.SurfaceTexture
import com.tencent.qgame.animplayer.inter.IAnimListener
import com.tencent.qgame.animplayer.inter.IFetchResource
import com.tencent.qgame.animplayer.inter.OnResourceClickListener
import com.tencent.qgame.animplayer.mask.MaskConfig
import com.tencent.qgame.animplayer.util.IScaleType
import com.tencent.qgame.animplayer.util.ScaleType
import java.io.File

interface IAnimView {

    fun prepareTextureView()

    fun getSurfaceTexture(): SurfaceTexture?

    fun setAnimListener(animListener: IAnimListener?)

    fun setFetchResource(fetchResource: IFetchResource?)

    fun setOnResourceClickListener(resourceClickListener: OnResourceClickListener?)

    fun setLoop(playLoop: Int)

    fun supportMask(isSupport: Boolean, isEdgeBlur: Boolean)

    fun updateMaskConfig(maskConfig: MaskConfig?)

    fun setFps(fps: Int)

    fun setScaleType(type: ScaleType)

    fun setScaleType(scaleType: IScaleType)

    fun startPlay(file: File)

    fun startPlay(assetManager: AssetManager, assetsPath: String)

    fun startPlay(fileContainer: FileContainer)

    fun stopPlay()

    fun isRunning(): Boolean

    fun getRealSize(): Pair<Int, Int>
}
