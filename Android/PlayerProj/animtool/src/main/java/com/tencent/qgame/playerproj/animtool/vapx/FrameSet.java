package com.tencent.qgame.playerproj.animtool.vapx;

import com.tencent.qgame.playerproj.animtool.data.PointRect;

import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

public class FrameSet {

    // for sync
    public Vector<FrameObj> frameObjs = new Vector<>();

    @Override
    public String toString() {
        StringBuilder json = new StringBuilder();

        json.append("\"frame\":[");
        FrameSet.FrameObj frameObj;
        for (int i=0; i<frameObjs.size(); i++) {
            frameObj = frameObjs.get(i);
            json.append(frameObj.toString());
            if (i != frameObjs.size() - 1) {
                json.append(",");
            }
        }

        json.append("]");

        return json.toString();
    }

    public static class FrameObj {
        public List<Frame> frames = new ArrayList<>();
        public int frameIndex = 0;

        @Override
        public String toString() {
            StringBuilder json = new StringBuilder();

            json.append("{");
            json.append("\"i\":").append(frameIndex).append(",");
            json.append("\"obj\":[");
            FrameSet.Frame frame;
            for (int i=0; i<frames.size(); i++) {
                frame = frames.get(i);
                json.append(frame.toString());
                if (i != frames.size() - 1) {
                    json.append(",");
                }
            }
            json.append("]");
            json.append("}");

            return json.toString();
        }
    }

    public static class Frame {
        public String srcId = "";
        public int z = 0;
        public int mt = 0; // 旋转角度 目前只支持0
        public PointRect frame = new PointRect(); // src位置
        public PointRect mFrame = new PointRect(); // 遮罩区域


        @Override
        public String toString() {

            return "{" +
                    "\"srcId\":" + "\"" + srcId + "\"," +
                    "\"z\":" + z + "," +
                    "\"frame\":" + frame.toString() + "," +
                    "\"mFrame\":" + mFrame.toString() + "," +
                    "\"mt\":" + mt +
                    "}";
        }
    }
}
