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

import android.media.*
import com.tencent.qgame.animplayer.file.IFileContainer
import com.tencent.qgame.animplayer.util.ALog
import com.tencent.qgame.animplayer.util.MediaUtil
import java.lang.RuntimeException

class AudioPlayer(val player: AnimPlayer) {

    companion object {
        private const val TAG = "${Constant.TAG}.AudioPlayer"
    }

    var extractor: MediaExtractor? = null
    var decoder: MediaCodec? = null
    var audioTrack: AudioTrack? = null
    val decodeThread = HandlerHolder(null, null)
    var isRunning = false
    var playLoop = 0
    var isStopReq = false
    var needDestroy = false



    private fun prepareThread(): Boolean {
        return Decoder.createThread(decodeThread, "anim_audio_thread")
    }

    fun start(fileContainer: IFileContainer) {
        isStopReq = false
        needDestroy = false
        if (!prepareThread()) return
        if (isRunning) {
            stop()
        }
        isRunning = true
        decodeThread.handler?.post {
            try {
                startPlay(fileContainer)
            } catch (e: Throwable) {
                ALog.e(TAG, "Audio exception=$e", e)
                release()
            }
        }
    }

    fun stop() {
        isStopReq = true
    }

    private fun startPlay(fileContainer: IFileContainer) {
        val extractor = MediaUtil.getExtractor(fileContainer)
        this.extractor = extractor
        val audioIndex = MediaUtil.selectAudioTrack(extractor)
        if (audioIndex < 0) {
            ALog.e(TAG, "cannot find audio track")
            release()
            return
        }
        extractor.selectTrack(audioIndex)
        val format = extractor.getTrackFormat(audioIndex)
        val mime = format.getString(MediaFormat.KEY_MIME) ?: ""
        ALog.i(TAG, "audio mime=$mime")
        if (!MediaUtil.checkSupportCodec(mime)) {
            ALog.e(TAG, "mime=$mime not support")
            release()
            return
        }

        val decoder = MediaCodec.createDecoderByType(mime).apply {
            configure(format, null, null, 0)
            start()
        }
        this.decoder = decoder

        val decodeInputBuffers = decoder.inputBuffers
        var decodeOutputBuffers = decoder.outputBuffers

        val bufferInfo = MediaCodec.BufferInfo()
        val sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        val channelConfig = getChannelConfig(format.getInteger(MediaFormat.KEY_CHANNEL_COUNT))

        val bufferSize = AudioTrack.getMinBufferSize(sampleRate, channelConfig, AudioFormat.ENCODING_PCM_16BIT)
        val audioTrack = AudioTrack(AudioManager.STREAM_MUSIC, sampleRate, channelConfig, AudioFormat.ENCODING_PCM_16BIT, bufferSize, AudioTrack.MODE_STREAM)
        this.audioTrack = audioTrack
        val state = audioTrack.state
        if (state != AudioTrack.STATE_INITIALIZED) {
            release()
            ALog.e(TAG, "init audio track failure")
            return
        }
        audioTrack.play()
        val timeOutUs = 1000L
        var isEOS = false
        while (!isStopReq) {
            if (!isEOS) {
                val inputIndex = decoder.dequeueInputBuffer(timeOutUs)
                if (inputIndex >= 0) {
                    val inputBuffer = decodeInputBuffers[inputIndex]
                    inputBuffer.clear()
                    val sampleSize = extractor.readSampleData(inputBuffer, 0)
                    if (sampleSize < 0) {
                        isEOS = true
                        decoder.queueInputBuffer(inputIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                    } else {
                        decoder.queueInputBuffer(inputIndex, 0, sampleSize, 0, 0)
                        extractor.advance()
                    }
                }
            }
            val outputIndex = decoder.dequeueOutputBuffer(bufferInfo, 0)
            if (outputIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                decodeOutputBuffers = decoder.outputBuffers
            }
            if (outputIndex >= 0) {
                val outputBuffer = decodeOutputBuffers[outputIndex]
                val chunkPCM = ByteArray(bufferInfo.size)
                outputBuffer.get(chunkPCM)
                outputBuffer.clear()
                audioTrack.write(chunkPCM, 0, bufferInfo.size)
                decoder.releaseOutputBuffer(outputIndex, false)
            }

            if (isEOS && bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                if (--playLoop > 0) {
                    ALog.d(TAG, "Reached EOS, looping -> playLoop")
                    extractor.seekTo(0, MediaExtractor.SEEK_TO_CLOSEST_SYNC)
                    decoder.flush()
                    isEOS = false
                } else {
                    ALog.i(TAG, "decode finish")
                    release()
                    break
                }
            }
        }
        release()
    }


    private fun release() {
        try {
            decoder?.apply {
                stop()
                release()
            }
            decoder = null
            extractor?.release()
            extractor = null
            audioTrack?.apply {
                pause()
                flush()
                stop()
                release()
            }
            audioTrack = null
        } catch (e: Throwable) {
            ALog.e(TAG, "release exception=$e", e)
        }
        isRunning = false
        if (needDestroy) {
            destroyInner()
        }
    }

    fun destroy() {
        if (isRunning) {
            needDestroy = true
            stop()
        } else {
            destroyInner()
        }
    }

    private fun destroyInner() {
        if (player.isDetachedFromWindow) {
            ALog.i(TAG, "destroyThread")
            decodeThread.handler?.removeCallbacksAndMessages(null)
            decodeThread.thread = Decoder.quitSafely(decodeThread.thread)
        }
    }

    private fun getChannelConfig(channelCount: Int): Int {
        return when (channelCount) {
            1 -> AudioFormat.CHANNEL_CONFIGURATION_MONO
            2 -> AudioFormat.CHANNEL_OUT_STEREO
            3 -> AudioFormat.CHANNEL_OUT_STEREO or AudioFormat.CHANNEL_OUT_FRONT_CENTER
            4 -> AudioFormat.CHANNEL_OUT_QUAD
            5 -> AudioFormat.CHANNEL_OUT_QUAD or AudioFormat.CHANNEL_OUT_FRONT_CENTER
            6 -> AudioFormat.CHANNEL_OUT_5POINT1
            7 -> AudioFormat.CHANNEL_OUT_5POINT1 or AudioFormat.CHANNEL_OUT_BACK_CENTER
            else -> throw RuntimeException("Unsupported channel count: $channelCount")
        }
    }
}