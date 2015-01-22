/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.zip.CRC32;
import java.util.zip.Checksum;

import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.Utils;

/**
 * Interface to extract data from models (mdl, xcos, etc. -> xml).
 * <p>
 * To fasten the overall generation process, a cache system is implemented to
 * not extract data from models that haven't changed since their last
 * extraction.
 * <dl>
 * <dt>The extraction will be skipped if the following conditions are verified:</dt>
 * <dd>- The model isn't opened in the editor with unsaved changes.<br>
 * - The given XML output file already exists.<br>
 * - The model versions read from the model file and inside the XML file
 * matches.</dd>
 * <dt>All the snap methods defined in this class implements this behavior.</dt>
 * </dl>
 * <p>
 * The structure of the XML file produced by the extraction is defined by <a
 * href="../../../../../xml/sydSnap.xsd">this schema</a>.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see SnapperManager
 */
public abstract class Snapper {
	
	/**
	 * Global snapper version
	 */
	protected static final String SNAPPER_VER = "1.4";
	
	/**
	 * Default empty list to define no model references.
	 */
	protected static final List<File> NO_MDLREF = new ArrayList<File>(0);
	
	
	/**
	 * Pattern to extract the model version from the XML file.
	 */
	protected static final Pattern XML_VERSION_PATTERN = Pattern.compile("mdlversion=[\"']([^\"']+)[\"']");
	
	/**
	 * Pattern to extract the model dependencies from the XML file.
	 */
	protected static final Pattern XML_DEPS_PATTERN = Pattern.compile("mdldep=[\"'']([\\w\\|]+)[\"'']");
	
	/**
	 * Pattern to extract the snapper version from the XML file.
	 */
	protected static final Pattern XML_SNAPVER_PATTERN = Pattern.compile("snapver=[\"']([\\w\\.]+)[\"']");
	
	/**
	 * Pattern to extract the snapper configuration from the XML file.
	 */
	protected static final Pattern XML_SNAPCONF_PATTERN = Pattern.compile("snapconf=[\"']([^\"']*)[\"']");
	
	
	/**
	 * Utility method to extract the first line of text defining the root
	 * element in the given XML file.
	 * 
	 * @param xmlFile
	 *            The XML file.
	 * @return The first line of text defining the root element.
	 */
	protected static String readRootFromXml(File xmlFile) {
		BufferedReader reader = null;
		String rootEl = null;
		try {
			reader = new BufferedReader(new FileReader(xmlFile));
			while ((rootEl = reader.readLine()) != null) {
				if(rootEl.startsWith("<syd:model") || rootEl.startsWith("<syd:system"))
					break;
			}
		} catch (Exception e) {
		} finally {
			try {
				if (reader != null) reader.close();
			} catch (IOException e) {}
		}
		return rootEl;
	}
	
	/**
	 * Extracts XML data from a model.
	 * <p>
	 * The progress of the extraction is reported to the supplied monitor. If an
	 * error occurs, it is reported to the progress monitor and
	 * <code>null</code> is returned.
	 * <p>
	 * If the model hasn't changed since the last extraction as given by the XML
	 * file, the snaps may not actually be performed and the XML directly
	 * reused.
	 * 
	 * @param mdlFile
	 *            The model file from which to extract the data.
	 * @param followLinks
	 *            If the extraction will follow links.
	 * @param lookUnderMasks
	 *            If the extraction will look under masks.
	 * @param params
	 *            The parameters to pass to the snapper.
	 * @param xmlFile
	 *            The output XML file.
	 * @param monitor
	 *            The progress monitor to which progress and errors are
	 *            reported.
	 * @return The list of models referenced by <code>mdlFile</code> or
	 *         <code>null</code> if the extraction failed.
	 */
	public List<File> snap(File mdlFile, boolean followLinks, boolean lookUnderMasks, Map<String,String> params, File xmlFile, IProgressMonitor monitor) {
		monitor.start("Extracting data from model \"" + mdlFile.getName() + "\"...", 1.0);
		List<File> refMdls = usePrevSnap(mdlFile, followLinks, lookUnderMasks, params, xmlFile);
		if(refMdls == null) {
			refMdls = resnap(mdlFile, followLinks, lookUnderMasks, params, xmlFile, monitor);
		} else {
			monitor.finish("Model \"" + mdlFile.getName() + "\" not changed, reuse cached extraction.");
		}
		return refMdls;
	}
	
	/**
	 * Gets a default XML output file for the given model.
	 * 
	 * @param mdlFile
	 *            The model file.
	 * @return The default XML output file.
	 */
	public File getDefaultSnapFile(File mdlFile) {
		String mdlName = Utils.getFileNameWithoutExtension(mdlFile);
		return new File(System.getProperty("java.io.tmpdir") + mdlName + ".xml");	
	}

	/**
	 * Checks if the XML file can be be directly reused in case the model hasn't
	 * changed since the last extraction.
	 * 
	 * @param mdlFile
	 *            The model file.
	 * @param followLinks
	 *            If the extraction will follow links.
	 * @param lookUnderMasks
	 *            If the extraction will look under masks.
	 * @param params
	 *            The parameters to pass to the snapper.
	 * @param xmlFile
	 *            The XML file that could be reused. Might not actually exist.
	 * @return The list of referenced models extracted from the XML file if it
	 *         can be reused or <code>null</code> otherwise.
	 */
	protected List<File> usePrevSnap(File mdlFile, boolean followLinks, boolean lookUnderMasks, Map<String,String> params, File xmlFile) {
		if(!isDirty(mdlFile)) {
			if(xmlFile.exists()) {
				String mdlVersion = getVersion(mdlFile);
				if(mdlVersion != null) {
					String rootEl = readRootFromXml(xmlFile);
					Matcher verMatcher = XML_VERSION_PATTERN.matcher(rootEl);
					if(verMatcher.find()) {
						String xmlVersion = verMatcher.group(1);
						if(mdlVersion.equals(xmlVersion)) {
							Matcher snapMatcher = XML_SNAPVER_PATTERN.matcher(rootEl);
							if(snapMatcher.find()) {
								String snapVer = snapMatcher.group(1);
								if(snapVer.equals(SNAPPER_VER)) {
									Matcher confMatcher = XML_SNAPCONF_PATTERN.matcher(rootEl);
									if(confMatcher.find()) {
										String snapConf = confMatcher.group(1);
										StringBuilder strBuilder = new StringBuilder();
										strBuilder.append(followLinks);
										strBuilder.append("|");
										strBuilder.append(lookUnderMasks);
										for(String key : params.keySet()) {
											strBuilder.append("|");
											strBuilder.append(key);
											strBuilder.append(":");
											strBuilder.append(params.get(key));
										}
										Checksum checksum = new CRC32();
										byte[] bytes = strBuilder.toString().getBytes();
										checksum.update(bytes,0,bytes.length);
										if(snapConf.equals(Long.toString(checksum.getValue()))) {
											Matcher depsMatcher = XML_DEPS_PATTERN.matcher(rootEl);
											if(depsMatcher.find())
												return locateModels(depsMatcher.group(1).split("\\|"));
											else
												return NO_MDLREF;
										}
									}
								}
							}
						}
					}
				}
			}
		}
		return null;
	}
	
	/**
	 * Gets the current directory of the modeling tool in which SyD is running.
	 * 
	 * @return The current directory.
	 */
	public abstract String getCurDir();

	/**
	 * The actual implementation of the XML extraction from the model.
	 * <p>
	 * If the result from the previous extraction can be reused, this method
	 * will be called to extract again the data.
	 * 
	 * @param mdlFile
	 *            The model file from which to extract the data.
	 * @param followLinks
	 *            If the extraction will follow links.
	 * @param lookUnderMasks
	 *            If the extraction will look under masks.
	 * @param params
	 *            The parameters to pass to the snapper.
	 * @param xmlFile
	 *            The output XML file.
	 * @param monitor
	 *            The progress monitor to which progress and errors are
	 *            reported.
	 * @return The list of models referenced by <code>mdlFile</code> or
	 *         <code>null</code> if the extraction failed.
	 */
	protected abstract List<File> resnap(File mdlFile, boolean followLinks, boolean lookUnderMasks, Map<String,String> params, File xmlFile, IProgressMonitor mon);
	
	/**
	 * Checks if the given model is opened and has unsaved modifications.
	 * 
	 * @param mdlFile
	 *            The model file to check.
	 * @return True if the model is opened and has unsaved changes in the
	 *         editor, false otherwise.
	 */
	protected abstract boolean isDirty(File mdlFile);
	
	/**
	 * Gets the version of the given model.
	 * <p>
	 * To retrieve the version, the implementation must not open the model if
	 * not already opened, in order to save loading time if the previous
	 * extraction can be reused.
	 * 
	 * @param mdlFile
	 *            The model file.
	 * @return The version of the model.
	 */
	protected abstract String getVersion(File mdlFile);
	
	/**
	 * Locates models referenced by their names.
	 * <p>
	 * Implementation will use the paths of the current modeling tool to find
	 * where the models with the given names are stored.
	 * 
	 * @param mdlNames
	 *            The names of the referenced models.
	 * @return The corresponding files.
	 */
	protected abstract List<File> locateModels(String[] mdlNames);

}
