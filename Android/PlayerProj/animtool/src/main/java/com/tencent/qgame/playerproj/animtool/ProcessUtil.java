package com.tencent.qgame.playerproj.animtool;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;


/**
 * porcess.waitFor() 必须读取执行结果
 * https://www.javaworld.com/javaworld/jw-12-2000/jw-1229-traps.html
 */
class ProcessUtil {

    public static int run(String[] cmd) throws Exception {
        Process proc = Runtime.getRuntime().exec(cmd);

        StreamReader errorReader = new StreamReader(proc.getErrorStream(), "ERROR");
        StreamReader outputReader = new StreamReader(proc.getInputStream(), "OUTPUT");
        errorReader.start();
        outputReader.start();

        int result = proc.waitFor();
        if (result != 0) TLog.i(errorReader.type, errorReader.sb.toString());
        return result;
    }

    private static class StreamReader extends Thread {
        InputStream is;
        String type;
        StringBuilder sb = new StringBuilder();

        StreamReader(InputStream is, String type) {
            this.is = is;
            this.type = type;
        }

        public void run() {
            try {
                InputStreamReader isr = new InputStreamReader(is);
                BufferedReader br = new BufferedReader(isr);
                String line = null;
                while ((line = br.readLine()) != null) {
                    sb.append(line);
                    sb.append("\n");
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
