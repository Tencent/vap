package com.tencent.qgame.animplayer

import android.graphics.Bitmap
import android.opengl.GLES11Ext
import android.opengl.GLES20
import android.os.Environment
import android.util.Log
import com.tencent.qgame.animplayer.util.*
import android.util.DisplayMetrics

import android.view.WindowManager
import java.io.BufferedOutputStream
import java.io.FileOutputStream
import java.io.IOException
import java.nio.ByteBuffer


/**
 * Date： 2022/1/11
 * Time: 3:00 下午
 * Author: jeoffery
 * Description :
 */
class CacheBuffer {

    companion object {
        const val TAG = "CacheBuffer"
    }

    private val vertexArray = GlFloatArray()
    private val alphaArray = GlFloatArray()
    private val rgbArray = GlFloatArray()
    private var shaderProgram = 0
    private var uTextureLocation: Int = 0
    private var aPositionLocation: Int = 0
    private var aTextureAlphaLocation: Int = 0
    private var aTextureRgbLocation: Int = 0

    private var width: Int = 0
    private var height: Int = 0

    // 输入纹理ID
    private var textureId = -1
    // FBO纹理ID
    private var fboTextureId = -1
    // 帧缓冲
    private var fboFrameBuffer: Int = -1

    fun setVertexArr(vertexArray: FloatArray) {
        ALog.d(TAG, "setVertexArr fbo : vertexArray: ${vertexArray.toList()}")
        this.vertexArray.setArray(vertexArray)
    }

    fun setTexArr(texRgbArray: FloatArray, texAlphaArray: FloatArray) {
        val fboTexRgbArr = texRgbArray.copyOf()
        val fboTexAlphaArr = texAlphaArray.copyOf()
        TexCoordsUtil.rotateE(fboTexRgbArr)
        TexCoordsUtil.rotateE(fboTexAlphaArr)
        ALog.d(TAG, "setTexArr fbo : fboTexRgbArr: ${fboTexRgbArr.toList()}")
        ALog.d(TAG, "setTexArr fbo : fboTexAlphaArr: ${fboTexAlphaArr.toList()}")
        this.rgbArray.setArray(fboTexRgbArr)
        this.alphaArray.setArray(fboTexAlphaArr)

    }

    /**
     * 初始化Catch FBO
     */
    fun init(textureId: Int) : Int {
        if (textureId < 1) {
            throw RuntimeException("CacheBuffer init ERROR: input textureId = $textureId")
            return -1
        }
        this.textureId = textureId

        shaderProgram = ShaderUtil.createProgram(RenderConstant.VERTEX_SHADER, RenderConstant.FBO_FRAGMENT_SHADER)
        uTextureLocation = GLES20.glGetUniformLocation(shaderProgram, "texture")
        aPositionLocation = GLES20.glGetAttribLocation(shaderProgram, "vPosition")
        aTextureAlphaLocation = GLES20.glGetAttribLocation(shaderProgram, "vTexCoordinateAlpha")
        aTextureRgbLocation = GLES20.glGetAttribLocation(shaderProgram, "vTexCoordinateRgb")

        // 创建纹理id
        val textures = IntArray(1)
        GLES20.glGenTextures(1, textures, 0)
        checkGLError("glGenTextures mFboTextureId")
        fboTextureId = textures[0]
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, fboTextureId)
        checkGLError("glBindTexture mFboTextureId")
        // 配置边缘过渡参数
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MIN_FILTER, GLES20.GL_NEAREST.toFloat())
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_MAG_FILTER,GLES20.GL_LINEAR.toFloat())
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_S,GLES20.GL_CLAMP_TO_EDGE.toFloat())
        GLES20.glTexParameterf(GLES20.GL_TEXTURE_2D, GLES20.GL_TEXTURE_WRAP_T,GLES20.GL_CLAMP_TO_EDGE.toFloat())
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, GLES20.GL_NONE)

        // 创建frameBuffer
        val fbs = IntArray(1)
        GLES20.glGenFramebuffers(1, fbs, 0)
        fboFrameBuffer = fbs[0]

        return fboTextureId
    }

    /**
     * 根据宽高生成纹理
     */
    fun genCatch(width: Int, height: Int) {
        ALog.d(TAG, "genCatch: $width x $height")
        this.width = width
        this.height = height
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, fboFrameBuffer)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, fboTextureId)
        GLES20.glFramebufferTexture2D(GLES20.GL_FRAMEBUFFER, GLES20.GL_COLOR_ATTACHMENT0, GLES20.GL_TEXTURE_2D, fboTextureId, 0)
        GLES20.glTexImage2D(GLES20.GL_TEXTURE_2D, 0, GLES20.GL_RGBA, width, height, 0, GLES20.GL_RGBA, GLES20.GL_UNSIGNED_BYTE, null)
        GLES20.glBindTexture(GLES20.GL_TEXTURE_2D, GLES20.GL_NONE)
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, GLES20.GL_NONE)
    }

    /**
     * 绘制外部纹理到FBO
     */
    fun draw() {
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, fboFrameBuffer)
        checkGLError("glBindFramebuffer drawFBO")
        GLES20.glUseProgram(shaderProgram)
        checkGLError("glUseProgram drawFBO")

        //激活指定纹理单元
        GLES20.glActiveTexture(GLES20.GL_TEXTURE0)
        checkGLError("glActiveTexture drawFBO")
        //绑定纹理ID到纹理单元
        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, textureId)
        checkGLError("glBindTexture drawFBO $textureId")
        //将激活的纹理单元传递到着色器里面
        GLES20.glUniform1i(uTextureLocation, 0)
        checkGLError("glUniform1i drawFBO")
        // 设置顶点坐标
        vertexArray.setVertexAttribPointer(aPositionLocation)
        // 设置纹理坐标
        alphaArray.setVertexAttribPointer(aTextureAlphaLocation)
        rgbArray.setVertexAttribPointer(aTextureRgbLocation)
        //开始绘制
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4)
        checkGLError("glDrawArrays drawFBO")

        // todo : 测试用，记得删
//        saveRgb2Bitmap(intArrayOf(230), width, height, "fbo")

        GLES20.glBindTexture(GLES11Ext.GL_TEXTURE_EXTERNAL_OES, 0)
        checkGLError("glBindTexture 0 drawFBO")
        GLES20.glBindFramebuffer(GLES20.GL_FRAMEBUFFER, 0)
        checkGLError("glBindFramebuffer 0 drawFBO")
    }

}