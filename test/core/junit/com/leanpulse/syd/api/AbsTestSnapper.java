/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import static org.junit.Assert.assertTrue;

import java.io.File;

import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;

import com.leanpulse.syd.internal.GenProfileSnapConfImpl;

/**
 * Abstract class to test various <code>Snapper</code> implementations.
 * <p>
 * This parameterized test class can be extended to easily defines unit tests
 * for implementations of the {@link Snapper} API.<br>
 * It provides a generic test method to check if data extraction from models is
 * correctly working, with or without wait bar displayed.
 * <p>
 * Implementations just have to reference the default super constructor and a
 * static method annotated with <code>&#064;Parameters</code> to provide the
 * test cases.
 * <p>
 * Note that test classes extending this one can only be <b>executed inside a
 * modeling environment</b> with a <code>Snapper</code> implementation provided.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Snapper
 * @see SnapperManager
 */
@RunWith(Parameterized.class)
public abstract class AbsTestSnapper {
	
	protected File mdlFile;
	protected File xmlFile;
	protected boolean showUI;
	
	/**
	 * Default constructor to be referenced by implementations.
	 * 
	 * @param mdlFile
	 *            The model file from which to extract the data.
	 * @param xmlFile
	 *            The output XML file.
	 * @param showUI
	 *            Whether the wait bar should be displayed.
	 */
	public AbsTestSnapper(File mdlFile, File xmlFile, boolean showUI) {
		this.mdlFile = mdlFile;
		this.xmlFile = xmlFile;
		this.showUI = showUI;
	}
	
	/**
	 * Deletes the XML output file before running the test.
	 */
	@Before
	public void setUp() {
		xmlFile.delete();
	}
	
	/**
	 * Tests if the available snapper implementation can successfully extract
	 * XML data from the model.
	 * 
	 * @throws Exception
	 *             Means an error occurred and the test will fail.
	 */
	@Test
	public void testSnap() throws Exception {
		if(showUI)
			assertTrue(new GenProfileSnapConfImpl().snapUI(mdlFile, xmlFile, null) != null);
		else
			assertTrue(new GenProfileSnapConfImpl().snap(mdlFile, xmlFile) != null);
		assertTrue(xmlFile.exists());
	}

}
