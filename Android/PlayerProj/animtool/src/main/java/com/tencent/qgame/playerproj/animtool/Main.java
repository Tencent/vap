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
import com.tencent.qgame.playerproj.animtool.vapx.SrcSet;

public class Main {


    public static void main(String[] args) throws Exception {
        // 启动UI界面
        new ToolUI().run();

        // java工具普通动画
        // animTool();

        // java工具融合动画
        // animVapxTool();
    }


    /**
     *
     * 运行前请先安装ffmpeg与bento4这两个工具
     *
     * 生成图片的工具
     * step 1 填写如下参数，运行后生成中间图片
     * step 2 进入outputPath目录，运行如下ffmpeg命令（需要预先安装ffmpeng）
     *
     * h264
     * ffmpeg -r 24 -i "%03d.png" -pix_fmt yuv420p -vcodec libx264 -b:v 3000k -profile:v main -level 4.0 -bf 0 -bufsize 3000k -y demo.mp4
     *
     * h265
     * ffmpeg -r 24 -i "%03d.png" -pix_fmt yuv420p -vcodec libx265 -b:v 2000k -profile:v main -level 4.0 -bf 0 -bufsize 2000k -tag:v hvc1 -y demo.mp4
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
         * 是否开启h265
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
     * 融合动画 demo
     */
    public static void animVapxTool() throws Exception {
        final CommonArg commonArg = new CommonArg();
        // ffmpeg 命令路径
        commonArg.ffmpegCmd = "ffmpeg";
        // bento4 mp4edit 命令路径
        commonArg.mp4editCmd = "mp4edit";

        String path = "/path/to/your/demo";

        commonArg.enableH265 = false;
        // fps
        commonArg.fps = 24;
        // 素材文件路径
        commonArg.inputPath = path + "video";
        // 启动融合动画
        commonArg.isVapx = true;
        if (commonArg.isVapx) {
            // 融合动画默认需要缩放0.5f 空出区域
            commonArg.scale = 0.5f;
        }
        // src 设置
        commonArg.srcSet = getSrcSet(path);


        // 开始运行
        AnimTool animTool = new AnimTool();
        // needVideo true 直接生成video false 生成帧图片，由用户手动生成最终视频文件
        animTool.create(commonArg, true);
    }


    private static SrcSet getSrcSet(String path) {
        SrcSet srcSet = new SrcSet();

        {
            SrcSet.Src src = new SrcSet.Src();
            src.srcPath = path + "mask1";
            src.srcId = "1";
            src.srcType = SrcSet.Src.SRC_TYPE_IMG;
            src.srcTag = "head1";
            src.fitType = SrcSet.Src.FIT_TYPE_CF;
            srcSet.srcs.add(src);
        }


        {
            SrcSet.Src src = new SrcSet.Src();
            src.srcPath = path + "mask2";
            src.srcId = "2";
            src.srcType = SrcSet.Src.SRC_TYPE_TXT;
            src.srcTag = "text1";
            src.fitType = SrcSet.Src.FIT_TYPE_FITXY;
            src.color = "#0000ff";
            src.style = SrcSet.Src.TEXT_STYLE_BOLD;
            srcSet.srcs.add(src);
        }




        return srcSet;
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
