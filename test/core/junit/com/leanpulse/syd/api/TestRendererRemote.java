/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import static org.junit.Assert.assertTrue;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.Locale;

import org.junit.AfterClass;
import org.junit.Test;
import org.junit.runners.Parameterized;

import com.leanpulse.syd.internal.RendererImplRemote;
import com.leanpulse.syd.internal.Utils;

/**
 * Tests the rendering server and the remote client.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Renderer
 * @see RendererManager
 */
public class TestRendererRemote extends AbsTestRenderer {
	
	/**
	 * Sets the test cases to test the rendering server and remote client.
	 * <p>
	 * The test cases check if the renderer server can be started and if the
	 * remote client can simultaneously post requests to the server to render
	 * the same XML input file with 2 different formats.
	 * 
	 * @return The collection of array of arguments to be passed to the
	 *         constructor to set each test case.
	 */
	@Parameterized.Parameters
    public static Collection<Object[]> parameters() {
    	String[] xslParams = new String[] {"resourcespath", Utils.getAbsolutePath("styles" + File.separator + "resources"),
				"currentdate", new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH).format(new Date()),
				"refmdlpaths", ""};
    	return Arrays.asList(new Object[][] {
    			{new File("SyDdemo.xml").getAbsoluteFile(),
    				new File("../../../src/core/styles/template.xsl").getAbsoluteFile(),
    				new String[][] {xslParams, xslParams},
	    			new File[] {new File("Remote1.pdf").getAbsoluteFile(),
    					new File("Remote2.pdf").getAbsoluteFile()}}
    	});
	}
	
    /**
     * Default constructor.
     * 
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
	public TestRendererRemote(File xmlFile, File xslFile,
			String[][] xslParams, File[] outFiles) {
		super(RendererManager.getRenderer(), xmlFile, xslFile, xslParams, outFiles);
	}

	/**
	 * Checks if the <code>Renderer</code> started by the
	 * {@link RendererManager} is the remote renderer client.
	 */
	@Test
	public void testRemoteRendererLaunch() {
		assertTrue(renderer instanceof RendererImplRemote);
	}
	
	/**
	 * Shuts down the rendering server that should have been started.
	 */
	@AfterClass
    public static void tearDownAfterClass() {
        RendererManager.killRemoteRenderer();
    }

}
