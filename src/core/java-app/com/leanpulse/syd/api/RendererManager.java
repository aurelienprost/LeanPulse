/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.RendererImplExternal;
import com.leanpulse.syd.internal.RendererImplRemote;

/**
 * Manager to get the {@link Renderer} to use to render documents.
 * <p>
 * SyD includes two implementation of the {@link Renderer} interface, one
 * starting a new application for each document to render and another one
 * implementing a rendering server.
 * <dl>
 * <dt>The benefits of the latest are multiple:</dt>
 * <dd>- When multiple documents must be generated, the server is only started
 * once, saving significant startup time.<br>
 * - The server caches the stylesheets used, saving a lot of loading time when
 * the same styling is applied to several documents.<br>
 * - It supports the rendering of several documents in parallel, leveraging the
 * power of multitasking.<br>
 * - To free up resources, it can be stopped by the client or will automatically
 * shut down if in idle state for more than a predefined delay.</dd>
 * </dl>
 * <p>
 * The static methods of this manager give <b>priority to the server</b> and
 * will always try to first return this implementation. If no connection can be
 * established and the server can't be started, then the default implementation
 * is returned.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Renderer
 */
public class RendererManager {
	
	/**
	 * Retrieves a usable renderer to render documents.
	 * 
	 * @return The renderer implementation.
	 * 
	 * @see #getRenderer(IProgressMonitor)
	 */
	public static Renderer getRenderer() {
		return getRenderer(null);
	}
	
	/**
	 * Retrieves a usable renderer to render documents.<br>
	 * The priority is given to the rendering server but if no connection can be
	 * established and a new server can't be started, a default implementation
	 * is returned.
	 * 
	 * @param mon
	 *            The monitor to indicate the progress of the connection to the
	 *            rendering server and its startup in case of unavailability. If
	 *            those steps fail, the last error is reported to the monitor
	 *            and the default implementation is returned.
	 * @return The renderer implementation.
	 */
	public static Renderer getRenderer(IProgressMonitor mon) {
		Renderer renderer = null;
		RendererImplRemote rmRenderer = RendererImplRemote.getDefault();
		if(rmRenderer.prepareRendering(mon))
			renderer = rmRenderer;
		else
			renderer = RendererImplExternal.getDefault();
		return renderer;
	}
	
	/**
	 * Sends a command to the rendering server to shut down.<br>
	 * Has no effect if the server wasn't started at first.
	 */
	public static void killRemoteRenderer() {
		RendererImplRemote.killServer();
	}

}
