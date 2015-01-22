/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.progress;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CancellationException;

import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * 
 * 
 * <p>
 * 
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class ThrowExStubMonitor implements IProgressMonitor {
	
	protected boolean isCancelled = false;
	protected boolean isFinished = false;
	protected ThrowExStubMonitor parent;
	protected List<ThrowExStubMonitor> children;
	protected Exception stoppingException;
	
	public ThrowExStubMonitor() {}
	
	private ThrowExStubMonitor(ThrowExStubMonitor parent) {
		this.parent = parent;
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#start(java.lang.String, double)
	 */
	public void start(String message, double totalWork) {
		if(parent != null)
			parent.subMonitorStarted(this);
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(double)
	 */
	public void progress(double work) {
		//NOP
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(java.lang.String)
	 */
	public void progress(String description) {
		//NOP
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(java.lang.String, double)
	 */
	public void progress(String description, double work) {
		//NOP
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#requestCancel()
	 */
	public synchronized void requestCancel() {
		isCancelled = true;
		if(children != null)
			for(IProgressMonitor child : children)
				child.requestCancel();
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#checkCanceled()
	 */
	public void checkCanceled() throws CancellationException {
		if(isCancelled)
			throw new CancellationException();
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isRunning()
	 */
	public boolean isRunning() {
		return !isFinished;
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isCanceled()
	 */
	public boolean isCanceled() {
		return isCancelled;
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isFinished()
	 */
	public boolean isFinished() {
		return isFinished;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#hasError()
	 */
	public boolean hasError() {
		return stoppingException != null;
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#finish(java.lang.String)
	 */
	public void finish(String message) {
		finish(message, null);
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#finish(java.lang.String, java.lang.Exception)
	 */
	public synchronized void finish(String message, Exception e) {
		if(parent != null)
			parent.subMonitorFinished(this);
		if(e != null)
			sendExceptionToRoot(e);
		notifyAll();
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#waitFinish()
	 */
	public synchronized void waitFinish() throws InterruptedException {
		if(isFinished)
			return;
		wait();
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#createSubProgress(java.lang.String, double)
	 */
	public IProgressMonitor createSubProgress(String name, double parentWorkUnits) {
		return new ThrowExStubMonitor(this);
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#waitSubProgessFinish()
	 */
	public void waitSubProgessFinish() throws InterruptedException {
		while(children != null && children.size() > 0) {
			children.get(0).waitFinish();
		}
	}
	
	public Exception getStoppingException() {
		return stoppingException;
	}
	
	private synchronized void sendExceptionToRoot(Exception e) {
		if(parent != null)
			parent.sendExceptionToRoot(e);
		else {
			stoppingException = e;
			requestCancel();
		}
	}
	
	private synchronized void subMonitorStarted(ThrowExStubMonitor subMon) {
		if(children == null)
			children = new ArrayList<ThrowExStubMonitor>();
		children.add(subMon);
	}

	private synchronized void subMonitorFinished(ThrowExStubMonitor subMon) {
		if(children != null)
			children.remove(subMon);
	}

}
