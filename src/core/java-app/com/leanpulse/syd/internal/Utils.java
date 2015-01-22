/*********************************************
 * Copyright (c) 2014 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal;

import java.io.File;
import java.io.IOException;
import java.net.URL;

import javax.swing.SwingUtilities;

import org.w3c.dom.Element;

/**
 * A set of utility methods.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class Utils {
	
	private static String rootPath;
	
	public static String getRootPath() {
		if(rootPath == null) {
			String urlpath = Utils.class.getResource("/" + Utils.class.getName().replace('.', '/') + ".class").toString();
			urlpath = urlpath.substring(0, urlpath.indexOf(".jar") + 4);
			urlpath = urlpath.substring(urlpath.lastIndexOf(':') - 1);
			try {
				rootPath = new File(new URL("file:///" + urlpath).toURI()).getParentFile().getParent();
			} catch (Exception e) {}
		}
		return rootPath;
	}
	
	public static String getAbsolutePath(String relPath) {
		return getRootPath() + File.separator + relPath;
	}
	
	
	public static String getDefinedAttribute(Element element, String name) throws IOException {
		if(!element.hasAttribute(name))
			throw new IOException("The attribute " + name + "isn't defined.");
		return element.getAttribute(name);
	}
	
	public static String getDefaultAttribute(Element element, String name, String defval) {
		if(element.hasAttribute(name))
			return element.getAttribute(name);
		else
			return defval;
	}
	
	public static int getDefaultAttribute(Element element, String name, String[] options, int defval) {
		if(element.hasAttribute(name)) {
			String value = element.getAttribute(name);
			for(int i=0; i < options.length; i++) {
				if(options[i].equals(value))
					return i;
			}
			return defval;
		} else
			return defval;
	}
	
	public static boolean getDefaultAttribute(Element element, String name, boolean defval) {
		if(element.hasAttribute(name)) {
			return Boolean.parseBoolean(element.getAttribute(name));
		} else
			return defval;
	}
	
	public static String getFileNameWithoutExtension(File file) {
		String fileName = file.getName();
		int dotIdx = fileName.lastIndexOf('.');
		if(dotIdx > 0 && dotIdx <= fileName.length() - 2 )
			return fileName.substring(0, dotIdx);
		else
			return fileName;
	}
	
	public static void runInEdt(Runnable runnable) {
		if(SwingUtilities.isEventDispatchThread())
			runnable.run();
		else
			SwingUtilities.invokeLater(runnable);
	}

}
