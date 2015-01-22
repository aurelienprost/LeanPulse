/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

import com.leanpulse.syd.internal.GenProfileRenderConfImpl;

/**
 * Tests all generation profiles defined in SyD.
 * <p>
 * This unit test checks if all the render configurations in the generation
 * profiles defined by SyD (read from "sydProfiles.xml") are running
 * correctly.<br>
 * It invokes {@link GenProfileRenderConf#render(File, List)} for each render
 * configuration loaded and passes a default test XML file as input.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see GenProfile
 * @see GenProfileRenderConf
 */
public class TestGenProfiles {
	
	protected static File xmlFile;
	protected static List<File> refMdls = new ArrayList<File>(0);
	protected static GenProfile[] profiles;
	
	/**
	 * Sets up the tests and loads the profiles defined in SyD.
	 */
	@BeforeClass
    public static void setUpBeforeClass() {
		xmlFile = new File("SyDdemo.xml").getAbsoluteFile();
		refMdls = new ArrayList<File>(0);
		profiles = GenProfile.getGenProfiles();
		for(GenProfile profile : profiles) {
			for(GenProfileRenderConf renderConf : profile.getRenderConfs())
				((GenProfileRenderConfImpl)renderConf).setNoOpen(); // Force renderers to not open documents after generation
		}
    }
	
	/**
	 * Tests only the first renderer of the first profile with progress report
	 * UI.
	 */
	@Test
	public void testRenderUI() {
		GenProfileRenderConf[] renderConfs = profiles[0].getRenderConfs();
		assertTrue(renderConfs.length > 0);
		assertTrue(renderConfs[0].renderUI(xmlFile, refMdls, null));
	}
	
	/**
	 * Tests all profiles fully without the graphical user interface.
	 * 
	 * @throws Exception
	 *             Means an error occurred and the test will fail.
	 */
	@Test
	public void testRender() throws Exception {
		for(GenProfile profile : profiles) {
			for(GenProfileRenderConf renderConf : profile.getRenderConfs())
				renderConf.render(xmlFile, refMdls);
		}
	}
	
	/**
	 * Shuts down the rendering server.
	 */
	@AfterClass
    public static void tearDownAfterClass() {
        RendererManager.killRemoteRenderer();
    }

}
