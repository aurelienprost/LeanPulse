<?xml version="1.0" encoding="UTF-8"?>

<!-- =================================================================

This stylesheet implements the default SyD document layout and formatting.
It can be imported in another stylesheet in order to override some of the
templates and modify the styling or some pages of the output document.

Copyright (c) 2014 LeanPulse. All rights reserved.

Author: Aurélien PROST (a.prost@leanpulse.com)


======================================================================
					!!!! DEVELOPER NOTES !!!!
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

NEVER EDIT THIS FILE !
ALL MODIFICATIONS MUST BE DONE IN <template.xsl>.

This stylesheet has been designed to define parameters and templates
that can be separately overridden to modify specific parts of the output
document.

To update a given template, the default implementation found here can be
copied in <template.xsl> and modified in this last file.

================================================================== -->

<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:fox="http://xmlgraphics.apache.org/fop/extensions"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:syd="http://www.leanpulse.com/schemas/syd/2011/core"
	exclude-result-prefixes="xsl fn syd"
	version="1.0">
	
	<xsl:output method="xml" version="1.0" indent="no" encoding="UTF-8" />
	
	
	<!-- Include utility named templates and functions. -->
	<xsl:include href="utils.xsl" />
	
	
	
	<!-- ==========================================================================================
										Transformation Parameters
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	The following parameters can be overridden in the parent stylesheet or in the profiles definition
	file <sydProfiles.xml>.
	The context parameters are automatically provided by SyD when invoking the transformation.
	=========================================================================================== -->
	
	<!-- Page format -->
	<xsl:param name="pageheight" select="297"/>
	<xsl:param name="pagewidth" select="210"/>
	<xsl:param name="pageheaderheight" select="12"/>
	<xsl:param name="pagefooterheight" select="11"/>
	<xsl:param name="pagemargintop" select="5"/>
	<xsl:param name="pagemarginbottom" select="5"/>
	<xsl:param name="pagemarginleft" select="10"/>
	<xsl:param name="pagemarginright" select="10"/>
	
	<!-- Font parameters -->
	<xsl:param name="default-font-family" select="'Arial, Helvetica'" />
	<xsl:param name="default-font-size" select="10" />
	<xsl:param name="dico-font-size-prop" select="'70%'" />
	
	<!-- Security parameter -->
	<xsl:param name="security" select="-1"/>
	
	<!-- Context parameters -->
	<xsl:param name="resourcespath" />
	<xsl:param name="currentdate" select="'01/01/1900'"/>
	
	<!-- Parameter to enable tiled printing -->
	<xsl:param name="printtiles" select="'false'" />
	
	<!-- Parameter to disable the print of bus signals usage tables in subsystems  -->
	<xsl:param name="disablebussignalsusage" select="'false'" />
	
	
	<!-- ==========================================================================================
											Document Styles
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	The templates below defines the styles used for the various titles and sections of the output
	document.
	They can be overridden in the parent stylesheet to modify the default styling implemented here.
	=========================================================================================== -->
	
	<!-- TitlePage styling -->
	<xsl:template name="StyleTitlePage">
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="font-size">133%</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="space-after">10mm</xsl:attribute>
	</xsl:template>
	
	<!-- Title0 styling -->
	<xsl:template name="StyleTitle0">
		<xsl:attribute name="font-size">133%</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="space-before">5mm</xsl:attribute>
		<xsl:attribute name="space-after">5mm</xsl:attribute>
	</xsl:template>
	
	<!-- Title1 styling -->
	<xsl:template name="StyleTitle1">
		<xsl:attribute name="font-size">120%</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="space-before">5mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
	</xsl:template>
	
	<!-- Title2 styling -->
	<xsl:template name="StyleTitle2">
		<xsl:attribute name="font-size">110%</xsl:attribute>
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="space-before">5mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
	</xsl:template>
	
	<!-- Paragraph styling -->
	<xsl:template name="StyleParagraph">
		<xsl:attribute name="space-before">3mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
		<xsl:attribute name="space-after.minimum">0mm</xsl:attribute>
	</xsl:template>
	
	<!-- Snapshot styling -->
	<xsl:template name="StyleSnapshot">
		<xsl:attribute name="text-align">center</xsl:attribute>
		<xsl:attribute name="space-before">3mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
		<xsl:attribute name="space-after.minimum">0mm</xsl:attribute>
	</xsl:template>
	
	<!-- Truthtable styling -->
	<xsl:template name="StyleTruthtable">
		<xsl:attribute name="space-before">3mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
		<xsl:attribute name="space-after.minimum">0mm</xsl:attribute>
	</xsl:template>
	
	<!-- MFunction styling -->
	<xsl:template name="StyleMFunction">
		<xsl:attribute name="border">1pt solid #000000</xsl:attribute>
		<xsl:attribute name="padding">3.5pt</xsl:attribute>
		<xsl:attribute name="space-before">3mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
		<xsl:attribute name="space-after.minimum">0mm</xsl:attribute>
	</xsl:template>
	
	<!-- TransitionMatrix styling -->
	<xsl:template name="StyleTransitionMatrix">
		<xsl:attribute name="space-before">3mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
		<xsl:attribute name="space-after.minimum">0mm</xsl:attribute>
	</xsl:template>
	
	<!-- DictionaryTable styling -->
	<xsl:template name="StyleDictionaryTable">
		<xsl:attribute name="space-before">3mm</xsl:attribute>
		<xsl:attribute name="space-after">3mm</xsl:attribute>
		<xsl:attribute name="space-after.minimum">0mm</xsl:attribute>
	</xsl:template>
	
	<!-- Table of content title1 reference styling -->
	<xsl:template name="StyleTocTitle0">
		<xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="space-before">2mm</xsl:attribute>
	</xsl:template>
	
	<!-- Table of content title2 reference styling -->
	<xsl:template name="StyleTocTitle1"/>
	
	
	
	<!-- ==========================================================================================
										Document Structure
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	The code below initializes a variable "structure" that defines the structure of	the output
	document.
	The result tree fragment contained in this variable indeed controls the sequence of named
	templates to be called to build the XSL-FO document. The name of each node corresponds to the
	name of the template to call and while applying the template, the configuration node will be
	passed as parameter to retrieve its attributes if necessary.
	Another advantage of holding the structure of the document inside a variable is that it can
	then be directly reused to generate the bookmarks tree and the table of content in the document
	rather than having to recompute them from the input XML file.
	The "structure" variable definition might be overridden in the parent stylesheet to modify the
	content of the output document.
	=========================================================================================== -->
	
	<!-- Maximum width and height for the content of pages -->
	<xsl:variable name="maxwidth" select="$pagewidth - $pagemarginleft - $pagemarginright - 2"/>
	<xsl:variable name="maxheight" select="$pageheight - $pagemargintop - $pageheaderheight - $pagefooterheight - $pagemarginbottom - 18"/>
	
	<!-- Variable holding the structure of the output document -->
	<xsl:variable name="structure">
		<xsl:for-each select="/syd:model | /syd:system">
			<PageFront id="_front" tocstyle="StyleTocTitle0" level="0">
				<xsl:choose>
					<xsl:when test="not(syd:extradata)">
						<xsl:attribute name="title" select="@id"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="title" select="syd:extradata/@title"/>
					</xsl:otherwise>
				</xsl:choose>
			</PageFront>
			<AddTitle id="_history" title="Document history" style="StyleTitlePage" break="page" tocstyle="StyleTocTitle0" level="1"/>
			<ContentHistory/>
			<AddTitle id="_toc" title="Contents" style="StyleTitlePage" break="page"/>
			<ContentTOC/>
			<AddTitle id="_geninfo" title="General information" num="{syd:calcTitleNum(1)}" style="StyleTitle0" break="page" tocstyle="StyleTocTitle0" level="1"/>
				<xsl:call-template name="LoopComments">
					<xsl:with-param name="level" select="1"/>
				</xsl:call-template>
			<AddTitle id="_fundes" title="Functional description" num="{syd:calcTitleNum(1)}" style="StyleTitle0" break="page" tocstyle="StyleTocTitle0" level="1"/>
				<AddTitle id="{@id}" title="Top level overview" num="{syd:calcTitleNum(2)}" style="StyleTitle1" tocstyle="StyleTocTitle1" level="2"/>
				<xsl:if test="syd:reqinfos">
					<AddRequirementsTable id="{@id}" style="StyleParagraph"/>
				</xsl:if>
				<AddSnapshot id="{@id}" style="StyleSnapshot" maxwidth="{$maxwidth}"
					maxheight="{$maxheight - fn:ceiling($default-font-size * 1.4281)}"/> <!-- 1.4281 = (1.33 + 1.1) * 1.6 * 25.4 div 72 -->
				<xsl:call-template name="LoopSystems">
					<xsl:with-param name="level" select="2"/>
				</xsl:call-template>
			<AddTitle id="_dico" title="Data dictionary" num="{syd:calcTitleNum(1)}" style="StyleTitle0" break="page" tocstyle="StyleTocTitle0" level="1"/>
				<AddTitle id="_dicosignals" title="Signals" num="{syd:calcTitleNum(2)}" style="StyleTitle1" level="2"/>
				<AddSignalsTable tpname="GetSignals" emptydes="No signals defined." style="StyleDictionaryTable"/>
				<AddTitle id="_dicoparameters" title="Parameters" num="{syd:calcTitleNum(2)}" style="StyleTitle1" level="2"/>
				<AddParametersTable tpname="GetParameters" emptydes="No parameters defined." style="StyleDictionaryTable"/>
				<xsl:variable name="lookupset">
					<xsl:call-template name="Get1DLookups"/>
					<xsl:call-template name="Get2DLookups"/>
				</xsl:variable>
				<xsl:if test="fn:count($lookupset/syd:lookup) > 0">
					<AddTitle id="_dicolookups" title="Lookup Tables" num="{syd:calcTitleNum(2)}" style="StyleTitle1" level="2"/>
					<AddTitle id="_dico1Dlookups" title="1D Lookup Tables" style="StyleTitle2"/>
					<Add1DLookupsTable tpname="Get1DLookups" emptydes="No 1D lookups." style="StyleDictionaryTable"/>
					<AddTitle id="_dico2Dlookups" title="2D Lookup Tables" style="StyleTitle2"/>
					<Add2DLookupsTable tpname="Get2DLookups" emptydes="No 2D lookups." style="StyleDictionaryTable"/>
				</xsl:if>
				<xsl:variable name="busset">
					<xsl:call-template name="GetBuses"/>
				</xsl:variable>
				<xsl:if test="fn:count($busset/syd:bus) > 0">
					<AddTitle id="_dicobuses" title="Buses" num="{syd:calcTitleNum(2)}" style="StyleTitle1" level="2"/>
					<AddBusesTable tpname="GetBuses" emptydes="No bus." style="StyleDictionaryTable"/>
				</xsl:if>
			<xsl:variable name="reqset">
				<xsl:call-template name="GetRequirements"/>
			</xsl:variable>
			<xsl:if test="fn:count($reqset/syd:req) > 0">
				<AddTitle id="_reqs" title="Requirements" num="{syd:calcTitleNum(1)}" style="StyleTitle0" break="page" tocstyle="StyleTocTitle0" level="1"/>
				<AddRequirementsTable tpname="GetRequirements" emptydes="No requirement." style="StyleDictionaryTable"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	
	<!-- Template to iterate over the sub-systems in order to compute the document structure -->
	<xsl:template name="LoopSystems">
		<xsl:param name="level"/>
		<xsl:param name="file" select="''"/>
		<xsl:for-each select="(syd:system | syd:chart | syd:modelref | syd:state | syd:box | syd:function | syd:truthtable | syd:mfunction | syd:tablechart | syd:tablestate)[not(syd:extradata/@security) or syd:extradata/@security &lt;= $security]">
			<xsl:choose>
				<xsl:when test="name(.)='syd:modelref'">
					<AddTitle id="{if(fn:exists(@system)) then @system else @file}" num="{syd:calcTitleNum($level)}" title="{syd:getSystemTitle(.)}" style="StyleTitle1" break="page" tocstyle="StyleTocTitle1" level="{$level}"/>
					<xsl:choose>
						<xsl:when test="$gendep='embed'">
							<xsl:variable name="refsystem" select="if(fn:exists(@system)) then syd:getNodeById(fn:root(),@file,@system,'syd:system') else fn:document(fn:concat($xmluri,'/',@file,'.xml'))/node()[fn:name() = 'syd:model' or fn:name() = 'syd:system']"/>
							<xsl:variable name="tmpfile" select="@file"/>
							<xsl:for-each select="$refsystem">
								<xsl:if test="syd:reqinfos">
									<AddRequirementsTable file="{$tmpfile}" id="{@id}" style="StyleParagraph"/>
								</xsl:if>
								<AddSnapshot file="{$tmpfile}" id="{@id}" style="StyleSnapshot" maxwidth="{$maxwidth}"
									maxheight="{$maxheight - fn:ceiling($default-font-size * 0.6774)}" /> <!-- 0.6774 = 1.2 * 1.6 * 25.4 div 72 -->
								<xsl:if test="$disablebussignalsusage='false'">
									<AddBusSignalsUsage id="{@id}" style="StyleParagraph"/>
								</xsl:if>
								<xsl:call-template name="LoopComments">
									<xsl:with-param name="level" select="$level"/>
									<xsl:with-param name="file" select="$tmpfile"/>
								</xsl:call-template>
								<xsl:call-template name="LoopSystems">
									<xsl:with-param name="level" select="$level + 1"/>
									<xsl:with-param name="file" select="$tmpfile"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							<xsl:if test="syd:reqinfos">
								<AddRequirementsTable file="{$file}" id="{@id}" style="StyleParagraph"/>
							</xsl:if>
							<AddModelReference file="{$file}" id="{@id}" style="StyleParagraph"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<AddTitle id="{@id}" num="{syd:calcTitleNum($level)}" title="{syd:getSystemTitle(.)}" style="StyleTitle1" break="page" tocstyle="StyleTocTitle1" level="{$level}"/>
					<xsl:if test="syd:reqinfos">
						<AddRequirementsTable file="{$file}" id="{@id}" style="StyleParagraph"/>
					</xsl:if>
					<xsl:choose>
						<xsl:when test="name(.)='syd:truthtable'">
							<AddTruthTable file="{$file}" id="{@id}" style="StyleTruthtable"/>
						</xsl:when>
						<xsl:when test="name(.)='syd:mfunction'">
							<AddMFunction file="{$file}" id="{@id}" style="StyleMFunction"/>
						</xsl:when>
						<xsl:otherwise>
							<AddSnapshot file="{$file}" id="{@id}" style="StyleSnapshot" maxwidth="{$maxwidth}"
									maxheight="{$maxheight - fn:ceiling($default-font-size * 0.6774)}" /> <!-- 0.6774 = 1.2 * 1.6 * 25.4 div 72 -->
							<xsl:if test="name(.)='syd:tablechart' or name(.)='syd:tablestate'">
								<xsl:for-each select="syd:transitionmatrix">
									<AddTransitionMatrix file="{$file}" id="{@id}" style="StyleTransitionMatrix"/>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="name(.)='syd:system' and $disablebussignalsusage='false'">
								<AddBusSignalsUsage id="{@id}" style="StyleParagraph"/>
							</xsl:if>
							<xsl:call-template name="LoopComments">
								<xsl:with-param name="level" select="$level"/>
								<xsl:with-param name="file" select="$file"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="LoopSystems">
				<xsl:with-param name="level" select="$level + 1"/>
				<xsl:with-param name="file" select="$file"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Template to loop over the comments in order to compute the document structure -->
	<xsl:template name="LoopComments">
		<xsl:param name="level"/>
		<xsl:param name="file" select="''"/>
		<xsl:for-each select="syd:comment[not(syd:extradata/@security) or syd:extradata/@security &lt;= $security]">
			<AddTitle style="StyleTitle2">
				<xsl:attribute name="id" select="@id"/>
				<xsl:attribute name="title">
					<xsl:number value="position()" format="a"/>
					<xsl:text>. </xsl:text>
					<xsl:value-of select="@name" />
				</xsl:attribute>
			</AddTitle>
			<AddComment file="{$file}" id="{@id}" style="StyleParagraph"/>
			<xsl:call-template name="ComputeCommentStructure"/>
		</xsl:for-each>
	</xsl:template>
	
	
	
	<!-- ==========================================================================================
											Root Template
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	The template below will match the root node of the input XML file. Thus, it is the starting
	point of the tranformation and defines the root	element of the output XSL-FO document.
	=========================================================================================== -->
	
	<!-- Root template -->
	<xsl:template match="/syd:model | /syd:system">
	
		<fo:root xmlns:fo="http://www.w3.org/1999/XSL/Format"
			xmlns:fox="http://xmlgraphics.apache.org/fop/extensions" xmlns:svg="http://www.w3.org/2000/svg">

			<!-- LAYOUT DEFINITION -->
			<xsl:call-template name="DocumentLayout" />
			
			<!-- DOCUMENT METADATA -->
			<xsl:call-template name="DocumentMetaData" />
			
			<!-- BOOKMARK TREE -->
			<fo:bookmark-tree>
				<xsl:call-template name="LoopBookmarkTree">
					<xsl:with-param name="structure" select="$structure/child::node()"/>
				</xsl:call-template>
			</fo:bookmark-tree>

			<fo:page-sequence master-reference="doc" font-family="{$default-font-family}" font-size="{concat($default-font-size,'pt')}">
			
				<!-- HEADER -->
				<fo:static-content flow-name="xsl-region-before">
					<xsl:call-template name="DocumentHeader" />
				</fo:static-content>
				
				<!-- FOOTNOTE SEPARATOR -->
				<fo:static-content flow-name="xsl-footnote-separator">
					<xsl:call-template name="DocumentFootnoteSeparator" />
				</fo:static-content>
				
				<!-- FOOTER -->
				<fo:static-content flow-name="xsl-region-after">
					<xsl:call-template name="DocumentFooter" />
				</fo:static-content>
				
				<fo:flow flow-name="xsl-region-body">
					
					<xsl:call-template name="ExecStructure">
						<xsl:with-param name="structure" select="$structure"/>
					</xsl:call-template>
					
					<fo:block id="last-page" line-height="0" />
				</fo:flow>
			</fo:page-sequence>
			
			<xsl:if test="$printtiles='true'">
				<xsl:call-template name="PrintTileSnapshots" />
			</xsl:if>
		</fo:root>
	</xsl:template>
	
	
	
	<!-- ==========================================================================================
									Document Initialization
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	The following templates perform different parts of the initialization of the output XSL-FO
	document.
	They might be individually overridden in the parent stylesheet to, for instance, modify the
	header of the document.
	=========================================================================================== -->
	
	<!-- Defines the layout of the document. -->
	<xsl:template name="DocumentLayout">
		<fo:layout-master-set>
			<fo:simple-page-master master-name="doc"
					page-height="{fn:concat($pageheight,'mm')}" page-width="{fn:concat($pagewidth,'mm')}"
					margin-top="{fn:concat($pagemargintop,'mm')}" margin-bottom="{fn:concat($pagemarginbottom,'mm')}"
					margin-left="{fn:concat($pagemarginleft,'mm')}" margin-right="{fn:concat($pagemarginright,'mm')}">
				<fo:region-body margin-top="{fn:concat($pageheaderheight + 5,'mm')}" margin-bottom="{fn:concat($pagefooterheight + 5,'mm')}" />
				<fo:region-before extent="{fn:concat($pageheaderheight,'mm')}" />
				<fo:region-after extent="{fn:concat($pagefooterheight,'mm')}" />
			</fo:simple-page-master>
			<xsl:if test="$printtiles='true'">
				<xsl:call-template name="AddTilePageMasters" />
			</xsl:if>
		</fo:layout-master-set>
	</xsl:template>
	
	<!-- Defines the metadata of the document. -->
	<xsl:template name="DocumentMetaData">
		<xsl:call-template name="AddDocumentMetaData">
			<xsl:with-param name="title">
				<xsl:choose>
					<xsl:when test="not(syd:extradata/@title)">
						<xsl:value-of select="substring-before(@id,'/')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="syd:extradata/@title" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="author" select="syd:extradata/syd:version[last()]/@author"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Computes the bookmark tree of the document. -->
	<xsl:template name="LoopBookmarkTree">
		<xsl:param name="structure"/>
		<xsl:param name="level" select="0"/>
		<xsl:for-each select="$structure">
			<xsl:if test="@level = $level">
				<fo:bookmark internal-destination="{@id}">
					<fo:bookmark-title>
						<xsl:if test="@num">
							<xsl:value-of select="@num"/>
							<xsl:choose>
								<xsl:when test="@sep">
									<xsl:value-of select="@sep"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:value-of select="@title"/>
					</fo:bookmark-title>
					<xsl:variable name="curpos" select="fn:position()"/>
					<xsl:variable name="nextsibling" select="following-sibling::node()[@level = $level]"/>
					<xsl:choose>
						<xsl:when test="$nextsibling">
							<xsl:variable name="posdiff" select="fn:count($nextsibling[1]/preceding-sibling::node()) - fn:count(preceding-sibling::node())"/>
							<xsl:if test="$posdiff > 1">
								<xsl:call-template name="LoopBookmarkTree">
									<xsl:with-param name="structure" select="$structure[$curpos &lt; fn:position() and fn:position() &lt; ($curpos + $posdiff)]"/>
									<xsl:with-param name="level" select="$level + 1"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="LoopBookmarkTree">
								<xsl:with-param name="structure" select="$structure[$curpos &lt; fn:position()]"/>
								<xsl:with-param name="level" select="$level + 1"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</fo:bookmark>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Defines the header for all pages. -->
	<xsl:template name="DocumentHeader">
		<fo:table border-bottom="1pt solid #000000" table-layout="fixed" width="100%" font-size="9pt">
			<fo:table-column column-width="40%" />
			<fo:table-column column-width="60%" />
			<fo:table-body>
				<fo:table-row>
					<fo:table-cell>
						<fo:block-container position="absolute">
							<fo:block>
								<fo:external-graphic scaling="uniform" content-height="6.35mm"> <!-- 6.35 = 9 * 2 * 25.4 div 72 -->
									<xsl:attribute name="src"><xsl:call-template name="GetCompanyLogoPath" /></xsl:attribute>
								</fo:external-graphic>
							</fo:block>
						</fo:block-container>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block text-align="end">
							<xsl:choose>
								<xsl:when test="not(syd:extradata/@ref)">
									Model <xsl:value-of select="@id" />
								</xsl:when>
								<xsl:otherwise>
									Reference <xsl:value-of select="syd:extradata/@ref" />
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block />
					</fo:table-cell>
					<fo:table-cell>
						<fo:block text-align="end">Version 
							<xsl:choose>
								<xsl:when test="not(syd:extradata/syd:version)">
									<xsl:value-of select="@mdlversion" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="syd:extradata/syd:version[last()]/@num" />
								</xsl:otherwise>
							</xsl:choose>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
				<fo:table-row>
					<fo:table-cell>
						<fo:block text-align="start">Engineering Department</fo:block>
					</fo:table-cell>
					<fo:table-cell>
						<fo:block text-align="end">
							Page <fo:page-number />/<fo:page-number-citation ref-id="last-page" />
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	<!-- Returns the path to the company logo. -->
	<xsl:template name="GetCompanyLogoPath">
		<xsl:value-of select="concat($resourcespath,'/company-logo.png')"/>
	</xsl:template>
	
	<!-- Defines the footnote separator for all pages. -->
	<xsl:template name="DocumentFootnoteSeparator">
		<fo:block>
			<fo:leader leader-pattern="rule" leader-length="40%" />
		</fo:block>
	</xsl:template>
	
	<!-- Defines the footer for all pages. -->
	<xsl:template name="DocumentFooter">
		<fo:block text-align="center" font-size="10.0pt">Confidential</fo:block>
		<fo:block text-align="center" font-size="7.0pt">All rights reserved. No part of this publication may be reproduced in any
			material form (including photocopying or storing in any medium by electronic means and whether or not transciently or
			incidentally for some other use of this publication) without the owner written permission. - Generated by LeanPulse SyD</fo:block>
	</xsl:template>
	
	
	
	<!-- ==========================================================================================
										Document Content
	- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	The following named templates implement the generation of the content of various parts of the
	output document.
	They might be individually overridden in the parent stylesheet to, for instance, modify the
	output document front page.
	=========================================================================================== -->
	
	<!-- Defines the front page. -->
	<xsl:template name="PageFront">
		<xsl:param name="config"/>
		<fox:destination internal-destination="{$config/@id}" />
		
		<fo:table id="{$config/@id}" table-layout="fixed" width="100%">
			<fo:table-column column-width="100%" />
			<fo:table-body>
				<fo:table-row>
					<xsl:attribute name="height" select="concat($maxheight,'mm')" />
					<fo:table-cell display-align="center">
						<fo:table table-layout="fixed" width="100%" margin-bottom="{concat($maxheight div 10,'mm')}">
							<fo:table-column column-width="10%" />
							<fo:table-column column-width="80%" />
							<fo:table-column column-width="10%" />
							<fo:table-body text-align="center">
								<fo:table-row>
									<fo:table-cell><fo:block/></fo:table-cell>
									<fo:table-cell display-align="center">
										<fo:block font-size="200%" padding="4pt" border="2pt solid #000000" margin-bottom="10mm">
											<xsl:value-of select="$config/@title"/>
										</fo:block>
										<xsl:if test="syd:extradata">
											<fo:block font-size="150%" margin-bottom="10mm">
												<xsl:text>Version </xsl:text>
												<xsl:value-of select="syd:extradata/syd:version[last()]/@num" />
											</fo:block>
											<fo:block font-size="133%" font-style="italic">
												<xsl:value-of select="syd:extradata/@owner"/>
											</fo:block>
										</xsl:if>
									</fo:table-cell>
									<fo:table-cell><fo:block/></fo:table-cell>
								</fo:table-row>
							</fo:table-body>
						</fo:table>
						<fo:block font-size="110%" margin-left="5mm" margin-right="5mm">
							<fo:block margin-bottom="5mm">
								<fo:inline text-decoration="underline">Date</fo:inline>
								<xsl:value-of select="concat(': ',$currentdate)" />
							</fo:block>
							<xsl:if test="syd:extradata/syd:version[last()]">
								<fo:block margin-bottom="5mm">
									<fo:inline text-decoration="underline">Author</fo:inline>
									<xsl:text>: </xsl:text>
									<xsl:value-of select="syd:extradata/syd:version[last()]/@author" />
								</fo:block>
								<fo:block>
									<fo:inline text-decoration="underline">Version description</fo:inline>
									<xsl:text>: </xsl:text>
									<fo:block font-size="90%" margin-left="10mm">
										<xsl:value-of select="syd:extradata/syd:version[last()]/text()" />
									</fo:block>
								</fo:block>
							</xsl:if>
						</fo:block>
					</fo:table-cell>
				</fo:table-row>
			</fo:table-body>
		</fo:table>
	</xsl:template>
	
	<!-- Defines the history. -->
	<xsl:template name="ContentHistory">
		<xsl:param name="config"/>
		<xsl:variable name="versionset" select="syd:extradata/syd:version"/>
		<xsl:choose>
			<xsl:when test="fn:count($versionset) > 0">
				<fo:table border="1pt solid #000000" table-layout="fixed" width="100%">
					<fo:table-column column-width="5%" />
					<fo:table-column column-width="15%" />
					<fo:table-column column-width="20%" />
					<fo:table-column column-width="60%" />
					<fo:table-header border="1pt solid #000000">
						<fo:table-row>
							<fo:table-cell border-right="1pt solid #000000">
								<fo:block margin="3.5pt" font-weight="bold">Ver</fo:block>
							</fo:table-cell>
							<fo:table-cell border-right="1pt solid #000000">
								<fo:block margin="3.5pt" font-weight="bold">Date</fo:block>
							</fo:table-cell>
							<fo:table-cell border-right="1pt solid #000000">
								<fo:block margin="3.5pt" font-weight="bold">Author</fo:block>
							</fo:table-cell>
							<fo:table-cell>
								<fo:block margin="3.5pt" font-weight="bold">Comments</fo:block>
							</fo:table-cell>
						</fo:table-row>
					</fo:table-header>
					<fo:table-body>
						<xsl:for-each select="$versionset">
							<xsl:sort select="position()" data-type="number" order="descending"/>
							<fo:table-row border-color="black" border-style="solid" border-width="0.5pt">
								<fo:table-cell border-right="1pt solid #000000">
									<fo:block margin="3.5pt"><xsl:value-of select="@num" /></fo:block>
								</fo:table-cell>
								<fo:table-cell border-right="1pt solid #000000">
									<fo:block margin="3.5pt"><xsl:value-of select="@date" /></fo:block>
								</fo:table-cell>
								<fo:table-cell border-right="1pt solid #000000">
									<fo:block margin="3.5pt"><xsl:value-of select="@author" /></fo:block>
								</fo:table-cell>
								<fo:table-cell linefeed-treatment="preserve" white-space-collapse="false" white-space-treatment="ignore-if-surrounding-linefeed" wrap-option="wrap">
									<fo:block margin="3.5pt"><xsl:value-of select="text()" /></fo:block>
								</fo:table-cell>
							</fo:table-row>
						</xsl:for-each>
					</fo:table-body>
				</fo:table>
			</xsl:when>
			<xsl:otherwise>
				<fo:block>No history.</fo:block>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Defines the table of content. -->
	<xsl:template name="ContentTOC">
		<xsl:param name="config"/>
		<fo:block text-align-last="justify">
			<xsl:call-template name="LoopTOC">
				<xsl:with-param name="structure" select="$config/following::node()"/>
			</xsl:call-template>
		</fo:block>
	</xsl:template>
	
	<xsl:template name="LoopTOC">
		<xsl:param name="structure"/>
		<xsl:param name="level" select="1"/>
		<xsl:for-each select="$structure">
			<xsl:if test="fn:exists(@tocstyle) and @level = $level">
				<fo:block>
					<xsl:call-template name="ApplyStyle">
						<xsl:with-param name="style" select="@tocstyle"/>
					</xsl:call-template>
					<fo:basic-link internal-destination="{@id}">
						<xsl:if test="@num">
							<xsl:value-of select="@num"/>
							<xsl:choose>
								<xsl:when test="@sep">
									<xsl:value-of select="@sep"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text> </xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:if>
						<xsl:value-of select="@title"/>
						<fo:leader leader-pattern="dots" leader-pattern-width="3mm"/>
						<fo:page-number-citation ref-id="{@id}"/>
					</fo:basic-link>
				</fo:block>				
				<fo:block margin-left="5mm">			
					<xsl:variable name="curpos" select="fn:position()"/>
					<xsl:variable name="nextsibling" select="following-sibling::node()[@level = $level]"/>
					<xsl:choose>
						<xsl:when test="$nextsibling">
							<xsl:variable name="posdiff" select="fn:count($nextsibling[1]/preceding-sibling::node()) - fn:count(preceding-sibling::node())"/>
							<xsl:if test="$posdiff > 1">
								<xsl:call-template name="LoopTOC">
									<xsl:with-param name="structure" select="$structure[$curpos &lt; fn:position() and fn:position() &lt; ($curpos + $posdiff)]"/>
									<xsl:with-param name="level" select="$level + 1"/>
								</xsl:call-template>
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="LoopTOC">
								<xsl:with-param name="structure" select="$structure[$curpos &lt; fn:position()]"/>
								<xsl:with-param name="level" select="$level + 1"/>
							</xsl:call-template>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Computes the list of signals to appear in the data dictionary. -->
	<xsl:template name="GetSignals">
		<xsl:param name="root" select="fn:root()"/>
		<xsl:sequence select="$root/*/syd:dictionary/syd:signal"/>
		<xsl:if test="$gendep='embed'">
			<xsl:call-template name="IterateOverDeps">
				<xsl:with-param name="root" select="$root"/>
				<xsl:with-param name="tpname" select="'GetSignals'"/>
			</xsl:call-template>
		</xsl:if>	
	</xsl:template>
	
	<!-- Computes the list of parameters to appear in the data dictionary. -->
	<xsl:template name="GetParameters">
		<xsl:param name="root" select="fn:root()"/>
		<xsl:sequence select="$root/*/syd:dictionary/syd:parameter"/>
		<xsl:if test="$gendep='embed'">
			<xsl:call-template name="IterateOverDeps">
				<xsl:with-param name="root" select="$root"/>
				<xsl:with-param name="tpname" select="'GetParameters'"/>
			</xsl:call-template>
		</xsl:if>	
	</xsl:template>
	
	<!-- Computes the list of 1D Lookups to appear in the data dictionary. -->
	<xsl:template name="Get1DLookups">
		<xsl:param name="root" select="fn:root()"/>
		<xsl:sequence select="$root/syd:model/syd:lookups/syd:lookup[@type = '1D']"/>
		<xsl:sequence select="$root//syd:lookup[@type = '1D' and not(fn:exists(ancestor::syd:system[syd:extradata/@security &gt; $security]))]"/>
		<xsl:if test="$gendep='embed'">
			<xsl:call-template name="IterateOverDeps">
				<xsl:with-param name="root" select="$root"/>
				<xsl:with-param name="tpname" select="'Get1DLookups'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Computes the list of 2D Lookups to appear in the data dictionary. -->
	<xsl:template name="Get2DLookups">
		<xsl:param name="root" select="fn:root()"/>
		<xsl:sequence select="$root/syd:model/syd:lookups/syd:lookup[@type = '2D']"/>
		<xsl:sequence select="$root//syd:lookup[@type = '2D' and not(fn:exists(ancestor::syd:system[syd:extradata/@security &gt; $security]))]"/>
		<xsl:if test="$gendep='embed'">
			<xsl:call-template name="IterateOverDeps">
				<xsl:with-param name="root" select="$root"/>
				<xsl:with-param name="tpname" select="'Get2DLookups'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<!-- Computes the list of Buses to appear in the data dictionary. -->
	<xsl:template name="GetBuses">
		<xsl:sequence select="$globalbustree//syd:bus[@out]"/>
	</xsl:template>
	
	<!-- Computes the list of requirements. -->
	<xsl:template name="GetRequirements">
		<xsl:param name="root" select="fn:root()"/>
		<xsl:sequence select="$root/syd:model/syd:reqinfos/syd:req"/>
		<xsl:sequence select="$root//syd:req[not(fn:exists(ancestor::syd:system[syd:extradata/@security &gt; $security]))]"/>
		<xsl:if test="$gendep='embed'">
			<xsl:call-template name="IterateOverDeps">
				<xsl:with-param name="root" select="$root"/>
				<xsl:with-param name="tpname" select="'GetRequirements'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>