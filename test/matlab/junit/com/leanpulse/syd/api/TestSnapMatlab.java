/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.io.File;
import java.util.Arrays;
import java.util.Collection;

import org.junit.runners.Parameterized;

import com.leanpulse.syd.internal.matlab.MatlabControl;

/**
 * Tests the <code>Snapper</code> implementation in Matlab.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Snapper
 */
public class TestSnapMatlab extends AbsTestSnapper {
	
	/**
	 * Sets the test cases to test the <code>Snapper</code> implementation in
	 * Matlab.
	 * <p>
	 * Actually returns only one test case to check the XML data extraction on
	 * a single model as this feature will be more deeply tested while checking
	 * the full generation on sets of models.
	 * 
	 * @return The collection of array of arguments to be passed to the
	 *         constructor to set each test case.
	 */
	@Parameterized.Parameters
    public static Collection<Object[]> parameters() {
    	String matVerSuffix = "_" + MatlabControl.getMatlabVer().replaceAll("\\.", "_");
    	return Arrays.asList(new Object[][] {
    			{new File("../single/demo/SyDdemo.mdl"), new File("../single/demo/SyDdemo" + matVerSuffix + ".xml"), true}
    	});
    }
	
    /**
     * Default constructor.
     * 
     * @param mdlFile
	 *            The model file from which to extract the data.
	 * @param xmlFile
	 *            The output XML file.
	 * @param showUI
	 *            Whether the wait bar should be displayed.
     */
	public TestSnapMatlab(File mdlFile, File xmlFile, boolean showUI) {
		super(mdlFile, xmlFile, showUI);
	}

}
