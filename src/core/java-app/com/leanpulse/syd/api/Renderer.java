/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.io.File;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * Interface to render data extracted from a model to a document (xml -> pdf).
 * <p>
 * <dl>
 * <dt>A renderer performs two distinct tasks in a unique step:</dt>
 * <dd>1. Transform the extracted XML data to a formatted counterpart (XSL-FO)
 * with the help of an appropriate stylesheet and a XSLT processor,<br>
 * 2. Print format the formatted data to a PDF document.</dd>
 * <dt>Those two tasks are performed as a unique step to improve performances as the
 * generation of the PDF can start as soon as the first elements of the input
 * XML are transformed.</dt>
 * </dl>
 * <p>
 * This interface enables to render several documents at the same time and for
 * this purpose, only defines asynchronous methods. The report of the progress
 * is then done via progress monitors.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see RendererManager
 */
public abstract class Renderer {
	
	/**
	 * A pool of services to be able to execute simultaneously a given number of
	 * renderings.
	 */
	protected ExecutorService service = null;
	
	/**
	 * Default constructor defining a pool of rendering services consistent with
	 * the number of processors available.
	 */
	protected Renderer() {
		int numProcs = Runtime.getRuntime().availableProcessors();
		service = Executors.newFixedThreadPool(numProcs > 1 ? numProcs-1 : 1);
	}

	/**
	 * Posts a request to render the given XML file to the given output.
	 * 
	 * @param xmlFile
	 *            The XML file to render.
	 * @param xslFile
	 *            The stylesheet to format the document.
	 * @param xslParams
	 *            The parameters to pass to the XSLT processor.
	 * @param outFile
	 *            The file in which the document will be generated.
	 * @param secOptions
	 *            The security options to protect the PDF document.
	 * @param open
	 *            If the document must be opened after the generation succeeded.
	 * @param mon
	 *            The progress monitor to which progress and errors are
	 *            reported.
	 */
	public abstract void asyncRender(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions, boolean open, IProgressMonitor mon);

}
