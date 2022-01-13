package com.tencent.qgame.animplayer.util

import android.graphics.Bitmap
import android.opengl.GLES20
import android.os.Environment
import android.util.Log
import com.tencent.qgame.animplayer.CacheBuffer
import java.io.BufferedOutputStream
import java.io.FileOutputStream
import java.io.IOException
import java.nio.ByteBuffer

/**
 * Date： 2022/1/12
 * Time: 1:58 下午
 * Author: jeoffery
 * Description :
 */

/**
 * 检查GL错误
 */
fun checkGLError(extMsg: String? = "none") {
    var error: Int
    if (GLES20.glGetError().also { error = it } != GLES20.GL_NO_ERROR) {
        ALog.e("CheckGLError", "extMsg: $extMsg, >> ERROR: $error <<")
    }
}

private var rgbaBuf: ByteBuffer? = null
private var index = 0

@Synchronized
fun saveRgb2Bitmap(frameIndex: IntArray, width: Int, height: Int, msg: String)
{
    if (frameIndex.contains(index)) {
        if (null == rgbaBuf) {
            rgbaBuf = ByteBuffer.allocateDirect(width * height * 4)
        }
        rgbaBuf?.let {
            it.position(0)
            val start = System.nanoTime()
            GLES20.glReadPixels(0, 0, width, height, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, rgbaBuf)
            val end = System.nanoTime()
            Log.d(CacheBuffer.TAG, "glReadPixels: " + (end - start))

            Log.d(CacheBuffer.TAG, "saveRgb2Bitmap: msg: $msg,  index = $index")
            var bos: BufferedOutputStream? = null
            try {
                bos = BufferedOutputStream(FileOutputStream(Environment.getExternalStorageDirectory().absolutePath + "/AAVapTest/" + "$index" + "_$msg.png"))
                val bmp = Bitmap.createBitmap (width, height, Bitmap.Config.ARGB_8888)
                bmp.copyPixelsFromBuffer(it)
                bmp.compress(Bitmap.CompressFormat.PNG, 90, bos)
                bmp.recycle()
            } catch (e: IOException) {
                e.printStackTrace()
                Log.e(CacheBuffer.TAG, "saveRgb2Bitmap: $e")
            } finally {
                if (bos != null) {
                    try {
                        bos.close()
                    } catch (e: IOException) {
                        e.printStackTrace()
                        Log.e(CacheBuffer.TAG, "saveRgb2Bitmap: $e")
                    }
                }
            }
        }
    }

}

fun updateSave2BitmapIndex() {
    index++
}

fun resetSave2Bitmap() {
    index = -1
    rgbaBuf?.clear()
    rgbaBuf = null
}