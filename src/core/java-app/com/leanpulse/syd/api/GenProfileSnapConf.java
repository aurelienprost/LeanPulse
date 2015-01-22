/*********************************************
 * Copyright (c) 2012 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.awt.Window;
import java.io.File;
import java.util.List;
import java.util.Map;

import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 *
 * @see Snapper
 */
public abstract class GenProfileSnapConf {
	
	/*
	 * Implementation will provide the correct constructor.
	 */
	protected GenProfileSnapConf() {};
	
	public abstract boolean isFollowingLinks();
	
	public abstract boolean isLookingUnderMasks();
	
	/**
	 * Gets the parameters to pass to the snapper.
	 * 
	 * @return The parameters to pass to the snapper.
	 */
	public abstract Map<String,String> getParams();
	
	/**
	 * Utility method to extract XML data from a model with this snapper
	 * configuration.
	 * <p>
	 * The progress of the extraction is reported to the supplied monitor. If an
	 * error occurs, it is reported to the progress monitor and
	 * <code>null</code> is returned.
	 * <p>
	 * If the model hasn't changed since the last extraction as given by the XML
	 * file, the snaps may not actually be performed and the XML directly
	 * reused.
	 * 
	 * @param mdlFile
	 *            The model file from which to extract the data.
	 * @param xmlFile
	 *            The output XML file.
	 * @param mon
	 *            The progress monitor to which progress and errors are
	 *            reported.
	 * @return The list of models referenced by <code>mdlFile</code> or
	 *         <code>null</code> if the extraction failed.
	 */
	public abstract List<File> snap(File mdlFile, File xmlFile, IProgressMonitor mon);

	/**
	 * Utility method to extract XML data from a model with this snapper
	 * configuration and without reporting progress.
	 * <p>
	 * If an error occurs during the rendering, it is directly thrown.
	 * 
	 * @param mdlFile
	 *            The model file from which to extract the data.
	 * @param xmlFile
	 *            The output XML file.
	 * @return The list of models referenced by <code>mdlFile</code>.
	 * 
	 * @throws Exception
	 *            If an error occurred during the extraction.
	 * 
	 * @see #snap(File, File, IProgressMonitor)
	 */
	public abstract List<File> snap(File mdlFile, File xmlFile) throws Exception;
	
	/**
	 * Utility method to extract XML data from a model with this snapper
	 * configuration and report progress to the user with an advanced wait bar.
	 * <p>
	 * If an error occurs during the extraction, the exception is reported in the
	 * UI and <code>null</code> is returned.
	 * 
	 * @param mdlFile
	 *            The model file from which to extract the data.
	 * @param xmlFile
	 *            The output XML file.
	 * @param appwin
	 *            The window in relation to which the wait bar location is
	 *            determined. If <code>null</code>, it is placed at the center
	 *            of the screen.
	 * @return The list of models referenced by <code>mdlFile</code> or
	 *         <code>null</code> if the extraction failed.
	 * 
	 * @see #snap(File, File, IProgressMonitor)
	 */
	public abstract List<File> snapUI(File mdlFile, File xmlFile, Window appwin);

}
