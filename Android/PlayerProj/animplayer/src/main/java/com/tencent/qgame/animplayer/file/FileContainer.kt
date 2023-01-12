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

import android.media.MediaExtractor
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.util.ALog
import java.io.File
import java.io.FileNotFoundException
import java.io.RandomAccessFile

class FileContainer(private val file: File) : IFileContainer {

    companion object {
        private const val TAG = "${Constant.TAG}.FileContainer"
    }

    private var randomAccessFile: RandomAccessFile? = null

    init {
        ALog.i(TAG, "FileContainer init")
        if (!(file.exists() && file.isFile && file.canRead())) throw FileNotFoundException("Unable to read $file")
    }

    override fun setDataSource(extractor: MediaExtractor) {
        extractor.setDataSource(file.toString())
    }

    override fun startRandomRead() {
        randomAccessFile = RandomAccessFile(file, "r")
    }

    override fun read(b: ByteArray, off: Int, len: Int): Int {
        return randomAccessFile?.read(b, off, len) ?: -1
    }

    override fun skip(pos: Long) {
        randomAccessFile?.skipBytes(pos.toInt())
    }

    override fun closeRandomRead() {
        randomAccessFile?.close()
    }

    override fun close() {
    }
}