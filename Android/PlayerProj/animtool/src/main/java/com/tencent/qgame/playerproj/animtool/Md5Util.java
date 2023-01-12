/*
 * Tencent is pleased to support the open source community by making vap available.
 *
 * Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
 *
 * Licensed under the MIT License (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 *
 * http://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is
 * distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
 * either express or implied. See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.tencent.qgame.playerproj.animtool;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;

public class Md5Util {
    public static final String MD5_FILE = "md5.txt";
    private char[] hexDigits = new char[] {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};


    public String getFileMD5(File file, String outputPath) {
        if (!file.exists() || !file.isFile() || file.length() <= 0) {
            return null;
        }
        InputStream inputStream = null;
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            inputStream = new FileInputStream(file);
            byte[] dataBytes = new byte[4096];
            int iRd = inputStream.read(dataBytes);
            while (iRd != -1) {
                md.update(dataBytes, 0, iRd);
                iRd = inputStream.read(dataBytes);
            }
            inputStream.close();
            byte[] digest = md.digest();
            String md5txt = "";
            if (digest != null) {
                md5txt = bufferToHex(digest);
            }
            try {
                BufferedWriter writer = new BufferedWriter(new FileWriter(outputPath + MD5_FILE));
                writer.write(md5txt);
                writer.flush();
                writer.close();
            } catch (IOException e) {
                e.printStackTrace();
                throw new RuntimeException();
            }
            return md5txt;
        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            if (inputStream != null) {
                try {
                    inputStream.close();
                } catch (Throwable e) {
                    e.printStackTrace();
                }

            }
        }
        return null;
    }

    private String bufferToHex(byte[] bytes) {
        return bufferToHex(bytes, 0, bytes.length);
    }

    private String bufferToHex(byte[] bytes, int m, int n) {
        StringBuffer sb = new StringBuffer(2 * n);
        int k = m + n;
        for (int l=m; l<k; l++) {
            appendHexPair(bytes[l], sb);
        }
        return sb.toString();
    }

    private void appendHexPair(byte bt, StringBuffer sb) {
        char c0 = hexDigits[(bt & 0xf0) >>> 4];
        char c1 = hexDigits[bt & 0x0f];
        sb.append(c0);
        sb.append(c1);
    }
}
