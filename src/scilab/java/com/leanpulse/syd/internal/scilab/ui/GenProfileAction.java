/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.scilab.ui;

import java.awt.event.ActionEvent;

import javax.swing.AbstractAction;
import javax.swing.KeyStroke;
import javax.swing.SwingUtilities;

import org.scilab.modules.gui.bridge.menuitem.SwingScilabMenuItem;
import org.scilab.modules.gui.menuitem.MenuItem;
import org.scilab.modules.gui.menuitem.ScilabMenuItem;
import org.scilab.modules.xcos.graph.XcosDiagram;

import com.leanpulse.syd.api.GenProfile;
import com.leanpulse.syd.api.Generator;

/**
 * Action to start the generation with a given profile.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class GenProfileAction extends AbstractAction {
	
	private static final long serialVersionUID = 842812473862251238L;

	/**
	 * Creates a new menu item for a given generation profile.
	 * <p>
	 * This utility method returns a menu item based on a new generation profile
	 * action corresponding to the input arguments.
	 * 
	 * @param diagram
	 *            The Xcos diagram.
	 * @param profile
	 *            The generation profile.
	 * @return A new menu item.
	 */
	public static MenuItem createMenuItem(XcosDiagram diagram, GenProfile profile) {
		GenProfileAction action = new GenProfileAction(diagram, profile);
		MenuItem item = ScilabMenuItem.createMenuItem();
		SwingScilabMenuItem swingItem = (SwingScilabMenuItem) item.getAsSimpleMenuItem();
		swingItem.setAction(action);
		return item;
	}
	
	private XcosDiagram diagram;
	private GenProfile profile;

	/*
	 * Default constructor
	 */
	public GenProfileAction(XcosDiagram diagram, GenProfile profile) {
		super(profile.getName());
		String description = profile.getDescription();
		if(description != null) {
			putValue(SHORT_DESCRIPTION, description);
			putValue(LONG_DESCRIPTION, description);
		}
		String shortcut = profile.getShortcut();
		if(shortcut != null)
			putValue(ACCELERATOR_KEY, KeyStroke.getKeyStroke(shortcut.replace("+", " ").toLowerCase()));
		
		this.diagram = diagram;
		this.profile = profile;
	}

	/*
	 * (non-Javadoc)
	 * @see java.awt.event.ActionListener#actionPerformed(java.awt.event.ActionEvent)
	 */
	public void actionPerformed(ActionEvent e) {
		Generator.getDefault().asyncGenerateUI(diagram.getRootDiagram().getSavedFile(), profile,
			SwingUtilities.windowForComponent(diagram.getAsComponent()));
	}

}
