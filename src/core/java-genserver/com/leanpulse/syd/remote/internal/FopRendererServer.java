/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.remote.internal;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.util.concurrent.CancellationException;

import javax.swing.Timer;

import com.leanpulse.syd.api.PdfSecurityOptions;
import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.remote.IProgressMonitorRm;
import com.leanpulse.syd.remote.IRendererRm;

/**
 * Implementation of the remote rendering server.
 * <p>
 * The server enables to remotely render several documents in parallel and
 * includes features to release memory after renderings finished and to
 * automatically shut down if idle for too long.<br>
 * The main method of this class fully setups the rendering server, including
 * the binding to the RMI registry.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class FopRendererServer extends UnicastRemoteObject implements IRendererRm {

	private static final long serialVersionUID = -1079404354464192784L;
	
	/* Delay in seconds after which the server will shuts itself down if in idle. */
	private static final int IDLE_SHUTDOWN_DELAY = 300;
	
	/*
	 * Time in seconds during which garbage collection will be requested each
	 * second to release memory after a rendering and while in idle.
	 */
	private static final int GARBAGE_COLLECTION_TIME = 10;
	
	private static File libFile = null;
	private static int genJobsRunning = 0;
	private static ForceGcThread gcThread = null;
	private static Timer shutDownTimer;
	
	/**
	 * The main method for the command line interface.
	 * <p>
	 * It fully set up the rendering server.
	 * 
	 * @param args
	 *            The command line parameters (none are used).
	 */
	public static void main(String[] args) {
		// Defines the codebase to let RMI know from where to download the code.
		File libFile = getLibFile();
		if(libFile != null) {
			System.setProperty("java.rmi.server.codebase", libFile.toURI().toString());
		} else {
			System.err.println("RemoteRenderer exception:");
			System.err.println("Cannot locate the SyD remote renderer library in the classpath.");
			System.exit(1);
		}
		
		// Adds a shutdown hook to the JRE to stop the RMI registry process when the server shuts down.
		Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
			public void run() {
				RmiRegistryManager.getDefault().stopRegistry();
			}
		}, "Rmiregistry Shutdown"));
		// Ensures the RMI registry process is started to be able to connect to the server.
		RmiRegistryManager.getDefault().startRegistry();
		
		// Sets up the shutdown timer to automatically stops the server if idle for too long.
		shutDownTimer = new Timer(IDLE_SHUTDOWN_DELAY * 1000, new ActionListener() {
			public void actionPerformed(ActionEvent e) {
				System.exit(0);
			}
		});
		
		// Binds the remote renderer server.
		try {
			Registry registry = LocateRegistry.getRegistry();
			registry.rebind(SERVICE_NAME, new FopRendererServer());
			System.out.println("RemoteRenderer bound");
		} catch (Exception e) {
			System.err.println("RemoteRenderer exception:");
			e.printStackTrace();
			System.exit(2);
		}
		
		shutDownTimer.start();
	}
	
	/**
	 * Locates the jar file containing the remote server code.
	 * 
	 * @return The jar file containing the remote server code.
	 */
	public static File getLibFile() {
		if(libFile == null)
			try {
				libFile = new File(new URI(FopRendererServer.class.getProtectionDomain().getCodeSource().getLocation().toString().replaceAll(" ", "%20")));
			} catch (URISyntaxException e) {}
		return libFile;
	}
	
	/* Called when a new render job is started. */
	private static synchronized void renderJobStarted() {
		shutDownTimer.stop(); // Stop the shutdown time while a document is rendered.
		genJobsRunning++;
		if(gcThread != null && gcThread.isAlive()) { // Interrupt and reset the garbage collection thread.
			gcThread.interrupt();
			gcThread = null;
		}
	}
	
	/* Called when a render job finished. */
	private static synchronized void renderJobEnded() {
		genJobsRunning--;
		if(genJobsRunning == 0) { // No more documents are rendering.
			gcThread = new ForceGcThread();
			gcThread.start(); // Force garbage collection.
			shutDownTimer.restart(); // Restart the shutdown timer.
		}
	}
	
	/* Daemon thread to force garbage collection when renderings finished. */
	private static class ForceGcThread extends Thread {
		private int itNum = 0;
		public ForceGcThread() {
			super("Forced Garbage Collection");
			setDaemon(true);
		}
		@Override
		public void run() {
			while(itNum < GARBAGE_COLLECTION_TIME) {
				Runtime runtime = Runtime.getRuntime();
				runtime.gc();
				try {
					Thread.sleep(1000L);
				} catch (InterruptedException e) {
					return;
				}
				itNum++;
			}
		}
	}
	
	/* A simple progress monitor implementation that delegates to a remote sibling. */
	private static class ProgressMonitorClient implements IProgressMonitor {
		private IProgressMonitorRm delegate;
		ProgressMonitorClient(IProgressMonitorRm delegate) {
			this.delegate = delegate;
		}
		public void start(String message, double totalWork) {
			try {
				delegate.start(message, totalWork);
			} catch (RemoteException e) {}
		}
		public void progress(double work) {
			try {
				delegate.progress(work);
			} catch (RemoteException e) {}
		}
		public void progress(String description) {
			try {
				delegate.progress(description);
			} catch (RemoteException e) {}
		}
		public void progress(String description, double work) {
			try {
				delegate.progress(description, work);
			} catch (RemoteException e) {}
		}
		public void requestCancel() {
			try {
				delegate.requestCancel();
			} catch (RemoteException e) {}
		}
		public boolean isRunning() {
			try {
				return delegate.isCanceled();
			} catch (RemoteException e) {
				return false;
			}
		}
		public void checkCanceled() throws CancellationException {
			try {
				delegate.checkCanceled();
			} catch (RemoteException e) {
				throw new CancellationException();
			}
		}
		public boolean isCanceled() {
			try {
				return delegate.isCanceled();
			} catch (RemoteException e) {
				return true;
			}
		}
		public boolean isFinished() {
			try {
				return delegate.isFinished();
			} catch (RemoteException e) {
				return true;
			}
		}
		public boolean hasError() {
			try {
				return delegate.hasError();
			} catch (RemoteException e) {
				return false;
			}
		}
		public void finish(String message) {
			renderJobEnded();
			try {
				delegate.finish(message);
			} catch (RemoteException e) {}
		}
		public void finish(String message, Exception e) {
			renderJobEnded();
			try {
				// Repack the exception as an IOException to ensure the other JVM can load the class
				IOException ioe = new IOException(e.toString());
				delegate.finish(message, ioe);
			} catch (RemoteException re) {}
		}
		public void waitFinish() throws InterruptedException {
			try {
				delegate.waitFinish();
			} catch (RemoteException re) {}
		}
		public IProgressMonitor createSubProgress(String name, double parentWorkUnits) {
			try {
				return new ProgressMonitorClient(delegate.createSubProgress(name, parentWorkUnits));
			} catch (RemoteException e) {
				return null;
			}
		}
		public void waitSubProgessFinish() throws InterruptedException {
			try {
				delegate.waitSubProgressFinish();
			} catch (RemoteException re) {}
		}
	}
	
	
	private EmbedFopRenderer renderer = new EmbedFopRenderer();
	
	protected FopRendererServer() throws RemoteException {
		super();
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.remote.IRendererRm#isAlive()
	 */
	public boolean isAlive() throws RemoteException {
		return true;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.remote.IRendererRm#startRendering(java.io.File, java.io.File, java.lang.String[], java.io.File, com.leanpulse.syd.api.PdfSecurityOptions, boolean, com.leanpulse.syd.remote.IProgressMonitorRm)
	 */
	public synchronized void startRendering(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions,
			boolean open, IProgressMonitorRm mon) {
		renderJobStarted();
		renderer.asyncRender(xmlFile, xslFile, xslParams, outFile, secOptions, open, new ProgressMonitorClient(mon));
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.remote.IRendererRm#shutDown()
	 */
	public synchronized void shutDown() {
		System.exit(0);
	}

}
