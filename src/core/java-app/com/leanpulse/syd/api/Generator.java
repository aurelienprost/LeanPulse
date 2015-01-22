/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.awt.Window;
import java.io.File;

import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.GeneratorImpl;

/**
 * API to generate documentation from models (mdl, xcos, etc. -> pdf).
 * <p>
 * This class provides methods to directly generate documentation from a model,
 * with or without report of progress to the user.<br>
 * Depending on the generation profile applied, one or several documents can be
 * generated at once. The entire or partial hierarchy starting from the root
 * model can also be documented in a single shot.
 * <p>
 * Even for a hierarchy, one document per model is generated, with direct
 * cross-links embedded to enable seamless navigation in the documentation
 * package.
 * <dl>
 * <dt>For each model, the generation follows a 2-steps process:</dt>
 * <dd>1. XML data are extracted from the model by a {@link Snapper},<br>
 * 2. The XML is rendered to a PDF by a {@link Renderer}.</dd>
 * </dl>
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see GenProfile
 * @see Snapper
 * @see Renderer
 */
public abstract class Generator {
	
	private static Generator instance;
	
	/**
	 * Get the default implementation of the API.
	 * 
	 * @return The implementation of the API.
	 */
	public static synchronized final Generator getDefault() {
		if(instance == null)
			instance = new GeneratorImpl();
		return instance;
	}
	
	
	/**
	 * Generates system documentation from a model.
	 * <p>
	 * Where the documents are output and how the generation is performed is
	 * controlled by the given <code>profile</code>.<br>
	 * The progress of the generation is reported to the supplied
	 * <code>monitor</code>. If an error occurs in a subtask, it will be
	 * reported to the progress monitor but the generation will carry on, so far
	 * as possible.
	 * 
	 * @param mdlFile
	 *            The model file from which the system documentation will be
	 *            generated.
	 * @param profile
	 *            The generation profile to apply.
	 * @param monitor
	 *            The progress monitor to which progress and errors are
	 *            reported.
	 * @return True if the generation fully succeeded or false if an error
	 *         occurred.
	 */
	public abstract boolean generate(File mdlFile, GenProfile profile, IProgressMonitor monitor);
	
	
	/**
	 * Generate system documentation from a model without reporting progress.
	 * <p>
	 * In case of errors during the generation process, exceptions are directly
	 * thrown and other parallel running tasks aborted.
	 * 
	 * @param mdlFile
	 *            The model file from which the system documentation will be
	 *            generated.
	 * @param profile
	 *            The generation profile to apply.
	 * @throws Exception
	 *            If an error occurred during the generation.
	 * 
	 * @see #generate(File, GenProfile, IProgressMonitor)
	 */
	public abstract void generate(File mdlFile, GenProfile profile) throws Exception;
	
	
	/**
	 * Generates system documentation from a model and reports progress to the
	 * user with an advanced wait bar.
	 * <p>
	 * In cases of error during the generation process, exceptions are reported
	 * in the UI without stopping other parallel running tasks.
	 * 
	 * @param mdlFile
	 *            The model file from which the system documentation will be
	 *            generated.
	 * @param profile
	 *            The generation profile to apply.
	 * @param appwin
	 *            The window in relation to which the wait bar location is
	 *            determined. If <code>null</code>, it is placed at the center
	 *            of the screen.
	 * @return True if the generation fully succeeded or false if an error
	 *         occurred.
	 * 
	 * @see #generate(File, GenProfile, IProgressMonitor)
	 */
	public abstract boolean generateUI(File mdlFile, GenProfile profile, Window appwin);
	
	
	/**
	 * Utility method to start the generation and not wait for it to be
	 * finished.
	 * <p>
	 * Same behavior as <code>generateUI</code> but the task is executed in a
	 * separate thread.
	 * 
	 * @param mdlFile
	 *            The model file from which the system documentation will be
	 *            generated.
	 * @param profile
	 *            The generation profile to apply.
	 * @param appwin
	 *            The window in relation to which the wait bar location is
	 *            determined. If <code>null</code>, it is placed at the center
	 *            of the screen.
	 * 
	 * @see #generateUI(File, GenProfile, Window)
	 */
	public abstract void asyncGenerateUI(File mdlFile, GenProfile profile, Window appwin);
	
	
}
