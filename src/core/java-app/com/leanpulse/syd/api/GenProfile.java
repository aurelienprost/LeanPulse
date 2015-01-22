/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.io.File;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;

import com.leanpulse.syd.internal.GenProfileImpl;
import com.leanpulse.syd.internal.Utils;

/**
 * Defines a generation profile.
 * <p>
 * A generation profile holds information to populate the graphical user
 * interface (name, description and shortcut) and one or several render
 * configurations to generate one or several documentations simultaneously.
 * <p>
 * In SyD, an XML file defines the generation profiles available. It is located
 * in the SyD installation directory and its name is "sydProfiles.xml". This
 * class provides utility methods to directly get a specific or all generation
 * profiles defined in this file. Profiles can also be loaded from an external
 * file if required.
 * <p>
 * The structure of the profiles definition file must comply with <a
 * href="../../../../../xml/sydProfiles.xsd">this XML schema</a>.
 * 
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see GenProfileRenderConf
 */
public abstract class GenProfile {
	
	/**
	 * Gets the generation profile with the given ID from the profiles available
	 * in SyD.
	 * 
	 * @param id
	 *            The ID of the generation profile.
	 * @return The corresponding generation profile or <code>null</code> if not
	 *         found.
	 */
	public static GenProfile getGenProfile(String id) {
		for(GenProfile profile : getGenProfiles()) {
			if(profile.getId().equals(id))
				return profile;
		}
		return null;
	}
	
	private static GenProfile[] genProfiles;
	private static long lastModifiedProfiles;
	
	/**
	 * Gets the generation profiles available in SyD.
	 * <p>
	 * They are defined in the file "sydProfiles.xml" located in the SyD
	 * installation directory.
	 * 
	 * @return An array of generation profiles or <code>null</code> if
	 *         "sydProfiles.xml" can't be read.
	 */
	public static synchronized GenProfile[] getGenProfiles() {
		File profilesFile = new File(Utils.getAbsolutePath("sydProfiles.xml"));
		long tmpLastModified = profilesFile.lastModified();
		if(genProfiles == null || tmpLastModified > lastModifiedProfiles) {
			genProfiles = getGenProfiles(profilesFile);
			lastModifiedProfiles = tmpLastModified;
		}
		return genProfiles;
	}
	
	/**
	 * Loads generation profiles from an external file.
	 * 
	 * @param profilesFile
	 *            The profiles definition file to load.
	 * @return An array of generation profiles or <code>null</code> if the file
	 *         can't be read.
	 */
	public static GenProfile[] getGenProfiles(File profilesFile) {
		try {
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			DocumentBuilder db = dbf.newDocumentBuilder();
			Document doc = db.parse(profilesFile);
			return GenProfileImpl.readProfiles(doc.getDocumentElement());
		} catch(Exception ex) {
			ex.printStackTrace();
			return null;
		}
	}
	
	/*
	 * Implementation will provide the correct constructor.
	 */
	protected GenProfile() {}
	
	
	/**
	 * Gets the ID, uniquely identifying the generation profile.
	 * 
	 * @return The ID.
	 */
	public abstract String getId();
	
	/**
	 * Gets the name of the generation profile.
	 * 
	 * @return The name.
	 */
	public abstract String getName();
	
	/**
	 * Gets the description of the generation profile.
	 * 
	 * @return The description.
	 */
	public abstract String getDescription();
	
	/**
	 * Gets the shortcut keys to run the generation profile.
	 * 
	 * @return The shortcut keys.
	 */
	public abstract String getShortcut();
	
	/**
	 * Returns the snap configuration of the generation profile.
	 * 
	 * @return The snap configuration.
	 */
	public abstract GenProfileSnapConf getSnapConf(); 
	
	/**
	 * Returns the render configurations of the generation profile.
	 * 
	 * @return The render configurations.
	 */
	public abstract GenProfileRenderConf[] getRenderConfs(); 

}
