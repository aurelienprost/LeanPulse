/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.io.FilenameFilter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.junit.AfterClass;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

/**
 * Abstract class to test the <code>Generator</code> API.
 * <p>
 * This parameterized test class can be extended to easily defines unit tests on
 * the <code>Generator</code> API in various modeling environments.<br>
 * It provides a generic test method to check if the generation is correctly
 * working, with or without wait bar displayed.
 * <p>
 * Implementations just have to reference the default super constructor and a
 * static method annotated with <code>&#064;Parameters</code> to provide the
 * test cases.<br>
 * For this purpose, this class provides 2 static methods (
 * <code>loopOnModels</code> and <code>loopOnModelArchitectures</code>) to
 * easily compute test cases to verify the generation on, respectively, single
 * models and model architectures.
 * <p>
 * Note that test classes extending this one can only be <b>executed inside a
 * modeling environment</b> with a <code>Snapper</code> implementation provided.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Generator
 */
@RunWith(Parameterized.class)
public abstract class AbsTestGenerator {
	
	/**
	 * Computes a set of test cases checking the generation for each test models
	 * found recursively in the given directory.
	 * 
	 * @param mdlsDir
	 *            The directory where test models are stored
	 * @param mdlExt
	 *            The model file extension (ex: ".mdl", ".xcos").
	 * @param profile
	 *            The generation profile to apply.
	 * @param showUI
	 *            Whether the wait bar should be displayed.
	 * @return A collection of array of arguments that can be passed to the
	 *         constructor to set each test case.
	 */
	protected static Collection<Object[]> loopOnModels(File mdlsDir, String mdlExt, GenProfile profile, boolean showUI) {
    	List<Object[]> params = new ArrayList<Object[]>();
    	for(File file : mdlsDir.listFiles()) {
    		if(file.isDirectory()) {
    			params.addAll(loopOnModels(file, mdlExt, profile, showUI));
    		} else if(file.getName().toLowerCase().endsWith(mdlExt)) {
    			params.add(new Object[] {file, profile, showUI});
    		}
    	}
    	return params;
    }
	
	/**
	 * Computes a set of test cases checking the architecture generation
	 * starting form each root test models found in sub-directories of the given
	 * directory.
	 * 
	 * @param archDir
	 *            The directory where test model architectures are stored
	 * @param mdlExt
	 *            The model file extension (ex: ".mdl", ".xcos").
	 * @param profile
	 *            The generation profile to apply.
	 * @param showUI
	 *            Whether the wait bar should be displayed.
	 * @return A collection of array of arguments that can be passed to the
	 *         constructor to set each test case.
	 */
	protected static Collection<Object[]> loopOnModelArchitectures(File archDir, final String mdlExt, GenProfile profile, boolean showUI) {
    	List<Object[]> params = new ArrayList<Object[]>();
    	for(File dir : archDir.listFiles()) {
    		if(dir.isDirectory()) {
    			File[] mdls = dir.listFiles(new FilenameFilter() {
    				public boolean accept(File dir, String name) {
    					return name.toLowerCase().endsWith(mdlExt);
    				}
    			});
    			for(File mdl : mdls) {
    				params.add(new Object[] {mdl, profile, showUI});
    			}
    		}
    	}
    	return params;
    }
	
	protected File mdlFile;
	protected GenProfile profile;
	protected boolean showUI;
	
	/**
	 * Default constructor to be referenced by implementations.
	 * 
	 * @param mdlFile
	 *            The model file from which the documentation will be generated.
	 * @param profile
	 *            The generation profile to apply.
	 * @param showUI
	 *            Whether the wait bar should be displayed.
	 */
	public AbsTestGenerator(File mdlFile, GenProfile profile, boolean showUI) {
		this.mdlFile = mdlFile;
		this.profile = profile;
		this.showUI = showUI;
	}
	
	/**
	 * Clears the temporary extracted XML file before each test to force to
	 * re-extract data from the model.
	 */
	@Before
	public void setUp() {
		File xmlFile = SnapperManager.getSnapper().getDefaultSnapFile(mdlFile);
		File[] xmls = xmlFile.getParentFile().listFiles(new FilenameFilter() {
			public boolean accept(File dir, String name) {
				return name.toLowerCase().endsWith(".xml");
			}
		});
		for(File xml : xmls)
			xml.delete();
	}

	/**
	 * Tests the full document generation process.
	 * 
	 * @throws Exception
	 *             Means an error occurred and the test will fail.
	 */
	@Test
	public void testGenerate() throws Exception {
		if(showUI)
			assertTrue(Generator.getDefault().generateUI(mdlFile, profile, null));
		else
			Generator.getDefault().generate(mdlFile, profile);
	}
	
	/**
	 * Shuts down the rendering server.
	 */
	@AfterClass
    public static void tearDownAfterClass() {
        RendererManager.killRemoteRenderer();
    }
	
}
