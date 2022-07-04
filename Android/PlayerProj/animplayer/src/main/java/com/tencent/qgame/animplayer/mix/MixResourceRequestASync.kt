package com.tencent.qgame.animplayer.mix

import android.graphics.Bitmap
import android.os.Handler
import android.os.SystemClock
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.inter.IFetchResource
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.BitmapUtil
import com.tencent.qgame.animplayer.util.TextureLoadUtil


class MixResourceRequestASync(
    private val resourceRequest: IFetchResource?,
    private val srcMap: SrcMap?
) :
    IMixResourceRequest {
    companion object {
        private const val TAG = "${Constant.TAG}.MixResourceRequestASync"
    }

    private var resultCbCount = 0 // 回调次数

    var handler: Handler? = null

    override fun fetchResource(): Int {
        fetchResourceASync()

        ALog.i(TAG, "load resource $resultCbCount")
        srcMap?.map?.values?.forEach {
            if (it.bitmap?.config == Bitmap.Config.ALPHA_8) {
                ALog.e(TAG, "src $it bitmap must not be ALPHA_8")
                return Constant.REPORT_ERROR_TYPE_CONFIG_PLUGIN_MIX
            }
        }
        return Constant.OK
    }

    override fun destroy() {
        handler = null
    }

    private fun fetchResourceASync() {
        val time = SystemClock.elapsedRealtime()
        val totalSrc = srcMap?.map?.size ?: 0
        ALog.i(TAG, "load resource totalSrc = $totalSrc")

        resultCbCount = 0
        srcMap?.map?.values?.apply {
            handler = Handler()
            forEach { src ->
                if (src.srcType == Src.SrcType.IMG) {
                    ALog.i(TAG, "fetch image ${src.srcId}")
                    resourceRequest?.fetchImage(Resource(src)) {
                        handler?.post {
                            src.bitmap = if (it == null) {
                                ALog.e(TAG, "fetch image ${src.srcId} bitmap return null")
                                BitmapUtil.createEmptyBitmap()
                            } else it
                            src.srcTextureId = TextureLoadUtil.loadTexture(src.bitmap)
                            ALog.i(
                                TAG,
                                "fetch image ${src.srcId} finish bitmap is ${it?.hashCode()}"
                                        + "，cost=${SystemClock.elapsedRealtime() - time}ms"
                            )
                            resultCall()
                        }
                    }
                } else if (src.srcType == Src.SrcType.TXT) {
                    ALog.i(TAG, "fetch txt ${src.srcId}")
                    resourceRequest?.fetchText(Resource(src)) {
                        handler?.post {
                            src.txt = it ?: ""
                            try {
                                src.bitmap = BitmapUtil.createTxtBitmap(src)
                                src.srcTextureId = TextureLoadUtil.loadTexture(src.bitmap)
                            } catch (e: OutOfMemoryError) {
                                ALog.e(TAG, "draw text OOM $e", e)
                            }
                            ALog.i(
                                TAG, "fetch text ${src.srcId} finish txt is $it"
                                        + "，cost=${SystemClock.elapsedRealtime() - time}ms"
                            )
                            resultCall()
                        }
                    }
                }
            }
        }
    }

    private fun resultCall() {
        resultCbCount++
    }

}
