package com.tencent.qgame.animplayer.mix

import android.graphics.Bitmap
import android.os.SystemClock
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.inter.IFetchResource
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.BitmapUtil

class MixResourceRequestSync(
    private val resourceRequest: IFetchResource?,
    private val srcMap: SrcMap?
) :
    IMixResourceRequest {
    companion object {
        private const val TAG = "${Constant.TAG}.MixResourceRequestSync"
    }

    private var resultCbCount = 0 // 回调次数

    // 同步锁
    private val lock = Object()
    private var forceStopLock = false


    override fun fetchResource(): Int {
        // step 3 fetch resource
        fetchResourceSync()

        // step 4 生成文字bitmap
        val result = createBitmap()
        if (!result) {
            return Constant.REPORT_ERROR_TYPE_CONFIG_PLUGIN_MIX
        }

        // step 5 check resource
        ALog.i(TAG, "load resource $resultCbCount")
        srcMap?.map?.values?.forEach {
            if (it.bitmap == null) {
                ALog.e(TAG, "missing src $it")
                return Constant.REPORT_ERROR_TYPE_CONFIG_PLUGIN_MIX
            } else if (it.bitmap?.config == Bitmap.Config.ALPHA_8) {
                ALog.e(TAG, "src $it bitmap must not be ALPHA_8")
                return Constant.REPORT_ERROR_TYPE_CONFIG_PLUGIN_MIX
            }
        }
        return Constant.OK
    }

    override fun destroy() {
        // 强制结束等待
        forceStopLockThread()
    }

    private fun fetchResourceSync() {
        synchronized(lock) {
            forceStopLock = false // 开始时不会强制关闭
        }
        val time = SystemClock.elapsedRealtime()
        val totalSrc = srcMap?.map?.size ?: 0
        ALog.i(TAG, "load resource totalSrc = $totalSrc")

        resultCbCount = 0
        srcMap?.map?.values?.forEach {src ->
            if (src.srcType == Src.SrcType.IMG) {
                ALog.i(TAG, "fetch image ${src.srcId}")
                resourceRequest?.fetchImage(Resource(src)) {
                    src.bitmap = if (it == null) {
                        ALog.e(TAG, "fetch image ${src.srcId} bitmap return null")
                        BitmapUtil.createEmptyBitmap()
                    } else it
                    ALog.i(TAG, "fetch image ${src.srcId} finish bitmap is ${it?.hashCode()}")
                    resultCall()
                }
            } else if (src.srcType == Src.SrcType.TXT) {
                ALog.i(TAG, "fetch txt ${src.srcId}")
                resourceRequest?.fetchText(Resource(src)) {
                    src.txt = it ?: ""
                    ALog.i(TAG, "fetch text ${src.srcId} finish txt is $it")
                    resultCall()
                }
            }
        }

        // 同步等待所有资源完成
        synchronized(lock) {
            while (resultCbCount < totalSrc && !forceStopLock) {
                lock.wait()
            }
        }
        ALog.i(TAG, "fetchResourceSync cost=${SystemClock.elapsedRealtime() - time}ms")
    }

    private fun forceStopLockThread() {
        synchronized(lock) {
            forceStopLock = true
            lock.notifyAll()
        }
    }

    private fun resultCall() {
        synchronized(lock) {
            resultCbCount++
            lock.notifyAll()
        }
    }

    private fun createBitmap(): Boolean {
        return try {
            srcMap?.map?.values?.forEach { src ->
                if (src.srcType == Src.SrcType.TXT) {
                    src.bitmap = BitmapUtil.createTxtBitmap(src)
                }
            }
            true
        } catch (e: OutOfMemoryError) {
            ALog.e(TAG, "draw text OOM $e", e)
            false
        }
    }

}