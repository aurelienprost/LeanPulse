/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.scilab.ui;

import org.scilab.modules.gui.menu.Menu;
import org.scilab.modules.gui.menu.ScilabMenu;
import org.scilab.modules.gui.menuitem.MenuItem;
import org.scilab.modules.xcos.graph.XcosDiagram;
import org.scilab.modules.xcos.spi.XcosMenuExtension;

import com.leanpulse.syd.api.GenProfile;

/**
 * Xcos extension to add the SyD menu.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see XcosMenuExtension
 */
public class SydMenu implements XcosMenuExtension {

	/*
	 * (non-Javadoc)
	 * @see org.scilab.modules.xcos.spi.XcosMenuExtension#createMenu(org.scilab.modules.xcos.graph.XcosDiagram)
	 */
	public Menu createMenu(XcosDiagram diagram) {
		Menu syd = ScilabMenu.createMenu();
		syd.setText("LeanPulse SyD");
		syd.setMnemonic('L');
		GenProfile[] profiles = GenProfile.getGenProfiles();
		for(int i=0; i<profiles.length; i++) {
			MenuItem item = GenProfileAction.createMenuItem(diagram, profiles[i]);
			syd.add(item);
		}
		return syd;
	}

}
