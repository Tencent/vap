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
package com.tencent.qgame.animplayer

import android.content.res.AssetFileDescriptor
import android.content.res.AssetManager
import android.media.MediaExtractor
import java.io.File
import java.io.FileNotFoundException
import java.io.RandomAccessFile

open class FileContainer {

    private var isAssets = false

    private var file: File? = null
    private var randomAccessFile: RandomAccessFile? = null
    private var assetFd: AssetFileDescriptor? = null
    private var assetsInputStream: AssetManager.AssetInputStream? = null

    constructor(file: File) {
        isAssets = false
        this.file = file
        if (!(file.exists() && file.isFile && file.canRead())) throw FileNotFoundException("Unable to read $file")
    }

    constructor(assetManager: AssetManager, assetsPath: String) {
        isAssets = true
        assetFd = assetManager.openFd(assetsPath)
        assetsInputStream = assetManager.open(assetsPath, AssetManager.ACCESS_STREAMING) as AssetManager.AssetInputStream
    }


    fun setDataSource(extractor: MediaExtractor) {
        if (isAssets) {
            val assetFd = this.assetFd ?: return
            if (assetFd.declaredLength < 0) {
                extractor.setDataSource(assetFd.fileDescriptor)
            } else {
                extractor.setDataSource(assetFd.fileDescriptor, assetFd.startOffset, assetFd.declaredLength)
            }
        } else {
            val file = this.file ?: return
            extractor.setDataSource(file.toString())
        }
    }

    fun startRandomRead() {
        if (isAssets) return
        val file = this.file ?: return
        randomAccessFile = RandomAccessFile(file, "r")
    }

    fun read(b: ByteArray, off: Int, len: Int):Int {
        return if (isAssets) {
            assetsInputStream?.read(b, off, len) ?: -1
        } else {
            randomAccessFile?.read(b, off, len) ?: -1
        }
    }

    fun skip(pos: Long) {
        if (isAssets) {
            assetsInputStream?.skip(pos)
        } else {
            randomAccessFile?.skipBytes(pos.toInt())
        }
    }

    fun closeRandomRead() {
        if (isAssets) {
            assetsInputStream?.close()
        } else {
            randomAccessFile?.close()
        }
    }

    fun close() {
        if (isAssets) {
            assetFd?.close()
            assetsInputStream?.close()
        }
    }

}