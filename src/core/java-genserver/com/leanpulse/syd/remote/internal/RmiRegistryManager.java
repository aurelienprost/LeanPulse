/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.remote.internal;

import java.io.File;
import java.io.IOException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;

/**
 * Simple Manager to start and stop the RMI registry as required to enable the
 * connection between a server and a client via RMI.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class RmiRegistryManager {
	
	/*
	 * Delay in seconds to wait for the registry to reply after it has been started.
	 */
	private static final int START_WAIT_DELAY = 10;
	
	
	private static RmiRegistryManager instance;
	
	/**
	 * Returns the unique instance of the RMI registry manager.
	 * 
	 * @return The singleton.
	 */
	public static synchronized RmiRegistryManager getDefault() {
		if(instance == null)
			instance = new RmiRegistryManager();
		return instance;
	}
	
	
	private Process registryProc;
	
	
	/**
	 * Ensures the RMI registry process ("rmiregistry.exe") is started.
	 * <p>
	 * A new RMI registry will be started only if no connection can be established
	 * to an already running process.
	 */
	public synchronized void startRegistry() {
		Registry registry = null;
		try { // Verify if registry not already started
			registry = LocateRegistry.getRegistry();
			registry.list();
			return;
		} catch (Exception e) { // Not started, launch the exe
			try {
				registryProc = Runtime.getRuntime().exec(new String[] {
						System.getProperty("java.home") + File.separator + "bin" + File.separator + "rmiregistry.exe"
					});
			} catch (IOException e1) {
				return;
			}
			int count = 0;
			while(count < START_WAIT_DELAY) {
				try {
					registry = LocateRegistry.getRegistry();
					registry.list();
					return;
				} catch (RemoteException e1) {
					try {
						Thread.sleep(1000);
					} catch (InterruptedException e2) {
						return;
					}
				}
				count++;
			}
		}
	}
	
	/**
	 * Stops the RMI registry process that might have been started.
	 */
	public synchronized void stopRegistry() {
		if(registryProc != null)
			registryProc.destroy();
	}

}
