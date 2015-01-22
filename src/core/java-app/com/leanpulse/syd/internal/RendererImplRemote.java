/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.util.Properties;
import java.util.concurrent.CancellationException;

import com.leanpulse.syd.api.PdfSecurityOptions;
import com.leanpulse.syd.api.Renderer;
import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.remote.IProgressMonitorRm;
import com.leanpulse.syd.remote.IRendererRm;

/**
 * <code>Renderer</code> implementation as a client connecting to the rendering
 * server.
 * <p>
 * This implementation tries first to connect to an already running rendering
 * server and if no connection is available, try to start a new server.<br>
 * Requests to render documents are then posted to the server, this class then
 * acting as a simple client.
 * <p>
 * The communication between the server and the client relies on the Java Remote
 * Method Invocation (RMI) technology.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class RendererImplRemote extends Renderer {
	
	/*
	 * Delay in seconds to wait for the server to reply after it has been started.
	 */
	private static final int START_WAIT_DELAY = 20;
	
	
	private static RendererImplRemote instance;
	
	/**
	 * Returns the unique instance of the remote renderer.
	 * 
	 * @return The singleton.
	 */
	public static synchronized RendererImplRemote getDefault() {
		if(instance == null)
			instance = new RendererImplRemote();
		return instance;
	}
	
	/**
	 * Sends a command to the rendering server to shut down.<br>
	 * Has no effect if the server wasn't started at first.
	 */
	public static void killServer() {
		try {
        	Registry registry = LocateRegistry.getRegistry();
            IRendererRm renderer = (IRendererRm) registry.lookup(IRendererRm.SERVICE_NAME);
			renderer.shutDown();
		} catch (Exception e) {}
	}
	
	/*
	 * A default implementation to remotely report progress to the client.
	 * This class actually only delegates all the calls to the local implementation
	 * of the progress monitor.
	 */
	private static class ProgressMonitorServer extends UnicastRemoteObject implements IProgressMonitorRm {
		private static final long serialVersionUID = -5223911042231972707L;
		
		private IProgressMonitor delegate;
		public ProgressMonitorServer(IProgressMonitor delegate) throws RemoteException {
			super();
			this.delegate = delegate;
		}
		public void start(String message, double totalWork) throws RemoteException {
			delegate.start(message, totalWork);
		}
		public void progress(double work) throws RemoteException {
			delegate.progress(work);
		}
		public void progress(String description) throws RemoteException {
			delegate.progress(description);
		}
		public void progress(String description, double work)
				throws RemoteException {
			delegate.progress(description, work);
		}
		public void requestCancel() throws RemoteException {
			delegate.requestCancel();
		}
		public boolean isRunning() throws RemoteException {
			return delegate.isRunning();
		}
		public void checkCanceled() throws CancellationException, RemoteException {
			delegate.checkCanceled();
		}
		public boolean isCanceled() throws RemoteException {
			return delegate.isCanceled();
		}
		public boolean isFinished() throws RemoteException {
			return delegate.isFinished();
		}
		public boolean hasError() throws RemoteException {
			return delegate.hasError();
		}
		public void finish(String message) throws RemoteException {
			delegate.finish(message);
		}
		public void finish(String message, Exception e) throws RemoteException {
			delegate.finish(message, e);
		}
		public void waitFinish() throws InterruptedException, RemoteException {
			delegate.waitFinish();
		}
		public IProgressMonitorRm createSubProgress(String name, double parentWorkUnits) throws RemoteException {
			return new ProgressMonitorServer(delegate.createSubProgress(name, parentWorkUnits));
		}
		public void waitSubProgressFinish() throws InterruptedException, RemoteException {
			delegate.waitSubProgessFinish();
		}
	}
	
	private RendererImplRemote() {}
	
	/**
	 * Prepares the rendering with the server.
	 * <p>
	 * This method must be called before posting rendering request to the server
	 * in order to ensure a connection to the server can be established.<br>
	 * A connection to an already running server will first try to be opened and
	 * if unsuccessful, a new server will be started and a new connection
	 * opened.
	 * 
	 * @param mon
	 *            The progress monitor to which progress and errors are
	 *            reported.
	 * @return <code>true</code> if the preparation to use the rendering server
	 *         Succeed, <code>false</code> otherwise.
	 */
	public synchronized boolean prepareRendering(IProgressMonitor mon) {
		if(mon != null) {
			mon.start("Preparing to render documents...", 100.0);
		}
		Registry registry = null;
		try { // Try first to connect to an already running server.
			registry = LocateRegistry.getRegistry();
			IRendererRm renderer = (IRendererRm) registry.lookup(IRendererRm.SERVICE_NAME);
			renderer.isAlive();
			if(mon != null) {
				mon.finish("Remote renderer server already started.");
			}
			return true;
		} catch (Exception e) { // No server running.
			if(registry != null)
				try {
					registry.unbind(IRendererRm.SERVICE_NAME); // Cleans up the registry
				} catch (Exception e3) {}
			if(mon != null) {
				mon.progress(20.0);
			}
			
			String maxMem = null;
			Properties configFile = new Properties();
			try {
				configFile.load(new FileInputStream(new File(Utils.getAbsolutePath("syd.conf"))));
				maxMem = configFile.getProperty("syd.rmrender.maxmem");
			} catch (IOException ce) {}
			
			String[] startServerCmd = new String[] {System.getProperty("java.home") + "\\bin\\javaw",
					"-Xmx" + (maxMem == null ? "1024m" : maxMem),
					"-Djavax.xml.transform.TransformerFactory=com.leanpulse.syd.remote.internal.CachingTransformerFactory",
					"-Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.NoOpLog",
					"-jar", Utils.getAbsolutePath("lib" + File.separator + "syd-rmrender.jar")};
			try {
				Runtime.getRuntime().exec(startServerCmd); // Starts a new server.
			} catch (IOException se) {
				if(mon != null) {
					mon.finish("Can't start the remote renderer server !", se);
				}
				return false;
			}
			if(mon != null) {
				mon.progress(40.0);
			}
			int count = 0;
			Exception lastError = null;
			while(count < START_WAIT_DELAY) { // Loop for a given delay and try to connect to the server.
				try {
					registry = LocateRegistry.getRegistry();
					IRendererRm renderer = (IRendererRm) registry.lookup(IRendererRm.SERVICE_NAME);
					renderer.isAlive();
					if(mon != null) {
						mon.finish("Remote renderer server succesfully started.");
					}
					return true;
				} catch (Exception e1) {
					lastError = e1;
					try {
						Thread.sleep(1000);
						if(mon != null) {
							mon.progress(40.0 / START_WAIT_DELAY);
						}
					} catch (InterruptedException e2) {}
					count++;
				}
			}
			if(mon != null) {
				mon.finish("Can't connect to the remote renderer server !", lastError);
			}
			return false;
		}
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Renderer#asyncRender(java.io.File, java.io.File, java.lang.String[], java.io.File, com.leanpulse.syd.api.PdfSecurityOptions, boolean, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	@Override
	public void asyncRender(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions,
			boolean open, IProgressMonitor mon) {
		try {
            Registry registry = LocateRegistry.getRegistry();
            IRendererRm renderer = (IRendererRm) registry.lookup(IRendererRm.SERVICE_NAME);
            IProgressMonitorRm rmMon = new ProgressMonitorServer(mon);
        	mon.start("Rendering \"" + outFile.getName() + "\"...", 1.0);
            renderer.startRendering(xmlFile, xslFile, xslParams, outFile, secOptions, open, rmMon);
        } catch (Exception e) {
        	mon.finish("Can't connect to the remote renderer server !", e);
        }
	}
	

}
