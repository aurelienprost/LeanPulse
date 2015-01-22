<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================

This stylesheet converts MS Word 2003 XML documents to XSL Formatting
Objects.

This is topmost template. It defines global constants, defaults and
lays down the rule for general template matching. All formatting
specific to single elements is contained in subordinated stylesheets:

  a. structure.xsl - defines the presentation of the contents,

  b. properties.xsl - controls element properties at any level,
  
  c. graphs.xsl - translates graphic elements,

  d. utils.xsl - named templates that assist in performing common tasks.

Copyright (c) 2011 LeanPulse. All rights reserved.

Author: Aurélien PROST (a.prost@leanpulse.com)

==================================================================== -->

<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
	version="2.0">

	<xsl:include href="utils.xsl" />
	<xsl:include href="structure.xsl" />
	<xsl:include href="properties.xsl" />
	<xsl:include href="graphs.xsl" />

	<!-- Default variables -->
	<xsl:variable name="default-width.list-label" select="9" />
	<xsl:variable name="default-internal-gap.list-item" select="18" />
	<xsl:variable name="default-list-item-body-indent" select="36" />
	<xsl:variable name="default-font-size.list-label" select="10" />
	<xsl:variable name="default-font-size.symbol" select="10" />
	<xsl:variable name="default-factor-for-bullets" select="0.5" />
	<xsl:variable name="default-widows" select="2" />
	<xsl:variable name="default-orphans" select="2" />
	<xsl:variable name="white-space-collapse" select="'false'" />
	<xsl:variable name="default-line-height" select="1.147" />
	<xsl:variable name="not-supported-inlines" select="''"/>
    <xsl:variable name="standard-namespace-prefixes" select="' fo w o v wx aml w10 dt st1 '"/>
    <xsl:variable name="go-deeper-for-alien-elements" select="'yes'"/>

	<xsl:output method="xml" omit-xml-declaration="yes" version="2.0" indent="no" encoding="utf-8" />
	<xsl:strip-space elements='*' />

	<!-- Keys -->
	<xsl:key name="styles" match="//w:wordDocument/w:styles/w:style" use="@w:styleId" />
	<xsl:key name="tables-by-style" match="//w:tbl"	use="w:tblPr/w:tblStyle/@w:val" />
	<xsl:key name="lists" match="//w:wordDocument/w:lists/w:list" use="@w:ilfo" />
	<xsl:key name="list-properties" match="//w:wordDocument/w:lists/w:listDef" use="@w:listDefId" />
	<xsl:key name="list-picture-bullets" match="//w:wordDocument/w:lists/w:listPicBullet" use="@w:listPicBulletId" />
	<xsl:key name="fonts" match="//w:wordDocument/w:fonts/w:font" use="@w:name" />

	<!-- This param defines the mode for displaying output messages if an unsupported element encountered. -->
	<xsl:param name="verbose" select="'no'" />

	<!-- Global constants -->
	<xsl:variable name="section-block-name" select="'fo:block'" />
	<xsl:variable name="section-block-namespace" select="'http://www.w3.org/1999/XSL/Format'" />

	<xsl:variable name="default-paragraph-style" select="//w:wordDocument/w:styles/w:style[@w:default='on' and @w:type='paragraph'][1]" />
	<xsl:variable name="default-character-style" select="//w:wordDocument/w:styles/w:style[@w:default='on' and @w:type='character'][1]" />
	<xsl:variable name="default-table-style" select="//w:wordDocument/w:styles/w:style[@w:default='on' and @w:type='table'][1]" />

	<!-- GENERAL TEMPLATE MATCHING -->
	<xsl:template match="*" priority="-1">
		<xsl:choose>
			<xsl:when
				test="not(contains($standard-namespace-prefixes, concat(' ', substring-before(name(), ':'), ' ')))">
				<xsl:if test="$go-deeper-for-alien-elements = 'yes'">
					<xsl:apply-templates />
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="$verbose='yes'">
					<xsl:message>
						<xsl:text>Warning! Unsupported element: </xsl:text>
						<xsl:value-of select="name()" />
						<xsl:text>. Element's contents will be lost.</xsl:text>
					</xsl:message>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
