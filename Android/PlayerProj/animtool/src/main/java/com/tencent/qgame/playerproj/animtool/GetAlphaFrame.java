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
package com.tencent.qgame.playerproj.animtool;

import com.tencent.qgame.playerproj.animtool.data.PointRect;

import javax.imageio.ImageIO;

import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.Arrays;

public class GetAlphaFrame {

    public static class AlphaFrameOut {

        public int[] argb;

        public AlphaFrameOut(int[] argb) {
            this.argb = argb;
        }

    }

    public AlphaFrameOut createFrame(CommonArg commonArg, File inputFile) throws IOException {

        if (!inputFile.exists()) {
            return null;
        }

        int w = commonArg.rgbPoint.w;
        int h = commonArg.rgbPoint.h;
        int outW = commonArg.outputW;
        int outH = commonArg.outputH;

        BufferedImage inputBuf = ImageIO.read(inputFile);
        int[] inputArgb = inputBuf.getRGB(0, 0, w, h, null, 0, w);

        int[] outputArgb = new int[outW * outH];
        Arrays.fill(outputArgb, 0xff000000);

        BufferedImage alphaBuf = inputBuf;
        int[] alphaArgb = inputArgb;

        if (commonArg.scale < 1f) {
            AffineTransform at = new AffineTransform();
            at.scale(commonArg.scale, commonArg.scale);

            alphaBuf = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
            AffineTransformOp scaleOp = new AffineTransformOp(at, AffineTransformOp.TYPE_BILINEAR);
            alphaBuf = scaleOp.filter(inputBuf, alphaBuf);

            alphaArgb = alphaBuf.getRGB(0, 0, w, h, null, 0, w);
        }

        // rgb 区域
        fillColor(outputArgb, outW, commonArg.rgbPoint, false, inputArgb, w);

        // alpha 区域
        fillColor(outputArgb, outW, commonArg.alphaPoint, true, alphaArgb, w);

        return new AlphaFrameOut(outputArgb);

    }


    private void fillColor(int[] outputArgb, int outputW, PointRect point, boolean isAlpha, int[] inputArgb, int inputW) {
        int outX = 0;
        int outY = 0;
        for (int y = 0; y < point.h ; y++) {
            outY = point.y + y;
            for (int x = 0; x < point.w ; x++) {
                outX = point.x + x;
                int color = inputArgb[x + y * inputW];
                outputArgb[outX + outY * outputW] = isAlpha ? getAlpha(color) : getColor(color);
            }
        }
    }

    private int getColor(int color) {
        return blendBg(color, 0xff000000);
    }

    private int getAlpha(int color) {
        int alpha = color >>> 24;
        // r = g = b
        return 0xff000000 + (alpha << 16) + (alpha << 8) + alpha;
    }

    private int blendBg(int color, int colorBg) {
        float alpha = (color >>> 24) / 255f;

        float colorR = ((color & 0x00ff0000) >>> 16) / 255f;
        float colorG = ((color & 0x0000ff00) >>> 8) / 255f;
        float colorB = ((color & 0x000000ff)) / 255f;

        float colorBgR = ((colorBg & 0x00ff0000) >>> 16) / 255f;
        float colorBgG = ((colorBg & 0x0000ff00) >>> 8) / 255f;
        float colorBgB = ((colorBg & 0x000000ff)) / 255f;

        float r = alpha * colorR + (1f - alpha) * colorBgR;
        float g = alpha * colorG + (1f - alpha) * colorBgG;
        float b = alpha * colorB + (1f - alpha) * colorBgB;

        return 0xff000000 + ((int)(r * 255f) << 16) + ((int)(g * 255f) << 8) + (int)(b * 255f);

    }

}

