package com.tencent.qgame.animplayer.util

import android.opengl.GLES20

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