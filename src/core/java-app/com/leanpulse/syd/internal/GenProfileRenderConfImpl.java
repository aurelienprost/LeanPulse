/*********************************************
 * Copyright (c) 2014 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal;

import java.awt.Toolkit;
import java.awt.Window;
import java.io.File;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Map.Entry;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.leanpulse.syd.api.GenProfileRenderConf;
import com.leanpulse.syd.api.PdfSecurityOptions;
import com.leanpulse.syd.api.Renderer;
import com.leanpulse.syd.api.RendererManager;
import com.leanpulse.syd.api.Snapper;
import com.leanpulse.syd.api.SnapperManager;
import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.progress.ProgressFrame;
import com.leanpulse.syd.internal.progress.ProgressMonitor;
import com.leanpulse.syd.internal.progress.ThrowExStubMonitor;

/**
 * Implementation of the <code>GenProfileRenderConf</code> abstract class.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class GenProfileRenderConfImpl extends GenProfileRenderConf {
	
	/**
	 * Utility method to compute the relative path between 2 files.
	 * 
	 * @param baseFile
	 *            The base file to which the computed path will be relative.
	 * @param otherFile
	 *            The destination file.
	 * 
	 * @return The relative path.
	 */
	public static String computeRelPath(File baseFile, File otherFile) {
		String[] basePaths = baseFile.toURI().getPath().split("/");
		String[] otherPaths = otherFile.toURI().getPath().split("/");
		int n = 0;
		for(; n<Math.min(basePaths.length,otherPaths.length); n++) {
			if(!basePaths[n].equals(otherPaths[n]))
				break;
		}
		if(n < 3)
			return otherFile.toURI().getPath().replaceFirst(":", "");
		else {
			StringBuilder relPath = new StringBuilder();
			for(int m=n; m<basePaths.length; m++)
				relPath.append("../");
			for(int m=n; m<otherPaths.length; m++) {
				relPath.append(otherPaths[m]);
				if(m < otherPaths.length-1)
					relPath.append("/");
			}
			return relPath.toString();
		}
	}
	
	private static final GenProfileRenderConfImpl[] NO_RENDERERS = new GenProfileRenderConfImpl[0];
	
	protected static final String TAG_RENDERER = "pro:render";
	protected static final String ATTR_STYLE = "style";
	protected static final String ATTR_FORMAT = "format";
	protected static final String ATTR_OUTDIR = "outdir";
	protected static final String ATTR_RELTO = "relto";
	protected static final String ATTR_SUFFIX = "suffix";
	protected static final String ATTR_ACTION = "action";
	protected static final String ATTR_GENDEP = "gendep";
	protected static final String ATTR_USERPASS = "userpass";
	protected static final String ATTR_OWNERPASS = "ownerpass";
	protected static final String ATTR_NOPRINT = "noprint";
	protected static final String ATTR_NOCOPY = "nocopy";
	protected static final String ATTR_NOEDIT = "noedit";
	protected static final String ATTR_NOANNOT = "noannot";
	
	protected static final String TAG_PARAM = "pro:renderparam";
	protected static final String ATTR_NAME = "name";
	protected static final String ATTR_VALUE = "value";
	
	protected static final String[] RELTO_OPTIONS = new String[] {"model", "curdir", "parent"};
	protected static final String[] ACTION_OPTIONS = new String[] {"nop", "open"};
	protected static final String[] GENDEP_OPTIONS = new String[] {"false", "true", "embed"};
	
	protected static final String DEFAULT_STYLE = "template";
	protected static final int DEFAULT_RELTO = RELTO_MODEL;
	protected static final int DEFAULT_ACTION = ACTION_NOP;
	protected static final int DEFAULT_GENDEP = GENDEP_NO;
	protected static final String DEFAULT_SUFFIX = "";
	
	
	protected static GenProfileRenderConfImpl[] readConfRenderers(Element parentElement) throws IOException {
		return readConfRenderers(parentElement, null);
	}
	
	/*
	 * Reads the render configurations hold by the parent XML element.
	 */
	private static GenProfileRenderConfImpl[] readConfRenderers(Element parentElement, GenProfileRenderConfImpl parentConfRenderer) throws IOException {
		List<GenProfileRenderConfImpl> childRenderers = new ArrayList<GenProfileRenderConfImpl>();
		Map<String,String> profileparams = new HashMap<String,String>();
		NodeList childNodes = parentElement.getChildNodes();
		for(int i=0; i<childNodes.getLength(); i++) {
			Node child = childNodes.item(i);
			if(child.getNodeType() == Node.ELEMENT_NODE) {
				Element element = (Element) child;
				String tag = element.getTagName();
				if(TAG_RENDERER.equals(tag)) {
					String style = Utils.getDefaultAttribute(element, ATTR_STYLE, DEFAULT_STYLE);
					String format = Utils.getDefinedAttribute(element, ATTR_FORMAT);
					File outdir = new File(Utils.getDefinedAttribute(element, ATTR_OUTDIR));
					int relto = Utils.getDefaultAttribute(element, ATTR_RELTO, RELTO_OPTIONS, DEFAULT_RELTO);
					String suffix = Utils.getDefaultAttribute(element, ATTR_SUFFIX, DEFAULT_SUFFIX);
					String ownerpass = Utils.getDefaultAttribute(element, ATTR_OWNERPASS, null);
					String userpass = Utils.getDefaultAttribute(element, ATTR_USERPASS, null);
					boolean noprint = Utils.getDefaultAttribute(element, ATTR_NOPRINT, false);
					boolean nocopy = Utils.getDefaultAttribute(element, ATTR_NOCOPY, false);
					boolean noedit = Utils.getDefaultAttribute(element, ATTR_NOEDIT, false);
					boolean noannot = Utils.getDefaultAttribute(element, ATTR_NOANNOT, false);
					int action = Utils.getDefaultAttribute(element, ATTR_ACTION, ACTION_OPTIONS, DEFAULT_ACTION);
					int gendep = Utils.getDefaultAttribute(element, ATTR_GENDEP, GENDEP_OPTIONS, DEFAULT_GENDEP);
					GenProfileRenderConfImpl confRenderer = new GenProfileRenderConfImpl(style, format, outdir, relto, suffix,
							new PdfSecurityOptions(ownerpass, userpass, noprint, nocopy, noedit, noannot), action, gendep);
					confRenderer.children = readConfRenderers(element, confRenderer);
					childRenderers.add(confRenderer);
				} else if(TAG_PARAM.equals(tag)) {
					String name =  Utils.getDefinedAttribute(element, ATTR_NAME);
					String value =  Utils.getDefinedAttribute(element, ATTR_VALUE);
					if(parentConfRenderer != null) {
						parentConfRenderer.params.put(name,value);
					} else {
						profileparams.put(name,value);
					}
				}
			}
		}
		if(childRenderers.size() > 0) {
			GenProfileRenderConfImpl[] renderConfs = childRenderers.toArray(new GenProfileRenderConfImpl[0]);
			for(int i=0; i<renderConfs.length; i++) {
				renderConfs[i].inheriteParams(profileparams);
			}
			return renderConfs;
		} else
			return NO_RENDERERS;
	}
	
	
	private String style;
	private String format;
	private File outdir;
	private int relto;
	private String suffix;
	private PdfSecurityOptions secoptions;
	private int postaction;
	private int gendep;
	private Map<String,String> params;
	private GenProfileRenderConfImpl[] children;
	
	public GenProfileRenderConfImpl(String style, String format, File outdir, int relto, String suffix, PdfSecurityOptions secoptions,
			int action, int gendep) {
		this(style, format, outdir, relto, suffix, secoptions, action, gendep, new HashMap<String,String>(0), NO_RENDERERS);
	}
	
	public GenProfileRenderConfImpl(String style, String format, File outdir, int relto, String suffix, PdfSecurityOptions secoptions,
			int action, int gendep,	Map<String,String> params) {
		this(style, format, outdir, relto, suffix, secoptions, action, gendep, params, NO_RENDERERS);
	}
	
	public GenProfileRenderConfImpl(String style, String format, File outdir, int relto, String suffix, PdfSecurityOptions secoptions,
			int action, int gendep, Map<String,String> params, GenProfileRenderConfImpl[] children) {
		this.style = style;
		this.format = format;
		this.outdir = outdir;
		this.relto = relto;
		this.suffix = suffix;
		this.secoptions = secoptions;
		this.postaction = action;
		this.gendep = gendep;
		this.params = params;
		this.children = children;
	}
	
	protected void inheriteParams(Map<String,String> parentparams) {
		Iterator<Entry<String,String>> it = parentparams.entrySet().iterator();
		while(it.hasNext()) {
			Entry<String,String> profileparam = it.next();
			if(!params.containsKey(profileparam.getKey())) {
				params.put(profileparam.getKey(), profileparam.getValue());
			}
		}
		for(int i=0; i < children.length; i++) {
			children[i].inheriteParams(params);
		}
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getStyle()
	 */
	@Override
	public File getStyle() {
		File xslFile = new File(Utils.getAbsolutePath("styles" + File.separator + style + ".cxs"));
		if(!xslFile.exists())
			xslFile = new File(Utils.getAbsolutePath("styles" + File.separator + style + ".xsl"));
		return xslFile;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getOutputDir()
	 */
	@Override
	public File getOutputDir() {
		return outdir;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getRelativeTo()
	 */
	@Override
	public int getRelativeTo() {
		return relto;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getSuffix()
	 */
	@Override
	public String getSuffix() {
		return suffix;
	}
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getOutput(java.io.File, java.io.File)
	 */
	@Override
	public File computeOutput(File mdlFile, File parDir){
		String compOutDir = null;
		try {
			if(!outdir.isAbsolute()) {
				switch(relto) {
					case RELTO_CURDIR:
						Snapper snapper = SnapperManager.getSnapper();
						if(snapper != null) {
							String curDir = snapper.getCurDir();
							if(curDir.isEmpty()) // While unit-testing with Matlab, the CWD returned is empty
								curDir = System.getProperty("user.dir");
							compOutDir = new File(curDir + File.separator + outdir.getPath()).getCanonicalPath();
						} else
							compOutDir = new File(System.getProperty("user.dir") + File.separator + outdir.getPath()).getCanonicalPath();
						break;
					case RELTO_PARENT:
						compOutDir = new File(parDir.getPath() + File.separator + outdir.getPath()).getCanonicalPath();
						break;
					default:
						compOutDir = new File(mdlFile.getParent() + File.separator + outdir.getPath()).getCanonicalPath();
				}
			} else {
				compOutDir = outdir.getCanonicalPath();
			}
		} catch(IOException e) {}
		return new File(compOutDir + File.separator + Utils.getFileNameWithoutExtension(mdlFile) + suffix + "." + format);
	}
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getSecurityOptions()
	 */
	@Override
	public PdfSecurityOptions getSecurityOptions() {
		return secoptions;
	}

	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getPostGenAction()
	 */
	@Override
	public int getPostGenAction() {
		return postaction;
	}
	
	// For unit tests
	public void setNoOpen() {
		postaction = ACTION_NOP;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getGenDependencies()
	 */
	@Override
	public int getGenDependencies() {
		return gendep;
	}
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getSubRenderConf(java.io.File)
	 */
	@Override
	public GenProfileRenderConf getSubRenderConf(File refMdlFile) {
		return children.length > 0 ? children[0] : this;
	}
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getSubParentDir(java.io.File, java.io.File)
	 */
	@Override
	public File getSubParentDir(File outFile, File parDir) {
		if(relto == GenProfileRenderConfImpl.RELTO_PARENT)
			return parDir;
		else
			return outFile.getParentFile();
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#getStyleParams(java.io.File, java.io.File, java.util.List, java.io.File, java.util.List)
	 */
	@Override
	public String[] getStyleParams(File xmlFile, File outFile, List<File> refMdls, File subParDir, List<File> refOutFiles) {
		String[] xslParams = new String[params.size()*2 + 10];
		int i = 0;
		xslParams[i++] = "resourcespath";
		xslParams[i++] = Utils.getAbsolutePath("styles" + File.separator + "resources");
		xslParams[i++] = "currentdate";
		xslParams[i++] = new SimpleDateFormat("dd MMM yyyy", Locale.ENGLISH).format(new Date());
		xslParams[i++] = "gendep";
		xslParams[i++] = GENDEP_OPTIONS[gendep];
		xslParams[i++] = "xmluri";
		xslParams[i++] = xmlFile.getParentFile().toURI().toString();
		xslParams[i++] = "refmdlpaths";
		if(gendep != GENDEP_EMBED) {
			StringBuilder refMdlPaths = new StringBuilder();
			for(int j=0; j<refMdls.size(); j++) {
				File refMdlFile = refMdls.get(j);
				File refOutFile = getSubRenderConf(refMdlFile).computeOutput(refMdlFile, subParDir);
				if(refOutFiles != null)
					refOutFiles.add(refOutFile);
				refMdlPaths.append(Utils.getFileNameWithoutExtension(refMdlFile));
				refMdlPaths.append("=");
				refMdlPaths.append(computeRelPath(outFile.getParentFile(), refOutFile));
				if(j < refMdls.size()-1)
					refMdlPaths.append(";");
			}
			xslParams[i++] = refMdlPaths.toString();
		} else
			xslParams[i++] = "";
		Iterator<Entry<String,String>> it = params.entrySet().iterator();
		while(it.hasNext()) {
			Entry<String,String> param = it.next();
			xslParams[i++] = param.getKey();
			xslParams[i++] = param.getValue();
		}
		return xslParams;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#render(java.io.File, java.util.List)
	 */
	@Override
	public void render(File xmlFile, List<File> refMdls) throws Exception {
		ThrowExStubMonitor mon = new ThrowExStubMonitor();
		
		render(xmlFile, refMdls, mon);
		
		if(mon.hasError())
			throw mon.getStoppingException();
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#render(java.io.File, java.util.List, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	@Override
	public boolean render(File xmlFile, List<File> refMdls, IProgressMonitor mon) {
		mon.start("Initializing...", 100.0);
		long startTime = System.currentTimeMillis();
		
		Renderer renderer = RendererManager.getRenderer(mon.createSubProgress("Preparing to render documents...", 5.0));
		
		File parDir = xmlFile.getParentFile();
		if(!mon.isCanceled()) {
			File outFile = computeOutput(xmlFile, parDir);
			File subParDir = getSubParentDir(outFile, parDir);
			String[] xslParams = getStyleParams(xmlFile, outFile, refMdls, subParDir, null);
			renderer.asyncRender(xmlFile, getStyle(), xslParams, outFile, secoptions,
					postaction == GenProfileRenderConf.ACTION_OPEN,
					mon.createSubProgress("Rendering document \"" + outFile.getName() + "\"...", 95.0));
		}
		
		try {
			mon.waitSubProgessFinish();
		} catch (InterruptedException e) {}
		
		if(mon.hasError()) {
			mon.finish("Rendering finished with error...");
			return false;
		} else {
			if(mon.isCanceled())
				mon.finish("Rendering cancelled by user.");
			else {
				int timeElapsed = (int) (System.currentTimeMillis() - startTime) / 1000;
				mon.finish("Successful document(s) rendering in " + Integer.toString(timeElapsed) + "s.");
			}
			return true;
		}
		
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfileRenderConf#renderUI(java.io.File, java.util.List, java.awt.Window)
	 */
	@Override
	public boolean renderUI(File xmlFile, List<File> refMdls, Window appwin) {
		ProgressFrame dial = new ProgressFrame(appwin, "SyD - Rendering in progress...", "Rendering file " + xmlFile.getName());
		dial.display();
		ProgressMonitor mon = dial.getMonitor();
		
		render(xmlFile, refMdls, mon);
		
		if(mon.hasError()) {
			Toolkit.getDefaultToolkit().beep();
			dial.showDetails();
			return false;
		} else {
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {}
			dial.close();
			return true;
		}
	}
	

}
