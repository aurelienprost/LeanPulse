<?xml version="1.0" encoding="UTF-8"?>

<!-- ==============================================================================================

Empty template skeleton to override default layout and styling.

Copyright (c) 2013 LeanPulse. All rights reserved.

Author: Aurélien PROST (a.prost@leanpulse.com)


===================================================================================================
										DEVELOPER NOTES
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

The goal of this stylesheet is to transform the XML file extracted from the model (output by
default in the user temporary directory, as "modelname.xml") to a valid XSL-FO document that will
then be rendered.

For more information about the XSLT technology, please report to the :
 - W3C tutorial: http://www.w3schools.com/xsl/
 - W3C specification: http://www.w3.org/TR/xslt
 For more information about the XSL-FO format, please report to the :
 - W3C tutorial: http://www.w3schools.com/xslfo/
 - W3C specification: http://www.w3.org/TR/xsl

By default, this stylesheet is empty and only imports <default.xsl> which implements the default
SyD document layout and formatting. Parameters and templates of <default.xsl> can nevertheless be
overridden here to customize some parts of the output document. To know which template to override
to customize a given section, please report to the default implementation.

=============================================================================================== -->

<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:syd="http://www.leanpulse.com/schemas/syd/2011/core"
	exclude-result-prefixes="xsl fn syd"
	version="1.0">
	
	<!-- Just import default SyD document layout and formatting.  -->
	<xsl:import href="default.xsl" />
	
	<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" />
	
	
	<!-- ==========================================================================================
									ANY CUSTOMIZATION GOES HERE
	=========================================================================================== -->

	<!--							  Example : Custom Footer
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	After a quick look at the <default.xsl> stylesheet, we can guess that the way the footer is
	rendered in the output document is controlled by the template named "DocumentFooter".
	We just	copied the default implementation here and modified it a bit. You can uncomment the
	following lines of code and see the result of this modification by yourself.
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
	
	<!-- <xsl:template name="DocumentFooter">
		<fo:block text-align="center">A new simple footer with a single line of text.</fo:block>
	</xsl:template> -->
	
</xsl:stylesheet>