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

public class CommonArg {

    public static final int ORIN_H = 1; // 左右对齐
    public static final int ORIN_V = 2; // 上下对齐

    public String ffmpegCmd = "ffmpeg"; // ffmpeg 命令地址

    public String mp4editCmd = "mp4edit"; // bento4 mp4edit 命令地址

    public boolean enableH265 = false; // 是否开启h265

    public int version = 2;

    public int orin = ORIN_H;

    public int videoW;

    public int videoH;

    public int totalFrame;

    public int fps = 0;

    public String inputPath; // 输入帧文件地址

    public String outputPath; // 输出地址

    public String frameOutputPath; // 帧图片输出路径
}
