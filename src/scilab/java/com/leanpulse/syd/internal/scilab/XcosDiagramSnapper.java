/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal.scilab;

import java.awt.Dimension;
import java.awt.Point;
import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CancellationException;
import java.util.concurrent.ExecutionException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.batik.svggen.CachedImageHandlerBase64Encoder;
import org.apache.batik.svggen.SVGGeneratorContext;
import org.apache.batik.svggen.SVGGraphics2D;
import org.scilab.modules.graph.ScilabCanvas;
import org.scilab.modules.xcos.Xcos;
import org.scilab.modules.xcos.block.SuperBlock;
import org.scilab.modules.xcos.graph.SuperBlockDiagram;
import org.scilab.modules.xcos.graph.XcosDiagram;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.leanpulse.syd.api.Snapper;
import com.leanpulse.syd.api.progress.IProgressMonitor;
import com.leanpulse.syd.internal.Utils;
import com.mxgraph.canvas.mxGraphics2DCanvas;
import com.mxgraph.canvas.mxICanvas;
import com.mxgraph.model.mxGeometry;
import com.mxgraph.util.mxCellRenderer;
import com.mxgraph.util.mxCellRenderer.CanvasFactory;

/**
 * <code>Snapper</code> implementation for Xcos.
 * <p>
 * As Xcos if fully implemented in Java, the entire data extraction process from
 * Xcos models is implemented in this class, directly in Java.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class XcosDiagramSnapper extends Snapper {
	
	private static File tempDir;
	
	/**
	 * Returns the temporary directory.
	 * 
	 * @return The temporary directory.
	 */
	public static File getTempDir() {
		if(tempDir == null) { //Scilab temp dir is a subfolder of the OS temp dir
			tempDir = new File(System.getProperty("java.io.tmpdir")).getParentFile();
		}
		return tempDir;
	}
	
	/**
	 * Gets the Xcos diagram for a given opened model.
	 * 
	 * @param xcosFile
	 *            The Xcos file.
	 * @return The corresponding <code>XcosDiagram</code> if the model is
	 *         opened, <code>null</code> otherwise.
	 */
	public static XcosDiagram getOpenedDiagram(File xcosFile) {
		List<XcosDiagram> openedDiagrams = Xcos.getInstance().getDiagrams();
		for(XcosDiagram diagram : openedDiagrams) {
			if (diagram.getSavedFile() != null
					&& diagram.getSavedFile().equals(xcosFile)) {
				return diagram;
			}
		}
		return null;
	}
	
	/* Loop inside the element hierarchy to add the given prefix. */
	private static void addPrefix(Element el, String prefix) {
		el.setPrefix(prefix);
		NodeList children = el.getChildNodes();
        for(int i=0; i<children.getLength(); i++){
        	Node child = children.item(i);
        	if(child.getNodeType() == Node.ELEMENT_NODE)
        		addPrefix((Element)child, prefix);
        }
	}
	
	/*
	 * Loop inside the element hierarchy to add a link on the rectangle child
	 * element with the given coordinates.
	 */
	private static boolean addChildrenLink(Element el, String x, String y, String path) {
		NodeList children = el.getChildNodes();
		for(int i=0; i<children.getLength(); i++) {
			Node child = children.item(i);
			if(child.getNodeType() == Node.ELEMENT_NODE) {
				if("svg:rect".equals(((Element)child).getTagName())) {
					Element rect = (Element) child;
					if(x.equals(rect.getAttribute("x")) && y.equals(rect.getAttribute("y"))) {
						Element link = rect.getOwnerDocument().createElement("svg:a");
						link.setAttribute("xlink:href", "#" + path);
						Node parent = rect.getParentNode();
						link.appendChild(rect);
						parent.appendChild(link);
						return true;
					}
				}
				if(addChildrenLink((Element)child, x, y, path))
					return true;
			}
		}
		return false;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#getCurDir()
	 */
	@Override
	public String getCurDir() {
		return System.getProperty("user.dir"); // TODO: get the value of PWD from Scilab
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#isDirty(java.io.File)
	 */
	@Override
	protected boolean isDirty(File mdlFile) {
		XcosDiagram diagram = getOpenedDiagram(mdlFile);
		if(diagram == null) // File not opened
			return false;
		return diagram.isModified();
	}

	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#getVersion(java.io.File)
	 */
	@Override
	protected String getVersion(File mdlFile) {
		//Xcos doesn't support any internal version, use the file timestamp
		long lastModTime = mdlFile.lastModified();
		if(lastModTime > 0L)
			return Long.toString(lastModTime);
		else
			return null;
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#getDefaultSnapFile(java.io.File)
	 */
	@Override
	public File getDefaultSnapFile(File mdlFile) {
		String mdlName = Utils.getFileNameWithoutExtension(mdlFile);
		return new File(getTempDir().getPath() + File.separator + mdlName + ".xml");	
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#locateModels(java.lang.String[])
	 */
	@Override
	protected List<File> locateModels(String[] mdlNames) {
		return NO_MDLREF; // NOP: No paths in Scilab
	}
	
	/*
	 * (non-Javadoc)
	 * @see com.leanpulse.syd.api.Snapper#resnap(java.io.File, boolean, boolean, java.util.Map, java.io.File, com.leanpulse.syd.api.progress.IProgressMonitor)
	 */
	@Override
	protected List<File> resnap(File mdlFile, boolean followLinks, boolean lookUnderMasks, Map<String,String> params, File xmlFile, IProgressMonitor mon) {
		try {
			// Open diagram if required
			boolean wasClosed = false;
			XcosDiagram diagram = getOpenedDiagram(mdlFile);
			if(diagram == null) {
				wasClosed = true;
				Xcos.getInstance().open(mdlFile);
				diagram = getOpenedDiagram(mdlFile);
			}
			String mdlName = diagram.getTitle();
			
			// Created a new XML document
			DocumentBuilderFactory docBuilderFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder docBuilder = docBuilderFactory.newDocumentBuilder();
			Document doc = docBuilder.newDocument();
			
			// Setup the SVG generator context
			SVGGeneratorContext svgGenCtx = SVGGeneratorContext.createDefault(doc);
			svgGenCtx.setGenericImageHandler(new CachedImageHandlerBase64Encoder());
			svgGenCtx.setEmbeddedFontsOn(false);
			
			// Set root element and attributes
			Element root = doc.createElement("syd:model");
			root.setAttribute("xmlns:syd", "http://www.leanpulse.com/schemas/syd/2011/core");
			root.setAttribute("xmlns:svg", "http://www.w3.org/2000/svg");
			root.setAttribute("xmlns:xlink", "http://www.w3.org/1999/xlink");
			root.setAttribute("mdlversion", getVersion(mdlFile));
			root.setAttribute("snapver", SNAPPER_VER);
			root.setAttribute("snapconf", Boolean.toString(followLinks) + "|" + Boolean.toString(lookUnderMasks));
			root.setAttribute("id", mdlName);
			
			// Snap root
			extractDiagram(diagram, mdlName, root, svgGenCtx, mon, 1.0);
			
			// Add children
			doc.appendChild(root);
			
			// Serialize document to XML file
			TransformerFactory transformerFactory = TransformerFactory.newInstance();
	        Transformer serializer = transformerFactory.newTransformer();
	        serializer.setOutputProperty(OutputKeys.INDENT, "yes");
	        serializer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
	        DOMSource source = new DOMSource(doc);
	        StreamResult result =  new StreamResult(new FileOutputStream(xmlFile));
	        serializer.transform(source, result);
	        
	        // Close the model if not open at start
	        if(wasClosed)
	        	Xcos.getInstance().close(diagram, true);
	        
			mon.finish("Data extracted from model \"" + mdlFile.getName() + "\" successfully.");
			return NO_MDLREF;
		} catch(Exception e) {
			if(e instanceof CancellationException)
				mon.finish("Extraction from model \"" + mdlFile.getName() + "\" cancelled by user.");
			else
				mon.finish("An error occured while extracting data from model \"" + mdlFile.getPath() + "\" !", e);
			return null;
		}
	}
	
	/*
	 * Snaps the given diagram to SVG
	 */
	protected void extractSvg(XcosDiagram diagram, List<SuperBlockDiagram> children,
			List<String> childrenPath, Element sysEl, SVGGeneratorContext svgGenCtx) {
		Element svgSnap = sysEl.getOwnerDocument().createElement("syd:snapshot");
		final SVGGraphics2D svgGenerator = new SVGGraphics2D(svgGenCtx, false);
		mxCellRenderer.drawCells(diagram, null, 1, null,
			new CanvasFactory() {
				private mxGraphics2DCanvas canvas;
				@Override
				public mxICanvas createCanvas(int width, int height) {
					if (canvas == null) {
						canvas = new ScilabCanvas();
						canvas.setGraphics(svgGenerator);
						svgGenerator.setSVGCanvasSize(new Dimension(width, height));
					}
					return canvas;
				}
		});
		Element svgRoot = svgGenerator.getRoot();

		addPrefix(svgRoot, "svg");
		for(int i=0; i<children.size(); i++) {
			mxGeometry mGeom = children.get(i).getContainer().getGeometry();
			Point pos = mGeom.getPoint();
			String x = Integer.toString(pos.x);
			String y = Integer.toString(pos.y);
			addChildrenLink(svgRoot, x, y, childrenPath.get(i));
		}
		
		svgSnap.appendChild(svgRoot);
		sysEl.appendChild(svgSnap);
	}
	
	/*
	 * Extracts the given diagram and children
	 */
	protected void extractDiagram(XcosDiagram diag, String path, Element sysEl,
			SVGGeneratorContext svgGenCtx, IProgressMonitor monitor, double monInc) throws CancellationException, ExecutionException {
		monitor.checkCanceled();
		List<SuperBlockDiagram> children = new ArrayList<SuperBlockDiagram>();
		List<String> childrenPath = new ArrayList<String>();
		monitor.progress("Snapshot " + path);
		try {
			getChildrenToPrint(diag, path, children, childrenPath);
			extractSvg(diag, children, childrenPath, sysEl, svgGenCtx);
		} catch(Exception e) {
			throw new ExecutionException("An error occured while extracting snapshot from diagram \"" + path + "\" !", e);
		}
		double newInc = monInc / (children.size() + 1);
		monitor.progress(newInc);
		for(int i=0; i<children.size(); i++) { // Loop through children
			SuperBlockDiagram child = children.get(i);
			String childPath = childrenPath.get(i);
			Element childEl = sysEl.getOwnerDocument().createElement("syd:system");
			childEl.setAttribute("id", childPath);
			extractDiagram(child , childPath, childEl, svgGenCtx, monitor, newInc);
			sysEl.appendChild(childEl);
		}
	}
	
	/*
	 * Gets the children to extract for the given diagram.
	 */
	protected void getChildrenToPrint(XcosDiagram parDiag, String parPath, List<SuperBlockDiagram> children, List<String> childrenPath) {
		Object[] childCells = parDiag.getChildCells(parDiag.getDefaultParent());
		int i = 1;
		for(Object childCell : childCells) { // Loop through children to find not masked superblocks
			if(childCell instanceof SuperBlock) {
				SuperBlock superBlock = (SuperBlock) childCell;
				if(!superBlock.isMasked()) {
					SuperBlockDiagram childDiag = superBlock.getChild();
					children.add(childDiag);
					childrenPath.add(parPath + "/" + childDiag.getTitle() + i++);
				}
			}
		}
	}
	
}
