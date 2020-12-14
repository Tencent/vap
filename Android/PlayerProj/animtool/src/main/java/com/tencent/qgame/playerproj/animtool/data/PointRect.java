package com.tencent.qgame.playerproj.animtool.data;

public class PointRect {

    public int x = 0;
    public int y = 0;
    public int w = 0;
    public int h = 0;

    public PointRect() {
    }

    public PointRect(int x, int y, int w, int h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    @Override
    public String toString() {
        return "["+ x +","+ y +","+ w +","+ h +"]";
    }
}
