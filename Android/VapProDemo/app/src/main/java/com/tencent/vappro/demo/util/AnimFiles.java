package com.tencent.vappro.demo.util;

import android.content.Context;

import java.io.File;
import java.util.Arrays;
import java.util.List;

/**
 * mp4 动画资源列表（仅 mp4 测试）。
 * 将 assets/ 下的 mp4 测试资源拷贝到外部存储，然后供播放使用。
 */
public class AnimFiles {

    private static final String[] ANIM_FILES_ASSETS = new String[]{
            "demo.mp4",                 // 常规 VAP 动画
            "vap_car_ronghe.mp4",       // 带融合资源（图片 + 文本）
            "vap_king_ronghe.mp4",      // 带融合资源
    };

    private final Context context;
    private final List<String> animFiles = Arrays.asList(ANIM_FILES_ASSETS);

    public AnimFiles(Context context) {
        this.context = context;
    }

    public String getAnimFileName(int index) {
        if (index < 0 || index >= animFiles.size()) {
            return "";
        }
        return animFiles.get(index);
    }

    public String getAnimFilePath(int index) {
        if (index < 0 || index >= animFiles.size()) {
            return "";
        }
        return new File(context.getExternalFilesDir("/vappro/"), animFiles.get(index)).getAbsolutePath();
    }

    public int length() {
        return animFiles.size();
    }

    public void copyResourceIfNeed() {
        new Thread(() -> {
            File destinationDirectory = context.getExternalFilesDir("/vappro/");
            if (destinationDirectory == null) {
                return;
            }
            if (!destinationDirectory.exists()) {
                destinationDirectory.mkdirs();
            }
            for (String filename : ANIM_FILES_ASSETS) {
                File destFile = new File(destinationDirectory, filename);
                if (!destFile.exists()) {
                    Utils.copyAssetFile(context.getApplicationContext(), filename, destFile.toString());
                }
            }
        }).start();
    }
}
