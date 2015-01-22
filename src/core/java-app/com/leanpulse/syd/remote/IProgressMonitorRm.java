/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.remote;

import java.rmi.Remote;
import java.rmi.RemoteException;
import java.util.concurrent.CancellationException;

import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * Remote copy of the <code>IProgressMonitor</code> interface.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see IProgressMonitor
 */
public interface IProgressMonitorRm extends Remote {
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#start(java.lang.String, double)
	 */
	void start(String message, double totalWork) throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(double)
	 */
	void progress(double work) throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(java.lang.String)
	 */
	void progress(String description) throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(java.lang.String, double)
	 */
	void progress(String description, double work) throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#requestCancel()
	 */
	void requestCancel() throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isRunning()
	 */
	boolean isRunning() throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#checkCanceled()
	 */
	void checkCanceled() throws CancellationException, RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isCanceled()
	 */
	boolean isCanceled() throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isFinished()
	 */
	boolean isFinished() throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#hasError()
	 */
	boolean hasError() throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#finish(java.lang.String)
	 */
	void finish(String message) throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#finish(java.lang.String, java.lang.Exception)
	 */
	void finish(String message, Exception e) throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#waitFinish()
	 */
	void waitFinish() throws InterruptedException, RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#createSubProgress(java.lang.String, double)
	 */
	IProgressMonitorRm createSubProgress(String name, double parentWorkUnits) throws RemoteException;
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#waitSubProgessFinish()
	 */
	void waitSubProgressFinish() throws InterruptedException, RemoteException;

}
