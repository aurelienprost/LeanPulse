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

import com.leanpulse.syd.internal.progress.ThrowExStubMonitor;

/**
 * Abstract class to test various <code>Renderer</code> implementations.
 * <p>
 * This parameterized test class can be extended to easily defines unit tests
 * for implementations of the {@link Renderer} API.<br>
 * It provides a generic test method to simultaneously request the rendering of
 * several documents on a single renderer.
 * <p>
 * Implementations just have to reference the default super constructor and a
 * static method annotated with <code>&#064;Parameters</code> to provide the
 * test cases.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Renderer
 */
@RunWith(Parameterized.class)
public abstract class AbsTestRenderer {
	
    protected Renderer renderer;
    protected File xmlFile;
    protected File xslFile;
    protected String[][] xslParams;
    protected File[] outFiles;
	
	/**
	 * Default constructor to be referenced by implementations.
	 * 
	 * @param renderer
	 *            An instance of the <code>Renderer</code> implementation to
	 *            test.
	 * @param xmlFile
	 *            The test XML file to render.
	 * @param xslFile
	 *            The test stylesheet to format the document.
	 * @param xslParams
	 *            An array of sets of stylesheet parameters to perform several
	 *            rendering with various configurations.
	 * @param outFiles
	 *            The corresponding array of output files.
	 */
	public AbsTestRenderer(Renderer renderer, File xmlFile, File xslFile, String[][] xslParams, File[] outFiles) {
		this.renderer = renderer;
		this.xmlFile = xmlFile;
		this.xslFile = xslFile;
		this.xslParams = xslParams;
		this.outFiles = outFiles;
	}
	
	/**
	 * Deletes all the output files before running the tests.
	 */
	@Before
	public void setUp() {
		for(File outFile : outFiles) {
			outFile.delete();
		}
	}
	
	/**
	 * Tests if the renderer is working for all the configurations held by the
	 * class.
	 * <p>
	 * This test invokes
	 * {@link Renderer#asyncRender(File, File, String[], File, PdfSecurityOptions, boolean, com.leanpulse.syd.api.progress.IProgressMonitor)}
	 * in a loop to post all the rendering requests at the same time and verify
	 * parallel execution.
	 * 
	 * @throws Exception
	 *             Means an error occurred and the test will fail.
	 */
	@Test
	public void testAsyncRender() throws Exception {
		ThrowExStubMonitor mon = new ThrowExStubMonitor();
		mon.start("Initializing...", 100.0);
		double waitInc = 100.0 / outFiles.length;
		for(int i=0; i<outFiles.length; i++) {
			renderer.asyncRender(xmlFile, xslFile, xslParams[i], outFiles[i], new PdfSecurityOptions(),
					false, mon.createSubProgress("Rendering " + outFiles[i], waitInc));
		}
		try {
			mon.waitSubProgessFinish();
		} catch (InterruptedException e) {}
		if(mon.hasError())
			throw mon.getStoppingException();
		for(File outFile : outFiles) {
			assertTrue(outFile.exists());
		}
	}

}
