/*********************************************
 * Copyright (c) 2011 LeanPulse.
 * All rights reserved.
 *********************************************/
package com.leanpulse.syd.remote.internal;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.Source;
import javax.xml.transform.Templates;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.Configuration;
import net.sf.saxon.PreparedStylesheet;
import net.sf.saxon.StandardURIResolver;
import net.sf.saxon.TransformerFactoryImpl;
import net.sf.saxon.trans.Err;
import net.sf.saxon.trans.XPathException;

/**
 * Caching implementation of JAXP transformer factory.
 * <p>
 * This implementation caches templates that were loaded from local files so
 * that consequent calls to local stylesheets require stylesheet reparsing only
 * if stylesheet was changed. It also allows to load compiled stylesheets.
 * 
 * @author <a href="mailto:a.prost@leanpulse.com">Aurélien PROST</a>
 */
public class CachingTransformerFactory extends TransformerFactoryImpl {
	
	public static class ZxsURIResolver extends StandardURIResolver {
		
		private static final long serialVersionUID = -7067053151124712479L;
		
		public ZxsURIResolver(Configuration config) {
			super(config);
		}

		public Source resolve(String href, String base) throws XPathException {
			if(href != null && href.startsWith("zxs:file:")) {
				try {
					int pathidx = href.indexOf("!/");
					URL baseURL = new URL(base);
		            URL absoluteURL = new URL(baseURL, href.substring(9,pathidx));
		            href = "jar:" + absoluteURL.toString().replaceAll(" ", "%20") + href.substring(pathidx);
				} catch (MalformedURLException err) {
					throw new XPathException("Invalid URI " + Err.wrap(href) + " - base " + Err.wrap(base), err);
		        }
			}
			return super.resolve(href, base);
		}

	}
	
	public static final String COMPILED_STYLESHEET_EXT = ".cxs";
	
	public CachingTransformerFactory() {
		super();
		setURIResolver(new ZxsURIResolver(getConfiguration()));
	}

	/**
	 * Private class to hold templates cache entry.
	 */
	private static class TemplatesCacheEntry {
		/** When was the cached entry last modified. */
		private long lastModified;

		/** Cached templates object. */
		private Templates templates;

		/** Templates file object. */
		private File templatesFile;

		/**
		 * Constructs a new cache entry.
		 * 
		 * @param templates
		 *            templates to cache.
		 * @param templatesFile
		 *            file, from which this transformer was loaded.
		 */
		private TemplatesCacheEntry(final Templates templates,
				final File templatesFile) {
			this.templates = templates;
			this.templatesFile = templatesFile;
			this.lastModified = templatesFile.lastModified();
		}
	}

	/** Map to hold templates cache. */
	private static Map<String, TemplatesCacheEntry> templatesCache = new HashMap<String, TemplatesCacheEntry>();
	
	
	/**
	 * Process the source into a Transformer object. If source is a StreamSource
	 * with <code>systemID</code> pointing to a file, transformer is produced
	 * from a cached templates object. Cache is done in soft references; cached
	 * objects are reloaded, when file's date of last modification changes.
	 * 
	 * @param source
	 *            An object that holds a URI, input stream, etc.
	 * @return A Transformer object that may be used to perform a transformation
	 *         in a single thread, never null.
	 * @throws TransformerConfigurationException
	 *             - May throw this during the parse when it is constructing the
	 *             Templates object and fails.
	 * 
	 */
	@Override
	public Transformer newTransformer(final Source source) throws TransformerConfigurationException {
		// Check that source in a StreamSource
		if (source instanceof StreamSource)
			try {
				// Create URI of the source
				final URI uri = new URI(source.getSystemId());
				// If URI points to a file, load transformer from the file
				// (or from the cache)
				if ("file".equalsIgnoreCase(uri.getScheme()))
					return newTransformer(new File(uri));
			} catch (URISyntaxException urise) {
				throw new TransformerConfigurationException(urise);
			}
		return super.newTransformer(source);
	}

	/**
	 * Creates a transformer from a file (and caches templates) or from cached
	 * templates object.
	 * 
	 * @param file
	 *            file to load transformer from.
	 * @return Transformer, built from given file.
	 * @throws TransformerConfigurationException
	 *             if there was a problem loading transformer from the file.
	 */
	protected synchronized Transformer newTransformer(final File file) throws TransformerConfigurationException {
		// Search the cache for the templates entry
		TemplatesCacheEntry templatesCacheEntry = templatesCache.get(file.getAbsolutePath());

		// If entry found
		if (templatesCacheEntry != null) {
			// Check timestamp of modification
			if (templatesCacheEntry.lastModified < templatesCacheEntry.templatesFile
					.lastModified())
				templatesCacheEntry = null;
		}
		// If no templatesEntry is found or this entry was obsolete
		if (templatesCacheEntry == null) {
			// If this file does not exists, throw the exception
			if (!file.exists()) {
				throw new TransformerConfigurationException(
						"Requested transformation [" + file.getAbsolutePath()
								+ "] does not exist.");
			}
			
			Templates templates = null;
			if (file.getName().endsWith(COMPILED_STYLESHEET_EXT)) {
				try {
					templates = PreparedStylesheet.loadCompiledStylesheet(getConfiguration(), file.getPath());
				} catch (Exception e) {
					throw new TransformerConfigurationException("Error while loading the compiled stylesheet.",e);
				}
			} else
				templates = newTemplates(new StreamSource(file));

			// Create new cache entry
			templatesCacheEntry = new TemplatesCacheEntry(templates, file);

			// Save this entry to the cache
			templatesCache.put(file.getAbsolutePath(), templatesCacheEntry);
		}
		return templatesCacheEntry.templates.newTransformer();
	}

}
