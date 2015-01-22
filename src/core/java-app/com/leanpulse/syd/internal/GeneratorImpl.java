/*********************************************
 * Copyright (c) 2014 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal;

import java.awt.Toolkit;
import java.awt.Window;
import java.io.File;
import java.util.ArrayList;
import java.util.List;

import javax.swing.JOptionPane;

import com.leanpulse.syd.api.GenProfile;
import com.leanpulse.syd.api.GenProfileRenderConf;
import com.leanpulse.syd.api.GenProfileSnapConf;
import com.leanpulse.syd.api.Generator;
import com.leanpulse.syd.api.Renderer;
import com.leanpulse.syd.api.RendererManager;
import com.leanpulse.syd.api.Snapper;
import com.leanpulse.syd.api.SnapperManager;
import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.progress.ProgressFrame;
import com.leanpulse.syd.internal.progress.ProgressMonitor;
import com.leanpulse.syd.internal.progress.ThrowExStubMonitor;

/**
 * Implementation of the <code>Generator</code> abstract class.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class GeneratorImpl extends Generator {
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.Generator#generate(java.io.File, com.leanpulse.syd.api.GenProfile)
	 */
	@Override
	public void generate(File mdlFile, GenProfile profile) throws Exception {
		ThrowExStubMonitor mon = new ThrowExStubMonitor();
		
		generate(mdlFile, profile, mon);
		
		if(mon.hasError())
			throw mon.getStoppingException();
	}
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.Generator#generate(java.io.File, com.leanpulse.syd.api.GenProfile, com.leanpulse.syd.spi.progress.IProgressMonitor)
	 */
	@Override
	public boolean generate(File mdlFile, GenProfile profile, IProgressMonitor mon) {
		mon.start("Initializing...", 100.0);
		long startTime = System.currentTimeMillis();
		
		IProgressMonitor snapSubMon = mon.createSubProgress("Extracting data from model \"" + mdlFile.getName() + "\"...", 25.0);
		
		Snapper snapper = SnapperManager.getSnapper();
		if(snapper != null) { // SyD may have been started outside a modeling environment.
			File xmlFile = snapper.getDefaultSnapFile(mdlFile);
			GenProfileSnapConf snapConf = profile.getSnapConf();
			List<File> refMdls = snapper.snap(mdlFile, snapConf.isFollowingLinks(), snapConf.isLookingUnderMasks(), snapConf.getParams(), xmlFile, snapSubMon);
			
			if(refMdls != null) { // The XML data extraction from the model succeed.
				Renderer renderer = RendererManager.getRenderer(mon.createSubProgress("Preparing to render documents...", 5.0));
				
				if(!mon.isCanceled()) {
					GenProfileRenderConf[] rendererConfs = profile.getRenderConfs();
					for(GenProfileRenderConf renderConf : rendererConfs) { // Iterate through the rendering confs defined by the profile.
						File parDir = mdlFile.getParentFile();
						File outFile = renderConf.computeOutput(mdlFile, parDir);
						File refParDir = renderConf.getSubParentDir(outFile, parDir);
						if(!render(snapConf, renderer, renderConf, xmlFile, outFile, refMdls, refParDir, mon, 70.0 / rendererConfs.length))
							break;
					}
				}
				
				// Waits for document renderings started asynchronously to finish.
				try {
					mon.waitSubProgessFinish();
				} catch (InterruptedException e) {}
			}
		} else {
			mon.finish(null, new Exception("Current classpath doesn't include any implementation of MdlSnapper !!"));
		}
		
		// Checks if one of the main or sub-tasks finished with an error.
		if(mon.hasError()) {
			mon.finish("Generation finished with error...");
			return false;
		} else {
			if(mon.isCanceled())
				mon.finish("Generation cancelled by user.");
			else {
				int timeElapsed = (int) (System.currentTimeMillis() - startTime) / 1000;
				mon.finish("Successful document(s) generation in " + Integer.toString(timeElapsed) + "s.");
			}
			return true;
		}
	}
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.Generator#generateUI(java.io.File, com.leanpulse.syd.api.GenProfile, java.awt.Window)
	 */
	@Override
	public boolean generateUI(File mdlFile, GenProfile profile, Window appwin) {
		if(mdlFile == null || mdlFile.getPath().length() == 0) {
			JOptionPane.showMessageDialog(appwin,
			    "The model has to be saved first.",
			    "SyD - Error",
			    JOptionPane.ERROR_MESSAGE);
			return false;
		}
		
		ProgressFrame dial = new ProgressFrame(appwin, "SyD - Generation in progress...", "Generating profile " + profile.getName());
		dial.display();
		ProgressMonitor mon = dial.getMonitor();
		
		generate(mdlFile, profile, mon);
		
		if(mon.hasError()) {
			// In case of error, leave the dialog opened to report the error to the user.
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
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.Generator#asyncGenerateUI(java.io.File, com.leanpulse.syd.api.GenProfile, java.awt.Window)
	 */
	@Override
	public void asyncGenerateUI(final File mdlFile, final GenProfile profile, final Window appwin) {
		Thread genThread = new Thread(new Runnable() {
			public void run() {
				generateUI(mdlFile, profile, appwin);
			}
		}, "SydGenerationThread");
		genThread.start();
	}
	
	/*
	 * Renders the model just extracted and loops in the children if required by the profile.
	 */
	private boolean render(GenProfileSnapConf snapConf, Renderer renderer, GenProfileRenderConf renderConf,
			File xmlFile, File outFile, List<File> refMdls, File subParDir, IProgressMonitor mon, double waitInc) {
		if(mon.isCanceled())
			return false;
		
		// Prepare the rendering.
		List<File> subOutFiles = new ArrayList<File>(refMdls.size());
		String[] xslParams = renderConf.getStyleParams(xmlFile, outFile, refMdls, subParDir, subOutFiles);
		
		switch(renderConf.getGenDependencies()) {	
			case GenProfileRenderConf.GENDEP_SEPDOCS:
				double newWaitInc = waitInc / (1.0 + 3.0*refMdls.size());
				renderer.asyncRender(xmlFile, renderConf.getStyle(), xslParams, outFile, renderConf.getSecurityOptions(),
						renderConf.getPostGenAction() == GenProfileRenderConf.ACTION_OPEN,
						mon.createSubProgress("Rendering document \"" + outFile.getName() + "\"...", newWaitInc));
				Snapper snapper = SnapperManager.getSnapper();
				for(int i=0; i<refMdls.size(); i++) { // Loops in the referenced models.
					File subMdlFile = refMdls.get(i);
					File subXmlFile = snapper.getDefaultSnapFile(subMdlFile);
					List<File> subRefMdls = snapper.snap(subMdlFile, snapConf.isFollowingLinks(), snapConf.isLookingUnderMasks(), snapConf.getParams(), subXmlFile,
							mon.createSubProgress("Extracting data from model \"" + subMdlFile.getName() + "\"...", newWaitInc));
					if(subRefMdls == null)
						return false;
					GenProfileRenderConf subRenderConf = renderConf.getSubRenderConf(subMdlFile);
					File subOutFile = subOutFiles.get(i);
					File subRefParDir = subRenderConf.getSubParentDir(subOutFile, subParDir);
					if(!render(snapConf, renderer, subRenderConf, subXmlFile, subOutFile, subRefMdls, subRefParDir, mon, 2.0*newWaitInc))
						return false;
				}
				return true;
				
			case GenProfileRenderConf.GENDEP_EMBED:
				newWaitInc = waitInc / (1.0 + refMdls.size());
				snapper = SnapperManager.getSnapper();
				double snapWaitInc = newWaitInc;
				while(refMdls.size() > 0) { // Loops in the referenced models.
					List<File> subRefMdls = new ArrayList<File>();
					for(int i=0; i<refMdls.size(); i++) {
						File subMdlFile = refMdls.get(i);
						File subXmlFile = snapper.getDefaultSnapFile(subMdlFile);
						List<File> tmpRefMdls = snapper.snap(subMdlFile, snapConf.isFollowingLinks(), snapConf.isLookingUnderMasks(), snapConf.getParams(), subXmlFile,
								mon.createSubProgress("Extracting data from model \"" + subMdlFile.getName() + "\"...", snapWaitInc/3));
						if(tmpRefMdls == null)
							return false;
						subRefMdls.addAll(tmpRefMdls);
					}
					if(subRefMdls.size() > 0)
						snapWaitInc = 2*snapWaitInc/(3*subRefMdls.size());
					else
						mon.progress(2*snapWaitInc/3);
					refMdls = subRefMdls;
				}
				renderer.asyncRender(xmlFile, renderConf.getStyle(), xslParams, outFile, renderConf.getSecurityOptions(),
						renderConf.getPostGenAction() == GenProfileRenderConf.ACTION_OPEN,
						mon.createSubProgress("Rendering document \"" + outFile.getName() + "\"...", newWaitInc));
				return true;
				
			default:
				renderer.asyncRender(xmlFile, renderConf.getStyle(), xslParams, outFile, renderConf.getSecurityOptions(),
						renderConf.getPostGenAction() == GenProfileRenderConf.ACTION_OPEN,
						mon.createSubProgress("Rendering document \"" + outFile.getName() + "\"...", waitInc));
				return true;
		}
	}
	
	
}
