package com.tencent.qgame.playerproj.animtool.ui;

import com.tencent.qgame.playerproj.animtool.TLog;

import java.awt.Toolkit;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;

import javax.swing.BoxLayout;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

class OpenSourceUI {

    private final int WIDTH = 600;
    private final int HEIGHT = 800;

    public void createUI() {
        JFrame frame = new JFrame("open source software");
        frame.setSize(WIDTH, HEIGHT);
        frame.setDefaultCloseOperation(JFrame.HIDE_ON_CLOSE);

        int w = (Toolkit.getDefaultToolkit().getScreenSize().width - WIDTH) / 2;
        int h = (Toolkit.getDefaultToolkit().getScreenSize().height - HEIGHT) / 2;
        frame.setLocation(w, h);

        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.PAGE_AXIS));
        final JTextArea txtArea = new JTextArea();
        txtArea.setEditable(false);
        txtArea.setLineWrap(true);
        txtArea.setWrapStyleWord(true);
        JScrollPane areaScrollPane = new JScrollPane(txtArea);
        areaScrollPane.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);

        panel.add(areaScrollPane);

        frame.add(panel);
        frame.setVisible(true);

        new Thread(new Runnable() {
            @Override
            public void run() {
                readLicense(txtArea);
            }
        }).start();
    }

    private void readLicense(JTextArea txtArea) {
        StringBuilder sb = new StringBuilder();
        try {
            File file = new File("LICENSE.txt");
            BufferedReader reader = new BufferedReader(new FileReader(file));

            String line = reader.readLine();
            while (line != null) {
                if (line.length() != 0) {
                    sb.append(line);
                }
                sb.append("\n");
                line = reader.readLine();
            }
        } catch (Exception e) {
            TLog.i("OpenSourceUI", "ERROR -> " + e.getMessage());
        }
        txtArea.setText(sb.toString());
    }

}
