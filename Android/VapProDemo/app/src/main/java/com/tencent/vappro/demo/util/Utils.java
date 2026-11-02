package com.tencent.vappro.demo.util;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import java.io.Closeable;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

public class Utils {
    private static final String TAG = "Utils";

    public static void copyAssetFile(Context context, String assetFile, String dstFile) {
        AssetManager assetManager = context.getAssets();
        InputStream in = null;
        OutputStream out = null;
        try {
            in = assetManager.open(assetFile);
            out = new FileOutputStream(dstFile);
            copyFile(in, out);
        } catch (IOException e) {
            Log.e(TAG, "copy asset file failed.", e);
        } finally {
            closeQuietly(in);
            if (out != null) {
                try {
                    out.flush();
                    out.close();
                } catch (IOException e) {
                    // ignored
                }
            }
        }
    }

    public static void copyFile(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[8 * 1024];
        int read;
        while ((read = in.read(buffer)) != -1) {
            out.write(buffer, 0, read);
        }
    }

    public static void closeQuietly(final Closeable closeable) {
        try {
            if (closeable != null) {
                closeable.close();
            }
        } catch (final IOException ioe) {
            // ignore
        }
    }
}
