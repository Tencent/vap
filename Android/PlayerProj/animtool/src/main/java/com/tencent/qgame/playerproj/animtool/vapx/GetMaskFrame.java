package com.tencent.qgame.playerproj.animtool.vapx;

import com.tencent.qgame.playerproj.animtool.CommonArg;
import com.tencent.qgame.playerproj.animtool.TLog;
import com.tencent.qgame.playerproj.animtool.data.PointRect;

import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.File;

import javax.imageio.ImageIO;

/**
 * 获取融合动画遮罩
 */
public class GetMaskFrame {

    private static final String TAG = "GetMaskFrame";

    public FrameSet.FrameObj getFrameObj(int frameIndex, CommonArg commonArg, int[] outputArgb) throws Exception {

        FrameSet.FrameObj frameObj = new FrameSet.FrameObj();
        frameObj.frameIndex = frameIndex;

        FrameSet.Frame frame;
        // 需要放置的位置
        int x;
        int y;
        int gap = commonArg.gap;
        if (commonArg.isVLayout) {
            x = commonArg.alphaPoint.w + gap;
            y = commonArg.alphaPoint.y;
        } else {
            x = commonArg.alphaPoint.x;
            y = commonArg.alphaPoint.h + gap;
        }
        int startX = x;
        int lastMaxY = y;
        for (int i=0; i<commonArg.srcSet.srcs.size(); i++) {
            frame = getFrame(frameIndex, commonArg.srcSet.srcs.get(i), outputArgb, commonArg.outputW, commonArg.outputH, x, y, startX, lastMaxY);
            if (frame == null) continue;
            // 计算下一个遮罩起点
            x = frame.mFrame.x + frame.mFrame.w + gap;
            y = frame.mFrame.y;
            int newY = frame.mFrame.y + frame.mFrame.h + gap;
            if (newY > lastMaxY) {
                lastMaxY = newY;
            }

            frameObj.frames.add(frame);
        }

        if (frameObj.frames.isEmpty()) {
            return null;
        }
        return frameObj;
    }


    private FrameSet.Frame getFrame(int frameIndex, SrcSet.Src src, int[] outputArgb, int outW, int outH, int x, int y, int startX, int lastMaxY) throws Exception {
        File inputFile = new File(src.srcPath  + String.format("%03d", frameIndex)+".png");
        if (!inputFile.exists()) {
            return null;
        }

        BufferedImage inputBuf = ImageIO.read(inputFile);
        int maskW = inputBuf.getWidth();
        int maskH = inputBuf.getHeight();
        int[] maskArgb = inputBuf.getRGB(0, 0, maskW, maskH, null, 0, maskW);

        FrameSet.Frame frame = new FrameSet.Frame();
        frame.srcId = src.srcId;
        frame.z = src.z;

        frame.frame = getSrcFramePoint(maskArgb, maskW, maskH);
        if (frame.frame == null) {
            // 有文件，但内容是空
            return null;
        }

        PointRect maskPoint = new PointRect(
            frame.frame.x,
            frame.frame.y,
            frame.frame.w,
            frame.frame.h
        );

        PointRect mFrame = new PointRect(x, y, frame.frame.w, frame.frame.h);
        // 计算是否能放下遮罩
        if (mFrame.x + mFrame.w > outW) { // 超宽换行
            mFrame.x = startX;
            mFrame.y = lastMaxY;
            if (mFrame.x + mFrame.w > outW) {
                // 超长后缩放mask
                float scale = (outW - mFrame.x) * 1f / mFrame.w;

                mFrame.w = outW - mFrame.x;
                mFrame.h = (int) (mFrame.h * scale);

                // 设置缩放区域
                maskPoint.x = (int) (maskPoint.x * scale);
                maskPoint.y = (int) (maskPoint.y * scale);
                maskPoint.h = mFrame.h;
                maskPoint.w = mFrame.w;

                maskArgb = scaleMask(scale, inputBuf);

                TLog.w(TAG, "frameIndex=" + frameIndex + ",src=" + src.srcId + ", no more space for(w)" + mFrame + ",scale=" + scale);
            }
        }
        if (mFrame.y + mFrame.h > outH) { // 高度不够直接错误
            TLog.e(TAG, "frameIndex=" + frameIndex + ",src=" + src.srcId + ", no more space(h)" + mFrame);
            return null;
        }
        frame.mFrame = mFrame;

        fillMaskToOutput(outputArgb, outW, maskArgb, maskW, maskPoint, frame.mFrame);

        // 设置src的w,h 取所有遮罩里最大值
        synchronized (GetMaskFrame.class) {
            // 只按宽度进行判断防止横跳
            if (frame.frame.w > src.w) {
                src.w = frame.frame.w;
                src.h = frame.frame.h;
            }
        }
        return frame;
    }

    /**
     * 缩放遮罩
     */
    private int[] scaleMask(float scale, BufferedImage inputBuf) {
        AffineTransform at = new AffineTransform();
        at.scale(scale, scale);

        int w = inputBuf.getWidth();
        int h = inputBuf.getHeight();
        BufferedImage alphaBuf = new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
        AffineTransformOp scaleOp = new AffineTransformOp(at, AffineTransformOp.TYPE_BILINEAR);
        alphaBuf = scaleOp.filter(inputBuf, alphaBuf);

        return alphaBuf.getRGB(0, 0, w, h, null, 0, w);
    }

    /**
     * 获取遮罩位置信息 并转换为黑白
     */
    private PointRect getSrcFramePoint(int[] maskArgb, int w, int h) {

        PointRect point = new PointRect();

        int minX = Integer.MAX_VALUE;
        int minY = Integer.MAX_VALUE;
        int maxX = 0;
        int maxY = 0;
        for (int y=0; y<h; y++) {
            for (int x = 0; x < w; x++) {
                int alpha = maskArgb[x + y*w] >>> 24;
                if (alpha > 0) {
                    if (x < minX) minX = x;
                    if (y < minY) minY = y;
                    if (x > maxX) maxX = x;
                    if (y > maxY) maxY = y;
                }
            }
        }

        point.x = minX;
        point.y = minY;
        point.w = maxX - minX + 1;
        point.h = maxY - minY + 1;
        if (point.w <=0 || point.h <= 0) return null;

        return point;

    }


    private void fillMaskToOutput(int[] outputArgb, int outW,
                                  int[] maskArgb, int maskW,
                                  PointRect frame,
                                  PointRect mFrame) {
        for (int y=0; y < frame.h; y++) {
            for (int x=0; x < frame.w; x++) {
                int maskXOffset = frame.x;
                int maskYOffset = frame.y;
                // 先从遮罩 maskArgb 取色
                int maskColor = maskArgb[x + maskXOffset + (y + maskYOffset) * maskW];
                // 黑色部分不遮挡，红色部分被遮挡
                int alpha = maskColor >>> 24;
                int maskRed = (maskColor & 0x00ff0000) >>> 16;
                int redAlpha = 255 - maskRed; // 红色部分算遮挡
                alpha = (int) ((redAlpha / 255f) * (alpha / 255f) * 255f);
                // 最终color
                int color = 0xff000000 + (alpha << 16) + (alpha << 8) + alpha;

                // 将遮罩颜色放置到视频中对应区域
                int outputXOffset = mFrame.x;
                int outputYOffset = mFrame.y;
                outputArgb[x + outputXOffset + (y + outputYOffset) * outW] = color;

            }
        }
    }

}
