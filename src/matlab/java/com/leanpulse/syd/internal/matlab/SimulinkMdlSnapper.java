/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.matlab;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CancellationException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import org.apache.commons.io.FilenameUtils;

import com.leanpulse.syd.api.Snapper;
import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.mathworks.jmi.MatlabException;
import com.mathworks.jmi.bean.UDDObject;

/**
 * <code>Snapper</code> implementation for Simulink.
 * <p>
 * The actual implementation of the data extraction from Simulink models is
 * done by a Matlab script ("sydSnap.m") invoked by this class.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class SimulinkMdlSnapper extends Snapper {
	
	private MatlabControl matlab;
	
	/*
	 * Creates the Simulink snapper.
	 */
	public SimulinkMdlSnapper() {
		super();
		matlab = new MatlabControl();
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#getCurDir()
	 */
	@Override
	public String getCurDir() {
		// Requests Matlab for the cur dir (can be different from the Java "user.dir" value).
		return matlab.getCurDir();
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#isDirty(java.io.File)
	 */
	@Override
	protected boolean isDirty(File mdlFile) {
		UDDObject root = matlab.getSlRoot();
		// Loop through the Simulink root children to find the corresponding opened model
		root.updateChildCount();
		for(int i=0; i<root.getChildCount(); i++) {
			UDDObject child = root.getChildAt(i);
			if("Simulink.BlockDiagram".equals(child.getClassName())
					&& mdlFile.equals(new File((String)child.getPropertyValue("FileName")))) {
				return ((Boolean)child.getPropertyValue("Dirty")).booleanValue();
			}
		}
		// Model not opened, can't be dirty
		return false;
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#getVersion(java.io.File)
	 */
	@Override
	protected String getVersion(File mdlFile) {
		// Try to read the version from the opened model
		UDDObject root = matlab.getSlRoot();
		for(int i=0; i<root.getChildCount(); i++) {
			UDDObject child = root.getChildAt(i);
			if("Simulink.BlockDiagram".equals(child.getClassName())
					&& mdlFile.equals(new File((String)child.getPropertyValue("FileName")))) {
				return (String)child.getPropertyValue("ModelVersion");
			}
		}
		
		// Model not opened, read the version directly in the file to avoid opening it if unchanged
		BufferedReader reader = null;
		String ver = null;
		try {
			boolean isSlx = FilenameUtils.isExtension(mdlFile.getName(), "slx");
			if(isSlx) {
				ZipFile slxFile = new ZipFile(mdlFile);
				reader = new BufferedReader(new InputStreamReader(slxFile.getInputStream(new ZipEntry("simulink/blockdiagram.xml"))));
			} else {
				reader = new BufferedReader(new FileReader(mdlFile));
			}
			int lineIdx = 0;
			String line = null;
			while ((line = reader.readLine()) != null && lineIdx < 200) {
				lineIdx++;
				if(line.contains("ModelVersionFormat")) {
					Matcher matcher = Pattern.compile(isSlx ? "<P Name=\"ModelVersionFormat\">([^<]+)<\\/P>" : "ModelVersionFormat\\W+\"([^\\\"]+)\"").matcher(line);
					if(matcher.find())
						ver = matcher.group(1).replaceFirst(isSlx ? "%&lt;AutoIncrement:(\\d+)&gt;" : "%<AutoIncrement:(\\d+)>", "$1");
					break;
				}
			}
		} catch (Exception e) {
		} finally {
			try {
				if (reader != null) reader.close();
			} catch (IOException e) {}
		}
		return ver;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#locateModels(java.lang.String[])
	 */
	@Override
	protected List<File> locateModels(String[] mdlNames) {
		try {
			// Calls the "sydLocate" script to locate the models.
			String[] refMdlPaths = (String[]) matlab.feval("sydLocate", new Object[] {mdlNames});
			List<File> refMdls = new ArrayList<File>();
			if(refMdlPaths.length > 0) {
				for(String refMdlPath : refMdlPaths)
					refMdls.add(new File(refMdlPath));
			}
			return refMdls;
		} catch (MatlabException e) {
			return NO_MDLREF;
		}
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#resnap(java.io.File, boolean, boolean, java.util.Map, java.io.File, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	@Override
	protected List<File> resnap(File mdlFile, boolean followLinks, boolean lookUnderMasks, Map<String,String> params, File xmlFile, IProgressMonitor mon) {
		String[] paramsArray = new String[params.size()*2];
		int i = 0;
		for(String key : params.keySet()) {
			paramsArray[i++] = key;
			paramsArray[i++] = params.get(key);
		}
		try {
			// Calls the "sydSnap" script to snap the model.
			String[] refMdlPaths = (String[]) matlab.feval("sydSnap", new Object[] {mdlFile.getPath(),
					followLinks,
					lookUnderMasks,
					paramsArray,
					xmlFile.getPath(),
					mon});
			List<File> refMdls;
			if(refMdlPaths.length > 0) {
				refMdls = new ArrayList<File>();
				for(String refMdlPath : refMdlPaths)
					refMdls.add(new File(refMdlPath));
			} else
				refMdls = NO_MDLREF;
			mon.finish("Data extracted from model \"" + mdlFile.getName() + "\" successfully.");
			return refMdls;
		} catch (MatlabException e) { // If an error occurred or the operation was canceled by the user.
			String errMess = e.getMessage();
			if(errMess != null && errMess.contains(CancellationException.class.getCanonicalName()))
				mon.finish("Extraction from model \"" + mdlFile.getName() + "\" cancelled by user.");
			else
				mon.finish("An error occured while extracting data from model \"" + mdlFile.getPath() + "\" !", e);
			return null;
		}
	}

}
