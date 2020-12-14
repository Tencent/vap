package com.tencent.qgame.playerproj.animtool.ui;

import java.awt.FlowLayout;

import javax.swing.BoxLayout;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

class VapxUI {


    public JPanel createUI() {
        JPanel panel = new JPanel();
        panel.setLayout(new BoxLayout(panel, BoxLayout.PAGE_AXIS));

        JPanel controlPanel = new JPanel();
        controlPanel.setLayout(new BoxLayout(controlPanel, BoxLayout.PAGE_AXIS));


        JScrollPane areaScrollPane = new JScrollPane(controlPanel);

        for (int i = 0; i<100 ; i++) {
            // controlPanel.add(new JLabel("codec:" + i));
        }



        panel.add(areaScrollPane);
        return panel;
    }

}
