package com.tencent.qgame.playerproj.animtool.vapx;

import java.util.ArrayList;
import java.util.List;

public class SrcSet {


    public List<Src> srcs = new ArrayList<>();


    public static class Src {

        public static final String SRC_TYPE_IMG = "img";
        public static final String SRC_TYPE_TXT = "txt";

        public static final String LOAD_TYPE_NET = "net";
        public static final String LOAD_TYPE_LOC = "local";

        public static final String TEXT_STYLE_DEFAULT = "";
        public static final String TEXT_STYLE_BOLD = "b";

        public static final String FIT_TYPE_FITXY = "fitXY";
        public static final String FIT_TYPE_CF = "centerFull"; // 同centerCrop

        /**
         * src 配置
         */
        public String srcId = "";
        public String srcType = SRC_TYPE_IMG;
        public String loadType = LOAD_TYPE_NET;
        public String srcTag = "";
        public String color = "#000000";
        public String style = TEXT_STYLE_DEFAULT;
        public int w = 0;
        public int h = 0;
        public String fitType = FIT_TYPE_FITXY;

        /**
         * src 辅助信息
         */
        public String srcPath = "";
        public int z = 0; // 渲染层级 与输入顺序相关

        @Override
        public String toString() {
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"srcId\":").append("\"").append(srcId).append("\",");
            json.append("\"srcType\":").append("\"").append(srcType).append("\",");
            json.append("\"srcTag\":").append("\"").append(srcTag.trim()).append("\",");
            if (SRC_TYPE_TXT.equals(srcType)) {
                if (color != null && color != null) {
                    json.append("\"color\":").append("\"").append(color.trim()).append("\",");
                }
                json.append("\"style\":").append("\"").append(style).append("\",");
                json.append("\"loadType\":").append("\"").append(LOAD_TYPE_LOC).append("\",");
            } else {
                json.append("\"loadType\":").append("\"").append(loadType).append("\",");
            }


            json.append("\"fitType\":").append("\"").append(fitType).append("\",");
            json.append("\"w\":").append(w).append(",");
            json.append("\"h\":").append(h);
            json.append("}");

            return json.toString();
        }
    }

    @Override
    public String toString() {
        StringBuilder json = new StringBuilder();

        json.append("\"src\":[");
        Src src;
        for (int i=0; i<srcs.size(); i++) {
            src = srcs.get(i);
            json.append(src.toString());
            if (i != srcs.size() - 1) {
                json.append(",");
            }
        }

        json.append("]");

        return json.toString();
    }
}
