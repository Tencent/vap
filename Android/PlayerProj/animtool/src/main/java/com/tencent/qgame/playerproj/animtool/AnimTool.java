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
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.concurrent.TimeUnit;

public class AnimTool {

    private static final String TAG = "AnimTool";

    public static final String OUTPUT_DIR = "output"+ File.separator;
    public static final String FRAME_IMAGE_DIR = "frames"+ File.separator;
    public static final String VIDEO_FILE = "video.mp4";
    public static final String TEM_VIDEO_FILE = "tmp_video.mp4";
    public static final String VAPC_BIN_FILE = "vapc.bin";
    public static final String VAPC_JSON_FILE = "vapc.json";



    private volatile int totalP = 0;
    private volatile int finishThreadCount = 0;
    private long time;
    private GetAlphaFrame getAlphaFrame = new GetAlphaFrame();
    private IToolListener toolListener;

    public void setToolListener(IToolListener toolListener) {
        this.toolListener = toolListener;
    }

    /**
     * @param commonArg
     * @param needVideo true 生成完整视频 false 只合成帧图片
     */
    public void create(final CommonArg commonArg, final boolean needVideo) throws Exception{
        TLog.i(TAG, "start create");
        createAllFrameImage(commonArg, new Runnable() {
            @Override
            public void run() {
                if (needVideo) {
                    // 最终生成视频文件
                    createVideo(commonArg);
                }
            }
        });
    }

    /**
     * 参数校验
     * @param commonArg
     * @return
     */
    private boolean checkCommonArg(CommonArg commonArg) throws Exception {
        return CommonArgTool.autoFillAndCheck(commonArg);
    }

    private void createAllFrameImage(final CommonArg commonArg, final Runnable finishRunnable) throws Exception{
        if (!checkCommonArg(commonArg)) {
            if (toolListener != null) toolListener.onError();
            return;
        }

        TLog.i(TAG, "createAllFrameImage");
        time = System.currentTimeMillis();

        // 检测output文件是否存在，不存在则生成
        checkDir(commonArg.outputPath);
        checkDir(commonArg.frameOutputPath);

        totalP = 0;
        finishThreadCount = 0;
        final int threadNum = 16;

        final int[][] threadIndexSet = new int[threadNum][2];
        final int totalFrame = commonArg.totalFrame;
        int block = totalFrame / threadNum;
        for(int i=0; i<threadNum-1; i++) {
            threadIndexSet[i][0] = i * block;
            threadIndexSet[i][1] = i * block + block;
        }
        threadIndexSet[threadNum-1][0] = (threadNum-1) * block;
        threadIndexSet[threadNum-1][1] = totalFrame;

        for (int i=0; i<threadNum; i++) {
            final int k = i;
            new Thread(new Runnable() {
                @Override
                public void run() {
                    for(int i = threadIndexSet[k][0]; i<threadIndexSet[k][1]; i++) {
                        synchronized (AnimTool.class) {
                            totalP++;
                            float progress = totalP * 1.0f / commonArg.totalFrame;
                            if (toolListener != null) {
                                toolListener.onProgress(progress);
                            } else {
                                TLog.i(TAG, "progress " + progress);
                            }
                        }
                        try {
                            createFrame(commonArg, i);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                    synchronized (AnimTool.class) {
                        finishThreadCount++;
                        if (finishThreadCount == threadNum) {
                            if (finishRunnable != null) {
                                finishRunnable.run();
                            }
                            long cost = System.currentTimeMillis() - time;
                            TLog.i(TAG,"Finish cost=" + cost);
                            if (toolListener != null) {
                                toolListener.onComplete();
                            }
                        }
                    }
                }
            }).start();
        }
    }

    private void createFrame(CommonArg commonArg, int frameIndex) throws Exception {
        int w = commonArg.videoW;
        int h = commonArg.videoH;
        File inputFile = new File(commonArg.inputPath + String.format("%03d", frameIndex)+".png");
        GetAlphaFrame.AlphaFrameOut videoFrame = getAlphaFrame.createFrame(commonArg.orin, w, h,
                commonArg.gap, commonArg.wFill, commonArg.hFill, inputFile);
        if (videoFrame == null) {
            TLog.i(TAG, "frameIndex="+frameIndex +" is empty");
            return;
        }
        // 最后保存图片
        BufferedImage outBuf = new BufferedImage(videoFrame.outW, videoFrame.outH, BufferedImage.TYPE_INT_ARGB);
        outBuf.setRGB(0,0, videoFrame.outW, videoFrame.outH, videoFrame.argb, 0, videoFrame.outW);

        File outputFile = new File(commonArg.frameOutputPath + String.format("%03d", frameIndex) +".png");
        ImageIO.write(outBuf, "PNG", outputFile);
    }


    private void checkDir(String path) {
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
    }

    /**
     * 创建最终的视频
     * @param commonArg
     */
    private void createVideo(CommonArg commonArg){
        try {
            // 创建配置json文件
            createVapcJson(commonArg);
            // 创建mp4文件
            boolean result = createMp4(commonArg, commonArg.outputPath, commonArg.frameOutputPath);
            if (!result) {
                TLog.i(TAG, "createMp4 fail");
                return;
            }
            String input = commonArg.outputPath + VAPC_JSON_FILE;
            // 由json变为bin文件
            String vapcBinPath = mp4BoxTool(input, commonArg.outputPath);
            // 将bin文件合并到mp4里
            result = mergeBin2Mp4(commonArg, vapcBinPath, commonArg.outputPath);
            if (!result) {
                TLog.i(TAG, "mergeBin2Mp4 fail");
                return;
            }
            // 删除临时视频文件
            new File(commonArg.outputPath + TEM_VIDEO_FILE).delete();
            new File(commonArg.outputPath + VAPC_BIN_FILE).delete();
            // 计算文件md5
            String md5 = new Md5Util().getFileMD5(new File(commonArg.outputPath + VIDEO_FILE), commonArg.outputPath);
            TLog.i(TAG, "md5="+md5);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 创建对应的配置json
     * @param commonArg
     */
    private void createVapcJson(CommonArg commonArg) {
        String json = "{\"info\":{\"v\":$(v),\"f\":$(f),\"w\":$(w),\"h\":$(h),\"videoW\":$(videoW),\"videoH\":$(videoH),\"orien\":0,\"fps\":$(fps),\"isVapx\":0,\"aFrame\":$(aFrame),\"rgbFrame\":$(rgbFrame)}}";
        json = json.replace("$(v)", String.valueOf(commonArg.version));
        json = json.replace("$(f)", String.valueOf(commonArg.totalFrame));
        json = json.replace("$(w)", String.valueOf(commonArg.videoW));
        json = json.replace("$(h)", String.valueOf(commonArg.videoH));
        json = json.replace("$(fps)", String.valueOf(commonArg.fps));
        int realW = 0;
        int realH = 0;
        int cx, cy;
        String aFrame = "[0,0,"+commonArg.videoW+","+commonArg.videoH+"]";
        String rgbFrame = "[0,0,0,0]";
        if (commonArg.orin == CommonArg.ORIN_H) { // 水平对齐
            realW = 2 * commonArg.videoW + commonArg.gap;
            realH = commonArg.videoH;
            cx = commonArg.videoW + commonArg.gap;
            cy = 0;
        } else { // 上下对齐
            realW = commonArg.videoW;
            realH = 2 * commonArg.videoH + commonArg.gap;
            cx = 0;
            cy = commonArg.videoH + commonArg.gap;
        }
        rgbFrame = "["+cx+","+cy+","+commonArg.videoW+","+commonArg.videoH+"]";

        realW += commonArg.wFill;
        realH += commonArg.hFill;
        json = json.replace("$(videoW)", String.valueOf(realW));
        json = json.replace("$(videoH)", String.valueOf(realH));
        json = json.replace("$(aFrame)", aFrame);
        json = json.replace("$(rgbFrame)", rgbFrame);
        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(commonArg.outputPath + VAPC_JSON_FILE));
            writer.write(json);
            writer.flush();
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
            throw new RuntimeException();
        }
        TLog.i(TAG,json);

    }





    /**
     * 创建mp4
     * @param commonArg
     * @throws Exception
     */
    private boolean createMp4(CommonArg commonArg, String videoPath, String frameImagePath) throws Exception {
        String[] cmd = null;
        if (commonArg.enableH265) {
            cmd = new String[] {commonArg.ffmpegCmd, "-r", String.valueOf(commonArg.fps),
                    "-i", frameImagePath + "%03d.png",
                    "-pix_fmt", "yuv420p",
                    "-vcodec", "libx265",
                    "-b:v", "2000k",
                    "-profile:v", "main",
                    "-level", "4.0",
                    "-tag:v", "hvc1",
                    "-bufsize", "2000k",
                    "-y", videoPath + TEM_VIDEO_FILE};
        } else {
            cmd = new String[]{commonArg.ffmpegCmd, "-r", String.valueOf(commonArg.fps),
                    "-i", frameImagePath + "%03d.png",
                    "-pix_fmt", "yuv420p",
                    "-vcodec", "libx264",
                    "-b:v", "3000k",
                    "-profile:v", "baseline",
                    "-level", "3.0",
                    "-bf", "0",
                    "-y", videoPath + TEM_VIDEO_FILE};
        }

        TLog.i(TAG, "run createMp4");
        int result = ProcessUtil.run(cmd);
        TLog.i(TAG, "createMp4 result=" + (result == 0? "success" : "fail"));
        return result == 0;
    }

    /**
     * 合并vapc.bin到mp4里
     * @param inputFile
     * @throws Exception
     */
    private boolean mergeBin2Mp4(CommonArg commonArg, String inputFile, String videoPath) throws Exception{
        String[] cmd = new String[] {commonArg.mp4editCmd, "--insert", ":"+inputFile+":1", videoPath + TEM_VIDEO_FILE, videoPath + VIDEO_FILE};
        TLog.i(TAG, "run mergeBin2Mp4");
        int result = ProcessUtil.run(cmd);
        TLog.i(TAG, "mergeBin2Mp4 result=" + (result == 0? "success" : "fail"));
        return result == 0;
    }

    /**
     * 生成对应的box bin
     * 执行 mp4edit --insert :vapc.bin:1 demo_origin.mp4 demo_output.mp4 插入对应box
     */
    private String mp4BoxTool(String inputFile, String outputPath) throws Exception {
        Mp4BoxTool mp4BoxTool = new Mp4BoxTool();
        return mp4BoxTool.create(inputFile, outputPath);
    }


    public interface IToolListener {
        void onProgress(float progress);
        void onError();
        void onComplete();
    }

}
