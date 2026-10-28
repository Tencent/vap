package com.tencent.vappro.demo;

import android.app.Application;
import android.content.Context;

public class DemoApplication extends Application {
    private static Context mAppContext;

    @Override
    public void onCreate() {
        super.onCreate();
        mAppContext = getApplicationContext();

        // 初始化鉴权，确保在使用 TCEffectAnimView 前完成
        TCMediaXLicenseService.getInstance().init();
    }

    public static Context getAppContext() {
        return mAppContext;
    }
}
