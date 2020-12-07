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

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class GetAlphaFrame {

    public static final int ORIN_H = 1; // 左右对齐
    public static final int ORIN_V = 2; // 上下对齐


    public static class AlphaFrameOut {


        public int orin;
        public int[] argb;
        public int w;
        public int h;
        public int outW;
        public int outH;
        public int gap;


        public AlphaFrameOut(int orin, int[] argb, int w, int h, int outW, int outH, int gap) {
            this.orin = orin;
            this.argb = argb;
            this.w = w;
            this.h = h;
            this.outW = outW;
            this.outH = outH;
            this.gap = gap;
        }

    }

    /**
     *
     * @param orin
     * @param w 原图像宽
     * @param h 原图像高
     * @param gap rgb 与 alpha 之间间隔距离
     * @param inputFile
     * @return
     * @throws IOException
     */
    public AlphaFrameOut createFrame(int orin, int w, int h, int gap, File inputFile) throws IOException {

        if (!inputFile.exists()) {
            return null;
        }

        int outW = orin == ORIN_H ? (w * 2 + gap) : w;
        int outH = orin == ORIN_H ? h : (h * 2 + gap);

        BufferedImage inputBuf = ImageIO.read(inputFile);
        int[] inputArgb = inputBuf.getRGB(0, 0, w, h, null, 0, w);


        int[] outputArgb = new int[outW * outH];


        for (int k=0; k<2; k++) {
            for (int x = 0; x < w; x++) {
                for (int y = 0; y < h; y++) {
                    int outPoint = orin == ORIN_H ? k * (w + gap) + x + y * outW : k * w * (h + gap) + x + y * w;
                    if (k == 0) {
                        int alpha = inputArgb[x + y * w] >>> 24;
                        // r = g = b
                        outputArgb[outPoint] = 0xff000000 + (alpha << 16) + (alpha << 8) + alpha;
                    } else {
                        outputArgb[outPoint] = blendBg(inputArgb[x + y * w], 0xff000000);
                    }
                }
            }
        }

        return new AlphaFrameOut(orin, outputArgb, w, h, outW, outH, gap);

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

