/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.remote;

import java.io.File;
import java.rmi.Remote;
import java.rmi.RemoteException;

import com.leanpulse.syd.api.PdfSecurityOptions;
import com.leanpulse.syd.api.Renderer;

/**
 * Remote copy of the <code>Renderer</code> interface.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Renderer
 */
public interface IRendererRm extends Remote {
	
	public static String SERVICE_NAME = "rmi://localhost/SydRemoteRenderer";
	
	/**
	 * Checks the rendering server is alive.
	 * 
	 * @return <code>true</code> if the server is running, <code>false</code>
	 *         otherwise.
	 * @throws RemoteException
	 *             If a communication-related exceptions occurred during the
	 *             execution of the remote method call.
	 */
	boolean isAlive() throws RemoteException;

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Renderer#asyncRender(java.io.File, java.io.File, java.lang.String[], java.io.File, com.leanpulse.syd.api.PdfSecurityOptions, boolean, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	void startRendering(File xmlFile, File xslFile, String[] xslParams, File outFile, PdfSecurityOptions secOptions,
			boolean open, IProgressMonitorRm mon) throws RemoteException;
	
	/**
	 * Requests the rendering server to shut down.
	 * 
	 * @throws RemoteException
	 *             If a communication-related exceptions occurred during the
	 *             execution of the remote method call.
	 */
	void shutDown() throws RemoteException;
	
}
