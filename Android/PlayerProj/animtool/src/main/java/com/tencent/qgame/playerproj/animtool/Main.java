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


import com.tencent.qgame.playerproj.animtool.ui.ToolUI;

public class Main {


    public static void main(String[] args) throws Exception {
        // 启动UI界面
        new ToolUI().run();
        // java工具
        // animTool();
    }


    /**
     *
     * 运行前请先安装ffmpeg与bento4这两个工具
     *
     * 生成图片的工具
     * step 1 填写如下参数，运行后生成中间图片
     * step 2 进入outputPath目录，运行如下ffmpeg命令（需要预先安装ffmpeng）
     * ffmpeg -r 24 -i "%03d.png" -pix_fmt yuv420p -vcodec libx264 -b:v 3000k -profile:v baseline -level 3.0 -bf 0 -y demo.mp4
     *
     *
     * -vcodec libx264 h264编码
     * -b:v 3000K 表示码率为3000K，可以改变码率调节文件大小和视频清晰度
     * -bf 0 没有B帧
     * -profile:v baseline baseline模式
     *
     * 使用固定码率能使文件更小，但会损失清晰度
     * 使用-crf 参数可以提高清晰度但文件大小不可控（会变大），推荐值 29（0 最好 51 最差）
     *
     *
     * ps: 项目是普通的java程序，需要在Run Configuration 里加入Application运行项目，并选择animtool项目，接下来按提示配置即可
     */
    public static void animTool() throws Exception {
        final CommonArg commonArg = new CommonArg();
        // ffmpeg 命令路径
        commonArg.ffmpegCmd = "ffmpeg";
        // bento4 mp4edit 命令路径
        commonArg.mp4editCmd = "mp4edit";

        /*
         * 是否开启h265（默认关闭）
         * 优点：压缩率更高，视频更清晰
         * 缺点：Android 4.x系统 & 极少部分低端机 无法播放265视频
         */
        commonArg.enableH265 = false;
        // fps
        commonArg.fps = 24;
        // 素材文件路径
        commonArg.inputPath = "/path/to/your/demo";
        // alpha 区域缩放大小  (0.5 - 1)
        commonArg.scale = 0.5f;

        // 开始运行
        AnimTool animTool = new AnimTool();
        // needVideo true 直接生成video false 生成帧图片，由用户手动生成最终视频文件
        animTool.create(commonArg, true);
    }
    /**
     * 生成对应的box bin
     * 执行 mp4edit --insert :vapc.bin:1 demo_origin.mp4 demo_output.mp4 插入对应box
     */
    private void mp4BoxTool(String inputFile, String outputPath) throws Exception {
        Mp4BoxTool mp4BoxTool = new Mp4BoxTool();
        mp4BoxTool.create(inputFile, outputPath);
    }

    /**
     * 取出mp4文件中vapc部分json内容
     */
    public static void mp4ParseBox(String inputFile, String outputPath) throws Exception {
        Mp4BoxTool mp4BoxTool = new Mp4BoxTool();
        mp4BoxTool.parse(inputFile, outputPath);
    }


}
