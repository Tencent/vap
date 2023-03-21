package com.tencent.vapcli;

import com.tencent.qgame.playerproj.animtool.AnimTool;
import com.tencent.qgame.playerproj.animtool.CommonArg;
import picocli.CommandLine;
import picocli.CommandLine.Command;
import picocli.CommandLine.Option;

import java.util.concurrent.Callable;


@Command(name = "vapcli", mixinStandardHelpOptions = true, version = "1.0",
        description = "Vap CLI")
public class Main implements Callable<Integer> {

    @Option(names = {"--ffmpeg"}, description = "ffmpeg命令路径，如 /path/to/ffmpeg", required = true)
    private String ffmpegBin = "ffmpeg";

    @Option(names = {"--mp4edit"}, description = "mp4edit命令路径，如 /path/to/mp4edit", required = true)
    private String mp4editBin = "mp4edit";

    @Option(names = {"--h265"}, description = "是否开启h265")
    private boolean enableH265 = false;

    @Option(names = {"--enableCrf"}, description = "是否开启可变码率")
    private boolean enableCrf = false;

    @Option(names = {"--fps"}, description = "fps")
    private int fps = 24;

    @Option(names = {"-i", "--input-dir"}, description = "素材文件夹路径", required = true)
    private String inputDir;

    @Option(names = {"--scale"}, description = "alpha 区域缩放大小 (0.5 - 1)")
    private float scale = 0.5f;

    @Option(names = {"--bitrate"}, description = "码率")
    private int bitrate = 2000;

    @Option(names = {"--crf"}, description = "0(无损) - 50(最大压缩)")
    private int crf = 29;

    @Override
    public Integer call() throws Exception {
        final CommonArg commonArg = new CommonArg();

        commonArg.ffmpegCmd = this.ffmpegBin;
        commonArg.mp4editCmd = this.mp4editBin;
        commonArg.enableH265 = this.enableH265;
        commonArg.fps = this.fps;
        commonArg.inputPath = this.inputDir;
        commonArg.scale = this.scale;
        commonArg.bitrate = this.bitrate;
        commonArg.crf = this.crf;

        System.out.println("all args:");
        for(String str: commonArg.toString().replaceFirst("CommonArg\\{", "").split(", ")) {
            System.out.println("\t" + str);
        }

        AnimTool animTool = new AnimTool();

        animTool.setToolListener(new AnimTool.IToolListener() {
            @Override
            public void onProgress(float progress) {
                int p = (int)(progress * 100f);
                System.out.println("onProgress: " + (Math.min(p, 99)) + "%");
            }

            @Override
            public void onWarning(String msg) {
                System.err.println("onWarning: " + msg);
            }

            @Override
            public void onError() {
                System.err.println("onError!!!!!!!!");
                System.exit(1);
            }

            @Override
            public void onComplete() {
                System.out.println("onComplete: " + commonArg.outputPath);
                System.exit(0);
            }
        });

        try {
            animTool.create(commonArg, true);
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(1);
        }

        return 0;
    }

    public static void main(String[] args) {
        System.out.println("Vap CLI START");

        new CommandLine(new Main()).execute(args);
    }
}
