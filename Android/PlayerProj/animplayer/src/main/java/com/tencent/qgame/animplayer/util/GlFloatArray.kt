/*
 * Tencent is pleased to support the open source community by making vap available.
 *
 * Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * Licensed under the MIT License (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 *
 * http://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.tencent.qgame.animplayer.util

import android.opengl.GLES20
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer
import kotlin.FloatArray

class GlFloatArray {


    val array = FloatArray(8)

    private var floatBuffer: FloatBuffer

    init {
        floatBuffer = ByteBuffer
            .allocateDirect(array.size * 4)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()
            .put(array)
    }

    fun setArray(array: FloatArray) {
        floatBuffer.position(0)
        floatBuffer.put(array)
    }


    fun setVertexAttribPointer(attributeLocation: Int) {
        floatBuffer.position(0)
        GLES20.glVertexAttribPointer(attributeLocation, 2, GLES20.GL_FLOAT, false, 0, floatBuffer)
        GLES20.glEnableVertexAttribArray(attributeLocation)
    }
}