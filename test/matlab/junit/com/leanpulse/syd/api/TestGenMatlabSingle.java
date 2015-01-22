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
 * Recursively tests the generation on all Simulink models in
 * "matlab/material/single" and with a default generation profile.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Generator
 */
public class TestGenMatlabSingle extends AbsTestGenerator {

	/**
	 * Sets the test cases to test the generation on each Simulink models in
	 * "matlab/material/single"
	 * 
	 * @return The collection of array of arguments to be passed to the
	 *         constructor to test the generation with each model.
	 */
	@Parameterized.Parameters
    public static Collection<Object[]> parameters() {
    	File mdlsDir = new File("../single");
    	String matVerSuffix = "_" + MatlabControl.getMatlabVer().replaceAll("\\.", "_");
    	Map<String,String> params = new HashMap<String,String>();
    	params.put("security","2");
    	GenProfileRenderConfImpl singleConf = new GenProfileRenderConfImpl("template", "pdf", new File("."), GenProfileRenderConf.RELTO_MODEL,
    			matVerSuffix, new PdfSecurityOptions(), GenProfileRenderConf.ACTION_NOP, GenProfileRenderConf.GENDEP_NO, params);
    	GenProfile profile = new GenProfileImpl("single", "Single", "", "", new GenProfileSnapConfImpl(), new GenProfileRenderConfImpl[] {singleConf});
    	return loopOnModels(mdlsDir, ".mdl", profile, true);
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
	public TestGenMatlabSingle(File mdlFile, GenProfile profile, boolean showUI) {
		super(mdlFile, profile, showUI);
	}

}
