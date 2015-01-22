/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collection;
import java.util.Date;
import java.util.Locale;

import org.junit.runners.Parameterized;

import com.leanpulse.syd.internal.RendererImplExternal;
import com.leanpulse.syd.internal.Utils;

/**
 * Tests the external renderer.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Renderer
 */
public class TestRendererExternal extends AbsTestRenderer {
	
	/**
	 * Sets the test cases to test the external renderer.
	 * <p>
	 * The test cases check if the external renderer can simultaneously render
	 * the same XML input file with 2 different formats.
	 * 
	 * @return The collection of array of arguments to be passed to the
	 *         constructor to set each test case.
	 */
	@Parameterized.Parameters
    public static Collection<Object[]> parameters() {
    	String resPath = Utils.getAbsolutePath("styles" + File.separator + "resources");
    	String dateStr = new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH).format(new Date());
    	String[] xslPortraitParams = new String[] {"resourcespath", resPath,
				"currentdate", dateStr,
				"refmdlpaths", ""};
    	String[] xslLandscapeParams = new String[] {"resourcespath", resPath,
				"currentdate", dateStr,
				"refmdlpaths", "",
				"pageheight", "210",
				"pagewidth", "297"};
    	return Arrays.asList(new Object[][] {
    			{new File("SyDdemo.xml").getAbsoluteFile(),
    				new File("../../../src/core/styles/template.xsl").getAbsoluteFile(),
    				new String[][] {xslPortraitParams, xslLandscapeParams},
	    			new File[] {new File("External1.pdf").getAbsoluteFile(),
    					new File("External2.pdf").getAbsoluteFile()}}
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
	public TestRendererExternal(File xmlFile, File xslFile,
			String[][] xslParams, File[] outFiles) {
		super(RendererImplExternal.getDefault(), xmlFile, xslFile, xslParams, outFiles);
	}

}
