/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.remote.internal;

import java.awt.Desktop;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.OutputStream;
import java.util.concurrent.CancellationException;

import javax.swing.SwingUtilities;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.pdf.PDFEncryptionParams;
import org.xml.sax.SAXException;

import com.leanpulse.syd.api.PdfSecurityOptions;
import com.leanpulse.syd.api.Renderer;
import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * Embedded <code>Renderer</code> implementation using the FOP Java API to render documents.  
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class EmbedFopRenderer extends Renderer {
	
	private static final String SYD_VER = /*@SYDVER@*/"3.0"/*@SYDVER@*/;
	
	private static FopFactory fopFactory = null;
	
	private static synchronized FopFactory getFopFactory() throws SAXException, IOException {
		if(fopFactory == null) {
			FopFactory tmpFactory = FopFactory.newInstance();
			tmpFactory.setStrictValidation(false);
			File configFile = new File(FopRendererServer.getLibFile().getParent() + File.separator + "fop.xconf");
	        tmpFactory.setUserConfig(configFile);
	        fopFactory = tmpFactory;
		}
		return fopFactory;
	}
	
	/*
	 * Runnable class to asynchronously render documents with FOP.
	 */
	private static class EmbedFopRunnable implements Runnable {
		
		private File xmlFile;
		private File xslFile;
		private String[] xslParams;
		private File outFile;
		private PdfSecurityOptions secOptions;
		private boolean open;
		private IProgressMonitor mon;

		public EmbedFopRunnable(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions,
				boolean open, IProgressMonitor mon) {
			this.xmlFile = xmlFile;
			this.xslFile = xslFile;
			this.xslParams = xslParams;
			this.outFile = outFile;
			this.secOptions = secOptions;
			this.open = open;
			this.mon = mon;
		}
		
		@SuppressWarnings("unchecked")
		public void run() {
	        FopFactory fopFactory = null;
	        try {
				fopFactory = getFopFactory();
			} catch (Exception e) {
				mon.finish("Renderer factory configuration error...", e);
				return;
			}
			
			// Configure the user agent
			String producer = "LeanPulse System Document Generator (SyD) v" + SYD_VER;
			FOUserAgent foUserAgent = fopFactory.newFOUserAgent();
	        foUserAgent.setCreator(producer);
	        foUserAgent.setProducer(producer);
	        foUserAgent.setBaseURL(xmlFile.getParentFile().toURI().toString());
	        if(secOptions.getUserpass() != null || secOptions.getOwnerpass() != null || secOptions.isNoprint()
	        		|| secOptions.isNocopy() || secOptions.isNoedit() || secOptions.isNoannot())
		        foUserAgent.getRendererOptions().put("encryption-params", new PDFEncryptionParams(secOptions.getUserpass(),
		        		secOptions.getOwnerpass(), !secOptions.isNoprint(), !secOptions.isNocopy(), !secOptions.isNoedit(), !secOptions.isNoannot()));
	        
	        outFile.getParentFile().mkdirs();
			OutputStream out = null;
			try {
				out = new java.io.FileOutputStream(outFile);
			} catch (FileNotFoundException e) {
				mon.finish(null, e);
				return;
			}
			out = new java.io.BufferedOutputStream(out);
	        
	        try {
	            // Construct fop with desired output format
	            Fop fop = fopFactory.newFop(org.apache.xmlgraphics.util.MimeConstants.MIME_PDF, foUserAgent, out);

	            // Setup XSLT
	            TransformerFactory factory = TransformerFactory.newInstance();
	            Transformer transformer = factory.newTransformer(new StreamSource(xslFile));
	            if (xslParams != null) {
	                for (int i = 0; i < xslParams.length; i += 2) {
	                    transformer.setParameter(xslParams[i], xslParams[i+1]);
	                }
	            }

	            // Setup input for XSLT transformation
	            Source src = new StreamSource(new ProgressInputStream(new FileInputStream(xmlFile), mon, 10L *xmlFile.length() / 7L));

	            // Resulting SAX events (the generated FO) must be piped through to FOP
	            Result res = new SAXResult(fop.getDefaultHandler());

	            // Start XSLT transformation and FOP processing
	            transformer.transform(src, res);
	            
	        } catch (Throwable e) {
	        	Throwable rootCause = e.getCause();
	        	if(rootCause != null) {
		        	Throwable parCause = rootCause;
		        	while((parCause = parCause.getCause()) != null) {
		        		rootCause = parCause;
		        	}
	        	}
	        	if(rootCause instanceof CancellationException) {
	        		mon.finish("Document " + outFile.getName() + " rendering cancelled by user.");
	        	} else {
	        		if(e instanceof Exception) {
	        			mon.finish(null, (Exception) e);
	        		} else {
	        			if(e instanceof OutOfMemoryError) {
	        				mon.finish(null, new IOException("The remote render ran out of memory !\n"
	        						+ "Please try to increase the maximum memory allocated to the process by editing \"syd.conf\"."));
	        				System.exit(0);
	        			} else {
	        				mon.finish(null, new IOException(e));
	        			}
	        		}
	        	}
				return;
			} finally {
	        	try {
	        		out.close();
	        	} catch(IOException e) {}
	        }
			
	    	if(open) {
	        	mon.progress("Opening \"" + outFile.getName() + "\" ...", 0.25);
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
	    		mon.finish("Document " + outFile.getName() + " rendered successfully.");
		}
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Renderer#asyncRender(java.io.File, java.io.File, java.lang.String[], java.io.File, com.leanpulse.syd.api.PdfSecurityOptions, boolean, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	@Override
	public void asyncRender(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions,
			boolean open, IProgressMonitor mon) {
		service.submit(new EmbedFopRunnable(xmlFile, xslFile, xslParams, outFile, secOptions, open, mon));
	}
	
	
}
