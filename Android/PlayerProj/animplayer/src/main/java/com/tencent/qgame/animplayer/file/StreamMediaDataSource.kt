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
package com.tencent.qgame.animplayer.file

import android.annotation.TargetApi
import android.media.MediaDataSource
import android.os.Build

@TargetApi(Build.VERSION_CODES.M)
class StreamMediaDataSource(val bytes: ByteArray) : MediaDataSource() {

    override fun close() {
    }

    override fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int {
        var newSize = size
        synchronized(StreamMediaDataSource::class) {
            val length = bytes.size
            if (position >= length) {
                return -1
            }
            if (position + newSize > length) {
                newSize -= (position + newSize).toInt() - length
            }
            System.arraycopy(bytes, position.toInt(), buffer, offset, newSize)
            return newSize
        }

    }

    override fun getSize(): Long {
        synchronized(StreamMediaDataSource::class) {
            return bytes.size.toLong()
        }
    }
}
