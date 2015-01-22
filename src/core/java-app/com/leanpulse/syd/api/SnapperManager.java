/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.util.Iterator;
import java.util.ServiceConfigurationError;
import java.util.ServiceLoader;

/**
 * Manager to retrieve the current {@link Snapper} implementation.
 * <p>
 * Depending on the modeling tool on which SyD is running (Matlab, Scilab,
 * etc.), a different implementation of the {@link Snapper} interface will
 * be available. This class enables to transparently retrieve the correct
 * implementation.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see Snapper
 */
public class SnapperManager {
	
	private static Snapper instance;
	
	/**
	 * Retrieves the correct implementation of the {@link Snapper} interface.<br>
	 * Can return <code>null</code> if no implementation has been found. This
	 * occurs in particular when SyD is executed outside a modeling environment,
	 * to only render documents.
	 * 
	 * @return The snapper implementation.
	 */
	public static synchronized Snapper getSnapper() {
		if(instance == null) {
			ServiceLoader<Snapper> loader = ServiceLoader.load(Snapper.class, Snapper.class.getClassLoader());
			try {
	            Iterator<Snapper> it = loader.iterator();
	            if(it.hasNext())
	            	instance = it.next();
	        } catch (ServiceConfigurationError serviceError) {
	            serviceError.printStackTrace();
	        }
		}
        return instance;
	}

}
