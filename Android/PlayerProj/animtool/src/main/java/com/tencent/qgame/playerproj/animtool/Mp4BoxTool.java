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

import java.io.*;

/**
 * mp4 box 处理类
 * 生成对应的box bin
 * 执行 mp4edit --insert :vapc.bin:1 demo_origin.mp4 demo_output.mp4 插入对应个box
 */
public class Mp4BoxTool {

    private static final String TAG = "Mp4BoxTool";

    /**
     * 输入json文件，输出vapc.bin可以直接进行mp4合成
     */
    public String create(String inputFile, String outputPath) throws Exception {
        File input = new File(inputFile);
        if (!input.exists() || !input.isFile()) {
            TLog.i(TAG, "input file not exist");
            return null;
        }
        checkDir(outputPath);
        File output = new File(outputPath + AnimTool.VAPC_BIN_FILE);
        InputStream is = new FileInputStream(input);
        OutputStream os = new FileOutputStream(output);
        // 8字节的box头部
        byte[] boxHead = getBoxHead(input.length());
        os.write(boxHead, 0, boxHead.length);

        // 复制文件
        byte[] buffer = new byte[8192];
        int length;
        while ((length = is.read(buffer)) > 0) {
            os.write(buffer, 0, length);
        }
        is.close();
        os.close();
        TLog.i(TAG, "success");
        return output.getAbsolutePath();
    }

    private void checkDir(String path) {
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
    }

    private byte[] getBoxHead(long fileLen) {
        // 加上头部的8字节
        fileLen += 8;
        byte[] boxHead = new byte[8];
        // 只取4字节，大于2G的文件一概不处理
        boxHead[0] = (byte) (fileLen >>> 24 & 0xff);
        boxHead[1] = (byte) (fileLen >>> 16 & 0xff);
        boxHead[2] = (byte) (fileLen >>>  8 & 0xff);
        boxHead[3] = (byte) (fileLen & 0xff);

        // 插入vapc
        boxHead[4] = 0x76;
        boxHead[5] = 0x61;
        boxHead[6] = 0x70;
        boxHead[7] = 0x63;

        return boxHead;
    }


    /**
     * 取出mp4文件中vapc部分json内容
     */
    public void parse(String inputFile, String outputPath) throws Exception {
        File input = new File(inputFile);
        if (!input.exists() || !input.isFile()) {
            TLog.i(TAG, "input file not exist");
            return;
        }

        // 查找vapc box
        RandomAccessFile mp4File = new RandomAccessFile(inputFile, "r");

        byte[] boxHead = new byte[8];
        BoxHead head = null;
        long vapcStartIndex = 0;
        while (mp4File.read(boxHead, 0 , boxHead.length) == 8) {
            head = parseBoxHead(boxHead);
            if (head == null) break;
            if ("vapc".equals(head.type)) {
                head.startIndex = vapcStartIndex;
                break;
            }
            mp4File.seek(head.length);
            vapcStartIndex += head.length;
        }

        if (head == null) {
            TLog.i(TAG, "vapc box head not found");
            return;
        }

        // 读取vapc box
        byte[] vapcBuf = new byte[(int) (head.length - 8)]; // ps: OOM exception
        mp4File.seek(head.startIndex + 8); // 减去头部8字节
        mp4File.read(vapcBuf);
        mp4File.close();

        checkDir(outputPath);
        File output = new File(outputPath + AnimTool.VAPC_JSON_FILE);

        OutputStream os = new FileOutputStream(output);
        // 8字节的box头部
        os.write(vapcBuf, 0, vapcBuf.length);
        os.close();

        String json = new String(vapcBuf,0, vapcBuf.length, "UTF-8");
        TLog.i(TAG, "success");
        TLog.i(TAG, json);
    }

    private BoxHead parseBoxHead(byte[] boxHead) throws Exception {
        if (boxHead.length != 8) return null;
        BoxHead head = new BoxHead();
        long length = 0;
        length = length | ((boxHead[0] & 0xff) << 24);
        length = length | ((boxHead[1] & 0xff) << 16);
        length = length | ((boxHead[2] & 0xff) <<  8);
        length = length |  (boxHead[3] & 0xff);
        head.length = length;
        head.type = new String(boxHead,4, 4, "US-ASCII");
        return head;
    }

    class BoxHead {
        long startIndex;
        long length;
        String type;
    }


}
