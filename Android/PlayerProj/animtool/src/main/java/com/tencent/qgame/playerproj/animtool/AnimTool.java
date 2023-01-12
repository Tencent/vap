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

import com.tencent.qgame.playerproj.animtool.vapx.FrameSet;
import com.tencent.qgame.playerproj.animtool.vapx.GetMaskFrame;
import com.tencent.qgame.playerproj.animtool.vapx.SrcSet;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class AnimTool {

    private static final String TAG = "AnimTool";

    public static final String OUTPUT_DIR = "output"+ File.separator;
    public static final String FRAME_IMAGE_DIR = "frames"+ File.separator;
    public static final String VIDEO_FILE = "video.mp4";
    public static final String TEMP_VIDEO_FILE = "tmp_video.mp4";
    public static final String TEMP_VIDEO_AUDIO_FILE = "tmp_video_audio.mp4";
    public static final String VAPC_BIN_FILE = "vapc.bin";
    public static final String VAPC_JSON_FILE = "vapc.json";



    private volatile int totalP = 0;
    private volatile int finishThreadCount = 0;
    private long time;
    private GetAlphaFrame getAlphaFrame = new GetAlphaFrame();
    private GetMaskFrame getMaskFrame = new GetMaskFrame();
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
        createAllFrameImage(commonArg, new IRunResult() {
            @Override
            public boolean run() {
                if (finalCheck(commonArg) && needVideo) {
                    // 最终生成视频文件
                    return createVideo(commonArg);
                }
                return false;
            }
        });
    }

    /**
     * 参数校验
     * @param commonArg
     * @return
     */
    private boolean checkCommonArg(CommonArg commonArg) throws Exception {
        return CommonArgTool.autoFillAndCheck(commonArg, toolListener);
    }

    private boolean finalCheck(CommonArg commonArg) {
        if (commonArg.isVapx) {
            if (commonArg.srcSet.srcs.isEmpty()) {
                TLog.i(TAG, "vapx error: src is empty");
                return false;
            }
            for (SrcSet.Src src : commonArg.srcSet.srcs) {
                if (src.w <=0 || src.h <= 0) {
                    TLog.i(TAG, "vapx error: src.id=" + src.srcId + ",src.w=" + src.w + ",src.h=" + src.h);
                    return false;
                }
            }
        }
        return true;
    }

    private void createAllFrameImage(final CommonArg commonArg, final IRunResult finishRunnable) throws Exception{
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

        if (toolListener != null) {
            toolListener.onProgress(0f);
        }
        for (int i=0; i<threadNum; i++) {
            final int k = i;
            new Thread(new Runnable() {
                @Override
                public void run() {
                    for(int i = threadIndexSet[k][0]; i<threadIndexSet[k][1]; i++) {
                        try {
                            createFrame(commonArg, i);
                        } catch (Exception e) {
                            TLog.e(TAG, "createFrame error:" + e.getMessage());
                        }
                        synchronized (AnimTool.class) {
                            totalP++;
                            float progress = totalP * 1.0f / commonArg.totalFrame;
                            if (toolListener != null) {
                                toolListener.onProgress(progress);
                            } else {
                                TLog.i(TAG, "progress " + progress);
                            }
                        }
                    }
                    synchronized (AnimTool.class) {
                        finishThreadCount++;
                        if (finishThreadCount == threadNum) {
                            boolean result = false;
                            if (finishRunnable != null) {
                                result = finishRunnable.run();
                            }
                            long cost = System.currentTimeMillis() - time;
                            TLog.i(TAG,"Finish cost=" + cost);
                            if (toolListener != null) {
                                if (result) {
                                    toolListener.onComplete();
                                } else {
                                    toolListener.onError();
                                }
                            }
                        }
                    }
                }
            }).start();
        }
    }

    private void createFrame(CommonArg commonArg, int frameIndex) throws Exception {
        File inputFile = new File(commonArg.inputPath + String.format("%03d", frameIndex)+".png");
        GetAlphaFrame.AlphaFrameOut videoFrame = getAlphaFrame.createFrame(commonArg, inputFile);
        if (commonArg.isVapx) {
            FrameSet.FrameObj frameObj = getMaskFrame.getFrameObj(frameIndex, commonArg, videoFrame.argb);
            if (frameObj != null) {
                commonArg.frameSet.frameObjs.add(frameObj);
            }
        }
        if (videoFrame == null) {
            TLog.i(TAG, "frameIndex="+frameIndex +" is empty");
            return;
        }
        // 最后保存图片
        BufferedImage outBuf = new BufferedImage(commonArg.outputW, commonArg.outputH, BufferedImage.TYPE_INT_ARGB);
        outBuf.setRGB(0,0, commonArg.outputW, commonArg.outputH, videoFrame.argb, 0, commonArg.outputW);

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
    private boolean createVideo(CommonArg commonArg) {
        try {
            // 创建配置json文件
            createVapcJson(commonArg);
            // 创建mp4文件
            boolean result = createMp4(commonArg, commonArg.outputPath, commonArg.frameOutputPath);
            if (!result) {
                TLog.i(TAG, "createMp4 fail");
                deleteFile(commonArg);
                return false;
            }
            String tempVideoName = TEMP_VIDEO_FILE;
            if (commonArg.needAudio) {
                result = mergeAudio2Mp4(commonArg, tempVideoName);
                if (!result) {
                    TLog.i(TAG, "mergeAudio2Mp4 fail");
                    deleteFile(commonArg);
                    return false;
                }
                tempVideoName = TEMP_VIDEO_AUDIO_FILE;
            }

            String input = commonArg.outputPath + VAPC_JSON_FILE;
            // 由json变为bin文件
            String vapcBinPath = mp4BoxTool(input, commonArg.outputPath);
            // 将bin文件合并到mp4里
            result = mergeBin2Mp4(commonArg, vapcBinPath, tempVideoName, commonArg.outputPath);
            if (!result) {
                TLog.i(TAG, "mergeBin2Mp4 fail");
                deleteFile(commonArg);
                return false;
            }
            deleteFile(commonArg);
            // 计算文件md5
            String md5 = new Md5Util().getFileMD5(new File(commonArg.outputPath + VIDEO_FILE), commonArg.outputPath);
            TLog.i(TAG, "md5="+md5);
        } catch (Exception e) {
            TLog.e(TAG, "createVideo error:" + e.getMessage());
            return false;
        }
        return true;
    }

    private void deleteFile(CommonArg commonArg) {
        // 删除临时视频文件
        File file;
        file = new File(commonArg.outputPath + TEMP_VIDEO_FILE);
        if (file.exists()) file.delete();
        if (commonArg.needAudio) {
            file = new File(commonArg.outputPath + TEMP_VIDEO_AUDIO_FILE);
            if (file.exists()) file.delete();
        }
        file = new File(commonArg.outputPath + VAPC_BIN_FILE);
        if (file.exists()) file.delete();
    }

    /**
     * 创建对应的配置json
     * @param commonArg
     */
    private void createVapcJson(CommonArg commonArg) {

        String json = "\"info\":{" +
                "\"v\":" + commonArg.version + "," +
                "\"f\":" + commonArg.totalFrame + "," +
                "\"w\":" + commonArg.rgbPoint.w + "," +
                "\"h\":" + commonArg.rgbPoint.h + "," +
                "\"fps\":" + commonArg.fps + "," +
                "\"videoW\":" + commonArg.outputW + "," +
                "\"videoH\":" + commonArg.outputH + "," +
                "\"aFrame\":" + commonArg.alphaPoint.toString() + "," +
                "\"rgbFrame\":" + commonArg.rgbPoint.toString() + "," +
                "\"isVapx\":" + (commonArg.isVapx ? 1 : 0) + "," +
                "\"orien\":" + 0 +
                "}";
        TLog.i(TAG, "{" + json + "}");

        StringBuilder sb = new StringBuilder();
        sb.append("{");
        sb.append(json);
        if (commonArg.isVapx) {
            sb.append(",");
            sb.append(commonArg.srcSet.toString());
            sb.append(",");
            sb.append(commonArg.frameSet.toString());
        }
        sb.append("}");
        json = sb.toString();

        try {
            BufferedWriter writer = new BufferedWriter(new FileWriter(commonArg.outputPath + VAPC_JSON_FILE));
            writer.write(json);
            writer.flush();
            writer.close();
        } catch (IOException e) {
            TLog.e(TAG, "createVapcJson error:" + e.getMessage());
            throw new RuntimeException();
        }
    }





    /**
     * 创建mp4
     */
    private boolean createMp4(CommonArg commonArg, String videoPath, String frameImagePath) throws Exception {

        TLog.i(TAG, "run createMp4");
        int result = ProcessUtil.run(getFFmpegCmd(commonArg, videoPath, frameImagePath));
        TLog.i(TAG, "createMp4 result=" + (result == 0? "success" : "fail"));
        return result == 0;
    }

    private String[] getFFmpegCmd(CommonArg commonArg, String videoPath, String frameImagePath) {
        String[] cmd;
        if (commonArg.enableH265) {
            if (commonArg.enableCrf) {
                cmd = new String[] {commonArg.ffmpegCmd, "-framerate", String.valueOf(commonArg.fps),
                        "-i", frameImagePath + "%03d.png",
                        "-pix_fmt", "yuv420p",
                        "-vcodec", "libx265",
                        "-crf", Integer.toString(commonArg.crf),
                        "-profile:v", "main",
                        "-level", "4.0",
                        "-tag:v", "hvc1",
                        "-bufsize", "2000k",
                        "-y", videoPath + TEMP_VIDEO_FILE};
            } else {
                cmd = new String[] {commonArg.ffmpegCmd, "-framerate", String.valueOf(commonArg.fps),
                        "-i", frameImagePath + "%03d.png",
                        "-pix_fmt", "yuv420p",
                        "-vcodec", "libx265",
                        "-b:v", commonArg.bitrate + "k",
                        "-profile:v", "main",
                        "-level", "4.0",
                        "-tag:v", "hvc1",
                        "-bufsize", "2000k",
                        "-y", videoPath + TEMP_VIDEO_FILE};
            }

        } else {
            if (commonArg.enableCrf) {
                cmd = new String[]{commonArg.ffmpegCmd, "-framerate", String.valueOf(commonArg.fps),
                        "-i", frameImagePath + "%03d.png",
                        "-pix_fmt", "yuv420p",
                        "-vcodec", "libx264",
                        "-crf", Integer.toString(commonArg.crf),
                        "-profile:v", "main",
                        "-level", "4.0",
                        "-bf", "0",
                        "-bufsize", "2000k",
                        "-y", videoPath + TEMP_VIDEO_FILE};
            } else {
                cmd = new String[]{commonArg.ffmpegCmd, "-framerate", String.valueOf(commonArg.fps),
                        "-i", frameImagePath + "%03d.png",
                        "-pix_fmt", "yuv420p",
                        "-vcodec", "libx264",
                        "-b:v", commonArg.bitrate + "k",
                        "-profile:v", "main",
                        "-level", "4.0",
                        "-bf", "0",
                        "-bufsize", "2000k",
                        "-y", videoPath + TEMP_VIDEO_FILE};
            }

        }

        return cmd;
    }

    /**
     * 合并音频文件
     */
    private boolean mergeAudio2Mp4(CommonArg commonArg, String tempVideoFile) throws Exception {
        String[] cmd = new String[] {commonArg.ffmpegCmd,
                "-i", commonArg.audioPath,
                "-i", commonArg.outputPath + tempVideoFile,
                "-c:v", "copy",
                "-c:a", "aac",
                "-y", commonArg.outputPath + TEMP_VIDEO_AUDIO_FILE};
        TLog.i(TAG, "run mergeAudio2Mp4");
        int result = ProcessUtil.run(cmd);
        TLog.i(TAG, "mergeAudio2Mp4 result=" + (result == 0? "success" : "fail"));
        return result == 0;
    }


    /**
     * 合并vapc.bin到mp4里
     */
    private boolean mergeBin2Mp4(CommonArg commonArg, String inputFile, String tempVideoFile, String videoPath) throws Exception {
        String[] cmd = new String[]{commonArg.mp4editCmd, "--insert", ":" + inputFile + ":3", videoPath + tempVideoFile, videoPath + VIDEO_FILE};
        TLog.i(TAG, "run mergeBin2Mp4");
        int result = ProcessUtil.run(cmd);
        TLog.i(TAG, "mergeBin2Mp4 result=" + (result == 0 ? "success" : "fail"));
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
        void onWarning(String msg);
        void onError();
        void onComplete();
    }

    private interface IRunResult {
        boolean run();
    }

}
