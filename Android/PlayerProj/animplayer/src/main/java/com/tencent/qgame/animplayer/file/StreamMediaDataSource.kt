package com.tencent.qgame.animplayer.file

import android.media.MediaDataSource
import android.os.Build
import androidx.annotation.RequiresApi

@RequiresApi(Build.VERSION_CODES.M)
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
