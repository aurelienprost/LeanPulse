/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.api;

import java.awt.Window;
import java.io.File;
import java.util.List;

import com.leanpulse.syd.api.progress.IProgressMonitor;

/**
 * A render configuration defines how a documentation will be generated.
 * <p>
 * <dl>
 * <dt>It enables to control the following aspects of the generation:</dt>
 * <dd>- <b>The style, layout and content of the generated document</b>: the
 * render configuration defines which stylesheet to use to transform the raw XML
 * data extracted from the model to a formatted counterpart (XSL-FO), before the
 * rendering. It also enables to set some parameters of the stylesheet,<br>
 * - <b>Where to generate the document</b>: the output file can be automatically
 * computed from the model name and location, or relative to the current
 * directory or to the directory of a parent document in the hierarchy,<br>
 * - <b>The security options of the document</b>: to prevent the PDF from being
 * printed, edited, etc. ,<br>
 * - <b>The generation of hierarchy</b>: the render configuration can indicate
 * to loop threw the model dependencies to generate documents for all or part of
 * the models in the hierarchy. For this purpose, each configuration can also
 * define child render configurations to generate children documents with
 * different parameters than the parent.</dd>
 * </dl>
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 * 
 * @see PdfSecurityOptions
 * @see Snapper
 * @see Renderer
 */
public abstract class GenProfileRenderConf {
	
	/**
	 * Constant indicating the output directory is relative to the model
	 * directory.
	 */
	public static final int RELTO_MODEL = 0;
	/**
	 * Constant indicating the output directory is relative to the current
	 * directory.
	 */
	public static final int RELTO_CURDIR = 1;
	/**
	 * Constant indicating the output directory is relative to the counterpart
	 * computed by the parent render configuration while generating the
	 * hierarchy.
	 */
	public static final int RELTO_PARENT = 2;
	
	/**
	 * No action after the generation.
	 */
	public static final int ACTION_NOP = 0;
	/**
	 * Action to open the generated document after completion.
	 */
	public static final int ACTION_OPEN = 1;
	
	/**
	 * Do not generate referenced models
	 */
	public static final int GENDEP_NO = 0;
	/**
	 * Generate referenced models as separated documents
	 */
	public static final int GENDEP_SEPDOCS = 1;
	/**
	 * Generate referenced models in a single document
	 */
	public static final int GENDEP_EMBED = 2;
	
	/*
	 * Implementation will provide the correct constructor.
	 */
	protected GenProfileRenderConf() {};
	
	/**
	 * Returns the stylesheet to use to transform the raw XML data extracted
	 * from the model to a formatted counterpart (XSL-FO).
	 * <p>
	 * The stylesheet controls the style, layout and content of the generated document.
	 * 
	 * @return The stylesheet file.
	 */
	public abstract File getStyle();
	
	/**
	 * Returns the raw output directory.
	 * <p>
	 * The output directory can be absolute or relative. If relative, another method
	 * indicates to which element it is relative.
	 * 
	 * @return The raw output directory.
	 * 
	 * @see #getRelativeTo()
	 * @see #computeOutput(File, File)
	 */
	public abstract File getOutputDir();
	
	/**
	 * Indicates to what the output directory is relative.
	 * <p>
	 * Returns one of the constants defined by this class: {@link #RELTO_MODEL},
	 * {@link #RELTO_CURDIR} or {@link #RELTO_PARENT}. Has no sense if the
	 * output directory is absolute.
	 * 
	 * @return To what the output directory is relative.
	 * 
	 * @see #getOutputDir()
	 */
	public abstract int getRelativeTo();
	
	/**
	 * Returns the suffix used to compute the document name from the model name.
	 * 
	 * @return The suffix.
	 */
	public abstract String getSuffix();
	
	/**
	 * Computes the output file in which the document will be rendered for the
	 * given model.
	 * <p>
	 * The output file is computed in relation with the parameters returned by the
	 * three methods above.
	 * 
	 * @param mdlFile
	 *            The model file to generate.
	 * @param parDir
	 *            The directory computed by the parent render configuration
	 *            while generating the hierarchy.
	 * @return The output file for the generation.
	 */
	public abstract File computeOutput(File mdlFile, File parDir);
	
	/**
	 * Returns the security options to protect the PDF document.
	 * 
	 * @return The security options.
	 */
	public abstract PdfSecurityOptions getSecurityOptions();
	
	/**
	 * Returns the action to execute after the generation completion.
	 * <p>
	 * The value returned corresponds to one of the following constants:
	 * {@link #ACTION_NOP} or {@link #ACTION_OPEN}.
	 * 
	 * @return The post action.
	 */
	public abstract int getPostGenAction();
	
	/**
	 * Indicates if the dependencies of the current model must be generated.
	 * <p>
	 * The value returned corresponds to one of the following constants:
	 * {@link #GENDEP_NO}, {@link #GENDEP_SEPDOCS} or {@link #GENDEP_EMBED}.
	 * 
	 * @return The option to possibly generate model dependencies.
	 */
	public abstract int getGenDependencies();

	/**
	 * Gets the render configuration to apply for the given referenced model.
	 * <p>
	 * If the current render configuration has no child but does generate
	 * references, it will be reused for the referenced models. Otherwise, one
	 * of the child configurations will be returned, depending on the given
	 * referenced model.
	 * <p>
	 * TODO: The current implementation doesn't allow to select a render
	 * configuration according to a model and will actually always return the
	 * first child configuration.
	 * 
	 * @param refMdlFile
	 *            The referenced model to generate.
	 * @return The render configuration to apply for the referenced model.
	 */
	public abstract GenProfileRenderConf getSubRenderConf(File refMdlFile);
	
	/**
	 * Returns the parent directory to consider for the generation of the
	 * referenced models.
	 * 
	 * @param outFile
	 *            The output file as computed by the current render
	 *            configuration for the current model.
	 * @param parDir
	 *            The parent directory used by the current render configuration.
	 * @return The new parent directory
	 */
	public abstract File getSubParentDir(File outFile, File parDir);

	/**
	 * Gets the stylesheet parameters to pass to the XSLT processor.
	 * <p>
	 * Returns the name-value pairs statically defined by the render
	 * configuration as well as the following computed parameters:
	 * <ul>
	 * <li><i>resourcespath</i>: the absolute path to the "style/resources"
	 * directory in the SyD installation,</li>
	 * <li><i>currentdate</i>: the current date in the English local and with
	 * the "dd MMM yyyy" format,</li>
	 * <li><i>gendep</i>: indicates if the model dependencies are rendered and
	 * how (values are: "false", "true", "embed"),</li>
	 * <li><i>xmluri</i>: the URI to the directory where input XML files are
	 * stored,</li>
	 * <li><i>refmdlpaths</i>: a semi-colon separated string given, for each
	 * reference model name, the corresponding relative path between parent
	 * documents.</li>
	 * </ul>
	 * 
	 * @param xmlFile
	 *            The input XML file to be rendered.
	 * @param outFile
	 *            The output file in which the current model will be generated.
	 * @param refMdls
	 *            The list of models referenced by the current model.
	 * @param subParDir
	 *            The parent directory that should be considered for the
	 *            generation of the referenced models.
	 * @param refOutFiles
	 *            This list will be populated with the output files computed for
	 *            the referenced models to avoid to have to perform the
	 *            computation again while generating later each referenced
	 *            model. It must be empty and with the same size as the
	 *            referenced models before being passed to this method.<br>
	 *            It can also be <code>null</code> if retrieve the output dirs
	 *            is not required.
	 * @return The stylesheet parameters to pass to the XSLT processor.
	 */
	public abstract String[] getStyleParams(File xmlFile, File outFile, List<File> refMdls, File subParDir, List<File> refOutFiles);
	
	/**
	 * Utility method to render a previously extracted XML file with this render
	 * configuration.
	 * <p>
	 * In this particular case, the XML file replaces the model to determine
	 * where to render the document. The progress of the rendering is reported
	 * to the supplied monitor. If an error occurs, it is reported to the
	 * progress monitor and <code>false</code> is returned.
	 * 
	 * @param xmlFile
	 *            The XML file to render.
	 * @param refMdls
	 *            The list of models referenced by the model from which the XML
	 *            file was extracted; necessary to compute the relative paths to
	 *            cross-linked document.
	 * @param mon
	 *            The progress monitor to which progress and errors are
	 *            reported.
	 * @return True if the rendering succeeded or false if an error occurred.
	 */
	public abstract boolean render(File xmlFile, List<File> refMdls, IProgressMonitor mon);

	/**
	 * Utility method to render a previously extracted XML file with this render
	 * configuration and without reporting progress.
	 * <p>
	 * If an error occurs during the rendering, it is directly thrown.
	 * 
	 * @param xmlFile
	 *            The XML file to render.
	 * @param refMdls
	 *            The list of models referenced by the model from which the XML
	 *            file was extracted; necessary to compute the relative paths to
	 *            cross-linked document.
	 * @throws Exception
	 *             If an error occurred during the rendering.
	 * 
	 * @see #render(File, List, IProgressMonitor)
	 */
	public abstract void render(File xmlFile, List<File> refMdls) throws Exception;
	
	/**
	 * Utility method to render a previously extracted XML file with this render
	 * configuration and report progress to the user with an advanced wait bar.
	 * <p>
	 * If an error occurs during the rendering, the exception is reported in the
	 * UI and <code>false</code> is returned.
	 * 
	 * @param xmlFile
	 *            The XML file to render.
	 * @param refMdls
	 *            The list of models referenced by the model from which the XML
	 *            file was extracted; necessary to compute the relative paths to
	 *            cross-linked document.
	 * @param appwin
	 *            The window in relation to which the wait bar location is
	 *            determined. If <code>null</code>, it is placed at the center
	 *            of the screen.
	 * @return True if the rendering succeeded or false if an error occurred.
	 * 
	 * @see #render(File, List, IProgressMonitor)
	 */
	public abstract boolean renderUI(File xmlFile, List<File> refMdls, Window appwin);
	
}
