/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.progress;

import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * 
 * 
 * <p>
 * 
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class SubProgressMonitor extends ProgressMonitor {
	
	ProgressMonitor parent;
	double parentWorkUnits;
	
	protected SubProgressMonitor(String name, IProgressMonitor parent, double parentWorkUnits) {
		super(name);
		if(! parent.isRunning())
			throw new IllegalStateException("The parent progress monitor must be started !");
		this.parent = (ProgressMonitor) parent;
		this.parentWorkUnits = parentWorkUnits;
	}
	
	@Override
	public synchronized void start(String message, double workunits) {
		parent.subMonitorStarted(this);
		super.start(message, workunits);
	}
	
	@Override
	public synchronized void progress(String message, double workunit) {
		if(state == STATE_RUNNING)
			parent.progress(parentWorkUnits * workunit / totalUnits);
		super.progress(message, workunit);
	}
	
	@Override
	public synchronized void finish(String message, Exception error) {
		parent.subMonitorFinished(this, parentWorkUnits * (totalUnits - currentUnits) / totalUnits, error);
		super.finish(message, error);
	}
	
	@Override
	synchronized ProgressPanel getPanel() {
		if(panel == null)
			panel = new ProgressPanel(this);
		return panel;
	}

}
