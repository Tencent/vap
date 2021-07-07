package com.ourydc.yuebaobao.engine.vap

import android.media.MediaExtractor
import android.os.Build
import androidx.annotation.RequiresApi
import com.ourydc.yuebaobao.util.InputStreamUtils
import com.tencent.qgame.animplayer.file.IFileContainer
import java.io.InputStream

@RequiresApi(Build.VERSION_CODES.M)
class StreamContainer(val bytes: ByteArray) : IFileContainer {

    private var stream: InputStream? = InputStreamUtils.byteTOInputStream(bytes)

    override fun setDataSource(extractor: MediaExtractor) {
        val dataSource = StreamMediaDataSource(bytes)
        extractor.setDataSource(dataSource)
    }

    override fun startRandomRead() {
    }

    override fun read(b: ByteArray, off: Int, len: Int): Int {
        return stream?.read(b, off, len) ?: 0
    }

    override fun skip(pos: Long) {
        stream?.skip(pos)
    }

    override fun closeRandomRead() {
        stream?.close()
    }

    override fun close() {
        stream?.close()
        stream = null
    }
}
