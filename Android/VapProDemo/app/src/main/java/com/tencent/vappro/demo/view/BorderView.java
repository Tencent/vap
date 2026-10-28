package com.tencent.vappro.demo.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;

public class BorderView extends View {

    private Paint borderPaint;
    private RectF borderRect;
    private static final int BORDER_COLOR = 0xFFFF0000;
    private static final int BORDER_WIDTH = 2;

    public BorderView(Context context) {
        super(context);
        init();
    }

    public BorderView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public BorderView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        borderPaint = new Paint();
        borderPaint.setStyle(Paint.Style.STROKE);
        borderPaint.setStrokeWidth(BORDER_WIDTH);
        borderPaint.setColor(BORDER_COLOR);
        borderRect = new RectF();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        borderRect.set(BORDER_WIDTH / 2f, BORDER_WIDTH / 2f,
                getWidth() - BORDER_WIDTH / 2f, getHeight() - BORDER_WIDTH / 2f);
        canvas.drawRect(borderRect, borderPaint);
    }
}
