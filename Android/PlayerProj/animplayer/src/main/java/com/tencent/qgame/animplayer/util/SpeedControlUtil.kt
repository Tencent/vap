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

import com.tencent.qgame.animplayer.Constant

class SpeedControlUtil {

    companion object {
        private const val TAG = "${Constant.TAG}.SpeedControlUtil"
    }
    private val ONE_MILLION = 1000000L

    private var prevPresentUsec: Long = 0
    private var prevMonoUsec: Long = 0
    private var fixedFrameDurationUsec: Long = 0
    private var loopReset = true

    fun setFixedPlaybackRate(fps: Int) {
        if (fps <=0) return
        fixedFrameDurationUsec = ONE_MILLION / fps
    }

    fun preRender(presentationTimeUsec: Long) {
        if (prevMonoUsec == 0L) {
            prevMonoUsec = System.nanoTime() / 1000
            prevPresentUsec = presentationTimeUsec
        } else {
            var frameDelta: Long
            if (loopReset) {
                prevPresentUsec = presentationTimeUsec - ONE_MILLION / 30
                loopReset = false
            }
            frameDelta = if (fixedFrameDurationUsec != 0L) {
                fixedFrameDurationUsec
            } else {
                presentationTimeUsec - prevPresentUsec
            }
            when {
                frameDelta < 0 -> frameDelta = 0
                frameDelta > 10 * ONE_MILLION -> frameDelta = 5 * ONE_MILLION
            }

            val desiredUsec = prevMonoUsec + frameDelta
            var nowUsec = System.nanoTime() / 1000
            while (nowUsec < desiredUsec - 100 ) {
                var sleepTimeUsec = desiredUsec - nowUsec
                if (sleepTimeUsec > 500000) {
                    sleepTimeUsec = 500000
                }
                try {
                    Thread.sleep(sleepTimeUsec / 1000, (sleepTimeUsec % 1000).toInt() * 1000)
                } catch (e: InterruptedException) {
                    ALog.e(TAG, "e=$e", e)
                }
                nowUsec = System.nanoTime() / 1000
            }

            prevMonoUsec += frameDelta
            prevPresentUsec += frameDelta
        }
    }

    fun reset() {
        prevPresentUsec = 0
        prevMonoUsec = 0
    }
}