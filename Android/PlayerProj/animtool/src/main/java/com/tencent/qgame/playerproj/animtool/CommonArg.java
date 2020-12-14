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

public class CommonArg {

    public String ffmpegCmd = "ffmpeg"; // ffmpeg 命令地址

    public String mp4editCmd = "mp4edit"; // bento4 mp4edit 命令地址

    public boolean enableH265 = false; // 是否开启h265

    public int fps = 0;

    public String inputPath; // 输入帧文件地址

    public float scale = 1f; // alpha 区域缩放大小

    /**
     * 自动填充参数配置
     */
    public String outputPath; // 输出地址

    public String frameOutputPath; // 帧图片输出路径

    public int version = 2;

    public int gap; // rgb 与 alpha 之间间隔距离

    // public int wFill; // 宽度填充

    // public int hFill; // 高度填充

    public int totalFrame;

    public PointRect rgbPoint = new PointRect(); // rgb 区域 原始图像区域

    public PointRect alphaPoint = new PointRect();  // alpha 区域

    public int outputW = 0; // 输出最终视频的宽高

    public int outputH = 0;

    @Override
    public String toString() {
        return "CommonArg{" +
                "ffmpegCmd='" + ffmpegCmd + '\'' +
                ", mp4editCmd='" + mp4editCmd + '\'' +
                ", enableH265=" + enableH265 +
                ", fps=" + fps +
                ", scale=" + scale +
                ", inputPath='" + inputPath + '\'' +
                '}';
    }
}
