/*********************************************
 * Copyright (c) 2014 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal;

import java.awt.Toolkit;
import java.awt.Window;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.swing.JOptionPane;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.leanpulse.syd.api.GenProfileSnapConf;
import com.leanpulse.syd.api.Snapper;
import com.leanpulse.syd.api.SnapperManager;
import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.progress.ProgressFrame;
import com.leanpulse.syd.internal.progress.ProgressMonitor;
import com.leanpulse.syd.internal.progress.ThrowExStubMonitor;

/**
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 *
 */
public class GenProfileSnapConfImpl extends GenProfileSnapConf {
	
	protected static final String TAG_SNAPPER = "pro:snap";
	protected static final String ATTR_LINKS = "followlinks";
	protected static final String ATTR_MASKS = "lookundermasks";
	
	protected static final String TAG_PARAM = "pro:snapparam";
	protected static final String ATTR_NAME = "name";
	protected static final String ATTR_VALUE = "value";
	
	protected static GenProfileSnapConfImpl readConfSnapper(Element parentElement) throws IOException {
		return readConfSnapper(parentElement, null);
	}
	
	/*
	 * Reads the snapper configuration hold by the parent XML element.
	 */
	protected static GenProfileSnapConfImpl readConfSnapper(Element parentElement, GenProfileSnapConfImpl parentConfSnapper) throws IOException {
		NodeList childNodes = parentElement.getChildNodes();
		for(int i=0; i<childNodes.getLength(); i++) {
			Node child = childNodes.item(i);
			if(child.getNodeType() == Node.ELEMENT_NODE) {
				Element element = (Element) child;
				String tag = element.getTagName();
				if(TAG_SNAPPER.equals(tag)) {
					boolean followLinks = Utils.getDefaultAttribute(element, ATTR_LINKS, false);
					boolean lookUnderMasks = Utils.getDefaultAttribute(element, ATTR_MASKS, false);
					GenProfileSnapConfImpl snapConf = new GenProfileSnapConfImpl(followLinks, lookUnderMasks);
					readConfSnapper(element, snapConf);
					return snapConf;
				} else if(TAG_PARAM.equals(tag)) {
					String name =  Utils.getDefinedAttribute(element, ATTR_NAME);
					String value =  Utils.getDefinedAttribute(element, ATTR_VALUE);
					if(parentConfSnapper != null)
						parentConfSnapper.params.put(name,value);
				}
			}
		}
		return new GenProfileSnapConfImpl();
	}
	
	
	private boolean followLinks;
	private boolean lookUnderMasks;
	private Map<String,String> params;
	
	public GenProfileSnapConfImpl() {
		this(false, false, new HashMap<String,String>(0));
	}
	
	public GenProfileSnapConfImpl(boolean followLinks, boolean lookUnderMasks) {
		this(followLinks, lookUnderMasks, new HashMap<String,String>(0));
	}

	public GenProfileSnapConfImpl(boolean followLinks, boolean lookUnderMasks, Map<String,String> params) {
		this.followLinks = followLinks;
		this.lookUnderMasks = lookUnderMasks;
		this.params = params;
	}
	
	protected void inheriteParams(Map<String,String> parentparams) {
		Iterator<Entry<String,String>> it = parentparams.entrySet().iterator();
		while(it.hasNext()) {
			Entry<String,String> profileparam = it.next();
			if(!params.containsKey(profileparam.getKey())) {
				params.put(profileparam.getKey(), profileparam.getValue());
			}
		}
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileSnapConf#isFollowingLinks()
	 */
	@Override
	public boolean isFollowingLinks() {
		return followLinks;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileSnapConf#isLookingUnderMasks()
	 */
	@Override
	public boolean isLookingUnderMasks() {
		return lookUnderMasks;
	}

	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileSnapConf#getParams()
	 */
	@Override
	public Map<String, String> getParams() {
		return params;
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileSnapConf#snap(java.io.File, java.io.File, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	@Override
	public List<File> snap(File mdlFile, File xmlFile, IProgressMonitor mon) {
		mon.start("Initializing...", 100.0);
		long startTime = System.currentTimeMillis();
		List<File> refMdls = null;
		
		Snapper snapper = SnapperManager.getSnapper();
		refMdls = snapper.snap(mdlFile, followLinks, lookUnderMasks, params, xmlFile,
				mon.createSubProgress("Extracting data from model \"" + mdlFile.getName() + "\"...", 100.0));
		
		if(mon.hasError())
			mon.finish("Rendering finished with error...");
		else {
			if(mon.isCanceled())
				mon.finish("Rendering cancelled by user.");
			else {
				int timeElapsed = (int) (System.currentTimeMillis() - startTime) / 1000;
				mon.finish("Successful extraction in " + Integer.toString(timeElapsed) + "s.");
			}
		}
		return refMdls;
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileSnapConf#snap(java.io.File, java.io.File)
	 */
	@Override
	public List<File> snap(File mdlFile, File xmlFile) throws Exception {
		ThrowExStubMonitor mon = new ThrowExStubMonitor();
		List<File> refMdls = snap(mdlFile, xmlFile, mon);
		if(mon.hasError())
			throw mon.getStoppingException();
		return refMdls;
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileSnapConf#snapUI(java.io.File, java.io.File, java.awt.Window)
	 */
	@Override
	public List<File> snapUI(File mdlFile, File xmlFile, Window appwin) {
		if(mdlFile == null || mdlFile.getPath().length() == 0) {
			JOptionPane.showMessageDialog(appwin,
			    "The model has to be saved first.",
			    "SyD - Error",
			    JOptionPane.ERROR_MESSAGE);
			return null;
		}
		
		ProgressFrame dial = new ProgressFrame(appwin, "SyD - Generation in progress...", "Extracting data from model " + mdlFile.getName());
		dial.display();
		ProgressMonitor mon = dial.getMonitor();
		
		List<File> refMdls = snap(mdlFile, xmlFile, mon);
		
		if(mon.hasError()) {
			Toolkit.getDefaultToolkit().beep();
			dial.showDetails();
			return null;
		} else {
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {}
			dial.close();
			return refMdls;
		}
	}

}
