/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.progress;

import java.awt.Color;
import java.awt.Desktop;
import java.awt.Font;
import java.awt.SystemColor;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.BoxLayout;
import javax.swing.GroupLayout;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JEditorPane;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.JScrollPane;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.event.HyperlinkEvent;
import javax.swing.event.HyperlinkListener;
import javax.swing.text.html.HTMLDocument;

/**
 * 
 * 
 * <p>
 * 
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class ProgressPanel extends JPanel {
	
	private static final long serialVersionUID = 1L;
	
	private static final ImageIcon CANCEL_ICON = new ImageIcon(ProgressPanel.class.getResource("/com/leanpulse/syd/internal/progress/cancel_enabled.png"));
	private static final ImageIcon CANCEL_OVER_ICON = new ImageIcon(ProgressPanel.class.getResource("/com/leanpulse/syd/internal/progress/cancel_over.png"));
	private static final ImageIcon CANCEL_PRESSED_ICON = new ImageIcon(ProgressPanel.class.getResource("/com/leanpulse/syd/internal/progress/cancel_pressed.png"));
	
	private ProgressMonitor progressMon;
	
	private JLabel nameLabel;
	private JProgressBar progressBar;
	private JButton cancelButton;
	private JLabel iconLabel;
	private JEditorPane descriptionPane;
	private JButton detailsButton;
	private JScrollPane detailsPane;
	private JPanel subProgressPane;
	
	public ProgressPanel(ProgressMonitor mon) {
		this(null, mon);
	}
	
	public ProgressPanel(String title, ProgressMonitor mon) {
		progressMon = mon;
		
		nameLabel = new JLabel(title);
		progressBar = new JProgressBar(0,100);
		progressBar.setStringPainted(true);
		iconLabel = new JLabel();
		
		descriptionPane = new JEditorPane();
		descriptionPane.setContentType("text/html");
		descriptionPane.setEditable(false);
		descriptionPane.setOpaque(false);
		descriptionPane.setBackground(null);
        Font font = UIManager.getFont("Label.font");
        String bodyRule = "body { font-family: " + font.getFamily() + "; " +
                "font-size: " + font.getSize() + "pt; }";
        ((HTMLDocument)descriptionPane.getDocument()).getStyleSheet().addRule(bodyRule);
		descriptionPane.addHyperlinkListener(new HyperlinkListener() {
            public void hyperlinkUpdate(final HyperlinkEvent e) {
                if (e.getEventType().equals(HyperlinkEvent.EventType.ACTIVATED)) {
                    try {
                        Desktop.getDesktop().mail(e.getURL().toURI());
                    } catch (IOException e1) {
                        throw new RuntimeException(e1);
                    } catch (URISyntaxException e1) {
                        throw new RuntimeException(e1);
                    }
                }
            }
        });
		
		cancelButton = new JButton(CANCEL_ICON);
		cancelButton.setBorderPainted(false);
		cancelButton.setBorder(BorderFactory.createEmptyBorder());
		cancelButton.setOpaque(false);
		cancelButton.setContentAreaFilled(false);
		cancelButton.setRolloverEnabled(true);
		cancelButton.setRolloverIcon(CANCEL_OVER_ICON);
		cancelButton.setPressedIcon(CANCEL_PRESSED_ICON);
		cancelButton.setToolTipText("Cancel this task");
		cancelButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				progressMon.requestCancel();
			}
		});
		
		detailsButton = new JLinkButton("More details...");
		detailsButton.addActionListener(new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				setDetailsVisible(!detailsPane.isVisible());
			}
		});
		
		subProgressPane = new JPanel();
		subProgressPane.setBackground(SystemColor.text);
		subProgressPane.setLayout(new BoxLayout(subProgressPane, BoxLayout.Y_AXIS));
		detailsPane = new JScrollPane(subProgressPane);
		
		int prefWidth = title != null ? 600 : GroupLayout.PREFERRED_SIZE;
		
		GroupLayout layout = new GroupLayout(this);
		layout.setHorizontalGroup(layout.createSequentialGroup()
			.addGroup(layout.createParallelGroup()
				.addComponent(nameLabel)
				.addGroup(layout.createSequentialGroup()
						.addComponent(progressBar)
						.addPreferredGap(ComponentPlacement.RELATED)
						.addComponent(cancelButton))
				.addGroup(layout.createSequentialGroup()
						.addComponent(iconLabel)
						.addComponent(descriptionPane, GroupLayout.DEFAULT_SIZE, prefWidth, Short.MAX_VALUE))
				.addComponent(detailsButton)
				.addComponent(detailsPane, GroupLayout.DEFAULT_SIZE, prefWidth, Short.MAX_VALUE)));
		layout.setVerticalGroup(layout.createSequentialGroup()
			.addComponent(nameLabel)
			.addPreferredGap(ComponentPlacement.RELATED)
			.addGroup(layout.createParallelGroup()
				.addComponent(progressBar)
				.addGroup(layout.createSequentialGroup()
					.addGap(2)
					.addComponent(cancelButton)))
			.addPreferredGap(ComponentPlacement.RELATED)
			.addGroup(layout.createParallelGroup()
				.addComponent(iconLabel)
				.addComponent(descriptionPane, 20, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE))
			.addPreferredGap(ComponentPlacement.RELATED)
			.addComponent(detailsButton, 16, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE)
			.addPreferredGap(ComponentPlacement.RELATED)
			.addComponent(detailsPane, GroupLayout.DEFAULT_SIZE, 200, GroupLayout.DEFAULT_SIZE));
		setLayout(layout);
		setBorder(BorderFactory.createEmptyBorder(10, 10, 10, 10));
		setOpaque(false);
		
		update();
		initChildren();
		
		if(title == null) {
			nameLabel.setVisible(false);
			detailsButton.setVisible(false);
		}
		detailsPane.setVisible(false);
	}
	
	public void update() {
		cancelButton.setEnabled(progressMon.getState() == ProgressMonitor.STATE_RUNNING);
		int state = progressMon.getState();
		switch(state) {
			case ProgressMonitor.STATE_CANCELLED:
				progressBar.setForeground(Color.GRAY);
				descriptionPane.setText("Cancel requested...");
				break;
			case ProgressMonitor.STATE_FINISHED:
				Exception error = progressMon.getStoppingException();
				if(error != null) {
					progressBar.setVisible(false);
					cancelButton.setVisible(false);
					iconLabel.setIcon(UIManager.getIcon("OptionPane.errorIcon"));
					StringBuilder text = new StringBuilder();
					text.append("<html><div>" +	progressMon.getLastMessage() + "</div>" +
							"<div>" + error.getMessage() + "</div>");
					StackTraceElement[] trace = error.getStackTrace();
		            for (int i=0; i < trace.length; i++)
		            	text.append("<div style=\"text-indent:10px;\"> " + trace[i] + "</div>");
		            text.append("</html>");
					descriptionPane.setText(text.toString());
				} else {
					progressBar.setValue((int) (100.0 * progressMon.getCurrentUnits() / progressMon.getTotalUnits()));
					descriptionPane.setText(progressMon.getLastMessage());
				}
				break;
			default:
				progressBar.setValue((int) (100.0 * progressMon.getCurrentUnits() / progressMon.getTotalUnits()));
				descriptionPane.setText(progressMon.getLastMessage());
		}
	}
	
	public void setDetailsVisible(boolean visible) {
		detailsButton.setText(visible ? "Less details..." : "More details...");
		detailsPane.setVisible(visible);
		((JFrame)SwingUtilities.getAncestorOfClass(JFrame.class, ProgressPanel.this)).pack();
	}
	
	public void initChildren() {
		List<SubProgressMonitor> children = progressMon.getChildren();
		if(children != null) {
			for(SubProgressMonitor subMon : children) {
				subProgressPane.add(subMon.getPanel());
			}
		}
	}

	public void addSubProgress(SubProgressMonitor subMon) {
		subProgressPane.add(subMon.getPanel());
		subProgressPane.repaint();
	}

	public void removeSubProgress(SubProgressMonitor subMon) {
		subProgressPane.remove(subMon.getPanel());
		subProgressPane.repaint();
	}
	
	
	

}
