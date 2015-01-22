/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal;

import java.awt.Desktop;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.concurrent.ExecutionException;

import javax.swing.SwingUtilities;

import com.leanpulse.syd.api.PdfSecurityOptions;
import com.leanpulse.syd.api.Renderer;
import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * External <code>Renderer</code> implementation.
 * <p>
 * This implementation starts FOP as a new standalone application each time a
 * document needs to be rendered.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class RendererImplExternal extends Renderer {
	
	private static RendererImplExternal instance;
	
	/**
	 * Returns the unique instance of the external renderer.
	 * 
	 * @return The singleton.
	 */
	public static synchronized RendererImplExternal getDefault() {
		if(instance == null)
			instance = new RendererImplExternal();
		return instance;
	}
	
	/*
	 * Runnable class to asynchronously run FOP.
	 */
	private static class ExtFopRunnable implements Runnable {
		
		private File xmlFile;
		private File xslFile;
		private String[] xslParams;
		private File outFile;
		private PdfSecurityOptions secOptions;
		private boolean open;
		private IProgressMonitor mon;

		public ExtFopRunnable(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions,
				boolean open, IProgressMonitor mon) {
			this.xmlFile = xmlFile;
			this.xslFile = xslFile;
			this.xslParams = xslParams;
			this.outFile = outFile;
			this.secOptions = secOptions;
			this.open = open;
			this.mon = mon;
		}

		public void run() {
			// Computes the command line to execute.
			String relLibPath = "lib" + File.separator;
			ArrayList<String> cmdList = new ArrayList<String>(10);
			cmdList.add("\"" + Utils.getAbsolutePath(relLibPath + "fop.bat") + "\"");
			cmdList.add("-r");
			cmdList.add("-c");
			cmdList.add("\"" + Utils.getAbsolutePath(relLibPath + "fop.xconf") + "\"");
			cmdList.add("-xml");
			cmdList.add("\"" + xmlFile.getPath() + "\"");
			cmdList.add("-xsl");
			cmdList.add("\"" + xslFile.getPath() + "\"");
			cmdList.add("-pdf");
			cmdList.add("\"" + outFile.getPath() + "\"");
			if(secOptions.getOwnerpass() != null) {
				cmdList.add("-o");
				cmdList.add("\"" + secOptions.getOwnerpass() + "\"");
			}
			if(secOptions.getUserpass() != null) {
				cmdList.add("-u");
				cmdList.add("\"" + secOptions.getUserpass() + "\"");
			}
			if(secOptions.isNoprint())
				cmdList.add("-noprint");
			if(secOptions.isNocopy())
				cmdList.add("-nocopy");
			if(secOptions.isNoedit())
				cmdList.add("-noedit");
			if(secOptions.isNoannot())
				cmdList.add("-noannotations");
			for(int i=0; i<xslParams.length; i+=2) {
				cmdList.add("-param");
				cmdList.add(xslParams[i]);
				cmdList.add("\"" + xslParams[i+1] + "\"");
			}
			String[] cmd = cmdList.toArray(new String[cmdList.size()]);
			
			StringBuffer error = new StringBuffer();
			try {
				// Ensures output directory exists.
				outFile.getParentFile().mkdirs();
				
				// Run FOP and reads possible errors written in the error stream.
				Process p = Runtime.getRuntime().exec(cmd);
				BufferedReader bre = new BufferedReader (new InputStreamReader(p.getErrorStream()));
				String line = null;
				while((line = bre.readLine ()) != null) {
					error.append(line);
					error.append("\n");
				}
				
				// FOP exited with errors.
				if(p.exitValue() != 0) {
					mon.finish(null, new ExecutionException(error.toString(), null));
					return;
				}
			} catch (IOException e) {
				mon.finish("Can't start the external renderer program...", e);
				return;
			}
			if(open) {
				mon.progress("Opening \"" + outFile.getName() + "\" ...", 0.95);
				try {
					SwingUtilities.invokeAndWait(new Runnable() {
						public void run() {
							try {
								Desktop.getDesktop().open(outFile);
							} catch (IOException e) {
								mon.finish(null, e);
							}
						}
					});
				} catch (Exception e) {}
			}
			if(!mon.isFinished())
				mon.finish("Document " + outFile.getName() + " generated successfully.");
		}
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Renderer#asyncRender(java.io.File, java.io.File, java.lang.String[], java.io.File, com.leanpulse.syd.api.PdfSecurityOptions, boolean, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	@Override
	public void asyncRender(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions,
			boolean open, IProgressMonitor mon) {
		mon.start("Rendering \"" + outFile.getName() + "\"...", 1.0);
		service.submit(new ExtFopRunnable(xmlFile, xslFile, xslParams, outFile, secOptions, open, mon));
	}

}
