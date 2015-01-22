/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.io.Serializable;

/**
 * Represents the security options that can be defined to protect a PDF document.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class PdfSecurityOptions implements Serializable {
	
	private static final long serialVersionUID = -7893562291656346551L;
	
	private String ownerpass;
	private String userpass;
	private boolean noprint;
	private boolean nocopy;
	private boolean noedit;
	private boolean noannot;
	
	/**
	 * Creates security options with no protection.
	 */
	public PdfSecurityOptions() {
		this(null, null, false, false, false, false);
	}
	
	/**
	 * Creates security options with protection as defined by the parameters.
	 * 
	 * @param ownerpass
	 *            The owner password.
	 * @param userpass
	 *            The user password.
	 * @param noprint
	 *            Disable print.
	 * @param nocopy
	 *            Disable copy.
	 * @param noedit
	 *            Disable edition.
	 * @param noannot
	 *            Disable annotations.
	 */
	public PdfSecurityOptions(String ownerpass,	String userpass, boolean noprint, boolean nocopy, boolean noedit, boolean noannot) {
		this.ownerpass = ownerpass;
		this.userpass = userpass;
		this.noprint = noprint;
		this.nocopy = nocopy;
		this.noedit = noedit;
		this.noannot = noannot;
	}
	
	/**
	 * Gets the owner password.
	 * 
	 * @return The owner password.
	 */
	public String getOwnerpass() {
		return ownerpass;
	}
	
	/**
	 * Gets the user password.
	 * 
	 * @return The user password.
	 */
	public String getUserpass() {
		return userpass;
	}
	
	/**
	 * Returns if the print is disabled.
	 * 
	 * @return True if the print is disabled.
	 */
	public boolean isNoprint() {
		return noprint;
	}
	
	/**
	 * Returns if the copy is disabled.
	 * 
	 * @return True if the copy is disabled.
	 */
	public boolean isNocopy() {
		return nocopy;
	}
	
	/**
	 * Returns if the edition is disabled.
	 * 
	 * @return True if the edition is disabled.
	 */
	public boolean isNoedit() {
		return noedit;
	}
	
	/**
	 * Returns if the annotations are disabled.
	 * 
	 * @return True if the annotation are disabled.
	 */
	public boolean isNoannot() {
		return noannot;
	}

}
