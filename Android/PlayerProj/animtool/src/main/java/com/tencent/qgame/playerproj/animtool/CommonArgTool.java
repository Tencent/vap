package com.tencent.qgame.playerproj.animtool;

import com.tencent.qgame.playerproj.animtool.vapx.SrcSet;

import java.awt.image.BufferedImage;
import java.io.File;

import javax.imageio.ImageIO;

/**
 * 构造参数
 */
class CommonArgTool {

    private static final String TAG = "CommonArgTool";
    private static final int MIN_GAP = 4; // 元素最小间隙 防止编码与光栅化导致边界模糊问题

    /**
     * 参数自动填充
     * @param commonArg
     */
    static boolean autoFillAndCheck(CommonArg commonArg, AnimTool.IToolListener toolListener) throws Exception {

        String os = System.getProperty("os.name");
        TLog.i(TAG, os);

        if (commonArg.inputPath == null && "".equals(commonArg.inputPath)) {
            TLog.e(TAG, "input path invalid");
            return false;
        }

        //  路径检查
        File input = new File(commonArg.inputPath);
        if (!input.exists()) {
            TLog.e(TAG, "input path invalid " + commonArg.inputPath);
            return false;
        }

        if (!File.separator.equals(commonArg.inputPath.substring(commonArg.inputPath.length() - 1))) {
            commonArg.inputPath = commonArg.inputPath + File.separator;
        }

        // 检查音频文件是否存在
        if (commonArg.needAudio) {
            File audio = new File(commonArg.audioPath);
            if (!audio.exists() || commonArg.audioPath == null || commonArg.audioPath.length() < 3) {
                TLog.e(TAG , "audio file not exists " + commonArg.audioPath);
                return false;
            }
            String type = commonArg.audioPath.substring(commonArg.audioPath.length() - 3).toLowerCase();
            if (!"mp3".equals(type)) {
                TLog.e(TAG , "audio file must be mp3 file " + commonArg.audioPath);
                return false;
            }
        }

        // output path
        commonArg.outputPath = commonArg.inputPath + AnimTool.OUTPUT_DIR;

        // 帧图片生成路径
        commonArg.frameOutputPath = commonArg.outputPath + AnimTool.FRAME_IMAGE_DIR;

        // srcId自动生成 & 融合动画路径检查 & z序
        if (commonArg.isVapx) {
            // vapx 强制缩小
            commonArg.scale = 0.5f;
            int size = commonArg.srcSet.srcs.size();
            SrcSet.Src src;
            for (int i=0; i<size; i++) {
                src = commonArg.srcSet.srcs.get(i);
                src.srcId = String.valueOf(i);
                src.z = i;
                File srcPath = new File(src.srcPath);
                if (!srcPath.exists()) {
                    TLog.e(TAG, "src="+ src.srcId+",path invalid " + src.srcPath);
                    continue;
                }
                if (!File.separator.equals(src.srcPath.substring(src.srcPath.length() - 1))) {
                    src.srcPath = src.srcPath + File.separator;
                }
            }
        }

        // 限定scale的值
        if (commonArg.scale < 0.5f) {
            commonArg.scale = 0.5f;
        }

        if (commonArg.scale > 1f) {
            commonArg.scale = 1f;
        }

        // 检查第一帧
        File firstFrame = new File(commonArg.inputPath + "000.png");
        if (!firstFrame.exists()) {
            TLog.e(TAG, "first frame 000.png does not exist");
            return false;
        }
        // 获取视频高度
        BufferedImage inputBuf = ImageIO.read(firstFrame);
        commonArg.rgbPoint.w = inputBuf.getWidth();
        commonArg.rgbPoint.h = inputBuf.getHeight();
        if (commonArg.rgbPoint.w <= 0 || commonArg.rgbPoint.h <= 0) {
            TLog.e(TAG, "video size " + commonArg.rgbPoint.w + "x" + commonArg.rgbPoint.h);
            return false;
        }

        // 设置元素之间宽度
        commonArg.gap = MIN_GAP;

        // 计算alpha区域大小
        commonArg.alphaPoint.w = (int) (commonArg.rgbPoint.w * commonArg.scale);
        commonArg.alphaPoint.h = (int) (commonArg.rgbPoint.h * commonArg.scale);

        // 计算视频最佳方向 (最长边最小原则)
        int hW = commonArg.rgbPoint.w + commonArg.gap + commonArg.alphaPoint.w;
        int hH = commonArg.rgbPoint.h;
        int hMaxLen = Math.max(hW, hH);

        int vW = commonArg.rgbPoint.w;
        int vH = commonArg.rgbPoint.h + commonArg.gap + commonArg.alphaPoint.h;
        int vMaxLen = Math.max(vW, vH);

        if (hMaxLen > vMaxLen) { // 竖直布局
            commonArg.isVLayout = true;
            commonArg.alphaPoint.x = 0;
            commonArg.alphaPoint.y = commonArg.rgbPoint.h + commonArg.gap;

            commonArg.outputW = commonArg.rgbPoint.w;
            commonArg.outputH = commonArg.rgbPoint.h + commonArg.gap + commonArg.alphaPoint.h;
        } else { // 水平布局
            commonArg.isVLayout = false;
            commonArg.alphaPoint.x = commonArg.rgbPoint.w + commonArg.gap;
            commonArg.alphaPoint.y = 0;

            commonArg.outputW = commonArg.rgbPoint.w + commonArg.gap + commonArg.alphaPoint.w;
            commonArg.outputH = commonArg.rgbPoint.h;
        }

        // 计算出 16倍数的视频
        int[] size = calSizeFill(commonArg.outputW, commonArg.outputH);
        // 得到最终视频宽高
        commonArg.outputW += size[0];
        commonArg.outputH += size[1];

        if (commonArg.outputW > 1504 || commonArg.outputH > 1504) {
            String msg = "[Warning] Output video width:" + commonArg.outputW + " or height:" + commonArg.outputH
                    + " is over 1504. Some devices will display exception. For example green screen!";
            TLog.w(TAG, msg);
            if (toolListener != null) {
                toolListener.onWarning(msg);
            }
        }

        // 获取总帧数
        commonArg.totalFrame = 0;
        for (int i=0; i<=999; i++) {
            File frameFile = new File(commonArg.inputPath + String.format("%03d", i) + ".png");
            // 顺序检查
            if (!frameFile.exists()) {
                break;
            }
            commonArg.totalFrame++;
        }


        if (commonArg.totalFrame <= 0) {
            TLog.e(TAG, "totalFrame=" + commonArg.totalFrame);
            return false;
        }

        // 码率检查
        if (!commonArg.enableCrf && commonArg.bitrate <= 0) {
            TLog.e(TAG, "bitrate=" + commonArg.bitrate);
            return false;
        }

        // crf检查
        if (commonArg.enableCrf && (commonArg.crf < 0 || commonArg.crf > 51)) {
            TLog.e(TAG, "crf=" + commonArg.crf + ", no in [0, 51]");
            return false;
        }

        return true;
    }

    /**
     * 寻找最小wFill & hFill情况下 整个视频宽高能被16整除
     */
    private static int[] calSizeFill(int outW, int outH) {
        int wFill = 0;
        if (outW % 16 != 0) {
            wFill = ((outW / 16) + 1) * 16 - outW;
        }

        int hFill = 0;
        if (outH % 16 != 0) {
            hFill = ((outH / 16) + 1) * 16 - outH;
        }
        return new int[]{wFill, hFill};
    }


}
