<?xml version="1.0" encoding="UTF-8" ?>
<!-- XSL FO stylesheet to format standard classes XML documents $Id: raweb3fo.xsl,v 
	2.7 2007/01/09 08:39:59 grimm Exp $ -->

<!-- Copyright Inria 2003-2004 Jose Grimm. This file is an adaptation of 
	file from the TEI distribution. See original Copyright notice below. On 2004/09/14, 
	rawebfo.xsl copied to rawebfo3.xsl -->

<!-- Copyright 1999-2001 Sebastian Rahtz/Oxford University <sebastian.rahtz@oucs.ox.ac.uk> 
	Permission is hereby granted, free of charge, to any person obtaining a copy 
	of this software and any associated documentation files (the ``Software''), 
	to deal in the Software without restriction, including without limitation 
	the rights to use, copy, modify, merge, publish, distribute, sublicense, 
	and/or sell copies of the Software, and to permit persons to whom the Software 
	is furnished to do so, subject to the following conditions: The above copyright 
	notice and this permission notice shall be included in all copies or substantial 
	portions of the Software. -->


<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:m="http://www.w3.org/1998/Math/MathML"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:exsl="http://exslt.org/common"
	xmlns:syd="http://www.leanpulse.com/schemas/syd/2011/core"
	xmlns:tex="http://www-sop.inria.fr/miaou/tralics/"
	exclude-result-prefixes="xsl fn exsl syd tex"
	version="1.0">
	
<!-- Customizations -->

	<xsl:param name="texFigureDir"/>

	<!-- Standard elements -->
	<xsl:param name="texParaIdent">1.5em</xsl:param>
	<xsl:param name="texParaSkip">5pt</xsl:param>
	<xsl:param name="texParaSkipMax">24pt</xsl:param>
	<xsl:param name="texCodeFont">Computer-Modern-Typewriter</xsl:param>
	<xsl:param name="texIdentFont">Helvetica</xsl:param>
	<xsl:param name="texIdentColor">blue</xsl:param>
	
	<!-- Links -->
	<xsl:param name="texLinkColor">Blue</xsl:param>
	
	<!-- Lists -->
	<xsl:param name="texListRightMargin">10pt</xsl:param>
	<xsl:param name="texListLeftGlossIndent">7mm</xsl:param>
	<xsl:param name="texListLeftGlossInnerIndent">4mm</xsl:param>
	<xsl:param name="texListLeftIndent">5pt</xsl:param>
	<xsl:param name="texListItemsep">4pt</xsl:param>
	<xsl:param name="texListAbove-1">6pt</xsl:param>
	<xsl:param name="texListBelow-1">6pt</xsl:param>
	<xsl:param name="texListAbove-2">4pt</xsl:param>
	<xsl:param name="texListBelow-2">4pt</xsl:param>
	<xsl:param name="texListAbove-3">0pt</xsl:param>
	<xsl:param name="texListBelow-3">0pt</xsl:param>
	<xsl:param name="texListAbove-4">0pt</xsl:param>
	<xsl:param name="texListBelow-4">0pt</xsl:param>
	<xsl:param name="texBulletOne">&#x2219;</xsl:param>
	<xsl:param name="texBulletTwo">&#x2013;</xsl:param>
	<xsl:param name="texBulletThree">&#x002A;</xsl:param>
	<xsl:param name="texBulletFour">&#x002B;</xsl:param>
	
	<!-- Figures & Tables -->
	<xsl:param name="texFigureWord">Figure </xsl:param>
	<xsl:param name="texTableWord">Table </xsl:param>
	<xsl:param name="texFigTabAlign">center</xsl:param>
	<xsl:param name="texCaptionAlign">center</xsl:param>
	<xsl:param name="texCaptionFontStyle">italic</xsl:param>
	<xsl:param name="texCaptionFontWeight">bold</xsl:param>
	<xsl:param name="texCaptionSpaceAbove">2pt</xsl:param>
	<xsl:param name="texCaptionSpaceBelow">12pt</xsl:param>



<!-- Sections and subsections -->

	<xsl:template name="texComputeStructure">
		<xsl:param name="context"/>
		<xsl:for-each select="$context/descendant::tex:div0 | $context/descendant::tex:div1 | $context/descendant::tex:div2 |
				$context/descendant::tex:div3 | $context/descendant::tex:div4 | $context/descendant::tex:div5">
			<xsl:variable name="level" select="fn:substring-after(name(),'tex:div')"/>
			<NOP>
				<xsl:call-template name="texAddID"/>
				<xsl:attribute name="title" select="tex:head/text()"/>
				<xsl:if test="$level &lt; 2">
					<xsl:attribute name="num" select="syd:calcTitleNum($level + 1)"/>
				</xsl:if>
				<xsl:choose>
					<xsl:when test="$level = 0">
						<xsl:attribute name="style">StyleTitle0</xsl:attribute>
						<xsl:attribute name="break">page</xsl:attribute>
						<xsl:attribute name="tocstyle">StyleTocTitle0</xsl:attribute>
						<xsl:attribute name="level" select="$level + 1"/>
					</xsl:when>
					<xsl:when test="$level = 1">
						<xsl:attribute name="style">StyleTitle1</xsl:attribute>
						<xsl:attribute name="tocstyle">StyleTocTitle1</xsl:attribute>
						<xsl:attribute name="level" select="$level + 1"/>
					</xsl:when>
					<xsl:when test="$level = 2">
						<xsl:attribute name="style">StyleTitle2</xsl:attribute>
					</xsl:when>
					<xsl:when test="$level = 3">
						<xsl:attribute name="style">StyleTitle3</xsl:attribute>
					</xsl:when>
					<xsl:when test="$level = 4">
						<xsl:attribute name="style">StyleTitle4</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="style">StyleTitle5</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</NOP>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="tex:div0|tex:div1|tex:div2|tex:div3|tex:div4|tex:div5">
		<xsl:call-template name="NumberedHeading"/>
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template name="NumberedHeading">
		<fo:block keep-with-next="always">
			<xsl:variable name="id">
				<xsl:call-template name="texGetID"/>
			</xsl:variable>
			<xsl:attribute name="id" select="$id"/>
			<xsl:variable name="config" select="$structure/*[@id = $id][1]"/>
			<xsl:call-template name="ApplyStyle">
				<xsl:with-param name="style">
					<xsl:value-of select="$config/@style"/>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="$config/@num">
				<xsl:value-of select="$config/@num"/>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:apply-templates select="tex:head" mode="section" />
		</fo:block>
	</xsl:template>
	
	<xsl:template match="tex:head" mode="section">
		<fo:inline>
			<xsl:if test="@id">
				<xsl:attribute name="id" select="translate(@id,'_','-')" />
			</xsl:if>
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	

<!-- Standard elements -->

	<xsl:template match="tex:float">
		<fo:block>
			<xsl:if test="@rend='landscape'">
				<xsl:attribute name="reference-direction">-90</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="texAddID" />
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template match="tex:head">
		<xsl:variable name="parent" select="name(..)"/>
		<xsl:if test="not(starts-with($parent,'tex:div')) and not($parent = 'tex:module')"> 
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="tex:caption">
		<fo:block>
			<xsl:call-template name="texCaptionStyle"/>
			<xsl:choose>
				<xsl:when test="ancestor::tex:float[@type = 'figure']">
					<xsl:call-template name="texFigureNumber"/>
				</xsl:when>
				<xsl:when test="ancestor::tex:float[@type = 'table']">
					<xsl:call-template name="texTableNumber"/>
				</xsl:when>
			</xsl:choose>
			<xsl:apply-templates/>
		</fo:block>
	</xsl:template>
	
	<xsl:template name="texCaptionStyle">
		<xsl:attribute name="text-align" select="$texCaptionAlign"/>
		<xsl:attribute name="font-style" select="$texCaptionFontStyle"/>
		<xsl:attribute name="font-weight" select="$texCaptionFontWeight"/>
		<xsl:attribute name="space-before" select="$texCaptionSpaceAbove"/>
		<xsl:attribute name="space-after" select="$texCaptionSpaceBelow"/>
	</xsl:template>

	<xsl:template match="tex:p">
		<fo:block font-size="{$default-font-size}">
			<xsl:choose>
				<xsl:when test="preceding-sibling::tex:p">
					<xsl:if test="not(@noindent='true')">
						<xsl:attribute name="text-indent" select="$texParaIdent" />
					</xsl:if>
					<xsl:choose>
						<xsl:when test="@spacebefore">
							<xsl:attribute name="space-before.optimum" select="@spacebefore"/>
						</xsl:when>
						<xsl:when test="ancestor::tex:pseudocode">
							<xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="space-before.optimum" select="$texParaSkip" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:attribute name="space-before.maximum" select="$texParaSkipMax" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="@spacebefore">
						<xsl:attribute name="space-before.optimum" select="@spacebefore" />
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="@rend ='centered'">
					<xsl:attribute name="text-align">center</xsl:attribute>
				</xsl:when>
				<xsl:when test="@rend ='center'">
					<xsl:attribute name="text-align">center</xsl:attribute>
				</xsl:when>
				<xsl:when test="@rend ='flushed-left'">
					<xsl:attribute name="text-align">left</xsl:attribute>
				</xsl:when>
				<xsl:when test="@rend ='flushed-right'">
					<xsl:attribute name="text-align">right</xsl:attribute>
				</xsl:when>
				<xsl:when test="@rend ='quoted'">
					<xsl:attribute name="text-align">justify</xsl:attribute>
					<xsl:attribute name="margin-left">1cm</xsl:attribute>
					<xsl:attribute name="margin-right">1cm</xsl:attribute>
				</xsl:when>
				<xsl:when test="@rend ='justify'">
					<xsl:attribute name="text-align">justify</xsl:attribute>
			    </xsl:when>
			</xsl:choose>
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<xsl:template match="tex:pre/tex:p"> <!-- paragraph in verbatim mode -->
		<fo:block font-size="{$default-font-size}">
			<xsl:if test="not(preceding-sibling::tex:p)">
				<xsl:attribute name="space-before" select="$texParaSkip" />
			</xsl:if>
			<xsl:if test="not(following-sibling::tex:p)">
				<xsl:attribute name="space-after" select="$texParaSkip" />
			</xsl:if>
			<xsl:if test="parent::tex:pre/@class='latex-code'">
				<xsl:attribute name="color">maroon</xsl:attribute>
			</xsl:if>
			<xsl:if test="parent::tex:pre/@class='xml-code'">
				<xsl:attribute name="color">#4422FF</xsl:attribute>
			</xsl:if>
			<xsl:if test="tex:vbnumber">
				<xsl:attribute name="text-indent">-2em</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates />
		</fo:block>
	</xsl:template>
	
	<xsl:template match="tex:inline">
		<fo:inline>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	<xsl:template match="tex:hi">
		<fo:inline>
			<xsl:call-template name="texColor" />
			<xsl:call-template name="texRend" />
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>
	
	<xsl:template name="texColor">
		<xsl:if test="@color">
			<xsl:variable name="colorDef" select="ancestor::tex:std/tex:colorpool/tex:color[@id = current()/@color]" />
			<xsl:choose>
				<xsl:when test="$colorDef/@name">
					<xsl:attribute name="color" select="$colorDef/@name"/>
				</xsl:when>
				<!-- <xsl:when test="$colorDef/@model = 'rgb'">
					<xsl:attribute name="color" select="fn:concat('rgb(',$colorDef/@value,')')"/>
				</xsl:when> TODO: rgb value must be scaled up 0-1 to 0-255 -->
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="texRend">
		<xsl:choose>
			<xsl:when test="@rend='overline'">
				<xsl:attribute name="text-decoration">overline</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='underline'">
				<xsl:attribute name="text-decoration">underline</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='oldstyle'">
				<xsl:attribute name="font-family">Concrete</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='sub'">
				<xsl:attribute name="vertical-align">sub</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='sup'">
				<xsl:attribute name="vertical-align">super</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='it'">
				<xsl:attribute name="font-style">italic</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='slanted'">
				<xsl:attribute name="font-style">italic</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='sc'">
				<xsl:attribute name="font-variant">small-caps</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='tt'">
				<xsl:attribute name="font-family">Computer-Modern-Typewriter</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='sansserif'">
				<xsl:attribute name="font-family">sansserif</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='bold'">
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='ul'">
				<xsl:attribute name="text-decoration">ul</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='caps'">
				<xsl:attribute name="text-decoration">caps</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='hl'">
				<xsl:attribute name="text-decoration">hl</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='so'">
				<xsl:attribute name="text-decoration">so</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='st'">
				<xsl:attribute name="text-decoration">st</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='small'">
				<xsl:attribute name="font-size">8pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='small1'">
				<xsl:attribute name="font-size">9pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='small2'">
				<xsl:attribute name="font-size">8pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='small3'">
				<xsl:attribute name="font-size">7pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='small4'">
				<xsl:attribute name="font-size">5pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='large'">
				<xsl:attribute name="font-size">12pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='large1'">
				<xsl:attribute name="font-size">12pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='large2'">
				<xsl:attribute name="font-size">14pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='large3'">
				<xsl:attribute name="font-size">17pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='large4'">
				<xsl:attribute name="font-size">20pt</xsl:attribute>
			</xsl:when>
			<xsl:when test="@rend='large5'">
				<xsl:attribute name="font-size">25pt</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="font-weight">bold</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tex:vbnumber">
		<fo:inline font-size="9pt">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<xsl:template match="tex:latexcode">
		<fo:inline font-family="{$texCodeFont}" color="maroon">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<xsl:template match="tex:xmlcode">
		<fo:inline font-family="{$texCodeFont}" color="4422FF">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<xsl:template match="tex:code">
		<fo:inline font-family="{$texCodeFont}">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<xsl:template match="tex:ident">
		<fo:inline color="{$texIdentColor}" font-family="{$texIdentFont}">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>

	<xsl:template match="tex:term">
		<fo:inline font-style="italic">
			<xsl:apply-templates />
		</fo:inline>
	</xsl:template>



<!-- Links -->

	<xsl:template match="tex:ref">
		<fo:basic-link color="{$texLinkColor}">
			<xsl:attribute name="internal-destination" select="fn:concat(fn:count(preceding::syd:comment),'-',fn:translate(@target,'_','-'))" />
			<xsl:apply-templates />
		</fo:basic-link>
	</xsl:template>
	
	<xsl:template match="tex:xref">
		<fo:basic-link color="{$texLinkColor}" external-destination="{@url}">
			<xsl:apply-templates />
		</fo:basic-link>
	</xsl:template>
	
	<xsl:template match="tex:hyperlink">
		<fo:basic-link color="{$texLinkColor}" internal-destination="{@href}">
			<xsl:value-of select="."/>
		</fo:basic-link>
	</xsl:template>



<!-- Lists -->

	<xsl:template match="tex:list">
		<xsl:if test="child::tex:head">
			<fo:block font-style="italic" text-align="start" space-before.optimum="4pt">
				<xsl:apply-templates select="tex:head" />
			</fo:block>
		</xsl:if>
		<fo:list-block margin-right="{$texListRightMargin}">
			<xsl:call-template name="texSetListIndents" />
			<xsl:choose>
				<xsl:when test="@type='gloss'">
					<xsl:attribute name="margin-left">
						<xsl:choose>
							<xsl:when test="ancestor::tex:list">
								<xsl:value-of select="$texListLeftGlossInnerIndent" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$texListLeftGlossIndent" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="margin-left">
						<xsl:value-of select="$texListLeftIndent" />
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="tex:item" />
		</fo:list-block>
	</xsl:template>

	<xsl:template name="texSetListIndents">
		<xsl:variable name="listdepth" select="fn:count(ancestor::tex:list)" />
		<xsl:choose>
			<xsl:when test="$listdepth=0">
				<xsl:attribute name="space-before">
					<xsl:value-of select="$texListAbove-1" />
				</xsl:attribute>
				<xsl:attribute name="space-after">
					<xsl:value-of select="$texListBelow-1" />
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$listdepth=1">
				<xsl:attribute name="space-before">
					<xsl:value-of select="$texListAbove-2" />
				</xsl:attribute>
				<xsl:attribute name="space-after">
					<xsl:value-of select="$texListBelow-2" />
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$listdepth=2">
				<xsl:attribute name="space-before">
					<xsl:value-of select="$texListAbove-3" />
				</xsl:attribute>
				<xsl:attribute name="space-after">
					<xsl:value-of select="$texListBelow-3" />
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="$listdepth=3">
				<xsl:attribute name="space-before">
					<xsl:value-of select="$texListAbove-4" />
				</xsl:attribute>
				<xsl:attribute name="space-after">
					<xsl:value-of select="$texListBelow-4" />
				</xsl:attribute>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tex:item">
		<xsl:call-template name="texMakeItem" />
	</xsl:template>
	
	<xsl:template match="tex:item" mode="xref">
		<xsl:variable name="listdepth" select="fn:count(ancestor::tex:list)" />
		<xsl:variable name="listNFormat">
			<xsl:choose>
				<xsl:when test="$listdepth=1">
					<xsl:text>1</xsl:text>
				</xsl:when>
				<xsl:when test="$listdepth=2">
					<xsl:text>i</xsl:text>
				</xsl:when>
				<xsl:when test="$listdepth=3">
					<xsl:text>a</xsl:text>
				</xsl:when>
				<xsl:when test="$listdepth=4">
					<xsl:text>I</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:number format="{$listNFormat}" />
	</xsl:template>

	<xsl:template name="texMakeItem">
		<xsl:variable name="listdepth" select="fn:count(ancestor::tex:list)" />
		<fo:list-item space-before.optimum="{$texListItemsep}">
			<fo:list-item-label end-indent="label-end()">
				<xsl:if test="@id">
					<xsl:attribute name="id" select="fn:concat(fn:count(preceding::syd:comment),'-',@id)" />
				</xsl:if>
				<fo:block>
					<xsl:attribute name="margin-right">2.5pt</xsl:attribute>
					<xsl:choose>
						<xsl:when test="../@type='ordered'">
							<xsl:attribute name="text-align">end</xsl:attribute>
							<xsl:apply-templates mode="xref" select="." />
							<xsl:text>.</xsl:text>
						</xsl:when>
						<xsl:when test="../@type='gloss'">
							<xsl:attribute name="text-align">start</xsl:attribute>
							<xsl:attribute name="font-weight">bold</xsl:attribute>
							<xsl:choose>
								<xsl:when test="tex:label">
									<xsl:apply-templates mode="print" select="tex:label" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates mode="print" select="preceding-sibling::*[1]" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:when test="name(preceding-sibling::*[1])='tex:label'">
							<xsl:apply-templates mode="print" select="preceding-sibling::*[1]" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="text-align">center</xsl:attribute>
							<xsl:choose>
								<xsl:when test="$listdepth=1">
									<xsl:value-of select="$texBulletOne" />
								</xsl:when>
								<xsl:when test="$listdepth=2">
									<xsl:value-of select="$texBulletTwo" />
								</xsl:when>
								<xsl:when test="$listdepth=3">
									<xsl:value-of select="$texBulletThree" />
								</xsl:when>
								<xsl:when test="$listdepth=4">
									<xsl:value-of select="$texBulletFour" />
								</xsl:when>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</fo:list-item-label>
			<fo:list-item-body start-indent="body-start()">
				<xsl:choose>
					<xsl:when test="tex:p">
						<xsl:apply-templates />
					</xsl:when>
					<xsl:otherwise>
						<fo:block font-weight="normal">
							<xsl:apply-templates />
						</fo:block>
					</xsl:otherwise>
				</xsl:choose>
			</fo:list-item-body>
		</fo:list-item>
	</xsl:template>

	<xsl:template match="tex:label" mode="print">
		<xsl:apply-templates />
	</xsl:template>



<!-- Figures -->

	<xsl:template match="tex:figure[@rend='inline']">
		<xsl:call-template name='texFigure' />
		<xsl:apply-templates/>
	</xsl:template>

	<xsl:template match='tex:figure'>
		<fo:block text-align="{$texFigTabAlign}">
			<xsl:call-template name="texAddID" />
			<xsl:choose>
				<xsl:when test="@file">
					<xsl:call-template name='texFigure' />
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</fo:block>
	</xsl:template>
	
	<xsl:template name="texFigure">
		<fo:external-graphic>
			<xsl:attribute name="src"><xsl:value-of select="fn:concat($texFigureDir,'/',@file,'.',@extension)"/></xsl:attribute>
			<xsl:choose>
				<xsl:when test="@scale">
					<xsl:attribute name="content-width">
						<xsl:value-of select="@scale * 100" /><xsl:text>%</xsl:text>
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="@width">
					<xsl:attribute name="content-width">
						<xsl:value-of select="@width" />
					</xsl:attribute>
					<xsl:if test="@height">
						<xsl:attribute name="content-height">
							<xsl:value-of select="@height" />
						</xsl:attribute>
					</xsl:if>
					<xsl:if test="@angle">
						<xsl:attribute name="angle">
							<xsl:value-of select="@angle" />
						</xsl:attribute>
					</xsl:if>
				</xsl:when>
				<xsl:when test="@height">
					<xsl:attribute name="content-height">
						<xsl:value-of select="@height" />
					</xsl:attribute>
					<xsl:if test="@angle">
						<xsl:attribute name="angle">
							<xsl:value-of select="@angle" />
						</xsl:attribute>
					</xsl:if>
				</xsl:when>
			</xsl:choose>
		</fo:external-graphic>
	</xsl:template>
	
	<xsl:template name="texFigureNumber">
		<xsl:value-of select="$texFigureWord" />
		<xsl:value-of select="fn:count(preceding::figure[@rend != 'inline']) + fn:count(preceding::tex:float[@type = 'figure']) + 1" />
		<xsl:text>: </xsl:text>
	</xsl:template>


<!-- Tables -->

	<xsl:template match="tex:table">
		<xsl:choose>
			<xsl:when test="@rend='inline'">
				<xsl:call-template name="texTableBlock" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="texTableFloat" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="texTableBlock">
		<fo:table text-align="{$texFigTabAlign}">
			<xsl:call-template name="texAddID" />
			<xsl:call-template name="texTableCols" />
			<fo:table-body text-indent="0pt">
				<xsl:for-each select="tex:row">
					<fo:table-row>
						<xsl:apply-templates select="tex:cell" />
					</fo:table-row>
				</xsl:for-each>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	<xsl:template name="texTableFloat">
		<fo:block>
			<xsl:if test="@rend='landscape'">
				<xsl:attribute name="reference-direction">-90</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="texAddID" />
			<xsl:call-template name="texTableBlock" />
			<fo:block>
				<xsl:call-template name="texCaptionStyle"/>
				<xsl:call-template name="texTableNumber"/>
				<xsl:apply-templates select="tex:head" />
			</fo:block>
		</fo:block>
	</xsl:template>

	<xsl:template name="texTableCols">
		<xsl:variable name="tds">
			<xsl:for-each select=".//tex:cell">
				<xsl:variable name="stuff">
					<xsl:apply-templates />
				</xsl:variable>
				<cell>
					<xsl:attribute name="col"><xsl:number /></xsl:attribute>
					<xsl:value-of select="string-length($stuff) + 100" />
				</cell>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="total">
			<xsl:value-of select="sum(exsl:node-set($tds)/tex:cell)" />
		</xsl:variable>
		<xsl:for-each select="exsl:node-set($tds)/tex:cell">
			<xsl:sort select="@col" data-type="number" />
			<xsl:variable name="c" select="@col" />
			<xsl:if test="not(preceding-sibling::tex:cell[$c=@col])">
				<xsl:variable name="len">
					<xsl:value-of select="sum(following-sibling::tex:cell[$c=@col]) + current()" />
				</xsl:variable>
				<fo:table-column column-number="{@col}" column-width="{$len div $total * 100}%" />
			</xsl:if>
		</xsl:for-each>
		<xsl:text>
	  </xsl:text>
	</xsl:template>
	
	<xsl:template match="tex:cell">
		<fo:table-cell>
			<xsl:if test="@cols &gt; 1">
				<xsl:attribute name="number-columns-spanned">
					<xsl:value-of select="@cols" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="@rows &gt; 1">
				<xsl:attribute name="number-rows-spanned">
					<xsl:value-of select="@rows" />
				</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="texTableCellProps" />
			<fo:block>
				<xsl:choose>
					<xsl:when test="@role='label' or parent::tex:row[@role='label']">
						<xsl:attribute name="font-weight">bold</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:apply-templates />
			</fo:block>
		</fo:table-cell>
	</xsl:template>
	
	<xsl:template name="texTableCellProps" >
		<xsl:if test="@role='hi'">
			<xsl:attribute name="background-color">silver</xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="ancestor::tex:table[1][@rend='frame']">
				<xsl:if test="not(parent::tex:row/preceding-sibling::tex:row)">
					<xsl:attribute name="border-before-style">solid</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="border-after-style">solid</xsl:attribute>
				<xsl:if test="not(following-sibling::tex:cell)">
					<xsl:attribute name="border-end-style">solid</xsl:attribute>
				</xsl:if>
				<xsl:attribute name="border-start-style">solid</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="@left-border='true'">
					<xsl:attribute name="border-start-style">solid</xsl:attribute>
				</xsl:if>
				<xsl:if test="@right-border='true'">
					<xsl:attribute name="border-end-style">solid</xsl:attribute>
				</xsl:if>
				<xsl:if test="ancestor::tex:row/@top-border='true'">
					<xsl:attribute name="border-before-style">solid</xsl:attribute>
				</xsl:if>
				<xsl:if test="ancestor::tex:row/@bottom-border='true'">
					<xsl:attribute name="border-after-style">solid</xsl:attribute>
				</xsl:if>
				<xsl:if test="@bottom-border='true'">
					<xsl:attribute name="border-after-style">solid</xsl:attribute>
				</xsl:if>
				<xsl:if test="@top-border='true'">
					<xsl:attribute name="border-before-style">solid</xsl:attribute>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="not(ancestor::tex:table/@rend='tight')">
			<xsl:attribute name="padding">2</xsl:attribute>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="@halign">
				<xsl:attribute name="text-align">
					<xsl:value-of select="@halign" />
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="text-align">left</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="texTableNumber">
		<xsl:value-of select="$texTableWord" />
		<xsl:value-of select="fn:count(preceding::table[@rend != 'inline']) + fn:count(preceding::tex:float[@type = 'table']) + 1" />
		<xsl:text>: </xsl:text>
	</xsl:template>



<!-- Math -->

	<xsl:template match="tex:math">
		<fo:instream-foreign-object>
			<m:math>
				<xsl:copy-of select="@*" />
				<xsl:apply-templates mode="copymath" />
			</m:math>
		</fo:instream-foreign-object>
	</xsl:template>
	
	<xsl:template match="*" mode="copymath">
		<xsl:element name="{fn:concat('m:',local-name())}">
			<xsl:copy-of select="@*" />
			<xsl:apply-templates mode="copymath"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="tex:formula">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="tex:formula[@type='display']">
		<xsl:choose>
			<xsl:when test="@id">
				<fo:block id="{fn:concat(fn:count(preceding::syd:comment),'-',@id)}" padding-top="{$texParaSkip}" text-align="center">
					<xsl:apply-templates select="tex:math"/>
				</fo:block>
			</xsl:when>
			<xsl:when test="@tag">
				<fo:block padding-top="{$texParaSkip}" text-align="center">
					<xsl:apply-templates select="tex:math"/>
				</fo:block>
			</xsl:when>
			<xsl:otherwise>
				<fo:block padding-top="{$texParaSkip}" text-align="center">
					<xsl:apply-templates select="tex:math"/>
				</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="tex:simplemath">
		<m:math>
			<m:mi>
				<xsl:apply-templates mode="copymath"/>
			</m:mi>
		</m:math>
	</xsl:template>



<!-- Other elements -->
	
	<xsl:template match="tex:newpage">
		<fo:block break-after="page" />
	</xsl:template>
	
	<xsl:template match="tex:error">
		<fo:inline color="red">
			<fo:inline font-weight="bold">
				<xsl:text>LaTeX error on line</xsl:text>
				<xsl:value-of select="@l"/>
				<xsl:text>: </xsl:text>
			</fo:inline>
			<xsl:value-of select="@n"/>
			<xsl:text> -- </xsl:text>
			<xsl:value-of select="@c"/>
		</fo:inline>
	</xsl:template>
	

	<xsl:template match="tex:zws">
		<xsl:text>&#x200B;</xsl:text>
	</xsl:template>
	
	<xsl:template name="texAddID">
		<xsl:attribute name="id">
			<xsl:call-template name="texGetID"/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template name="texGetID">
		<xsl:choose>
			<xsl:when test="@id">
				<xsl:value-of select="fn:concat(fn:count(preceding::syd:comment),'-',fn:translate(@id,'_','-'))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="fn:generate-id()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
