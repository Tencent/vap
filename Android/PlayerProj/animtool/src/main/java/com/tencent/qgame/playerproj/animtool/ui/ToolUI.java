package com.tencent.qgame.playerproj.animtool.ui;

import com.tencent.qgame.playerproj.animtool.AnimTool;
import com.tencent.qgame.playerproj.animtool.CommonArg;
import com.tencent.qgame.playerproj.animtool.TLog;

import java.awt.Desktop;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

import javax.swing.BoxLayout;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SpinnerModel;
import javax.swing.SpinnerNumberModel;

public class ToolUI {

    private static final String TAG = "ToolUI";
    private static final String TOOL_VERSION = "VAP tool 2.0.6";
    private static final String PROPERTIES_FILE = "setting.properties";
    public static final int WIDTH = 900;
    public static final int HEIGHT = 750;

    private final JFrame frame = new JFrame(TOOL_VERSION);
    private final ButtonGroup group = new ButtonGroup();
    private final JRadioButton btnH264 = new JRadioButton("h264");
    private final JRadioButton btnH265 = new JRadioButton("h265");
    private final SpinnerModel modelFps = new SpinnerNumberModel(24, 1, 60, 1);
    private final Float[] scaleArray = new Float[]{0.5f, 1f};
    private final JComboBox<Float> boxScale = new JComboBox<>(scaleArray);
    private final JTextField textInputPath = new JTextField();
    private final JButton btnCreate = new JButton("create VAP");
    private final JTextArea txtAreaLog = new JTextArea();
    private final JTextField textAudioPath = new JTextField();
    private final JPanel panelAudioPath = new JPanel();

    private final JPanel panelBitrate = new JPanel();
    private final JTextField textBitrate = new JTextField();
    private final JPanel panelCrf = new JPanel();
    private final JTextField textCrf = new JTextField();

    private final ButtonGroup groupQuality = new ButtonGroup();
    private final JRadioButton btnBitrate = new JRadioButton("bitrate");
    private final JRadioButton btnCrf = new JRadioButton("crf");

    private final JLabel labelOutInfo = new JLabel();
    private final Dimension labelSize = new Dimension(100, 20);
    private final Properties props = new Properties();
    private final VapxUI vapxUI = new VapxUI(this);

    private boolean needAudio = false;

    private final ItemListener qualityGroupListener = new ItemListener() {
        @Override
        public void itemStateChanged(ItemEvent itemEvent) {
            if (itemEvent.getSource() == btnBitrate) {
                panelBitrate.setVisible(true);
                panelCrf.setVisible(false);
            } else if (itemEvent.getSource() == btnCrf) {
                panelBitrate.setVisible(false);
                panelCrf.setVisible(true);
            }
        }
    };

    public ToolUI() {
        TLog.logger = new TLog.ITLog() {
            @Override
            public void i(String tag, String msg) {
                log(tag, msg);
            }

            @Override
            public void e(String tag, String msg) {
                log(tag, "Error:" + msg);
            }

            @Override
            public void w(String tag, String msg) {
                log(tag, "Warning:" + msg);
            }
        };
    }


    public void run() {
        createUI();
        loadProperties();
    }

    private void loadProperties() {
        try {
            File file = new File(PROPERTIES_FILE);
            if (!file.exists()) {
                file.createNewFile();
            }
            props.load(new InputStreamReader(new FileInputStream(PROPERTIES_FILE), StandardCharsets.UTF_8));
            CommonArg commonArg = getProperties();
            group.setSelected(commonArg.enableH265 ? btnH265.getModel() : btnH264.getModel(), true);
            modelFps.setValue(commonArg.fps);
            textInputPath.setText(commonArg.inputPath);
            textAudioPath.setText(commonArg.audioPath);
            textBitrate.setText(String.valueOf(commonArg.bitrate));
            textCrf.setText(String.valueOf(commonArg.crf));
            groupQuality.setSelected(commonArg.enableCrf ? btnCrf.getModel() : btnBitrate.getModel(), true);
            if (commonArg.enableCrf) {
                panelBitrate.setVisible(false);
                panelCrf.setVisible(true);
            } else {
                panelBitrate.setVisible(true);
                panelCrf.setVisible(false);
            }

            float scale = commonArg.scale;
            for (int i = 0; i < scaleArray.length ; i++) {
                if (scaleArray[i] == scale) {
                    boxScale.setSelectedIndex(i);
                    break;
                }
            }
        } catch (Exception e) {
            TLog.e(TAG, e.getMessage());
        }
    }

    private void runTool() {
        txtAreaLog.setText("");
        TLog.i(TAG, TOOL_VERSION);
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    runAnimTool();
                } catch (Exception e) {
                    TLog.e(TAG, e.getMessage());
                    setOutput(false, "");
                }
            }
        }).start();
    }

    private void runAnimTool() throws Exception {
        final CommonArg commonArg = new CommonArg();
        String os = System.getProperty("os.name").toLowerCase();

        commonArg.ffmpegCmd = "ffmpeg";
        commonArg.mp4editCmd = "mp4edit";

        if (os != null && !"".equals(os)) {
            if (os.contains("mac") && new File("mac").exists()) {
                commonArg.ffmpegCmd = "mac/ffmpeg";
                commonArg.mp4editCmd = "mac/mp4edit";
            } else if (os.contains("windows") && new File("win").exists()) {
                commonArg.ffmpegCmd = "win/ffmpeg";
                commonArg.mp4editCmd = "win/mp4edit";
            }
        }
        commonArg.enableH265 = group.isSelected(btnH265.getModel());
        commonArg.fps = (Integer)modelFps.getValue();
        commonArg.inputPath = textInputPath.getText();
        commonArg.scale = scaleArray[boxScale.getSelectedIndex()];
        if (needAudio) {
            commonArg.needAudio = true;
            commonArg.audioPath = textAudioPath.getText();
        }

        if (vapxUI.isVapxEnable()) {
            commonArg.isVapx = true;
            commonArg.srcSet = vapxUI.getSrcSet();
            if (commonArg.srcSet == null) {
                return;
            }
        }
        try {
            commonArg.enableCrf = groupQuality.isSelected(btnCrf.getModel());
            commonArg.bitrate = Integer.parseInt(textBitrate.getText());
            commonArg.crf = Integer.parseInt(textCrf.getText());
        } catch (NumberFormatException e) {
            TLog.e(TAG, "bitrate format error " + textBitrate.getText() + e.getMessage());
        }

        TLog.i(TAG, commonArg.toString());

        AnimTool animTool = new AnimTool();
        animTool.setToolListener(new AnimTool.IToolListener() {
            @Override
            public void onProgress(float progress) {
                int p = (int)(progress * 100f);
                labelOutInfo.setText((Math.min(p, 99)) + "%");
            }

            @Override
            public void onWarning(String msg) {
                JOptionPane.showMessageDialog(frame, msg, "Warning", JOptionPane.WARNING_MESSAGE);
            }

            @Override
            public void onError() {
                setOutput(false, "");
            }

            @Override
            public void onComplete() {
                setOutput(true, commonArg.outputPath);
                try {
                    setProperties(commonArg);
                    Desktop.getDesktop().open(new File(commonArg.outputPath));
                } catch (IOException e) {
                    TLog.e(TAG, e.getMessage());
                }
            }
        });
        btnCreate.setEnabled(false);
        animTool.create(commonArg, true);

    }

    private void createUI() {
        frame.setSize(WIDTH, HEIGHT);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

        int w = (Toolkit.getDefaultToolkit().getScreenSize().width - WIDTH) / 2;
        int h = (Toolkit.getDefaultToolkit().getScreenSize().height - HEIGHT) / 2;
        frame.setLocation(w, h);

        JPanel panel = new JPanel();
        frame.add(panel);
        layout(panel);
        frame.setVisible(true);
    }

    public String getInputPath() {
        return textInputPath.getText();
    }

    private void layout(JPanel panel) {
        BoxLayout layout = new BoxLayout(panel, BoxLayout.PAGE_AXIS);
        panel.setLayout(layout);
        // codec
        panel.add(getCodecLayout());
        // fps
        panel.add(getFpsLayout());
        // bitrate/crf switch
        panel.add(getQualityLayout());
        // bitrate
        panel.add(getBitrateLayout());
        // crf
        panel.add(getCrfLayout());
        // scale
        panel.add(getScaleLayout());
        // path
        panel.add(getPathLayout());
        // audio path
        panel.add(getAudioPathLayout());
        // vapx
        panel.add(vapxUI.createUI());
        // create
        panel.add(getCreateLayout());
        // log
        panel.add(getLogLayout());
        // open source
        panel.add(getOpenSourceLayout());

    }

    private JPanel getCodecLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT));

        JLabel label = new JLabel("codec");
        label.setPreferredSize(labelSize);
        panel.add(label);

        JPanel panelRadio = new JPanel();
        panelRadio.setLayout(new GridLayout(1, 2));
        panelRadio.add(btnH264);
        panelRadio.add(btnH265);
        group.add(btnH264);
        group.add(btnH265);
        group.setSelected(btnH264.getModel(), true);
        panel.add(panelRadio);

        return panel;
    }

    private JPanel getFpsLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("fps");
        label.setPreferredSize(labelSize);
        panel.add(label);
        JSpinner spinner = new JSpinner(modelFps);
        spinner.setPreferredSize(new Dimension(60, 20));
        panel.add(spinner);
        return panel;
    }

    private JPanel getQualityLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT));

        JLabel label = new JLabel("quality");
        label.setPreferredSize(labelSize);
        panel.add(label);

        JPanel panelRadio = new JPanel();
        panelRadio.setLayout(new GridLayout(1, 2));
        panelRadio.add(btnBitrate);
        panelRadio.add(btnCrf);
        groupQuality.add(btnBitrate);
        groupQuality.add(btnCrf);
        groupQuality.setSelected(btnBitrate.getModel(), true);
        btnBitrate.addItemListener(qualityGroupListener);
        btnCrf.addItemListener(qualityGroupListener);
        panel.add(panelRadio);

        return panel;
    }

    private JPanel getBitrateLayout() {
        panelBitrate.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("bitrate");
        label.setPreferredSize(labelSize);
        panelBitrate.add(label);
        textBitrate.setPreferredSize(new Dimension(60, 20));
        panelBitrate.add(textBitrate);
        panelBitrate.add(new JLabel("k (default 2000k)"));
        return panelBitrate;
    }

    private JPanel getCrfLayout() {
        panelCrf.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("crf");
        label.setPreferredSize(labelSize);
        panelCrf.add(label);
        textCrf.setPreferredSize(new Dimension(60, 20));
        panelCrf.add(textCrf);
        panelCrf.add(new JLabel("[0, 51] (default 29)"));
        return panelCrf;
    }

    private JPanel getScaleLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("alpha scale");
        label.setPreferredSize(labelSize);
        panel.add(label);
        panel.add(boxScale);
        panel.add(new JLabel("(default 0.5)"));
        return panel;
    }

    private JPanel getPathLayout() {
        JPanel panel = new JPanel();

        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("frames path");
        label.setPreferredSize(labelSize);
        panel.add(label);
        JPanel gPanel = new JPanel();
        panel.add(gPanel);

        BoxLayout layout = new BoxLayout(gPanel, BoxLayout.LINE_AXIS);
        gPanel.setLayout(layout);

        textInputPath.setPreferredSize(new Dimension(400,20));
        gPanel.add(textInputPath);

        JButton btnInputPath = new JButton("choose");
        gPanel.add(btnInputPath);
        btnInputPath.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                JFileChooser fileChooser = new JFileChooser(new File(getInputPath()));
                fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
                int returnVal = fileChooser.showOpenDialog(fileChooser);
                if(returnVal == JFileChooser.APPROVE_OPTION) {
                    // 文件夹路径
                    String filePath = fileChooser.getSelectedFile().getAbsolutePath();
                    textInputPath.setText(filePath);
                }
            }
        });

        return panel;
    }


    private JPanel getAudioPathLayout() {
        JPanel panel = new JPanel();

        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("audio(mp3)");
        label.setPreferredSize(labelSize);
        panel.add(label);
        panel.add(panelAudioPath);
        final JLabel labelAudioAction = new JLabel("+");
        panel.add(labelAudioAction);
        labelAudioAction.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent mouseEvent) {
                needAudio = !needAudio;
                panelAudioPath.setVisible(needAudio);
                labelAudioAction.setText(needAudio ? "x" : "+");
            }
        });

        BoxLayout layout = new BoxLayout(panelAudioPath, BoxLayout.LINE_AXIS);
        panelAudioPath.setLayout(layout);

        textAudioPath.setPreferredSize(new Dimension(400,20));
        panelAudioPath.add(textAudioPath);

        JButton btnInputPath = new JButton("choose");
        panelAudioPath.add(btnInputPath);
        btnInputPath.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                JFileChooser fileChooser = new JFileChooser(new File(getInputPath()));
                fileChooser.setFileSelectionMode(JFileChooser.FILES_ONLY);
                int returnVal = fileChooser.showOpenDialog(fileChooser);
                if(returnVal == JFileChooser.APPROVE_OPTION) {
                    // 文件夹路径
                    String filePath = fileChooser.getSelectedFile().getAbsolutePath();
                    textAudioPath.setText(filePath);
                }
            }
        });

        if (!needAudio) {
            panelAudioPath.setVisible(false);
        }

        return panel;
    }

    private void setOutput(boolean success, final String path) {
        btnCreate.setEnabled(true);
        if (success) {
            labelOutInfo.setText("<html><font color='blue'>open output</font></html>");
            labelOutInfo.addMouseListener(new MouseAdapter() {
                @Override
                public void mouseClicked(MouseEvent mouseEvent) {
                    try {
                        Desktop.getDesktop().open(new File(path));
                    } catch (IOException e) {
                        TLog.e(TAG, e.getMessage());
                    }
                }
            });
        } else {
            labelOutInfo.setText("<html><font color='red'>create error!</font></html>");
        }
    }


    private JPanel getCreateLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        panel.add(btnCreate);
        btnCreate.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                runTool();
            }
        });

        panel.add(labelOutInfo);

        return panel;
    }


    private JPanel getLogLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.PAGE_AXIS));

        txtAreaLog.setEditable(false);
        txtAreaLog.setLineWrap(true);
        txtAreaLog.setWrapStyleWord(true);
        JScrollPane areaScrollPane = new JScrollPane(txtAreaLog);
        areaScrollPane.setVerticalScrollBarPolicy(
                JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
        areaScrollPane.setPreferredSize(new Dimension(WIDTH, 100));
        areaScrollPane.setMinimumSize(new Dimension(WIDTH, 100));

        panel.add(areaScrollPane);
        panel.setPreferredSize(new Dimension(WIDTH, HEIGHT));

        return panel;
    }

    private JPanel getOpenSourceLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.RIGHT));

        JLabel label = new JLabel("open source software");
        label.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent mouseEvent) {
                new OpenSourceUI().createUI();
            }
        });
        panel.add(label);
        return panel;
    }

    private void log(String tag, String msg) {
        txtAreaLog.append("[" + tag + "]:" + msg + "\n");
        txtAreaLog.setCaretPosition(txtAreaLog.getText().length());
    }


    private CommonArg getProperties() {
        CommonArg commonArg = new CommonArg();
        try {
            String version = props.getProperty("version", "0");
            String enableH265 = props.getProperty("enableH265", Boolean.toString(commonArg.enableH265));
            String fps = props.getProperty("fps", String.valueOf(commonArg.fps));
            String inputPath = props.getProperty("inputPath", "");
            String scale = props.getProperty("scale", String.valueOf(scaleArray[0]));
            String audioPath = props.getProperty("audioPath", "");
            String bitrate = props.getProperty("bitrate", String.valueOf(commonArg.bitrate));
            String enableCrf = props.getProperty("enableCrf", String.valueOf(commonArg.enableCrf));
            String crf = props.getProperty("crf", String.valueOf(commonArg.crf));

            int v = Integer.parseInt(version);
            // 版本不符直接返回默认值
            if (v != commonArg.version) return commonArg;
            commonArg.fps = Integer.parseInt(fps);
            commonArg.scale = Float.parseFloat(scale);
            commonArg.enableH265 = Boolean.TRUE.toString().equals(enableH265);
            commonArg.inputPath = inputPath;
            commonArg.audioPath = audioPath;
            commonArg.bitrate = Integer.parseInt(bitrate);
            commonArg.enableCrf = Boolean.TRUE.toString().equals(enableCrf);
            commonArg.crf = Integer.parseInt(crf);
        } catch (Exception e) {
            TLog.e(TAG, "getProperties error:" + e.getMessage());
        }
        return commonArg;
    }


    private void setProperties(CommonArg commonArg) throws IOException {
        props.setProperty("version", String.valueOf(commonArg.version));
        props.setProperty("enableH265", commonArg.enableH265? Boolean.TRUE.toString() : Boolean.FALSE.toString());
        props.setProperty("fps", String.valueOf(commonArg.fps));
        props.setProperty("inputPath", commonArg.inputPath == null ? "" : commonArg.inputPath);
        props.setProperty("audioPath", commonArg.audioPath == null ? "" : commonArg.audioPath);
        props.setProperty("scale", String.valueOf(commonArg.scale));
        props.setProperty("bitrate", String.valueOf(commonArg.bitrate));
        props.setProperty("crf", String.valueOf(commonArg.crf));
        props.setProperty("enableCrf", String.valueOf(commonArg.enableCrf));
        props.store(new OutputStreamWriter(new FileOutputStream(PROPERTIES_FILE), StandardCharsets.UTF_8), "");
    }


}
