package com.tencent.qgame.playerproj.animtool;

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
    static boolean autoFillAndCheck(CommonArg commonArg) throws Exception {

        //  路径检查
        File input = new File(commonArg.inputPath);
        if (!input.exists()) {
            TLog.i(TAG, "error: input path invalid " + commonArg.inputPath);
            return false;
        }

        if (!File.separator.equals(commonArg.inputPath.substring(commonArg.inputPath.length() - 1))) {
            commonArg.inputPath = commonArg.inputPath + File.separator;
        }
        if (!File.separator.equals(commonArg.outputPath.substring(commonArg.outputPath.length() - 1))) {
            commonArg.outputPath = commonArg.outputPath + File.separator;
        }


        // 帧图片生成路径
        commonArg.frameOutputPath = commonArg.outputPath + AnimTool.FRAME_IMAGE_DIR;

        // 检查第一帧
        File firstFrame = new File(commonArg.inputPath + "000.png");
        if (!firstFrame.exists()) {
            TLog.i(TAG, "first frame 000.png does not exist");
            return false;
        }
        // 获取视频高度
        BufferedImage inputBuf = ImageIO.read(firstFrame);
        commonArg.videoW = inputBuf.getWidth();
        commonArg.videoH = inputBuf.getHeight();
        if (commonArg.videoW <= 0 || commonArg.videoH <= 0) {
            TLog.i(TAG, "error: video size " + commonArg.videoW + "x" + commonArg.videoH);
            return false;
        }


        // 计算视频最佳方向
        commonArg.orin = commonArg.videoW >= commonArg.videoH ? CommonArg.ORIN_V : CommonArg.ORIN_H;

        // 设置元素之间宽度
        commonArg.gap = MIN_GAP;

        // 计算出 16倍数的视频
        int[] size = calSizeFill(commonArg.orin, commonArg.gap, commonArg.videoW, commonArg.videoH, 0, 0);
        commonArg.wFill = size[0];
        commonArg.hFill = size[1];


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
            TLog.i(TAG, "error: totalFrame=" + commonArg.totalFrame);
            return false;
        }



        return true;
    }

    /**
     * 寻找最小wFill & hFill情况下 整个视频宽高能被16整除
     */
    private static int[] calSizeFill(int orin, int gap, int w, int h, int wFill, int hFill) {
        int outW = (orin == CommonArg.ORIN_H ? (w * 2 + gap) : w) + wFill;
        int outH = (orin == CommonArg.ORIN_H ? h : (h * 2 + gap)) + hFill;

        boolean wCheck = outW % 16 == 0;
        boolean hCheck = outH % 16 == 0;
        if (wCheck && hCheck) {
            return new int[]{wFill, hFill};
        }

        // 递归计算
        return calSizeFill(orin, gap, w, h, wCheck? wFill : wFill + 1, hCheck? hFill : hFill + 1);
    }


}
