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

import android.os.SystemClock
import com.tencent.qgame.animplayer.file.IFileContainer
import com.tencent.qgame.animplayer.util.ALog
import org.json.JSONObject
import java.nio.charset.Charset

/**
 * 配置管理
 */
class AnimConfigManager(val player: AnimPlayer) {

    companion object {
        private const val TAG = "${Constant.TAG}.AnimConfigManager"
    }

    var config: AnimConfig? = null
    var isParsingConfig = false // 是否正在读取配置

    /**
     * 解析配置
     * @return true 解析成功 false 解析失败
     */
    fun parseConfig(fileContainer: IFileContainer, enableVersion1: Boolean, defaultVideoMode: Int, defaultFps: Int): Int {
        try {
            isParsingConfig = true
            // 解析vapc
            val time = SystemClock.elapsedRealtime()
            val result = parse(fileContainer, defaultVideoMode, defaultFps)
            ALog.i(TAG, "parseConfig cost=${SystemClock.elapsedRealtime() - time}ms enableVersion1=$enableVersion1 result=$result")
            if (!result) {
                isParsingConfig = false
                return Constant.REPORT_ERROR_TYPE_PARSE_CONFIG
            }
            if (config?.isDefaultConfig == true && !enableVersion1) {
                isParsingConfig = false
                return Constant.REPORT_ERROR_TYPE_PARSE_CONFIG
            }
            // 插件解析配置
            val resultCode = config?.let {
                player.pluginManager.onConfigCreate(it)
            } ?: Constant.OK
            isParsingConfig = false
            return resultCode
        } catch (e : Throwable) {
            ALog.e(TAG, "parseConfig error $e", e)
            isParsingConfig = false
            return Constant.REPORT_ERROR_TYPE_PARSE_CONFIG
        }
    }

    /**
     * 默认配置解析（兼容老视频格式）
     */
    fun defaultConfig(_videoWidth: Int, _videoHeight: Int) {
        if (config?.isDefaultConfig == false) return
        config?.apply {
            videoWidth = _videoWidth
            videoHeight = _videoHeight
            when (defaultVideoMode) {
                Constant.VIDEO_MODE_SPLIT_HORIZONTAL -> {
                    // 视频左右对齐（alpha左\rgb右）
                    width = _videoWidth / 2
                    height = _videoHeight
                    alphaPointRect = PointRect(0, 0, width, height)
                    rgbPointRect = PointRect(width, 0, width, height)
                }
                Constant.VIDEO_MODE_SPLIT_VERTICAL -> {
                    // 视频上下对齐（alpha上\rgb下）
                    width = _videoWidth
                    height = _videoHeight / 2
                    alphaPointRect = PointRect(0, 0, width, height)
                    rgbPointRect = PointRect(0, height, width, height)
                }
                Constant.VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE -> {
                    // 视频左右对齐（rgb左\alpha右）
                    width = _videoWidth / 2
                    height = _videoHeight
                    rgbPointRect = PointRect(0, 0, width, height)
                    alphaPointRect = PointRect(width, 0, width, height)
                }
                Constant.VIDEO_MODE_SPLIT_VERTICAL_REVERSE -> {
                    // 视频上下对齐（rgb上\alpha下）
                    width = _videoWidth
                    height = _videoHeight / 2
                    rgbPointRect = PointRect(0, 0, width, height)
                    alphaPointRect = PointRect(0, height, width, height)
                }
                else -> {
                    // 默认视频左右对齐（alpha左\rgb右）
                    width = _videoWidth / 2
                    height = _videoHeight
                    alphaPointRect = PointRect(0, 0, width, height)
                    rgbPointRect = PointRect(width, 0, width, height)
                }
            }
        }
    }


    private fun parse(fileContainer: IFileContainer, defaultVideoMode: Int, defaultFps: Int): Boolean {

        val config = AnimConfig()
        this.config = config


        // 查找vapc box
        fileContainer.startRandomRead()
        val boxHead = ByteArray(8)
        var head: BoxHead? = null
        var vapcStartIndex: Long = 0
        while (fileContainer.read(boxHead, 0, boxHead.size) == 8) {
            val h = parseBoxHead(boxHead) ?: break
            if ("vapc" == h.type) {
                h.startIndex = vapcStartIndex
                head = h
                break
            }
            vapcStartIndex += h.length
            fileContainer.skip(h.length - 8L)
        }

        if (head == null) {
            ALog.e(TAG, "vapc box head not found")
            // 按照默认配置生成config
            config.apply {
                isDefaultConfig = true
                this.defaultVideoMode = defaultVideoMode
                fps = defaultFps
            }
            player.fps = config.fps
            return true
        }

        // 读取vapc box
        val vapcBuf = ByteArray(head.length - 8) // ps: OOM exception
        fileContainer.read(vapcBuf, 0 , vapcBuf.size)
        fileContainer.closeRandomRead()

        val json = String(vapcBuf, 0, vapcBuf.size, Charset.forName("UTF-8"))
        val jsonObj = JSONObject(json)
        config.jsonConfig = jsonObj
        val result = config.parse(jsonObj)
        if (defaultFps > 0) {
            config.fps = defaultFps
        }
        player.fps = config.fps
        return result
    }

    private fun parseBoxHead(boxHead: ByteArray): BoxHead? {
        if (boxHead.size != 8) return null
        val head = BoxHead()
        var length: Int = 0
        length = length or (boxHead[0].toInt() and 0xff shl 24)
        length = length or (boxHead[1].toInt() and 0xff shl 16)
        length = length or (boxHead[2].toInt() and 0xff shl 8)
        length = length or (boxHead[3].toInt() and 0xff)
        head.length = length
        head.type = String(boxHead, 4, 4, Charset.forName("US-ASCII"))
        return head
    }

    private class BoxHead {
        var startIndex: Long = 0
        var length: Int = 0
        var type: String? = null
    }



}