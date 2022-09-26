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
package com.tencent.qgame.animplayer.mix

import android.graphics.Bitmap
import android.graphics.Color
import com.tencent.qgame.animplayer.Constant
import com.tencent.qgame.animplayer.util.ALog
import org.json.JSONObject

class Src// 可选

// 可选
    (json: JSONObject) {
    companion object {
        private const val TAG = "${Constant.TAG}.Src"
    }

    enum class SrcType(val type: String) {
        UNKNOWN("unknown"),
        IMG("img"),
        TXT("txt"),
    }

    enum class LoadType(val type: String) {
        UNKNOWN("unknown"),
        NET("net"), // 网络加载的图片
        LOCAL("local"), // 本地加载的图片
    }

    enum class FitType(val type: String) {
        FIT_XY("fitXY"), // 按原始大小填充纹理
        CENTER_FULL("centerFull"), // 以纹理中心点放置
    }

    enum class Style(val style: String) {
        DEFAULT("default"),
        BOLD("b"), // 文字粗体
    }

    var srcId = ""
    var w = 0
    var h = 0
    var srcType = SrcType.UNKNOWN
    var loadType = LoadType.UNKNOWN
    var srcTag = ""
    var bitmap: Bitmap? = null
    var txt = ""
    var style = Style.DEFAULT
    var color: Int = 0
    var fitType = FitType.FIT_XY
    var srcTextureId = 0

    init {
        srcId = json.getString("srcId")
        w = json.getInt("w")
        h = json.getInt("h")
        var colorStr = json.optString("color", "#000000")
        if (colorStr.isEmpty()) {
            colorStr = "#000000"
        }
        color = Color.parseColor(colorStr)
        srcTag = json.getString("srcTag")
        txt = srcTag
        srcType = when(json.getString("srcType")) {
            SrcType.IMG.type -> SrcType.IMG
            SrcType.TXT.type -> SrcType.TXT
            else -> SrcType.UNKNOWN
        }
        loadType = when(json.getString("loadType")) {
            LoadType.NET.type -> LoadType.NET
            LoadType.LOCAL.type -> LoadType.LOCAL
            else -> LoadType.UNKNOWN
        }
        fitType = when(json.getString("fitType")) {
            FitType.CENTER_FULL.type -> FitType.CENTER_FULL
            else -> FitType.FIT_XY
        }
        style = when(json.optString("style", "")) {
            Style.BOLD.style -> Style.BOLD
            else -> Style.DEFAULT
        }
        ALog.i(TAG, "${toString()} color=$colorStr")
    }



    override fun toString(): String {
        return "Src(srcId='$srcId', srcType=$srcType, loadType=$loadType, srcTag='$srcTag', bitmap=$bitmap, txt='$txt')"
    }

}


class SrcMap(json: JSONObject) {
    val map = HashMap<String, Src>()

    init {
        val srcJsonArray = json.getJSONArray("src")
        val srcLen = srcJsonArray.length()
        for (i in 0 until srcLen) {
            val srcJson = srcJsonArray.getJSONObject(i) ?: continue
            val src = Src(srcJson)
            if (src.srcType != Src.SrcType.UNKNOWN) { // 不认识的srcType丢弃
                map[src.srcId] = src
            }
        }
    }
}