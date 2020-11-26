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

import android.graphics.*
import android.text.TextPaint
import com.tencent.qgame.animplayer.mix.Src

object BitmapUtil {

    fun createEmptyBitmap() : Bitmap {
        return Bitmap.createBitmap(16, 16, Bitmap.Config.ARGB_8888).apply {
            eraseColor(Color.TRANSPARENT)
        }
    }

    fun createTxtBitmap(src: Src): Bitmap {
        val w = src.w
        val h = src.h
        // 这里使用ALPHA_8 在opengl渲染的时候图像出现错位
        val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val rect = Rect(0, 0, w, h)
        val bounds = Rect()
        var sizeR = 0.8f
        val paint = TextPaint().apply {
            textSize = h * sizeR
            textAlign = Paint.Align.CENTER
            style = Paint.Style.FILL
            isAntiAlias = true
            if (src.style == Src.Style.BOLD) {
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            }
            color = src.color
        }
        val text = src.txt
        while (sizeR > 0.1f) {
            paint.getTextBounds(text, 0, text.length, bounds)
            if (bounds.width() <= rect.width()) {
                break
            }
            sizeR -= 0.1f
            paint.textSize = h * sizeR
        }
        val fontMetrics = paint.fontMetricsInt
        val top = fontMetrics.top
        val bottom = fontMetrics.bottom
        val baseline = rect.centerY() - top/2 - bottom/2

        canvas.drawText(text, rect.centerX().toFloat(), baseline.toFloat(), paint)

        return bitmap
    }

}