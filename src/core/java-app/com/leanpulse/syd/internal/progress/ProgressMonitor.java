/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.progress;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CancellationException;

import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.Utils;

/**
 * 
 * 
 * <p>
 * 
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class ProgressMonitor implements IProgressMonitor {
	
	public static final int STATE_INITIALIZED = 0;
    public static final int STATE_RUNNING = 1;
    public static final int STATE_CANCELLED = 2;
    public static final int STATE_FINISHED = 3;
	
	protected String name;
	protected int state;
	protected double totalUnits;
	protected double currentUnits;
	protected String lastMessage;
	protected Exception stoppingException;
	protected boolean hasChildrenException;
	protected ProgressPanel panel;
	protected List<SubProgressMonitor> children;
	
	ProgressMonitor(String name) {
		this.name = name;
		this.state = STATE_INITIALIZED;
		this.hasChildrenException = false;
	}
	
	public String getName() {
		return name;
	}
	
	public int getState() {
		return state;
	}
	
	public double getTotalUnits() {
		return totalUnits;
	}
	
	public double getCurrentUnits() {
		return currentUnits;
	}
	
	public String getLastMessage() {
		return lastMessage;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#start(java.lang.String, double)
	 */
	public synchronized void start(String message, double workunits) {
		if(state != STATE_INITIALIZED)
			throw new IllegalStateException("Cannot call start twice on a progress monitor");
		if (workunits < 0)
            throw new IllegalArgumentException("Number of workunits cannot be negative");
		totalUnits = workunits;
		currentUnits = 0.0;
		if(message != null)
			lastMessage = message;
		state = STATE_RUNNING;
		if(panel != null)
			Utils.runInEdt(new Runnable() {
				public void run() {
					panel.update();
				}
			});
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(java.lang.String)
	 */
	public void progress(String message) {
		progress(message, 0.0);
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(double)
	 */
	public void progress(double workunit) {
		progress(null, workunit);
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#progress(java.lang.String, double)
	 */
	public synchronized void progress(String message, double workunit) {
		if (state != STATE_RUNNING && state != STATE_CANCELLED)
            return;
		double newunits = currentUnits + workunit;
		if(newunits < 0 || newunits > totalUnits*1.01) // To avoid exceptions due to cumulated computation error
			throw new IllegalArgumentException("Processed workunit count (" + newunits + ") exceeds progress bounds (0 -> " + totalUnits + ")");
		currentUnits = Math.min(newunits, totalUnits);
		if(message != null)
			lastMessage = message;
		if(panel != null)
			Utils.runInEdt(new Runnable() {
				public void run() {
					panel.update();
				}
			});
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#requestCancel()
	 */
	public synchronized void requestCancel() {
		state = STATE_CANCELLED;
		if(panel != null)
			Utils.runInEdt(new Runnable() {
				public void run() {
					panel.update();
				}
			});
		if(children != null)
			for(SubProgressMonitor child : children)
				child.requestCancel();
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isRunning()
	 */
	public boolean isRunning() {
		return (state == STATE_RUNNING || state == STATE_CANCELLED);
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#checkCanceled()
	 */
	public void checkCanceled() throws CancellationException {
		if(state == STATE_CANCELLED)
			throw new CancellationException();
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isCanceled()
	 */
	public boolean isCanceled() {
		return (state == STATE_CANCELLED);
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#isFinished()
	 */
	public boolean isFinished() {
		return (state == STATE_FINISHED);
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
	public synchronized void finish(String message, Exception error) {
        if (state == STATE_INITIALIZED)
            throw new IllegalStateException("Cannot finish a task that was never started");
        if (state == STATE_FINISHED)
            return;
        state = STATE_FINISHED;
        if(message != null)
			lastMessage = message;
        if(error != null)
        	stoppingException = error;
        currentUnits = totalUnits;
        notifyAll();
        if(panel != null)
        	Utils.runInEdt(new Runnable() {
				public void run() {
					panel.update();
				}
			});
    }
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#hasError()
	 */
	public boolean hasError() {
		return stoppingException != null || hasChildrenException;
	}
	
	public Exception getStoppingException() {
		return stoppingException;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#waitFinish()
	 */
	public synchronized void waitFinish() throws InterruptedException {
		if(state == STATE_FINISHED)
            return;
		wait();
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.progress.IProgressMonitor#createSubProgress(java.lang.String, double)
	 */
	public IProgressMonitor createSubProgress(String name, double parentWorkUnits) {
		return new SubProgressMonitor(name, this, parentWorkUnits);
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
	
	synchronized ProgressPanel getPanel() {
		if(panel == null)
			panel = new ProgressPanel(name, this);
		return panel;
	}
	
	synchronized List<SubProgressMonitor> getChildren() {
		return children;
	}

	synchronized void subMonitorStarted(final SubProgressMonitor subMon) {
		if(children == null)
			children = new ArrayList<SubProgressMonitor>();
		children.add(subMon);
		if(children.size() > 1)
			lastMessage = children.size() + " sub tasks running...";
		else
			lastMessage = subMon.getName();
		if(panel != null)
			Utils.runInEdt(new Runnable() {
				public void run() {
					panel.update();
					panel.addSubProgress(subMon);
				}
			});
	}

	synchronized void subMonitorFinished(final SubProgressMonitor subMon, double remainingWorkunit, final Exception ex) {
		if(children != null && children.remove(subMon)) {
			if(children.size() > 0)
				lastMessage = children.size() + " sub tasks running...";
			else
				children = null;
			currentUnits += remainingWorkunit;
			if(ex != null)
				hasChildrenException = true;
			if(panel != null)
				Utils.runInEdt(new Runnable() {
					public void run() {
						panel.update();
						if(ex == null)
							panel.removeSubProgress(subMon);
					}
				});
		}
	}

}
