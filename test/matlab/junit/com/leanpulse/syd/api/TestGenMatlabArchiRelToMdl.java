/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.io.File;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import org.junit.runners.Parameterized;

import com.leanpulse.syd.internal.GenProfileRenderConfImpl;
import com.leanpulse.syd.internal.GenProfileImpl;
import com.leanpulse.syd.internal.GenProfileSnapConfImpl;
import com.leanpulse.syd.internal.matlab.MatlabControl;

/**
 * Recursively tests the architecture generation starting from the Simulink root
 * models located in sub-directories of "matlab/material/architecture" and with
 * a generation profile that outputs each document next to its sibling mdl.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Generator
 * @see GenProfile
 * @see GenProfileRenderConf
 */
public class TestGenMatlabArchiRelToMdl extends AbsTestGenerator {

	/**
	 * Sets the test cases to test the architecture generation with output
	 * relative to model.
	 * 
	 * @return The collection of array of arguments to be passed to the
	 *         constructor to test the generation with each model architecture.
	 */
	@Parameterized.Parameters
    public static Collection<Object[]> parameters() {
    	File archDir = new File("../architecture");
    	String matVerSuffix = "_" + MatlabControl.getMatlabVer().replaceAll("\\.", "_");
    	Map<String,String> params = new HashMap<String,String>();
    	params.put("security","2");
    	GenProfileRenderConf archConf = new GenProfileRenderConfImpl("template", "pdf", new File("."), GenProfileRenderConf.RELTO_MODEL,
    			matVerSuffix, new PdfSecurityOptions(), GenProfileRenderConf.ACTION_NOP, GenProfileRenderConf.GENDEP_SEPDOCS, params);
    	GenProfile profile = new GenProfileImpl("archmdl", "ArchiRelToMdl", "", "", new GenProfileSnapConfImpl(), new GenProfileRenderConf[] {archConf});
    	return loopOnModelArchitectures(archDir, ".mdl", profile, true);
    }
	
    /**
     * Default constructor.
     * 
     * @param mdlFile
	 *            The model file from which the documentation will be generated.
	 * @param profile
	 *            The generation profile to apply.
	 * @param showUI
	 *            Whether the wait bar should be displayed.
	 */
	public TestGenMatlabArchiRelToMdl(File mdlFile, GenProfile profile, boolean showUI) {
		super(mdlFile, profile, showUI);
	}

}
