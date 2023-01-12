package com.tencent.qgame.playerproj.animtool.ui;

import com.tencent.qgame.playerproj.animtool.TLog;
import com.tencent.qgame.playerproj.animtool.vapx.SrcSet;

import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFileChooser;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTextField;

public class VapxUI {

    private static final String TAG = "VapxUI";

    private final Dimension labelSize = new Dimension(100, 20);
    private final JPanel controlPanel = new JPanel();
    private final List<MaskUI> maskUiList = new ArrayList<>();
    private int index = 0;
    private ToolUI toolUI;
    private final IMaskUIListener listener = new IMaskUIListener() {
        @Override
        public void onDelete(MaskUI maskUI) {
            controlPanel.remove(maskUI.getPanel());
            maskUiList.remove(maskUI);
            controlPanel.revalidate();
        }
    };

    public VapxUI(ToolUI toolUI) {
        this.toolUI = toolUI;
    }

    public JPanel createUI() {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.PAGE_AXIS));
        panel.setPreferredSize(new Dimension(ToolUI.WIDTH, 300));
        panel.setMinimumSize(new Dimension(ToolUI.WIDTH, 300));
        controlPanel.setLayout(new BoxLayout(controlPanel, BoxLayout.PAGE_AXIS));
        controlPanel.add(getAddLayout());
        JScrollPane areaScrollPane = new JScrollPane(controlPanel);
        panel.add(areaScrollPane);
        return panel;
    }

    public boolean isVapxEnable() {
        return !maskUiList.isEmpty();
    }

    public SrcSet getSrcSet() {
        if (maskUiList.isEmpty()) return null;
        SrcSet srcSet = new SrcSet();

        SrcSet.Src src;
        for (MaskUI maskUI : maskUiList) {
            src = maskUI.getSrc();
            if (src == null) return null;
            srcSet.srcs.add(src);
        }

        return srcSet;
    }


    private JPanel getAddLayout() {
        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.LEFT));
        JLabel label = new JLabel("add source");
        label.setPreferredSize(labelSize);

        JButton btnAdd = new JButton("add");
        btnAdd.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent actionEvent) {
                createMaskUI();
            }
        });

        panel.add(label);
        panel.add(btnAdd);
        panel.add(new JLabel("(simple video don't need add source)"));
        return panel;
    }

    private void createMaskUI() {
        MaskUI maskUI = new MaskUI(toolUI, ++index, listener);
        controlPanel.add(maskUI.getPanel());
        maskUiList.add(maskUI);
        controlPanel.revalidate();
    }

    private static class MaskUI {
        private ToolUI toolUI;
        public IMaskUIListener listener;
        public int index;
        public String maskPath;
        public JPanel panel = new JPanel();

        private final JLabel labelIndex = new JLabel();
        private final JTextField textSrcTag = new JTextField();
        // image -> SrcSet.Src.SRC_TYPE_IMG text -> SrcSet.Src.SRC_TYPE_TXT
        private final String[] srcTypeArray = new String[]{"image", "text"};
        private final JComboBox<String> boxSrcType = new JComboBox<>(srcTypeArray);

        // centerCrop -> SrcSet.Src.FIT_TYPE_CF
        private final String[] fitTypeArray = new String[]{"fitXY", "centerCrop"};
        private final JComboBox<String> boxFitType = new JComboBox<>(fitTypeArray);

        private final JPanel txtPanel = new JPanel();
        private final JTextField textTxtColor = new JTextField();
        private final JCheckBox checkTxtBold = new JCheckBox("text Bold");

        final JLabel labelMaskPathState = new JLabel();


        public MaskUI(ToolUI toolUI, int index, IMaskUIListener listener) {
            this.toolUI = toolUI;
            this.index = index;
            this.listener = listener;
            createUI();
        }

        public JPanel getPanel() {
            return panel;
        }

        public SrcSet.Src getSrc() {
            SrcSet.Src src = new SrcSet.Src();
            src.srcId = String.valueOf(index);
            src.srcTag = textSrcTag.getText().trim();

            src.srcType = SrcSet.Src.SRC_TYPE_IMG;
            if (boxSrcType.getSelectedIndex() == 1) {
                src.srcType = SrcSet.Src.SRC_TYPE_TXT;
            }

            src.fitType = SrcSet.Src.FIT_TYPE_FITXY;
            if (boxFitType.getSelectedIndex() == 1) {
                src.fitType = SrcSet.Src.FIT_TYPE_CF;
            }

            src.srcPath = maskPath;

            if (SrcSet.Src.SRC_TYPE_TXT.equals(src.srcType)) {
                src.color = textTxtColor.getText().trim();
                if (checkTxtBold.isSelected()) {
                    src.style = SrcSet.Src.TEXT_STYLE_BOLD;
                }
            }

            if (src.srcTag == null || "".equals(src.srcTag)) {
                String msg = "id:" + index + " source tag is empty";
                TLog.e(TAG, msg);
                JOptionPane.showMessageDialog(panel, msg, "Error", JOptionPane.ERROR_MESSAGE);
                return null;
            }

            if (src.srcPath == null || "".equals(src.srcPath)) {
                String msg = "id:" + index + " mask path is empty";
                TLog.e(TAG, msg);
                JOptionPane.showMessageDialog(panel, msg, "Error", JOptionPane.ERROR_MESSAGE);
                return null;
            }
            return src;
        }

        private void createUI() {
            panel.setLayout(new BoxLayout(panel, BoxLayout.PAGE_AXIS));
            setMaskPath();
            panel.add(new JSeparator());
            panel.add(part1Layout());
            panel.add(part2Layout());
            panel.add(part3Layout());

        }

        private void setMaskPath() {
            String text = maskPath == null? "<html><font color='red'>empty</font></html>" : maskPath;
            labelMaskPathState.setText(text);
        }

        public JPanel part1Layout() {
            JPanel panel = new JPanel();
            panel.setLayout(new FlowLayout(FlowLayout.LEFT));

            // index
            labelIndex.setText("id:" + index);
            panel.add(labelIndex);

            // srcTag
            panel.add(new JLabel(" source tag:"));
            textSrcTag.setPreferredSize(new Dimension(50, 20));
            textSrcTag.setText("tag" + index);
            panel.add(textSrcTag);

            // srcType
            panel.add(new JLabel(" source type:"));
            boxSrcType.setSelectedIndex(0);
            panel.add(boxSrcType);
            boxSrcType.addItemListener(new ItemListener() {
                @Override
                public void itemStateChanged(ItemEvent itemEvent) {
                    txtPanel.setVisible(srcTypeArray[1].equals(itemEvent.getItem()));
                }
            });
            // fitType
            panel.add(new JLabel(" fit type:"));
            boxFitType.setSelectedIndex(0);
            panel.add(boxFitType);




            // delete
            JLabel labelDelete = new JLabel("<html><font color='red'>delete</font></html>");
            panel.add(labelDelete);
            labelDelete.addMouseListener(new MouseAdapter() {
                @Override
                public void mouseClicked(MouseEvent mouseEvent) {
                    if (listener != null) {
                        listener.onDelete(MaskUI.this);
                    }
                }
            });

            return panel;
        }


        private JPanel part2Layout() {
            JPanel panel = txtPanel;
            panel.setLayout(new FlowLayout(FlowLayout.LEFT));

            panel.add(new JLabel(" text color:"));
            textTxtColor.setPreferredSize(new Dimension(100, 20));
            textTxtColor.setText("#000000");
            panel.add(textTxtColor);

            panel.add(checkTxtBold);
            panel.setVisible(false);
            return panel;
        }


        private JPanel part3Layout() {
            JPanel panel = new JPanel();
            panel.setLayout(new FlowLayout(FlowLayout.LEFT));
            // mask path
            panel.add(new JLabel(" mask path:"));
            JButton btnMaskPath = new JButton("choose");
            panel.add(btnMaskPath);
            btnMaskPath.addActionListener(new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent actionEvent) {
                    JFileChooser fileChooser = new JFileChooser(new File(toolUI.getInputPath()));
                    fileChooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
                    int returnVal = fileChooser.showOpenDialog(fileChooser);
                    if(returnVal == JFileChooser.APPROVE_OPTION) {
                        // 文件夹路径
                        maskPath = fileChooser.getSelectedFile().getAbsolutePath();
                        setMaskPath();
                    }
                }
            });


            panel.add(labelMaskPathState);

            return panel;
        }
    }

    private interface IMaskUIListener {
        void onDelete(MaskUI maskUI);
    }

}
