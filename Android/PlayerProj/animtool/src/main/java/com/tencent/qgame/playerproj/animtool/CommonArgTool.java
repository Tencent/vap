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

        String os = System.getProperty("os.name");
        TLog.i(TAG, os);

        if (commonArg.inputPath == null && "".equals(commonArg.inputPath)) {
            TLog.i(TAG, "error: input path invalid");
            return false;
        }

        //  路径检查
        File input = new File(commonArg.inputPath);
        if (!input.exists()) {
            TLog.i(TAG, "error: input path invalid " + commonArg.inputPath);
            return false;
        }

        if (!File.separator.equals(commonArg.inputPath.substring(commonArg.inputPath.length() - 1))) {
            commonArg.inputPath = commonArg.inputPath + File.separator;
        }
        // output path
        commonArg.outputPath = commonArg.inputPath + AnimTool.OUTPUT_DIR;

        // 帧图片生成路径
        commonArg.frameOutputPath = commonArg.outputPath + AnimTool.FRAME_IMAGE_DIR;


        // 限定scale的值
        if (commonArg.scale < 0.5f) {
            commonArg.scale =0.5f;
        }

        if (commonArg.scale > 1f) {
            commonArg.scale = 1f;
        }

        // 检查第一帧
        File firstFrame = new File(commonArg.inputPath + "000.png");
        if (!firstFrame.exists()) {
            TLog.i(TAG, "error: first frame 000.png does not exist");
            return false;
        }
        // 获取视频高度
        BufferedImage inputBuf = ImageIO.read(firstFrame);
        commonArg.rgbPoint.w = inputBuf.getWidth();
        commonArg.rgbPoint.h = inputBuf.getHeight();
        if (commonArg.rgbPoint.w <= 0 || commonArg.rgbPoint.h <= 0) {
            TLog.i(TAG, "error: video size " + commonArg.rgbPoint.w + "x" + commonArg.rgbPoint.h);
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
            commonArg.alphaPoint.x = 0;
            commonArg.alphaPoint.y = commonArg.rgbPoint.h + commonArg.gap;

            commonArg.outputW = commonArg.rgbPoint.w;
            commonArg.outputH = commonArg.rgbPoint.h + commonArg.gap + commonArg.alphaPoint.h;
        } else { // 水平布局
            commonArg.alphaPoint.x = commonArg.rgbPoint.w + commonArg.gap;
            commonArg.alphaPoint.y = 0;

            commonArg.outputW = commonArg.rgbPoint.w + commonArg.gap + commonArg.alphaPoint.w;
            commonArg.outputH = commonArg.rgbPoint.h;
        }

        // 计算出 16倍数的视频
        int[] size = calSizeFill( commonArg.outputW, commonArg.outputH, 0, 0);
        // 得到最终视频宽高
        commonArg.outputW += size[0];
        commonArg.outputH += size[1];


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
    private static int[] calSizeFill(int outW, int outH, int wFill, int hFill) {
        boolean wCheck = (outW + wFill)% 16 == 0;
        boolean hCheck = (outH + hFill) % 16 == 0;

        if (wCheck && hCheck) {
            return new int[]{wFill, hFill};
        }

        // 递归计算
        return calSizeFill(outW, outH, wCheck? wFill : wFill + 1, hCheck? hFill : hFill + 1);
    }


}
