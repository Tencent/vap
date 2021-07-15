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

object Constant {
    const val TAG = "AnimPlayer"

    // 视频适配的屏幕方向
    const val ORIEN_DEFAULT = 0 // 兼容模式
    const val ORIEN_PORTRAIT = 1 // 适配竖屏的视频
    const val ORIEN_LANDSCAPE = 2 // 适配横屏的视频

    // 视频对齐方式 (兼容老版本视频模式)
    @Deprecated("Compatible older version mp4")
    const val VIDEO_MODE_SPLIT_HORIZONTAL = 1 // 视频左右对齐（alpha左\rgb右）
    @Deprecated("Compatible older version mp4")
    const val VIDEO_MODE_SPLIT_VERTICAL = 2 // 视频上下对齐（alpha上\rgb下）
    @Deprecated("Compatible older version mp4")
    const val VIDEO_MODE_SPLIT_HORIZONTAL_REVERSE = 3 // 视频左右对齐（rgb左\alpha右）
    @Deprecated("Compatible older version mp4")
    const val VIDEO_MODE_SPLIT_VERTICAL_REVERSE = 4 // 视频上下对齐（rgb上\alpha下）


    const val OK = 0 // 成功

    const val REPORT_ERROR_TYPE_EXTRACTOR_EXC = 10001 // MediaExtractor exception
    const val REPORT_ERROR_TYPE_DECODE_EXC = 10002 // MediaCodec exception
    const val REPORT_ERROR_TYPE_CREATE_THREAD = 10003 // 线程创建失败
    const val REPORT_ERROR_TYPE_CREATE_RENDER = 10004 // render创建失败
    const val REPORT_ERROR_TYPE_PARSE_CONFIG = 10005 // 配置解析失败
    const val REPORT_ERROR_TYPE_CONFIG_PLUGIN_MIX = 10006 // vapx融合动画资源获取失败
    const val REPORT_ERROR_TYPE_FILE_ERROR = 10007 // 文件无法读取
    const val REPORT_ERROR_TYPE_HEVC_NOT_SUPPORT = 10008 // 不支持h265

    const val ERROR_MSG_EXTRACTOR_EXC = "0x1 MediaExtractor exception" // MediaExtractor exception
    const val ERROR_MSG_DECODE_EXC = "0x2 MediaCodec exception" // MediaCodec exception
    const val ERROR_MSG_CREATE_THREAD = "0x3 thread create fail" // 线程创建失败
    const val ERROR_MSG_CREATE_RENDER = "0x4 render create fail" // render创建失败
    const val ERROR_MSG_PARSE_CONFIG = "0x5 parse config fail" // 配置解析失败
    const val ERROR_MSG_CONFIG_PLUGIN_MIX = "0x6 vapx fail" // vapx融合动画资源获取失败
    const val ERROR_MSG_FILE_ERROR = "0x7 file can't read" // 文件无法读取
    const val ERROR_MSG_HEVC_NOT_SUPPORT = "0x8 hevc not support" // 不支持h265


    fun getErrorMsg(errorType: Int, errorMsg: String? = null): String {
        return when(errorType) {
            REPORT_ERROR_TYPE_EXTRACTOR_EXC -> ERROR_MSG_EXTRACTOR_EXC
            REPORT_ERROR_TYPE_DECODE_EXC -> ERROR_MSG_DECODE_EXC
            REPORT_ERROR_TYPE_CREATE_THREAD -> ERROR_MSG_CREATE_THREAD
            REPORT_ERROR_TYPE_CREATE_RENDER -> ERROR_MSG_CREATE_RENDER
            REPORT_ERROR_TYPE_PARSE_CONFIG -> ERROR_MSG_PARSE_CONFIG
            REPORT_ERROR_TYPE_CONFIG_PLUGIN_MIX -> ERROR_MSG_CONFIG_PLUGIN_MIX
            else -> "unknown"
        } + " ${errorMsg ?: ""}"
    }

}