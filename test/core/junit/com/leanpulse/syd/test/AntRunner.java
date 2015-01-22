/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.test;

import java.io.File;

import org.apache.tools.ant.Project;
import org.apache.tools.ant.ProjectHelper;

/**
 * A simple Ant runner to execute Ant build scripts.
 * <p>
 * This is used to run batch unit tests directly inside the modeling
 * environments (Matlab, Scilab, etc.).
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class AntRunner {
	
	protected Project antProject;
	
	/**
	 * Simplified constructor used in Scilab.
	 * <p>
	 * This constructor sets the results directory relative to the Ant build file
	 * with the following path: "../#results".
	 * 
	 * @param buildFile
	 *            The Ant build file to load.
	 */
	public AntRunner(String buildFile) {
		this(buildFile, new File(buildFile).getParentFile().getParentFile() + File.separator + "#results");
	}
	
	/**
	 * Default constructor that loads the provided build file and sets some
	 * properties.
	 * 
	 * @param buildFile
	 *            The Ant build file to load.
	 * @param resultsDir
	 *            The path of the results directory to define the "results.dir"
	 *            property used in the build script.
	 */
	public AntRunner(String buildFile, String resultsDir) {
		antProject = new Project();
		
		// setting up the ant.file and results.dir property
		antProject.setUserProperty("ant.file", buildFile);
		antProject.setUserProperty("results.dir", resultsDir);
		
		antProject.init();
		ProjectHelper.configureProject(antProject, new File(buildFile));
	}
	
	/**
	 * Executes the default target.
	 */
	public void execute() {
		String defaultTarget = antProject.getDefaultTarget();
		antProject.executeTarget(defaultTarget);
	}
	
	/**
	 * Executes the target with the provided name.
	 * 
	 * @param target
	 *            The name of the target to execute.
	 */
	public void execute(String target) {
		antProject.executeTarget(target);
	}
	

}
