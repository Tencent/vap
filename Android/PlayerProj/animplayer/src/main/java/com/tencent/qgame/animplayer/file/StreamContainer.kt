package com.tencent.qgame.animplayer.file

import android.annotation.TargetApi
import android.media.MediaExtractor
import android.os.Build
import java.io.ByteArrayInputStream

@TargetApi(Build.VERSION_CODES.M)
class StreamContainer(private val bytes: ByteArray) : IFileContainer {

    private var stream: ByteArrayInputStream = ByteArrayInputStream(bytes)

    override fun setDataSource(extractor: MediaExtractor) {
        val dataSource = StreamMediaDataSource(bytes)
        extractor.setDataSource(dataSource)
    }

    override fun startRandomRead() {
    }

    override fun read(b: ByteArray, off: Int, len: Int): Int {
        return stream.read(b, off, len)
    }

    override fun skip(pos: Long) {
        stream.skip(pos)
    }

    override fun closeRandomRead() {
    }

    override fun close() {
        stream.close()
    }
}
