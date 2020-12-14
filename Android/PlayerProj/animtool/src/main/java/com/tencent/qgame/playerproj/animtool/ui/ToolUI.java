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
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;

import javax.swing.BoxLayout;
import javax.swing.ButtonGroup;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
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
    private static final String PROPERTIES_FILE = "setting.properties";
    private final int WIDTH = 800;
    private final int HEIGHT = 600;

    private final ButtonGroup group = new ButtonGroup();
    private final JRadioButton btnH265 = new JRadioButton("h265");
    private final JRadioButton btnH264 = new JRadioButton("h264");
    private final SpinnerModel modelFps = new SpinnerNumberModel(24, 1, 60, 1);
    private final Float[] scaleArray = new Float[]{0.5f, 1f};
    private final JComboBox<Float> boxScale = new JComboBox<>(scaleArray);
    private final JTextField textInputPath = new JTextField();
    private final JButton btnCreate = new JButton("create VAP");
    private final JTextArea txtAreaLog = new JTextArea();
    private final JLabel labelOutInfo = new JLabel();
    private final Dimension labelSize = new Dimension(100, 20);
    private final Properties props = new Properties();

    private final VapxUI vapxUI = new VapxUI();



    public void run() {
        TLog.logger = new TLog.ITLog() {
            @Override
            public void i(String tag, String msg) {
                log(tag, msg);
            }
        };
        createUI();
        try {
            File file = new File(PROPERTIES_FILE);
            if (!file.exists()) {
                file.createNewFile();
            }
            props.load(new FileInputStream(PROPERTIES_FILE));
            CommonArg commonArg = getProperties();
            group.setSelected(commonArg.enableH265 ? btnH265.getModel() : btnH264.getModel(), true);
            modelFps.setValue(commonArg.fps);
            textInputPath.setText(commonArg.inputPath);
            float scale = commonArg.scale;
            for (int i=0; i<scaleArray.length ; i++) {
                if (scaleArray[i] == scale) {
                    boxScale.setSelectedIndex(i);
                    break;
                }
            }
        } catch (Exception e) {
            TLog.i(TAG, "ERROR -> " + e.getMessage());
        }
    }


    private void runTool() {
        txtAreaLog.setText("");
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    runAnimTool();
                } catch (Exception e) {
                    TLog.i(TAG, "ERROR -> " + e.getMessage());
                    btnCreate.setEnabled(true);
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

        TLog.i(TAG, commonArg.toString());

        AnimTool animTool = new AnimTool();
        animTool.setToolListener(new AnimTool.IToolListener() {
            @Override
            public void onProgress(float progress) {
                int p = (int)(progress * 100f);
                labelOutInfo.setText((Math.min(p, 99)) + "%");
            }

            @Override
            public void onError() {
                btnCreate.setEnabled(true);
            }

            @Override
            public void onComplete() {
                btnCreate.setEnabled(true);
                setOutput(commonArg.outputPath);
                try {
                    setProperties(commonArg);
                    Desktop.getDesktop().open(new File(commonArg.outputPath));
                } catch (IOException e) {
                    TLog.i(TAG, "ERROR -> " + e.getMessage());
                }
            }
        });
        btnCreate.setEnabled(false);
        animTool.create(commonArg, true);

    }

    private void createUI() {
        JFrame frame = new JFrame("VAP tool");
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

    private void layout(JPanel panel) {
        BoxLayout layout = new BoxLayout(panel, BoxLayout.PAGE_AXIS);
        panel.setLayout(layout);
        // codec
        panel.add(getCodecLayout());
        // fps
        panel.add(getFpsLayout());
        // scale
        panel.add(getScaleLayout());
        // path
        panel.add(getPathLayout());
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
        panelRadio.add(btnH265);
        panelRadio.add(btnH264);
        group.add(btnH265);
        group.add(btnH264);
        group.setSelected(btnH265.getModel(), true);
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

    private JPanel getScaleLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("alpha scale");
        label.setPreferredSize(labelSize);
        panel.add(label);

        panel.add(boxScale);
        return panel;
    }

    private JPanel getPathLayout() {
        JPanel panel = new JPanel();

        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("input path");
        label.setPreferredSize(labelSize);
        panel.add(label);
        JPanel gPanel = new JPanel();
        panel.add(gPanel);

        BoxLayout layout = new BoxLayout(gPanel, BoxLayout.LINE_AXIS);
        gPanel.setLayout(layout);

        textInputPath.setPreferredSize(new Dimension(300,20));
        gPanel.add(textInputPath);

        JButton btnInputPath = new JButton("choose");
        gPanel.add(btnInputPath);
        btnInputPath.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                JFileChooser fileChooser = new JFileChooser();
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

    private void setOutput(final String path) {
        labelOutInfo.setText("<html><font color='blue'>open output</font></html>");
        labelOutInfo.addMouseListener(new MouseAdapter() {
            @Override
            public void mouseClicked(MouseEvent mouseEvent) {
                try {
                    Desktop.getDesktop().open(new File(path));
                } catch (IOException e) {
                    TLog.i(TAG, "ERROR -> " + e.getMessage());
                }
            }
        });
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
        areaScrollPane.setPreferredSize(new Dimension(WIDTH, 200));

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
        String version = props.getProperty("version", "0");
        String enableH265 = props.getProperty("enableH265", Boolean.TRUE.toString());
        String fps = props.getProperty("fps", String.valueOf(commonArg.fps));
        String inputPath = props.getProperty("inputPath", "");
        String scale = props.getProperty("scale", String.valueOf(scaleArray[0]));

        try {
            int v = Integer.parseInt(version);
            // 版本不符直接返回默认值
            if (v != commonArg.version) return commonArg;
            commonArg.fps = Integer.parseInt(fps);
            commonArg.scale = Float.parseFloat(scale);
            commonArg.enableH265 = Boolean.TRUE.toString().equals(enableH265);
            commonArg.inputPath = inputPath;
        } catch (Exception e) {
            TLog.i(TAG, "getProperties error:" + e.getMessage());
        }
        return commonArg;
    }


    private void setProperties(CommonArg commonArg) throws IOException {
        props.setProperty("version", commonArg.version + "");
        props.setProperty("enableH265", commonArg.enableH265? Boolean.TRUE.toString() : Boolean.FALSE.toString());
        props.setProperty("fps", commonArg.fps + "");
        props.setProperty("inputPath", commonArg.inputPath == null ? "" : commonArg.inputPath);
        props.setProperty("scale", commonArg.scale + "");
        props.store(new FileOutputStream(PROPERTIES_FILE), "");
    }


}
