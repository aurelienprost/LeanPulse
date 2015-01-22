/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.progress;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Window;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.SwingConstants;
import javax.swing.SwingUtilities;

/**
 * 
 * 
 * <p>
 * 
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class ProgressFrame extends JFrame {
	
	private static final long serialVersionUID = -15476134382530814L;
	
	private static final ImageIcon LP_ICON = new ImageIcon(ProgressPanel.class.getResource("/com/leanpulse/syd/internal/progress/lp.png"));
	private static final ImageIcon LEANPULSE_ICON = new ImageIcon(ProgressPanel.class.getResource("/com/leanpulse/syd/internal/progress/leanpulse.png"));
	
	protected ProgressMonitor mon;
	
	public ProgressFrame(Window appwin, String title, String taskName) {
		super(title);
		setIconImage(LP_ICON.getImage());
		JPanel mainPanel = new JPanel(new BorderLayout());
		
		mon = new ProgressMonitor(taskName);
		ProgressPanel monPane = mon.getPanel();
		mainPanel.add(monPane, BorderLayout.CENTER);
		
		JPanel lpPanel = new JPanel(new BorderLayout());
		JLabel sydLabel = new JLabel("Powered by LeanPulse SyD - The System Document Generator");
		sydLabel.setForeground(Color.GRAY);
		lpPanel.add(sydLabel, BorderLayout.WEST);
		lpPanel.add(new JLabel(LEANPULSE_ICON, SwingConstants.RIGHT), BorderLayout.EAST);
		lpPanel.setBorder(BorderFactory.createEmptyBorder(0, 10, 10, 10));
		mainPanel.add(lpPanel, BorderLayout.SOUTH);
		
		setContentPane(mainPanel);
		pack();
		
		setDefaultCloseOperation(DO_NOTHING_ON_CLOSE);
		addWindowListener(new WindowAdapter() {
			@Override
			public void windowClosing(WindowEvent e) {
				if(mon.isFinished())
					dispose();
				else if(mon.isCanceled()) {
					int confirmed = JOptionPane.showOptionDialog(ProgressFrame.this,
	                        "Syd didn't yet reply to the cancellation request. Are you sure you want to force the exit?", "User Confirmation",
	                        JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, null,
	                        new String[] {"Yes", "No"}, "No");
			        if (confirmed == JOptionPane.YES_OPTION)
			        	dispose();
				} else {
					int confirmed = JOptionPane.showOptionDialog(ProgressFrame.this,
	                        "Are you sure you want to cancel the generation?", "User Confirmation",
	                        JOptionPane.YES_NO_OPTION, JOptionPane.QUESTION_MESSAGE, null,
	                        new String[] {"Yes", "No"}, "No");
			        if (confirmed == JOptionPane.YES_OPTION)
			        	mon.requestCancel();
				}
			}
		});
		setLocationRelativeTo(appwin);
	}
	
	public ProgressMonitor getMonitor() {
		return mon;
	}
	
	public void display() {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				setVisible(true);
				toFront();
			}
		});
	}
	
	public void showDetails() {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				mon.getPanel().setDetailsVisible(true);
				toFront();
			}
		});
	}
	
	public void close() {
		SwingUtilities.invokeLater(new Runnable() {
			public void run() {
				setVisible(false);
				dispose();
			}
		});
	}

}
