/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.internal;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.leanpulse.syd.api.GenProfile;
import com.leanpulse.syd.api.GenProfileRenderConf;
import com.leanpulse.syd.api.GenProfileSnapConf;

/**
 * Implementation of the <code>GenProfile</code> abstract class.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class GenProfileImpl extends GenProfile {
	
	protected static final String TAG_PROFILE = "pro:profile";
	protected static final String ATTR_ID = "id";
	protected static final String ATTR_NAME = "name";
	protected static final String ATTR_DESCRIPTION = "description";
	protected static final String ATTR_SHORTCUT = "shortcut";

	/*
	 * Reads the profiles from the profile definition file.
	 */
	public static GenProfile[] readProfiles(Element docElement) throws IOException {
		List<GenProfileImpl> profiles = new ArrayList<GenProfileImpl>();
		Map<String,String> globalSnapParams = new HashMap<String,String>();
		Map<String,String> globalRenderParams = new HashMap<String,String>();
		NodeList children = docElement.getChildNodes();
		for(int i=0; i<children.getLength(); i++) {
			Node child = children.item(i);
			if(child.getNodeType() == Node.ELEMENT_NODE) {
				Element element = (Element) child;
				String tag = element.getTagName();
				if(TAG_PROFILE.equals(tag)) {
					String id = Utils.getDefinedAttribute(element, ATTR_ID);
					String name = Utils.getDefinedAttribute(element, ATTR_NAME);
					String description = element.getAttribute(ATTR_DESCRIPTION);
					String shortcut = element.getAttribute(ATTR_SHORTCUT);
					GenProfileSnapConf snapper = GenProfileSnapConfImpl.readConfSnapper(element);
					GenProfileRenderConfImpl[] renderers = GenProfileRenderConfImpl.readConfRenderers(element);
					GenProfileImpl profile = new GenProfileImpl(id, name, description, shortcut, snapper, renderers);
					profiles.add(profile);
				} else if(GenProfileSnapConfImpl.TAG_PARAM.equals(tag)) {
					String name =  Utils.getDefinedAttribute(element, GenProfileSnapConfImpl.ATTR_NAME);
					String value =  Utils.getDefinedAttribute(element, GenProfileSnapConfImpl.ATTR_VALUE);
					globalSnapParams.put(name,value);
				} else if(GenProfileRenderConfImpl.TAG_PARAM.equals(tag)) {
					String name =  Utils.getDefinedAttribute(element, GenProfileRenderConfImpl.ATTR_NAME);
					String value =  Utils.getDefinedAttribute(element, GenProfileRenderConfImpl.ATTR_VALUE);
					globalRenderParams.put(name,value);
				}
			}
		}
		GenProfileImpl[] genprofiles = profiles.toArray(new GenProfileImpl[0]);
		for(int i=0; i<genprofiles.length; i++) {
			genprofiles[i].addGlobalParams(globalSnapParams, globalRenderParams);
		}
		return genprofiles;
	}
	
	private String id;
	private String name;
	private String description;
	private String shortcut;
	private GenProfileSnapConf snapper;
	private GenProfileRenderConf[] renderers;

	public GenProfileImpl(String id, String name, String description, String shortcut, GenProfileSnapConf snapper, GenProfileRenderConf[] renderers) {
		this.id = id;
		this.name = name;
		this.description = description;
		this.shortcut = shortcut;
		this.snapper = snapper;
		this.renderers = renderers;
	}
	
	protected void addGlobalParams(Map<String,String> globalSnapParams, Map<String,String> globalRenderParams) {
		((GenProfileSnapConfImpl)snapper).inheriteParams(globalSnapParams);
		for(int i=0; i<renderers.length; i++) {
			((GenProfileRenderConfImpl)renderers[i]).inheriteParams(globalRenderParams);
		}
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfile#getId()
	 */
	@Override
	public String getId() {
		return id;
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfile#getName()
	 */
	@Override
	public String getName() {
		return name;
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfile#getDescription()
	 */
	@Override
	public String getDescription() {
		return description;
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfile#getShortcut()
	 */
	@Override
	public String getShortcut() {
		return shortcut;
	}
	
	
	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfile#getRenderConfs()
	 */
	@Override
	public GenProfileRenderConf[] getRenderConfs() {
		return renderers;
	}

	/* (non-Javadoc)
	 * @see com.leanpulse.syd.api.GenProfile#getSnapConf()
	 */
	@Override
	public GenProfileSnapConf getSnapConf() {
		return snapper;
	}

}
