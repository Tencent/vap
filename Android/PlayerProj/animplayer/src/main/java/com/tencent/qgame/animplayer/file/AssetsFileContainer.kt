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

import android.content.res.AssetFileDescriptor
import android.content.res.AssetManager
import android.media.MediaExtractor
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.util.ALog

class AssetsFileContainer(assetManager: AssetManager, assetsPath: String): IFileContainer {

    companion object {
        private const val TAG = "${Constant.TAG}.FileContainer"
    }

    private val assetFd: AssetFileDescriptor = assetManager.openFd(assetsPath)
    private val assetsInputStream: AssetManager.AssetInputStream =
        assetManager.open(assetsPath, AssetManager.ACCESS_STREAMING) as AssetManager.AssetInputStream

    init {
        ALog.i(TAG, "AssetsFileContainer init")
    }

    override fun setDataSource(extractor: MediaExtractor) {
        if (assetFd.declaredLength < 0) {
            extractor.setDataSource(assetFd.fileDescriptor)
        } else {
            extractor.setDataSource(assetFd.fileDescriptor, assetFd.startOffset, assetFd.declaredLength)
        }
    }

    override fun startRandomRead() {
    }

    override fun read(b: ByteArray, off: Int, len: Int): Int {
        return assetsInputStream.read(b, off, len)
    }

    override fun skip(pos: Long) {
        assetsInputStream.skip(pos)
    }

    override fun closeRandomRead() {
        assetsInputStream.close()
    }

    override fun close() {
        assetFd.close()
        assetsInputStream.close()
    }
}