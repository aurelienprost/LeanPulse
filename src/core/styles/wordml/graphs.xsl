<?xml version="1.0" encoding="UTF-8"?>

<!-- =============================================================

This stylesheet controls translation of graphic elements such as
pictures or shapes.

Copyright (c) 2011 LeanPulse. All rights reserved.

Author: Aurélien PROST (a.prost@leanpulse.com)

============================================================== -->

<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml" xmlns:o="urn:schemas-microsoft-com:office:office"
	xmlns:v="urn:schemas-microsoft-com:vml" xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"
	xmlns:aml="http://schemas.microsoft.com/aml/2001/core" xmlns:w10="urn:schemas-microsoft-com:office:word"
	xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882" xmlns:st1="urn:schemas-microsoft-com:office:smarttags"
	version="1.0">

	<!-- Global variables -->
	<xsl:variable name="pi" select="3.14159265358" />
	<xsl:variable name="stroke.weight.coeff" select="10" />  <!-- coefficient for converting VML lines width to SVG -->
	<!-- default canvas parameters -->
	<xsl:variable name="canvas.width.default" select="'11in'" />
	<xsl:variable name="canvas.width.svgunit">
		<xsl:call-template name="ConvertToUserUnits">
			<xsl:with-param name="value" select="$canvas.width.default" />
		</xsl:call-template>
	</xsl:variable>
	<xsl:variable name="canvas.height.default" select="'19in'" />
	<xsl:variable name="canvas.height.svgunit">
		<xsl:call-template name="ConvertToUserUnits">
			<xsl:with-param name="value" select="$canvas.height.default" />
		</xsl:call-template>
	</xsl:variable>

	<!-- Debug parameter -->
	<xsl:param name="debug.border" select="0" />
	<xsl:param name="textbox.text.indent.left" select="'7.2pt'" />
	<xsl:param name="textbox.text.indent.top" select="'5pt'" />
	<xsl:param name="textbox.text.indent.right" select="'7.2pt'" />
	<xsl:param name="textbox.text.indent.bottom" select="'1pt'" />


	<!-- ======== -->
	<!-- Graphics -->
	<!-- ======== -->
	
	<!-- Represents a picture or other binary object -->
	<!-- that appears at this point in the document. -->
	<!-- Parent elements: w:r -->
	<xsl:template match="w:pict[not(v:shape/v:imagedata)]">
		<xsl:variable name="binary-data"
			select="w:binData | w:movie | w:background | w:applet | w:scriptAnchor | w:ocx | w:msAccessHTML" />
		<xsl:variable name="shapes"
			select="v:shape | v:group | v:rect | v:roundrect | v:line | v:polyline | v:oval | v:curve | v:arc | v:image" />
	
		<!-- The bitmap graphics is processed by the same template within structure.xsl -->
	
		<!-- convert VML to instream SVG. -->
		<xsl:if test="$shapes">
			<xsl:variable name="style-string" select="$shapes[1]/@style" />
			<xsl:choose>
				<xsl:when test="not(v:group[@editas='canvas'])">
					<!-- If graphics placed into document without canvas -->
					<fo:block-container absolute-position="absolute">
						<!-- left -->
						<xsl:variable name="margin.left">
							<xsl:choose>
								<xsl:when test="contains($style-string, 'margin-left:')">
									<xsl:call-template name="ParseCSSString">
										<xsl:with-param name="style-string" select="$style-string" />
										<xsl:with-param name="property-name" select="'margin-left'" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<!-- Workaround for lines -->
									<xsl:value-of select="'0pt'" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<!-- auxiliary variables -->
						<xsl:variable name="temp.width">
							<xsl:choose>
								<xsl:when test="contains($style-string, 'width:')">
									<xsl:call-template name="ParseCSSString">
										<xsl:with-param name="style-string" select="$style-string" />
										<xsl:with-param name="property-name" select="'width'" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'0pt'" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="temp.unit"
							select="translate ($temp.width, '-0123456789. ', '')" />
						<xsl:variable name="temp.width.number">
							<xsl:call-template name="ToNumber">
								<xsl:with-param name="Val" select="$temp.width" />
							</xsl:call-template>
						</xsl:variable>
						<!-- suppose that all values are set for the same measure-unit -->
						<xsl:variable name="margin.left.number">
							<xsl:call-template name="ConvertInto">
								<xsl:with-param name="value" select="$margin.left" />
								<xsl:with-param name="dest-unit" select="$temp.unit" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="shift.left">
							<xsl:choose>
								<xsl:when test="contains($style-string, 'rotation:')">
									<!-- workaround for rotated pictures - subtract the width of shape 
										from margin-left -->
									<xsl:value-of
										select="concat($margin.left.number - $temp.width.number, $temp.unit)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$margin.left" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<!-- set attribute @left -->
						<xsl:attribute name="left">
							<xsl:value-of select="$shift.left" />
						</xsl:attribute>
						<!-- top -->
						<xsl:variable name="margin.top">
							<xsl:choose>
								<xsl:when test="contains($style-string, 'margin-top:')">
									<xsl:variable name="margin.top">
										<xsl:call-template name="ParseCSSString">
											<xsl:with-param name="style-string" select="$style-string" />
											<xsl:with-param name="property-name" select="'margin-top'" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="margin.top.tmp">
										<xsl:call-template name="GetCipher">
											<xsl:with-param name="str" select="$margin.top" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:variable name="header.extent.current">
										<xsl:text>0</xsl:text>
									</xsl:variable>
									<xsl:variable name="header.extent.current.tmp">
										<xsl:call-template name="GetCipher">
											<xsl:with-param name="str" select="$header.extent.current" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:value-of
										select="concat($margin.top.tmp - $header.extent.current.tmp, substring-after($margin.top, $margin.top.tmp) )" />
								</xsl:when>
								<xsl:otherwise>
									<!-- Workaround for lines -->
									<xsl:value-of select="'0pt'" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<!-- auxiliary variables -->
						<xsl:variable name="temp.height">
							<xsl:choose>
								<xsl:when test="contains($style-string, 'height:')">
									<xsl:call-template name="ParseCSSString">
										<xsl:with-param name="style-string" select="$style-string" />
										<xsl:with-param name="property-name" select="'height'" />
									</xsl:call-template>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="'0pt'" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="temp.height.number">
							<xsl:call-template name="ConvertInto">
								<xsl:with-param name="value" select="$temp.height" />
								<xsl:with-param name="dest-unit" select="$temp.unit" />
							</xsl:call-template>
						</xsl:variable>
						<!-- suppose that all values are set for the same measure-unit -->
						<xsl:variable name="margin.top.number">
							<xsl:call-template name="ConvertInto">
								<xsl:with-param name="value" select="$margin.top" />
								<xsl:with-param name="dest-unit" select="$temp.unit" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="shift.top">
							<xsl:choose>
								<xsl:when test="contains($style-string, 'rotation:')">
									<!-- workaround for rotated pictures - subtract the width of shape 
										from margin-left -->
									<xsl:value-of
										select="concat($margin.top.number - $temp.height.number, $temp.unit)" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$margin.top" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<!-- set attribute @top -->
						<xsl:attribute name="top">
							<xsl:value-of select="$shift.top" />
						</xsl:attribute>
						<xsl:variable name="strViewBox">
							<xsl:value-of
								select="concat('0, 0, ', $canvas.width.svgunit, ', ', $canvas.height.svgunit)" />
						</xsl:variable>
						<fo:block>
							<fo:block-container>
								<xsl:if test="contains($style-string, 'height:')">
									<xsl:attribute name="block-progression-dimension">
										<xsl:call-template name="ParseCSSString">
											<xsl:with-param name="style-string" select="$style-string" />
											<xsl:with-param name="property-name" select="'height'" />
										</xsl:call-template>
									</xsl:attribute>
								</xsl:if>
								<fo:block>
									<fo:instream-foreign-object>
										<xsl:if test="$debug.border=1">
											<xsl:attribute name="border">solid 0.1pt blue</xsl:attribute>
										</xsl:if>
										<svg:svg>
											<xsl:attribute name="overflow">visible</xsl:attribute>
											<!-- defaults -->
											<xsl:attribute name="stroke">black</xsl:attribute>
											<xsl:attribute name="fill">none</xsl:attribute>
											<xsl:attribute name="width">
												<xsl:value-of select="$canvas.width.default" />
											</xsl:attribute>
											<xsl:attribute name="height">
												<xsl:value-of select="$canvas.height.default" />
											</xsl:attribute>
											<xsl:attribute name="viewBox">
												<xsl:value-of select="$strViewBox" />
											</xsl:attribute> <!-- 0 0 990 1710 -->
											<!-- process content -->
											<xsl:apply-templates select="*">
												<!--<xsl:with-param name="nocanvas">true</xsl:with-param> -->
											</xsl:apply-templates>
										</svg:svg>
									</fo:instream-foreign-object>
									<xsl:for-each select="$shapes/v:textbox">
										<xsl:variable name="style.width">
											<xsl:call-template name="GetCSSProperty">
												<xsl:with-param name="css.string" select="../@style" />
												<xsl:with-param name="css.property" select="'width'" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="style.width.tmp">
											<xsl:call-template name="GetCipher">
												<xsl:with-param name="str" select="$style.width" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="style.height">
											<xsl:call-template name="GetCSSProperty">
												<xsl:with-param name="css.string" select="../@style" />
												<xsl:with-param name="css.property" select="'height'" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:variable name="style.height.tmp">
											<xsl:call-template name="GetCipher">
												<xsl:with-param name="str" select="$style.height" />
											</xsl:call-template>
										</xsl:variable>
										<xsl:call-template name="TextInShapes">
											<xsl:with-param name="x.units"
												select="substring-after($style.width, $style.width.tmp)" />
											<xsl:with-param name="y.units"
												select="substring-after($style.height, $style.height.tmp)" />
											<xsl:with-param name="style.left" select="0" />
											<xsl:with-param name="style.top" select="0" />
										</xsl:call-template>
									</xsl:for-each>
								</fo:block>
							</fo:block-container>
						</fo:block>
					</fo:block-container>
				</xsl:when>
				<xsl:otherwise>
					<fo:block-container>
						<xsl:if test="contains($style-string, 'height:')">
							<xsl:attribute name="block-progression-dimension">
								<xsl:call-template name="ParseCSSString">
									<xsl:with-param name="style-string" select="$style-string" />
									<xsl:with-param name="property-name" select="'height'" />
								</xsl:call-template>
							</xsl:attribute>
						</xsl:if>
						<fo:block>
							<fo:instream-foreign-object>
								<xsl:if test="$debug.border=1">
									<xsl:attribute name="border">solid 0.1pt blue</xsl:attribute>
								</xsl:if>
								<svg:svg>
									<!-- Apply attributes -->
									<!-- By default attribute 'preserveAspectRatio' has value 'xMidYMid' 
										and forces uniform scaling. If you don't need scaling, then set value 'none'. -->
									<!-- <xsl:attribute name="preserveAspectRatio">none</xsl:attribute> -->
									<xsl:attribute name="overflow">visible</xsl:attribute>
									<!-- defaults -->
									<xsl:attribute name="stroke"><xsl:text>black</xsl:text></xsl:attribute>
									<xsl:attribute name="fill"><xsl:text>none</xsl:text></xsl:attribute>
									<!-- Set viewbox and svg object params (width, height). -->
									<!-- width -->
									<xsl:if test="contains($style-string, 'width:')">
										<xsl:attribute name="width">
											<xsl:call-template name="ParseCSSString">
												<xsl:with-param name="style-string" select="$style-string" />
												<xsl:with-param name="property-name" select="'width'" />
											</xsl:call-template>
										</xsl:attribute>
									</xsl:if>
									<!-- height -->
									<xsl:if test="contains($style-string, 'height:')">
										<xsl:attribute name="height">
											<xsl:call-template name="ParseCSSString">
												<xsl:with-param name="style-string" select="$style-string" />
												<xsl:with-param name="property-name" select="'height'" />
											</xsl:call-template>
										</xsl:attribute>
									</xsl:if>
	
									<xsl:if test="$shapes[1]/@coordorigin and $shapes[1]/@coordsize">
										<!-- coordorigin -->
										<xsl:variable name="coordorigin">
											<xsl:value-of select="$shapes[1]/@coordorigin" />
										</xsl:variable>
										<!-- coordsize -->
										<xsl:variable name="coordsize">
											<xsl:value-of select="$shapes[1]/@coordsize" />
										</xsl:variable>
										<!-- viewBox -->
										<xsl:attribute name="viewBox">
											<xsl:value-of select="concat($coordorigin, ',', $coordsize)" />
										</xsl:attribute>
									</xsl:if>
	
									<!-- Process VML content -->
									<xsl:apply-templates select="$shapes | v:shapetype" />
								</svg:svg>
							</fo:instream-foreign-object>
	
							<!-- Textboxes processing -->
							<xsl:if test="$shapes/*/v:textbox">
								<xsl:variable name="group.style" select="v:group/@style" />
								<xsl:variable name="group.coordorigin" select="v:group/@coordorigin" />
								<xsl:variable name="group.coordsize" select="v:group/@coordsize" />
								<xsl:variable name="group.width">
									<xsl:call-template name="GetCSSProperty">
										<xsl:with-param name="css.string" select="$group.style" />
										<xsl:with-param name="css.property" select="'width'" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="group.height">
									<xsl:call-template name="GetCSSProperty">
										<xsl:with-param name="css.string" select="$group.style" />
										<xsl:with-param name="css.property" select="'height'" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="base.x">
									<xsl:choose>
										<xsl:when test="$group.coordorigin != '' ">
											<xsl:value-of select="substring-before($group.coordorigin, ',' )" />
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="base.y">
									<xsl:choose>
										<xsl:when test="$group.coordorigin != '' ">
											<xsl:value-of select="substring-after($group.coordorigin, ',' )" />
										</xsl:when>
										<xsl:otherwise>0</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="group.width.tmp">
									<xsl:call-template name="GetCipher">
										<xsl:with-param name="str" select="$group.width" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="x.units"
									select="substring-after($group.width, $group.width.tmp)" />
								<xsl:variable name="textbox.text.indent.left.default">
									<xsl:variable name="tmp">
										<xsl:call-template name="ConvertInto">
											<xsl:with-param name="value"
												select="$textbox.text.indent.left" />
											<xsl:with-param name="dest-unit" select="$x.units" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:call-template name="GetCipher">
										<xsl:with-param name="str" select="$tmp" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="textbox.text.indent.right.default">
									<xsl:variable name="tmp">
										<xsl:call-template name="ConvertInto">
											<xsl:with-param name="value"
												select="$textbox.text.indent.right" />
											<xsl:with-param name="dest-unit" select="$x.units" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:call-template name="GetCipher">
										<xsl:with-param name="str" select="$tmp" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="group.height.tmp">
									<xsl:call-template name="GetCipher">
										<xsl:with-param name="str" select="$group.height" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="y.units"
									select="substring-after($group.height, $group.height.tmp)" />
								<xsl:variable name="textbox.text.indent.top.default">
									<xsl:variable name="tmp">
										<xsl:call-template name="ConvertInto">
											<xsl:with-param name="value" select="$textbox.text.indent.top" />
											<xsl:with-param name="dest-unit" select="$y.units" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:call-template name="GetCipher">
										<xsl:with-param name="str" select="$tmp" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="textbox.text.indent.bottom.default">
									<xsl:variable name="tmp">
										<xsl:call-template name="ConvertInto">
											<xsl:with-param name="value"
												select="$textbox.text.indent.bottom" />
											<xsl:with-param name="dest-unit" select="$y.units" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:call-template name="GetCipher">
										<xsl:with-param name="str" select="$tmp" />
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="koef.x"
									select="$group.width.tmp div number(substring-before($group.coordsize, ',' ))" />
								<xsl:variable name="koef.y"
									select="$group.height.tmp div number(substring-after($group.coordsize, ',' ))" />
	
								<xsl:for-each select="$shapes/*/v:textbox">
									<xsl:call-template name="TextInShapes">
										<xsl:with-param name="base.x" select="$base.x" />
										<xsl:with-param name="base.y" select="$base.y" />
										<xsl:with-param name="koef.x" select="$koef.x" />
										<xsl:with-param name="koef.y" select="$koef.y" />
										<xsl:with-param name="x.units" select="$x.units" />
										<xsl:with-param name="y.units" select="$y.units" />
										<xsl:with-param name="textbox.text.indent.left.default"
											select="$textbox.text.indent.left.default" />
										<xsl:with-param name="textbox.text.indent.right.default"
											select="$textbox.text.indent.right.default" />
										<xsl:with-param name="textbox.text.indent.top.default"
											select="$textbox.text.indent.top.default" />
										<xsl:with-param name="textbox.text.indent.bottom.default"
											select="$textbox.text.indent.bottom.default" />
									</xsl:call-template>
								</xsl:for-each>
							</xsl:if>
	
						</fo:block>
					</fo:block-container>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	

	<!-- Text in shapes processing -->
    <xsl:template name="TextInShapes">
		<xsl:param name="base.x" select="0" />
		<xsl:param name="base.y" select="0" />
		<xsl:param name="koef.x" select="1" />
		<xsl:param name="koef.y" select="1" />
		<xsl:param name="x.units" />
		<xsl:param name="y.units" />
		<xsl:param name="style" select="../@style" />
		<xsl:param name="style.left">
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str">
					<xsl:call-template name="GetCSSProperty">
						<xsl:with-param name="css.string" select="$style" />
						<xsl:with-param name="css.property" select="'left'" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="style.top">
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str">
					<xsl:call-template name="GetCSSProperty">
						<xsl:with-param name="css.string" select="$style" />
						<xsl:with-param name="css.property" select="'top'" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="style.width">
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str">
					<xsl:call-template name="GetCSSProperty">
						<xsl:with-param name="css.string" select="$style" />
						<xsl:with-param name="css.property" select="'width'" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="style.height">
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str">
					<xsl:call-template name="GetCSSProperty">
						<xsl:with-param name="css.string" select="$style" />
						<xsl:with-param name="css.property" select="'height'" />
					</xsl:call-template>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="textbox.text.indent.left.default">
			<xsl:variable name="tmp">
				<xsl:call-template name="ConvertInto">
					<xsl:with-param name="value" select="$textbox.text.indent.left" />
					<xsl:with-param name="dest-unit" select="$x.units" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str" select="$tmp" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="textbox.text.indent.right.default">
			<xsl:variable name="tmp">
				<xsl:call-template name="ConvertInto">
					<xsl:with-param name="value" select="$textbox.text.indent.right" />
					<xsl:with-param name="dest-unit" select="$x.units" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str" select="$tmp" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="textbox.text.indent.top.default">
			<xsl:variable name="tmp">
				<xsl:call-template name="ConvertInto">
					<xsl:with-param name="value" select="$textbox.text.indent.top" />
					<xsl:with-param name="dest-unit" select="$y.units" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str" select="$tmp" />
			</xsl:call-template>
		</xsl:param>
		<xsl:param name="textbox.text.indent.bottom.default">
			<xsl:variable name="tmp">
				<xsl:call-template name="ConvertInto">
					<xsl:with-param name="value" select="$textbox.text.indent.bottom" />
					<xsl:with-param name="dest-unit" select="$y.units" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str" select="$tmp" />
			</xsl:call-template>
		</xsl:param>
	
		<xsl:variable name="type" select="substring(../@type, 2)" />

		<!-- Section for attribute 'textboxrect' -->
		<xsl:variable name="textboxrect.tmp1" select="../v:path/@textboxrect" />
		<xsl:variable name="textboxrect.tmp2"
			select="//v:shapetype[@id = $type]/v:path/@textboxrect" />
		<xsl:variable name="textboxrect">
			<xsl:choose>
				<xsl:when test="$textboxrect.tmp1 != '' ">
					<xsl:value-of select="$textboxrect.tmp1" />
				</xsl:when>
				<xsl:when test="$textboxrect.tmp2 != '' ">
					<xsl:value-of select="$textboxrect.tmp2" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="textboxrect.left">
			<xsl:if test="$textboxrect != '' ">
				<xsl:variable name="textboxrect.left.tmp">
					<xsl:call-template name="GetArg">
						<xsl:with-param name="str"
							select="substring-before($textboxrect, ',' )" />
						<xsl:with-param name="shape" select=".." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($textboxrect.left.tmp, '|')">
						<xsl:value-of select="substring-before($textboxrect.left.tmp, '|' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$textboxrect.left.tmp" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="textboxrect.left.after">
			<xsl:if test="$textboxrect != '' ">
				<xsl:value-of select="substring-after($textboxrect, ',' )" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="textboxrect.top">
			<xsl:if test="$textboxrect != '' ">
				<xsl:variable name="textboxrect.top.tmp">
					<xsl:call-template name="GetArg">
						<xsl:with-param name="str"
							select="substring-before($textboxrect.left.after, ',' )" />
						<xsl:with-param name="shape" select=".." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($textboxrect.top.tmp, '|')">
						<xsl:value-of select="substring-before($textboxrect.top.tmp, '|' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$textboxrect.top.tmp" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="textboxrect.top.after">
			<xsl:if test="$textboxrect != '' ">
				<xsl:value-of select="substring-after($textboxrect.left.after, ',' )" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="textboxrect.right">
			<xsl:if test="$textboxrect != '' ">
				<xsl:variable name="textboxrect.right.tmp">
					<xsl:call-template name="GetArg">
						<xsl:with-param name="str"
							select="substring-before($textboxrect.top.after, ',' )" />
						<xsl:with-param name="shape" select=".." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($textboxrect.right.tmp, '|')">
						<xsl:value-of select="substring-before($textboxrect.right.tmp, '|' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$textboxrect.right.tmp" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="textboxrect.right.after">
			<xsl:if test="$textboxrect != '' ">
				<xsl:value-of select="substring-after($textboxrect.top.after, ',' )" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="textboxrect.bottom">
			<xsl:if test="$textboxrect != '' ">
				<xsl:variable name="textboxrect.bottom.tmp">
					<xsl:call-template name="GetArg">
						<xsl:with-param name="str">
							<xsl:choose>
								<xsl:when test="contains($textboxrect.right.after, ';' )">
									<xsl:value-of select="substring-before($textboxrect.right.after, ';' )" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$textboxrect.right.after" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="shape" select=".." />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="contains($textboxrect.bottom.tmp, '|')">
						<xsl:value-of select="substring-before($textboxrect.bottom.tmp, '|' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$textboxrect.bottom.tmp" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		
		<!-- General properties section -->
		<xsl:variable name="shapetype.coordsize" select="//v:shapetype[@id = $type]/@coordsize" />
		
		<xsl:variable name="textboxrect.koef.x">
			<xsl:choose>
				<xsl:when test="$textboxrect = $textboxrect.tmp2 ">
					<xsl:value-of
						select="$style.width div substring-before($shapetype.coordsize, ',' )" />
				</xsl:when>
				<xsl:otherwise>
					1
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="textboxrect.koef.y">
			<xsl:choose>
				<xsl:when test="$textboxrect = $textboxrect.tmp2 ">
					<xsl:value-of
						select="$style.height div substring-after($shapetype.coordsize, ',' )" />
				</xsl:when>
				<xsl:otherwise>
					1
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<xsl:variable name="inset" select="@inset" />
		<xsl:variable name="inset.left">
			<xsl:if test="$inset != '' ">
				<xsl:choose>
					<xsl:when test="contains($inset, ',' )">
						<xsl:value-of select="substring-before($inset, ',' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$inset" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="inset.left.after" select="substring-after($inset, ',' )" />
		<xsl:variable name="inset.top">
			<xsl:if test="$inset.left.after != '' ">
				<xsl:choose>
					<xsl:when test="contains($inset.left.after, ',' )">
						<xsl:value-of select="substring-before($inset.left.after, ',' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$inset.left.after" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="inset.top.after"
			select="substring-after($inset.left.after, ',' )" />
		<xsl:variable name="inset.right">
			<xsl:if test="$inset.top.after != '' ">
				<xsl:choose>
					<xsl:when test="contains($inset.top.after, ',' )">
						<xsl:value-of select="substring-before($inset.top.after, ',' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$inset.top.after" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="inset.bottom"
			select="substring-after($inset.top.after, ',' )" />
	
		<xsl:variable name="textbox.text.indent.left.current">
			<xsl:choose>
				<xsl:when test="$inset.left != '' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="ConvertInto">
							<xsl:with-param name="value" select="$inset.left" />
							<xsl:with-param name="dest-unit" select="$x.units" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="GetCipher">
						<xsl:with-param name="str" select="$tmp" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$textbox.text.indent.left.default" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="textbox.text.indent.right.current">
			<xsl:choose>
				<xsl:when test="$inset.right != '' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="ConvertInto">
							<xsl:with-param name="value" select="$inset.right" />
							<xsl:with-param name="dest-unit" select="$x.units" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="GetCipher">
						<xsl:with-param name="str" select="$tmp" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$textbox.text.indent.right.default" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="textbox.text.indent.top.current">
			<xsl:choose>
				<xsl:when test="$inset.top != '' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="ConvertInto">
							<xsl:with-param name="value" select="$inset.top" />
							<xsl:with-param name="dest-unit" select="$x.units" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="GetCipher">
						<xsl:with-param name="str" select="$tmp" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$textbox.text.indent.top.default" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="textbox.text.indent.bottom.current">
			<xsl:choose>
				<xsl:when test="$inset.bottom != '' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="ConvertInto">
							<xsl:with-param name="value" select="$inset.bottom" />
							<xsl:with-param name="dest-unit" select="$x.units" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="GetCipher">
						<xsl:with-param name="str" select="$tmp" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$textbox.text.indent.bottom.default" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
	
		<!-- Section for v:oval element -->
		<xsl:variable name="oval.x">
			<xsl:if test="name(..) = 'v:oval' ">
				<xsl:value-of select="0 - ($style.width div (2 * 1.4142))" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="oval.y">
			<xsl:if test="name(..) = 'v:oval' ">
				<xsl:value-of select="0 - ($style.height div $style.width) * $oval.x" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="oval.left">
			<xsl:if test="name(..) = 'v:oval' ">
				<xsl:value-of select="$oval.x + ($style.width div 2) + $style.left" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="oval.top">
			<xsl:if test="name(..) = 'v:oval' ">
				<xsl:value-of select="($style.height div 2) - $oval.y + $style.top" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="oval.width">
			<xsl:if test="name(..) = 'v:oval' ">
				<xsl:value-of select="0 - $oval.x * 2" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="oval.height">
			<xsl:if test="name(..) = 'v:oval' ">
				<xsl:value-of select="$oval.y * 2" />
			</xsl:if>
		</xsl:variable>
		<!-- Section for v:roundrect element -->
		<xsl:variable name="roundrect.rx">
			<xsl:if test="name(..) = 'v:roundrect' ">
				<xsl:variable name="arcsize">
					<xsl:call-template name="ConvertFractionalValue">
						<xsl:with-param name="fractional-value" select="../@arcsize" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$style.width > $style.height">
						<xsl:value-of select="$arcsize * $style.height" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$arcsize * $style.width" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="roundrect.x">
			<xsl:if test="name(..) = 'v:roundrect' ">
				<xsl:value-of select="0 - $roundrect.rx div 1.4142" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="roundrect.y">
			<xsl:if test="name(..) = 'v:roundrect' ">
				<xsl:value-of select="0 - $roundrect.x" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="roundrect.left">
			<xsl:if test="name(..) = 'v:roundrect' ">
				<xsl:value-of select="$roundrect.rx + $roundrect.x + $style.left" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="roundrect.top">
			<xsl:if test="name(..) = 'v:roundrect' ">
				<xsl:value-of select="$roundrect.rx - $roundrect.y + $style.top" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="roundrect.width">
			<xsl:if test="name(..) = 'v:roundrect' ">
				<xsl:value-of select="$style.width - 2 * ($roundrect.rx + $roundrect.x)" />
			</xsl:if>
		</xsl:variable>
		<xsl:variable name="roundrect.height">
			<xsl:if test="name(..) = 'v:roundrect' ">
				<xsl:value-of select="$style.height - 2 * ($roundrect.rx - $roundrect.y)" />
			</xsl:if>
		</xsl:variable>
	
		<fo:block-container absolute-position="absolute"
			overflow="hidden">
			<xsl:if test="$debug.border=1">
				<xsl:attribute name="border">0.1pt solid red</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="left">
	            <xsl:variable name="left">
	              <xsl:choose>
	                <xsl:when test="$textboxrect != '' "><xsl:value-of
				select="$textboxrect.left * $textboxrect.koef.x + $style.left" /></xsl:when>
	                <xsl:when test="name(..) = 'v:oval' "><xsl:value-of
				select="$oval.left" /></xsl:when>
	                <xsl:when test="name(..) = 'v:roundrect' "><xsl:value-of
				select="$roundrect.left" /></xsl:when>
	                <xsl:otherwise><xsl:value-of select="$style.left" /></xsl:otherwise>
	              </xsl:choose>
	            </xsl:variable>
	            <xsl:value-of
				select="concat( ($left - $base.x) * $koef.x + $textbox.text.indent.left.current, $x.units )" />
	          </xsl:attribute>
			<xsl:attribute name="top">
	            <xsl:variable name="top">
	              <xsl:choose>
	                <xsl:when test="$textboxrect != '' "><xsl:value-of
				select="$textboxrect.top * $textboxrect.koef.y + $style.top" /></xsl:when>
	                <xsl:when test="name(..) = 'v:oval' "><xsl:value-of
				select="$oval.top" /></xsl:when>
	                <xsl:when test="name(..) = 'v:roundrect' "><xsl:value-of
				select="$roundrect.top" /></xsl:when>
	                <xsl:otherwise><xsl:value-of select="$style.top" /></xsl:otherwise>
	              </xsl:choose>
	            </xsl:variable>
	            <xsl:value-of
				select="concat( ($top - $base.y) * $koef.y + $textbox.text.indent.top.current, $y.units )" />
	          </xsl:attribute>
			<xsl:attribute name="width">
	            <xsl:variable name="width">
	              <xsl:choose>
	                <xsl:when test="$textboxrect != '' "><xsl:value-of
				select="($textboxrect.right - $textboxrect.left) * $textboxrect.koef.x" /></xsl:when>
	                <xsl:when test="name(..) = 'v:oval' "><xsl:value-of
				select="$oval.width" /></xsl:when>
	                <xsl:when test="name(..) = 'v:roundrect' "><xsl:value-of
				select="$roundrect.width" /></xsl:when>
	                <xsl:otherwise><xsl:value-of select="$style.width" /></xsl:otherwise>
	              </xsl:choose>
	            </xsl:variable>
	            <xsl:value-of
				select="concat($width * $koef.x - ($textbox.text.indent.left.current + $textbox.text.indent.right.current), $x.units )" />
	          </xsl:attribute>
			<xsl:attribute name="height">
	            <xsl:variable name="height">
	              <xsl:choose>
	                <xsl:when test="$textboxrect != '' "><xsl:value-of
				select="($textboxrect.bottom - $textboxrect.top) * $textboxrect.koef.y" /></xsl:when>
	                <xsl:when test="name(..) = 'v:oval' "><xsl:value-of
				select="$oval.height" /></xsl:when>
	                <xsl:when test="name(..) = 'v:roundrect' "><xsl:value-of
				select="$roundrect.height" /></xsl:when>
	                <xsl:otherwise><xsl:value-of select="$style.height" /></xsl:otherwise>
	              </xsl:choose>
	            </xsl:variable>
	            <xsl:value-of
				select="concat($height * $koef.y - ($textbox.text.indent.top.current + $textbox.text.indent.bottom.current) div 2, $y.units )" />
	          </xsl:attribute>
			<fo:block hyphenate="true" language="en">
				<xsl:apply-templates select="w:txbxContent/*"></xsl:apply-templates>
			</fo:block>
		</fo:block-container>
	</xsl:template>

	<!-- Defines a group that can be used to collect shapes. -->
	<!-- Parent elements: w:pict -->
	<xsl:template match="v:group">
		<svg:g>
			<xsl:apply-templates select="o:*" mode="svg" />
			<xsl:apply-templates select="v:*" />
		</svg:g>
	</xsl:template>

	<!-- Images inside of SVG -->
	<xsl:template match="v:shape[v:imagedata]" mode="svg.image">
		<xsl:param name="binary-data"
			select="../w:binData | ../w:movie | ../w:background | ../w:applet | ../w:scriptAnchor | ../w:ocx | ../w:msAccessHTML" />
		<xsl:param name="x-factor" select="1" />
		<xsl:param name="y-factor" select="1" />

		<svg:image xmlns:xlink="http://www.w3.org/1999/xlink">
			<xsl:call-template name="CSSStyle">
				<xsl:with-param name="style-string" select="@style" />
				<xsl:with-param name="object" select="'rect'" />
			</xsl:call-template>
			<xsl:call-template name="ShapeFormat" />
			<xsl:call-template name="ShapeTransform">
				<xsl:with-param name="style-string" select="@style" />
			</xsl:call-template>
			<!--<xsl:variable name="src" select="v:imagedata/@src"/> <xsl:variable 
				name="binData" select="../w:binData[@w:name = $src ]"/> <xsl:attribute name="xlink:href"><xsl:value-of 
				select="concat( 'data:image/jpeg;base64,', $binData, '&#xA;' ) "/></xsl:attribute> -->
			<xsl:attribute name="xlink:href">
            <xsl:choose>
              <xsl:when test="$binary-data">
                <!-- Embedded object -->
                <xsl:apply-templates select="$binary-data"
				mode="svg.image" />
              </xsl:when>
              <xsl:otherwise>
                <!-- Linked object -->
                <xsl:variable name="src" select="v:imagedata/@src" />
                <xsl:choose>
                  <xsl:when test="starts-with($src, 'wordml://')">
                    <!--Internal link (in the same document) -->
                    <xsl:apply-templates
				select="ancestor::w:body//*[(self::w:binData or self::w:movie) and @w:name = $src]"
				mode="svg.image" />
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- external link -->
                    <xsl:value-of select="v:imagedata/@src" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
		</svg:image>
	</xsl:template>

	<!-- Contains the binary data representing this object. -->
	<!-- Parent elements: w:pict, w:bgPict -->
	<xsl:template match="w:binData" mode="svg.image">
		<xsl:variable name="media-type">
			<xsl:text>image/</xsl:text>
			<xsl:call-template name="RetrieveMediaSubtype">
				<xsl:with-param name="name" select="@w:name" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="concat('data:', $media-type, ';base64,', . )" />
	</xsl:template>

	<!-- The element used to describe a shape. -->
	<!-- Parent elements: w:pict, v:group -->
	<xsl:template match="v:shape[not(v:imagedata)]">
		<xsl:param name="nocanvas" select="'false'" />
		<xsl:choose>
			<xsl:when test="@path">
				<!--<xsl:value-of select="."/> -->
				<xsl:apply-templates select="." mode="path">
					<xsl:with-param name="path" select="@path" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="type" select="substring(@type, 2)" />
				<!--<xsl:apply-templates select="//v:shapetype[ @id = $type ]" mode="path"> 
					<xsl:with-param name="style" select="@style"/> </xsl:apply-templates> -->
				<xsl:if test="//v:shapetype[ @id = $type ]/@path">
					<xsl:apply-templates select="." mode="path">
						<xsl:with-param name="path"
							select="//v:shapetype[ @id = $type ]/@path" />
					</xsl:apply-templates>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="$nocanvas = 'true' and v:textbox">
			<xsl:apply-templates select="v:textbox" mode="svg.text" />
		</xsl:if>
	</xsl:template>

	<!-- Process 'path' attribute in v:shape tag. -->
	<!-- Except case using formulas in value of 'path' attribute. -->
	<!-- style - value from 'style' attribute. -->
	<xsl:template match="v:shape" mode="path">
		<xsl:param name="path" select="''" />
		<xsl:if test="$path != '' "> <!-- and not(contains($path, '@')) --><!-- If there is a symbol '@' in value of 'path' attribute - then it use 
				formula. This case doesn't support yet. -->
			<xsl:variable name="type" select="substring(@type, 2)" />
			<xsl:variable name="style">
				<xsl:choose>
					<xsl:when test="@style">
						<xsl:value-of select="@style" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//v:shapetype[ @id = $type ]/@style" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<svg:svg>
				<xsl:call-template name="NestedSvgStyles">
					<xsl:with-param name="style" select="$style" />
				</xsl:call-template>

				<xsl:variable name="width.prev">
					<xsl:variable name="temp">
						<xsl:call-template name="ParseCSSString">
							<xsl:with-param name="style-string" select="$style" />
							<xsl:with-param name="property-name" select="'width'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="ConvertToUserUnits">
						<xsl:with-param name="value" select="$temp" />
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="width">
					<xsl:choose>
						<xsl:when test="$width.prev != '' ">
							<xsl:value-of select="$width.prev" />
						</xsl:when>
						<xsl:otherwise>
							0
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="height.prev">
					<xsl:variable name="temp">
						<xsl:call-template name="ParseCSSString">
							<xsl:with-param name="style-string" select="$style" />
							<xsl:with-param name="property-name" select="'height'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="ConvertToUserUnits">
						<xsl:with-param name="value" select="$temp" />
					</xsl:call-template>
				</xsl:variable>

				<xsl:variable name="height">
					<xsl:choose>
						<xsl:when test="$height.prev != '' ">
							<xsl:value-of select="$height.prev" />
						</xsl:when>
						<xsl:otherwise>
							0
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="coordsize">
					<xsl:choose>
						<xsl:when test="@coordsize">
							<xsl:value-of select="@coordsize" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="//v:shapetype[ @id = $type ]/@coordsize" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:variable name="x.from" select="substring-before($coordsize, ',' )" />
				<xsl:variable name="y.from" select="substring-after($coordsize, ',' )" />

				<svg:g>
					<xsl:call-template name="ShapeTransform">
						<xsl:with-param name="style-string" select="$style" />
					</xsl:call-template>

					<xsl:call-template name="CreateSvgPath">
						<xsl:with-param name="path" select="$path" />
						<xsl:with-param name="filter" select=" 'fillnostroke' " />
						<xsl:with-param name="width" select="$width" />
						<xsl:with-param name="height" select="$height" />
						<xsl:with-param name="koef.x" select="$width div $x.from" />
						<xsl:with-param name="koef.y" select="$height div $y.from" />
					</xsl:call-template>

					<xsl:call-template name="CreateSvgPath">
						<xsl:with-param name="path" select="$path" />
						<xsl:with-param name="filter" select=" 'fillstroke' " />
						<xsl:with-param name="width" select="$width" />
						<xsl:with-param name="height" select="$height" />
						<xsl:with-param name="koef.x" select="$width div $x.from" />
						<xsl:with-param name="koef.y" select="$height div $y.from" />
					</xsl:call-template>

					<xsl:call-template name="CreateSvgPath">
						<xsl:with-param name="path" select="$path" />
						<xsl:with-param name="filter" select=" 'nofillstroke' " />
						<xsl:with-param name="width" select="$width" />
						<xsl:with-param name="height" select="$height" />
						<xsl:with-param name="koef.x" select="$width div $x.from" />
						<xsl:with-param name="koef.y" select="$height div $y.from" />
					</xsl:call-template>
				</svg:g>
			</svg:svg>
		</xsl:if>
	</xsl:template>

	<!-- Create svg:path tag. -->
	<!-- path - value from 'path' attribute. -->
	<!-- filter - filter for ParsePath template. -->
	<!-- x - value for 'x' attribute. -->
	<!-- y - value for 'y' attribute. -->
	<!-- width - value for 'width' attribute. -->
	<!-- height - value for 'height' attribute. -->
	<!-- koef.x - coefficient for multiplying on each x coordinate. -->
	<!-- koef.y - coefficient for multiplying on each y coordinate. -->
	<!-- base.x - base value to add on each x coordinate. -->
	<!-- base.y - base value to add on each y coordinate. -->
	<xsl:template name="CreateSvgPath">
		<xsl:param name="path" select="''" />
		<xsl:param name="filter" select="'all'" />
		<xsl:param name="x" select="0" />
		<xsl:param name="y" select="0" />
		<xsl:param name="width" select="0" />
		<xsl:param name="height" select="0" />
		<xsl:param name="koef.x" select="1" />
		<xsl:param name="koef.y" select="1" />
		<xsl:param name="base.x" select="0" />
		<xsl:param name="base.y" select="0" />

		<xsl:variable name="d">
			<xsl:call-template name="ParsePath">
				<xsl:with-param name="path" select="$path" />
				<xsl:with-param name="filter" select="$filter" />
				<xsl:with-param name="base.x" select="$base.x" />
				<xsl:with-param name="base.y" select="$base.y" />
				<xsl:with-param name="koef.x" select="$koef.x" />
				<xsl:with-param name="koef.y" select="$koef.y" />
			</xsl:call-template>
		</xsl:variable>

		<xsl:if test="normalize-space($d) != ''  ">
			<svg:path>
				<xsl:call-template name="ShapeFormat">
					<xsl:with-param name="filled.by.default">
						<xsl:choose>
							<xsl:when test="contains($path, 'wr' ) ">
								false
							</xsl:when> <!-- contains($path, 'at' ) or contains($path, 'ar' ) or contains($path, 
								'wt' ) or -->
							<xsl:otherwise>
								true
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="nofill">
						<xsl:choose>
							<xsl:when test="$filter = 'nofill' or $filter = 'nofillstroke' ">
								true
							</xsl:when>
							<xsl:otherwise>
								false
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="nostroke">
						<xsl:choose>
							<xsl:when test="$filter = 'nostroke' or $filter = 'fillnostroke' ">
								true
							</xsl:when>
							<xsl:otherwise>
								false
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>

				<xsl:attribute name="x"><xsl:value-of select="$x" /></xsl:attribute>
				<xsl:attribute name="y"><xsl:value-of select="$y" /></xsl:attribute>
				<xsl:attribute name="width"><xsl:value-of select="$width" /></xsl:attribute>
				<xsl:attribute name="height"><xsl:value-of select="$height" /></xsl:attribute>
				<xsl:attribute name="d"><xsl:value-of select="$d" /></xsl:attribute>
			</svg:path>
			<xsl:apply-templates select="v:stroke" mode="shape.marker">
				<xsl:with-param name="stroke-color">
					<xsl:choose>
						<xsl:when test="@strokecolor">
							<xsl:value-of select="@strokecolor" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'black'" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:with-param>
			</xsl:apply-templates>
		</xsl:if>
	</xsl:template>
	
	<!-- Set attributes in nested svg:svg tag. -->
	<!-- style - value from 'style' attribute. -->
	<xsl:template name="NestedSvgStyles">
		<xsl:param name="style" select="''" />
		<xsl:call-template name="CSSStyle">
			<xsl:with-param name="style-string" select="$style" />
			<xsl:with-param name="object" select="'rect'" />
		</xsl:call-template>
		<xsl:variable name="width.prev">
			<xsl:call-template name="ParseCSSString">
				<xsl:with-param name="style-string" select="$style" />
				<xsl:with-param name="property-name" select="'width'" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="$width.prev != '' ">
					<xsl:call-template name="ConvertToUserUnits">
						<xsl:with-param name="value" select="$width.prev" />
					</xsl:call-template>
					<!--<xsl:value-of select="$width.prev"/> -->
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="height.prev">
			<xsl:call-template name="ParseCSSString">
				<xsl:with-param name="style-string" select="$style" />
				<xsl:with-param name="property-name" select="'height'" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="height">
			<xsl:choose>
				<xsl:when test="$height.prev != '' ">
					<xsl:call-template name="ConvertToUserUnits">
						<xsl:with-param name="value" select="$height.prev" />
					</xsl:call-template>
					<!--<xsl:value-of select="$height.prev"/> -->
				</xsl:when>
				<xsl:otherwise>
					0
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- viewBox contains($style-string, 'rotation:') -->
		<xsl:attribute name="viewBox">
      <xsl:choose>
        <xsl:when test="not(parent::v:group[@editas='canvas'])">
          <xsl:choose>
            <xsl:when
			test="contains($style, 'rotation:') or contains($style, 'flip:')">
              <!-- Workaround for clipping of rotated pictures -->
              <xsl:value-of
			select="concat(- $width, ', ', - $height, ', ', $width, ', ', $height)" />        
            </xsl:when>
            <xsl:when test="@strokeweight">
              <!-- workaround for clipping thick borders -->
              <xsl:variable name="weight.number">
                <xsl:call-template name="ConvertToUserUnits">
                  <xsl:with-param name="value" select="@strokeweight" />
                </xsl:call-template>
              </xsl:variable>
              <xsl:value-of
			select="concat(-$weight.number div 2, ', ', -$weight.number div 2, ', ', $width, ', ', $height)" />        
            </xsl:when>            
            <xsl:otherwise>
              <xsl:value-of select="concat('0, 0, ', $width, ', ', $height )" />          
            </xsl:otherwise>            
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('0, 0, ', $width, ', ', $height )" />          
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
		<!-- By default attribute 'preserveAspectRatio' has value 'xMidYMid' and 
			forces uniform scaling. We don't need scaling, so set value 'none'. -->
		<xsl:attribute name="preserveAspectRatio">none</xsl:attribute>
		<xsl:attribute name="overflow">visible</xsl:attribute>
	</xsl:template>


	<!-- =========================================================== -->
	<!-- Predefined shapes provide a more compact representation -->
	<!-- of a small number of very frequently encountered drawings. -->
	<!-- Predefined shapes have the same properties as shape element -->
	<!-- except that the type attribute is not permitted. -->
	<!-- =========================================================== -->

	<!-- Predefined rectangle shape. -->
	<xsl:template match="v:rect">
		<xsl:param name="nocanvas" select="'false'" />
		<svg:svg>
			<xsl:call-template name="NestedSvgStyles">
				<xsl:with-param name="style" select="@style" />
			</xsl:call-template>
			<svg:g>
				<xsl:call-template name="ShapeTransform">
					<xsl:with-param name="style-string" select="@style" />
				</xsl:call-template>
				<svg:rect>
					<xsl:call-template name="CSSStyle">
						<xsl:with-param name="style-string" select="@style" />
						<xsl:with-param name="object" select="'rect'" />
					</xsl:call-template>
					<xsl:attribute name="x">0</xsl:attribute>
					<xsl:attribute name="y">0</xsl:attribute>
					<!-- Add shape format attributes -->
					<xsl:call-template name="ShapeFormat" />
				</svg:rect>
				<xsl:apply-templates select="o:*" mode="svg" />
				<xsl:apply-templates select="v:*" />
				<xsl:if test="$nocanvas = 'true' ">
					<xsl:apply-templates select="v:*" mode="svg.text" />
				</xsl:if>
			</svg:g>
		</svg:svg>
	</xsl:template>

	<!-- Predefined round rectangle shape. -->
	<xsl:template match="v:roundrect">
		<xsl:param name="nocanvas" select="'false'" />
		<xsl:variable name="ext-style">
			<xsl:choose>
				<xsl:when test="@arcsize">
					<xsl:value-of select="concat(@style, ';arcsize:', @arcsize)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="@style" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<svg:svg>
			<xsl:call-template name="NestedSvgStyles">
				<xsl:with-param name="style" select="@style" />
			</xsl:call-template>
			<svg:g>
				<xsl:call-template name="ShapeTransform">
					<xsl:with-param name="style-string" select="$ext-style" />
				</xsl:call-template>
				<svg:rect>
					<xsl:call-template name="CSSStyle">
						<xsl:with-param name="style-string" select="$ext-style" />
						<xsl:with-param name="object" select="'rect'" />
					</xsl:call-template>
					<xsl:attribute name="x">0</xsl:attribute>
					<xsl:attribute name="y">0</xsl:attribute>

					<!-- Add shape format attributes -->
					<xsl:call-template name="ShapeFormat" />
				</svg:rect>
				<xsl:apply-templates select="o:*" mode="svg" />
				<xsl:apply-templates select="v:*" />
				<xsl:if test="$nocanvas = 'true' ">
					<xsl:apply-templates select="v:*" mode="svg.text" />
				</xsl:if>
			</svg:g>
		</svg:svg>
	</xsl:template>

	<!-- Predefined line shape. -->
	<xsl:template match="v:line">
		<svg:g>
			<xsl:call-template name="ShapeTransform">
				<xsl:with-param name="style-string" select="@style" />
			</xsl:call-template>
			<svg:line>
				<xsl:variable name="from">
					<xsl:call-template name="Parse2D">
						<xsl:with-param name="string-2D" select="@from" />
						<xsl:with-param name="defaults" select="'0,0'" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="to">
					<xsl:call-template name="Parse2D">
						<xsl:with-param name="string-2D" select="@to" />
						<xsl:with-param name="defaults" select="'10,10'" />
					</xsl:call-template>
				</xsl:variable>
				<!-- x1, y1, x2, y2 attributes -->
				<xsl:attribute name="x1">
                  <xsl:call-template name="ConvertToUserUnits">
                    <xsl:with-param name="value"
					select="substring-before($from,',')" />
                  </xsl:call-template>
                  <!--<xsl:value-of select="substring-before($from,',')"/>-->
                </xsl:attribute>
				<xsl:attribute name="y1">
                  <xsl:call-template name="ConvertToUserUnits">
                    <xsl:with-param name="value"
					select="substring-after($from,',')" />
                  </xsl:call-template>
                  <!--<xsl:value-of select="substring-after($from,',')"/>-->
                </xsl:attribute>
				<xsl:attribute name="x2">
                  <xsl:call-template name="ConvertToUserUnits">
                    <xsl:with-param name="value"
					select="substring-before($to,',')" />
                  </xsl:call-template>
                  <!--<xsl:value-of select="substring-before($to,',')"/>-->
                </xsl:attribute>
				<xsl:attribute name="y2">
                  <xsl:call-template name="ConvertToUserUnits">
                    <xsl:with-param name="value"
					select="substring-after($to,',')" />
                  </xsl:call-template>
                  <!--<xsl:value-of select="substring-after($to,',')"/>-->
                </xsl:attribute>
				<!-- Add shape format attributes -->
				<xsl:call-template name="ShapeFormat" />
				<xsl:apply-templates select="v:stroke" mode="shape.marker">
					<xsl:with-param name="stroke-color">
						<xsl:choose>
							<xsl:when test="@strokecolor">
								<xsl:value-of select="@strokecolor" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'black'" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:apply-templates>
			</svg:line>
			<xsl:apply-templates select="o:*" mode="svg" />
			<xsl:apply-templates select="v:*" />
		</svg:g>
	</xsl:template>

	<!-- Predefined polyline shape. -->
	<xsl:template match="v:polyline">
		<!--<svg:polyline> </svg:polyline> -->
	</xsl:template>

	<!-- Predefined oval shape. -->
	<xsl:template match="v:oval">
		<xsl:param name="nocanvas" select="'false'" />
		<svg:svg>
			<xsl:call-template name="NestedSvgStyles">
				<xsl:with-param name="style" select="@style" />
			</xsl:call-template>
			<svg:g>
				<xsl:call-template name="ShapeTransform">
					<xsl:with-param name="style-string" select="@style" />
				</xsl:call-template>
				<svg:ellipse>
					<xsl:call-template name="CSSStyle">
						<xsl:with-param name="style-string" select="@style" />
						<xsl:with-param name="object" select="'oval'" />
					</xsl:call-template>
					<!-- Add shape format attributes -->
					<xsl:call-template name="ShapeFormat" />
				</svg:ellipse>
				<xsl:apply-templates select="o:*" mode="svg" />
				<xsl:apply-templates select="v:*" />
				<xsl:if test="$nocanvas = 'true' ">
					<xsl:apply-templates select="v:*" mode="svg.text" />
				</xsl:if>
			</svg:g>
		</svg:svg>
	</xsl:template>

	<!-- Predefined curve shape. -->
	<xsl:template match="v:curve">
	</xsl:template>

	<!-- Predefined arc shape. -->
	<xsl:template match="v:arc">
	</xsl:template>

	<!-- Predefined image shape. -->
	<xsl:template match="v:image">
	</xsl:template>


	<!-- =========== -->
	<!-- Text in VML -->
	<!-- =========== -->

	<!-- Attach text to a shape. -->
	<xsl:template match="v:textbox" mode="svg.text">
		<xsl:variable name="style">
			<xsl:choose>
				<xsl:when test="@inset">
					<xsl:value-of select="concat(../@style, ';inset:', @inset)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="../@style" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- the outline rectangle -->
		<svg:rect stroke="none" stroke-width="1"> <!-- stroke="black" fill="white" -->
			<xsl:choose>
				<xsl:when test="parent::v:shape/parent::v:group[@editas='canvas']">
					<xsl:attribute name="x">
                    <xsl:choose>
                      <xsl:when test="contains($style, 'left:')">
                        <xsl:call-template name="ConvertToUserUnits">
                          <xsl:with-param name="value">
                            <xsl:call-template name="ParseCSSString">
                              <xsl:with-param name="style-string"
						select="$style" />
                              <xsl:with-param name="property-name"
						select="'left'" />
                            </xsl:call-template>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
					<xsl:attribute name="y">
                    <xsl:choose>
                      <xsl:when test="contains($style, 'top:')">
                        <xsl:call-template name="ConvertToUserUnits">
                          <xsl:with-param name="value">
                            <xsl:call-template name="ParseCSSString">
                              <xsl:with-param name="style-string"
						select="$style" />
                              <xsl:with-param name="property-name"
						select="'top'" />
                            </xsl:call-template>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:when>
                      <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="x">0</xsl:attribute>
					<xsl:attribute name="y">0</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:attribute name="width">
                <xsl:choose>
                  <xsl:when test="contains($style, 'width:')">
                    <xsl:call-template name="ConvertToUserUnits">
                      <xsl:with-param name="value">
                        <xsl:call-template name="ParseCSSString">
                          <xsl:with-param name="style-string"
				select="$style" />
                          <xsl:with-param name="property-name"
				select="'width'" />
                        </xsl:call-template>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
			<xsl:attribute name="height">
                <xsl:choose>
                  <xsl:when test="contains($style, 'height:')">
                    <xsl:call-template name="ConvertToUserUnits">
                      <xsl:with-param name="value">
                        <xsl:call-template name="ParseCSSString">
                          <xsl:with-param name="style-string"
				select="$style" />
                          <xsl:with-param name="property-name"
				select="'height'" />
                        </xsl:call-template>
                      </xsl:with-param>
                    </xsl:call-template>    
                  </xsl:when>
                  <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
		</svg:rect>
		<xsl:apply-templates select="w:txbxContent">
			<xsl:with-param name="style" select="$style" />
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- Represents the contents of a text box. -->
	<xsl:template match="w:txbxContent">
		<xsl:param name="style" />
		<!-- the text contained in the textbox -->
		<xsl:apply-templates select="w:p" mode="svg">
			<xsl:with-param name="style" select="$style" />
		</xsl:apply-templates>
	</xsl:template>

	<!-- Represents a text. -->
	<xsl:template match="w:p" mode="svg">
		<!-- "w:p[parent::w:txbxContent]" -->
		<xsl:param name="style" />
		<svg:text>
			<!-- Set text formatting -->
			<!-- Check if textbox placed in canvas -->
			<xsl:variable name="inCanvas">
				<xsl:choose>
					<xsl:when test="ancestor::v:group[@editas='canvas']">
						1
					</xsl:when>
					<xsl:otherwise>
						0
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:attribute name="fill">black</xsl:attribute>
			<xsl:attribute name="font-family">
                <xsl:value-of select="'Times New Roman'" />
              </xsl:attribute>
			<xsl:variable name="font-size">
				<xsl:call-template name="ConvertToUserUnits">
					<xsl:with-param name="value">
						<xsl:choose>
							<xsl:when test="$inCanvas=1">
								<xsl:value-of select="concat(144, 'pt')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="concat(12, 'pt')" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:attribute name="font-size">
                <xsl:value-of select="$font-size" />
              </xsl:attribute>
			<xsl:variable name="default-x">
				<xsl:choose>
					<xsl:when test="$inCanvas=1">
						<xsl:value-of select="40" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="8" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="default-y">
				<xsl:choose>
					<xsl:when test="$inCanvas=1">
						<xsl:value-of select="40" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="8" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="delta-between-lines">
				<xsl:choose>
					<xsl:when test="$inCanvas=1">
						<xsl:value-of select="32" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="3" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- Set current text position -->
			<xsl:variable name="x0">
				<xsl:choose>
					<xsl:when test="$inCanvas=1">
						<xsl:choose>
							<xsl:when test="contains($style, 'left:')">
								<xsl:call-template name="ConvertToUserUnits">
									<xsl:with-param name="value">
										<xsl:call-template name="ParseCSSString">
											<xsl:with-param name="style-string" select="$style" />
											<xsl:with-param name="property-name" select="'left'" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>0</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="y0">
				<xsl:choose>
					<xsl:when test="$inCanvas=1">
						<xsl:choose>
							<xsl:when test="contains($style, 'top:')">
								<xsl:call-template name="ConvertToUserUnits">
									<xsl:with-param name="value">
										<xsl:call-template name="ParseCSSString">
											<xsl:with-param name="style-string" select="$style" />
											<xsl:with-param name="property-name" select="'top'" />
										</xsl:call-template>
									</xsl:with-param>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								0
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						0
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- output x, y pair of the first glyph -->
			<xsl:attribute name="x">
                  <xsl:value-of select="$x0 + $default-x" />
              </xsl:attribute>
			<xsl:variable name="cnt" select="count(preceding-sibling::w:p)" />
			<xsl:attribute name="y">
                  <xsl:value-of
				select="$y0 + $font-size  * ($cnt + 1) + $delta-between-lines * $cnt + $default-y" />
              </xsl:attribute>
			<!-- Apply text spans -->
			<xsl:apply-templates select="*" mode="svg" />
		</svg:text>
	</xsl:template>

	<!-- Represents a text span. -->
	<xsl:template match="w:r" mode="svg">
		<!-- "w:r[ancestor::w:txbxContent]" -->
		<svg:tspan>
			<xsl:apply-templates select="*" mode="svg" />
		</svg:tspan>
	</xsl:template>

	<!-- Text content -->
	<xsl:template match="w:t" mode="svg">
		<!-- "w:r[ancestor::w:txbxContent]" -->
		<xsl:value-of select="." />
	</xsl:template>

	<!-- Defines preserveAspectRatio attribute in SVG -->
	<xsl:template match="o:lock" mode="svg">
	</xsl:template>


	<!-- =================== -->
	<!-- Auxiliary templates -->
	<!-- =================== -->

	<!-- The template parses an CSS style. -->
	<xsl:template name="CSSStyle">
		<xsl:param name="style-string" />
		<xsl:param name="object" />
		<!-- width -->
		<xsl:variable name="width">
			<xsl:if test="contains($style-string, 'width:')">
				<xsl:call-template name="ParseCSSString">
					<xsl:with-param name="style-string" select="$style-string" />
					<xsl:with-param name="property-name" select="'width'" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<!-- Number value of width -->
		<xsl:variable name="width.number">
			<xsl:call-template name="ConvertToUserUnits">
				<xsl:with-param name="value" select="$width" />
			</xsl:call-template>
		</xsl:variable>
		<!-- height -->
		<xsl:variable name="height">
			<xsl:if test="contains($style-string, 'height:')">
				<xsl:call-template name="ParseCSSString">
					<xsl:with-param name="style-string" select="$style-string" />
					<xsl:with-param name="property-name" select="'height'" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<!-- Number value of height -->
		<xsl:variable name="height.number">
			<xsl:call-template name="ConvertToUserUnits">
				<xsl:with-param name="value" select="$height" />
			</xsl:call-template>
		</xsl:variable>
		<!-- left -->
		<xsl:variable name="left">
			<xsl:if test="contains($style-string, 'left:')">
				<xsl:call-template name="ConvertToUserUnits">
					<xsl:with-param name="value">
						<xsl:call-template name="ParseCSSString">
							<xsl:with-param name="style-string" select="$style-string" />
							<xsl:with-param name="property-name" select="'left'" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<!-- top -->
		<xsl:variable name="top">
			<xsl:if test="contains($style-string, 'top:')">
				<xsl:call-template name="ConvertToUserUnits">
					<xsl:with-param name="value">
						<xsl:call-template name="ParseCSSString">
							<xsl:with-param name="style-string" select="$style-string" />
							<xsl:with-param name="property-name" select="'top'" />
						</xsl:call-template>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<!-- arcsize -->
		<xsl:variable name="arcsize">
			<xsl:if test="contains($style-string, 'arcsize:')">
				<xsl:call-template name="ParseCSSString">
					<xsl:with-param name="style-string" select="$style-string" />
					<xsl:with-param name="property-name" select="'arcsize'" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<!-- Number value of arcsize -->
		<xsl:variable name="arcsize.number">
			<xsl:call-template name="ConvertToUserUnits">
				<xsl:with-param name="value" select="$arcsize" />
			</xsl:call-template>
		</xsl:variable>
		<!-- inset -->
		<xsl:variable name="inset">
			<xsl:if test="contains($style-string, 'inset:')">
				<xsl:call-template name="ParseCSSString">
					<xsl:with-param name="style-string" select="$style-string" />
					<xsl:with-param name="property-name" select="'inset'" />
				</xsl:call-template>
			</xsl:if>
		</xsl:variable>
		<!-- Set attributes -->
		<xsl:choose>
			<xsl:when test="$object='image'">
				<xsl:if test="string-length($width)!=0">
					<xsl:attribute name="content-width">
                <xsl:value-of select="$width" />
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($height)!=0">
					<xsl:attribute name="content-height">
                <xsl:value-of select="$height" />
              </xsl:attribute>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$object='rect'">
				<xsl:if test="string-length($width)!=0">
					<xsl:attribute name="width">
                <xsl:value-of select="$width.number" />
                <!--<xsl:value-of select="$width"/>-->
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($height)!=0">
					<xsl:attribute name="height">
                <xsl:value-of select="$height.number" />
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($left)!=0">
					<xsl:attribute name="x">
                <xsl:value-of select="$left" />
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($top)!=0">
					<xsl:attribute name="y">
                <xsl:value-of select="$top" />
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($arcsize)!=0">
					<xsl:choose>
						<xsl:when test="$height &lt; $width">
							<xsl:attribute name="rx"><xsl:value-of
								select="$arcsize.number * $height.number" /></xsl:attribute>
							<xsl:attribute name="ry"><xsl:value-of
								select="$arcsize.number * $height.number" /></xsl:attribute>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="rx"><xsl:value-of
								select="$arcsize.number * $width.number" /></xsl:attribute>
							<xsl:attribute name="ry"><xsl:value-of
								select="$arcsize.number * $width.number" /></xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$object='oval'">
				<xsl:variable name="x.half" select="$width.number div 2" />
				<xsl:variable name="y.half" select="$height.number div 2" />
				<xsl:if test="string-length($width)!=0">
					<xsl:attribute name="rx">
                <xsl:value-of select="$x.half" />
                <!--<xsl:value-of select="$width.number div 2"/>-->
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($height)!=0">
					<xsl:attribute name="ry">
                <xsl:value-of select="$y.half" />
                <!--<xsl:value-of select="$height.number div 2"/>-->
              </xsl:attribute>
				</xsl:if>
				<!--<xsl:if test="string-length($left)!=0"> -->
				<xsl:attribute name="cx">
                  <xsl:value-of select="$x.half" />
                  <!--<xsl:value-of select="$width.number div 2"/>--> <!-- $left + ($width div 2) -->
                </xsl:attribute>
				<!--</xsl:if> -->
				<!--<xsl:if test="string-length($top)!=0"> -->
				<xsl:attribute name="cy">
                <xsl:value-of select="$y.half" />
                <!--<xsl:value-of select="$height.number div 2"/> --><!-- $top + ($height div 2) -->
              </xsl:attribute>
				<!--</xsl:if> -->
			</xsl:when>
			<xsl:when test="$object='text'">
				<xsl:if test="string-length($left)!=0 and string-length($top)!=0">
					<xsl:variable name="inset-left">
						<!-- width=153pt, height=54pt, viewBox=(2400 836) -->
						<!-- Hence, horizontal 7.2pt = 7.2/153 * 2400 = 112.94 -->
						<!-- vertical 3.6pt = 3.6/54 * 836 = 55.73 -->
						<xsl:call-template name="ParseCoordVector">
							<xsl:with-param name="string-vector" select="$inset" />
							<xsl:with-param name="defaults" select="'112.94,55.73,112.94,55.73'" />
							<xsl:with-param name="side" select="'left'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="inset-top">
						<!-- width=153pt, height=54pt, viewBox=(2400 836) -->
						<!-- Hence, horizontal 7.2pt = 7.2/153 * 2400 = 112.94 -->
						<!-- vertical 3.6pt = 3.6/54 * 836 = 55.73 -->
						<xsl:call-template name="ParseCoordVector">
							<xsl:with-param name="string-vector" select="$inset" />
							<xsl:with-param name="defaults" select="'112.94,55.73,112.94,55.73'" />
							<xsl:with-param name="side" select="'top'" />
						</xsl:call-template>
					</xsl:variable>
					<!-- concat 4 translate(): -->
					<!-- (left,top) of the parent shape -->
					<!-- (left, top) of the text inset -->
					<!-- 1/2 em and 1/2 ex (vertical) -->
					<xsl:attribute name="transform">
                <xsl:value-of
						select="concat('translate(', $left, ' ', $top, ') ')" />
                <xsl:value-of
						select="concat('translate(', $inset-left, ' ', $inset-top, ') ')" />
                <xsl:value-of select="'translate(0 0.5em) '" />
                <xsl:value-of select="'translate(0 0.5ex)'" />
              </xsl:attribute>
				</xsl:if>
			</xsl:when>

			<xsl:otherwise>
				<xsl:if test="string-length($width)!=0">
					<xsl:attribute name="width">
                <xsl:value-of select="$width" />
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($height)!=0">
					<xsl:attribute name="height">
                <xsl:value-of select="$height" />
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($left)!=0">
					<xsl:attribute name="left">
                <xsl:value-of select="$left" />
              </xsl:attribute>
				</xsl:if>
				<xsl:if test="string-length($top)!=0">
					<xsl:attribute name="top">
                <xsl:value-of select="$top" />
              </xsl:attribute>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- The template parses a style-string. -->
	<xsl:template name="ParseCSSString">
		<xsl:param name="style-string" />
		<xsl:param name="property-name" />
		<xsl:variable name="ext-property-name" select="concat($property-name, ':')" />
		<xsl:variable name="value-with-trailing">
			<xsl:choose>
				<xsl:when test="starts-with($style-string, $ext-property-name)">
					<xsl:value-of select="substring-after($style-string, $ext-property-name)" />
				</xsl:when>
				<xsl:when
					test="contains($style-string, concat(';',  $ext-property-name) )">
					<xsl:value-of
						select="substring-after($style-string, concat(';',  $ext-property-name) )" />
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$value-with-trailing != '' ">
			<xsl:variable name="fractional-value">
				<xsl:choose>
					<xsl:when test="contains($value-with-trailing, ';')">
						<xsl:value-of select="substring-before($value-with-trailing, ';')" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$value-with-trailing" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="value">
				<!--<xsl:choose> <xsl:when test="contains($fractional-value, 'f')"> <xsl:value-of 
					select="concat('0.', substring-before($fractional-value, 'f'))"/> </xsl:when> 
					<xsl:otherwise><xsl:value-of select="$fractional-value"/></xsl:otherwise> 
					</xsl:choose> -->
				<xsl:call-template name="ConvertFractionalValue">
					<xsl:with-param name="fractional-value" select="$fractional-value" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of select="$value" />
		</xsl:if>
	</xsl:template>

	<!-- The template parses an 2-D string. -->
	<xsl:template name="Parse2D">
		<xsl:param name="string-2D" />
		<xsl:param name="defaults" />
		<xsl:choose>
			<xsl:when test="$string-2D">
				<xsl:value-of select="$string-2D" />
			</xsl:when>
			<xsl:otherwise>
				<!-- default values -->
				<xsl:value-of select="$defaults" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- The template parses a coord vector -->
	<xsl:template name="ParseCoordVector">
		<xsl:param name="string-vector" />
		<xsl:param name="defaults" />
		<xsl:param name="side" />
		<xsl:param name="delimiter" select="','" />
		<xsl:choose>
			<xsl:when test="$side='left'">
				<xsl:choose>
					<xsl:when test="substring-before($string-vector, $delimiter) != ''">
						<xsl:value-of select="substring-before($string-vector, $delimiter)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before($defaults, $delimiter)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$side='top'">
				<xsl:choose>
					<xsl:when
						test="substring-before(substring-after($string-vector, $delimiter), $delimiter) != ''">
						<xsl:value-of
							select="substring-before(substring-after($string-vector, $delimiter), $delimiter)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="substring-before(substring-after($defaults, $delimiter), $delimiter)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$side='right'">
				<xsl:choose>
					<xsl:when
						test="substring-before(substring-after(substring-after($string-vector, $delimiter), $delimiter), $delimiter) != ''">
						<xsl:value-of
							select="substring-before(substring-after(substring-after($string-vector, $delimiter), $delimiter), $delimiter)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="substring-before(substring-after(substring-after($defaults, $delimiter), $delimiter), $delimiter)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$side='bottom'">
				<xsl:choose>
					<xsl:when
						test="substring-after(substring-after(substring-after($string-vector, $delimiter), $delimiter), $delimiter) != ''">
						<xsl:value-of
							select="substring-after(substring-after(substring-after($string-vector, $delimiter), $delimiter), $delimiter)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="substring-after(substring-after(substring-after($defaults, $delimiter), $delimiter), $delimiter)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise />
		</xsl:choose>
	</xsl:template>

	<!-- Set format attributes for shape. -->
	<!-- Parent elements: v:rect | v:roundrect | v:line | v:oval | <other shape> -->
	<xsl:template name="ShapeFormat">
		<xsl:param name="filled.by.default" select="'true'" />
		<xsl:param name="nofill" select="'false'" />
		<xsl:param name="nostroke" select="'false'" />
		<xsl:variable name="type" select="substring(@type, 2)" />
		<xsl:variable name="filled">
			<xsl:choose>
				<xsl:when test="@filled">
					<xsl:value-of select="@filled" />
				</xsl:when>
				<xsl:when test="//v:shapetype[@id = $type]/@filled">
					<xsl:value-of select="//v:shapetype[@id = $type]/@filled" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="stroked">
			<xsl:choose>
				<xsl:when test="@stroked">
					<xsl:value-of select="@stroked" />
				</xsl:when>
				<xsl:when test="//v:shapetype[@id = $type]/@stroked">
					<xsl:value-of select="//v:shapetype[@id = $type]/@stroked" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$nostroke != 'true' and $stroked != 'f' ">
				<!-- strokecolor -->
				<xsl:choose>
					<xsl:when test="@strokecolor">
						<xsl:attribute name="stroke"><xsl:value-of
							select="@strokecolor" /></xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="stroke"><xsl:text>black</xsl:text></xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:variable name="inCanvas">
					<xsl:choose>
						<!-- Test whether graphics placed into canvas -->
						<xsl:when test="parent::v:group[@editas='canvas']">
							1
						</xsl:when>
						<xsl:otherwise>
							0
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<!-- strokeweight -->
				<xsl:variable name="svgStrokeweight">
					<xsl:choose>
						<xsl:when test="@strokeweight">
							<xsl:variable name="origStrokeweight">
								<xsl:value-of select="@strokeweight" />
							</xsl:variable>
							<xsl:variable name="unit"
								select="translate($origStrokeweight, '0123456789.', '')" />
							<xsl:choose>
								<xsl:when test="not($unit)">
									<xsl:value-of select="$origStrokeweight" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="numeric-value">
										<xsl:call-template name="ToNumber">
											<xsl:with-param name="Val" select="$origStrokeweight" />
										</xsl:call-template>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$unit = 'pt' and $inCanvas = 1">
											<xsl:value-of
												select="concat(round($stroke.weight.coeff* $numeric-value), 'pt')" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$origStrokeweight" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<!-- normal lines width -->
							<xsl:choose>
								<xsl:when test="$inCanvas=1">
									<xsl:value-of select="concat(round($stroke.weight.coeff*0.75), 'pt')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat(0.75, 'pt')" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:attribute name="stroke-width">
          <xsl:value-of select="$svgStrokeweight" />
        </xsl:attribute>
				<!-- Line style processing (solid, dashed...) -->
				<xsl:apply-templates select="v:stroke" mode="shape.style">
					<xsl:with-param name="stroke.width">
						<xsl:value-of select="number(substring-before($svgStrokeweight, 'pt'))" />
					</xsl:with-param>
					<xsl:with-param name="inCanvas" select="$inCanvas" />
				</xsl:apply-templates>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="stroke">none</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$nofill != 'true' ">
			<!-- Fill color -->
			<xsl:choose>
				<xsl:when test="$filled = 'f' "></xsl:when> <!-- filled = 'false' -->
				<xsl:when test="@fillcolor">
					<xsl:attribute name="fill"><xsl:value-of
						select="@fillcolor" /></xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$filled.by.default = 'true' or $filled = 't' ">
						<xsl:attribute name="fill">white</xsl:attribute>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
			<!-- Fill opacity (transparency) -->
			<xsl:if test="v:fill/@opacity">
				<xsl:attribute name="fill-opacity">
              <xsl:call-template name="ConvertOpacity">
                <xsl:with-param name="opacity" select="v:fill/@opacity" />
              </xsl:call-template>
            </xsl:attribute>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Processing shapes lines styles -->
	<!-- Param: stroke.width - width of shape line in pt -->
	<xsl:template match="v:stroke" mode="shape.style">
		<xsl:param name="stroke.width" />
		<xsl:param name="inCanvas" select="1" />
		<!-- getting shape lines dashed coefficient depending on lines width -->
		<xsl:variable name="stroke.coeff">
			<xsl:choose>
				<xsl:when test="stroke.width = 'NaN' or $inCanvas = 0">
					<xsl:value-of select="0.125" /> <!-- coefficient set by experiment -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of
						select="number($stroke.width div $stroke.weight.coeff div 0.75)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- dash line style processing -->
		<xsl:if test="@dashstyle">
			<xsl:choose>
				<xsl:when test="@dashstyle = 'dash'">  <!-- dashed lines -->
					<xsl:attribute name="stroke-dasharray">
						<xsl:value-of select="concat(round(47*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100)" /> <!-- 47 and 35 -  suitable values for dashed lines with line width = 1pt-->
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="@dashstyle = '1 1'"> <!-- dotted lines -->
					<xsl:choose>
						<xsl:when test="@endcap">
							<xsl:choose>
								<xsl:when test="@endcap = 'round'">  <!-- rounding lines ends -->
									<xsl:attribute name="stroke-dasharray">
										<xsl:value-of select="concat(0, ',', round(24*$stroke.coeff*100) div 100)" /> <!-- there is no dotted line support in SVG - so using lines segments with rounded ends for dots emulation.  0 and 24 -  suitable values for dotted lines with line width = 1pt-->
									</xsl:attribute>
									<xsl:attribute name="stroke-linecap">round</xsl:attribute>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="stroke-dasharray">
								<xsl:value-of select="concat(round(11.7*$stroke.coeff*100) div 100, ',', round(11.77*$stroke.coeff*100) div 100)" /> <!-- there is no dotted line support in SVG - so using lines segments with rounded ends for dots emulation.  11.7 and 11.77 -  suitable values for dotted lines with line width = 1pt-->
							</xsl:attribute>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@dashstyle = 'dashDot'"> <!-- dash-dot-dash line style -->
					<xsl:attribute name="stroke-dasharray">  <!-- 47,5 and 35 -  suitable values for dashed lines with line width = 1pt-->
						<xsl:value-of select="concat(round(47*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100, ',', round(12*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100)" />  <!-- 47-35-12-35 -->
          			</xsl:attribute>
				</xsl:when>
				<xsl:when test="@dashstyle = 'longDash'"> <!-- double dash line style -->
					<xsl:attribute name="stroke-dasharray">  <!-- 95 and 35 -  suitable values for dashed lines with line width = 1pt-->
						<xsl:value-of select="concat(round(95*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100)" />  <!-- 95-35 -->
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="@dashstyle = 'longDashDot'"> <!-- double dash-dot-double dash line style -->
					<xsl:attribute name="stroke-dasharray">  <!-- 95 and 35 -  suitable values for dashed lines with line width = 1pt-->
						<xsl:value-of select="concat(round(95*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100, ',', round(12*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100)" />  <!-- 95-35-12-35 -->
					</xsl:attribute>
				</xsl:when>
				<xsl:when test="@dashstyle = 'longDashDotDot'"> <!-- double dash-dot-dot-double dash line style -->
					<xsl:attribute name="stroke-dasharray">  <!-- 95 and 35 -  suitable values for dashed lines with line width = 1pt-->
						<xsl:value-of select="concat(round(95*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100, ',', round(12*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100, ',', round(12*$stroke.coeff*100) div 100, ',', round(35*$stroke.coeff*100) div 100)" />  <!-- 95-35-12-12-35 -->
					</xsl:attribute>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<!-- arrows for start and end -->
		<xsl:variable name="node.count">
			<xsl:value-of
				select="count(parent::node()/preceding-sibling::node()[v:stroke and not(self::v:shapetype)]) + 1" />
		</xsl:variable>
		<xsl:if test="@startarrow">
			<xsl:attribute name="marker-start">
        		<xsl:value-of select="concat('url(#arrow-start', $node.count, ')')" />
    		</xsl:attribute>
		</xsl:if>
		<xsl:if test="@endarrow">
			<xsl:attribute name="marker-end">
        		<xsl:value-of select="concat('url(#arrow-end', $node.count, ')')" />
      		</xsl:attribute>
		</xsl:if>
	</xsl:template>
  
	<xsl:template match="v:stroke" mode="shape.marker">
		<xsl:param name="stroke-color" select="'black'" />
		<xsl:variable name="node.count">
			<xsl:value-of
				select="count(parent::node()/preceding-sibling::node()[v:stroke and not(self::v:shapetype)]) + 1" />
		</xsl:variable>
		<svg:defs>
			<xsl:if test="@startarrow">
				<xsl:call-template name="CreateMarker">
					<xsl:with-param name="marker.size">
						<xsl:call-template name="ConvertSwInMs">
							<xsl:with-param name="strokeweight" select="../@strokeweight" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="marker.type" select="@startarrow" />
					<xsl:with-param name="marker.width" select="@startarrowwidth" />
					<xsl:with-param name="marker.length" select="@startarrowlength" />
					<xsl:with-param name="marker.end" select="0" />
					<xsl:with-param name="marker.color" select="$stroke-color" />
					<xsl:with-param name="marker.count" select="$node.count" />
				</xsl:call-template>
			</xsl:if>
			<xsl:if test="@endarrow">
				<xsl:call-template name="CreateMarker">
					<xsl:with-param name="marker.size">
						<xsl:call-template name="ConvertSwInMs">
							<xsl:with-param name="strokeweight" select="../@strokeweight" />
						</xsl:call-template>
					</xsl:with-param>
					<xsl:with-param name="marker.type" select="@endarrow" />
					<xsl:with-param name="marker.width" select="@endarrowwidth" />
					<xsl:with-param name="marker.length" select="@endarrowlength" />
					<xsl:with-param name="marker.color" select="$stroke-color" />
					<xsl:with-param name="marker.count" select="$node.count" />
				</xsl:call-template>
			</xsl:if>
		</svg:defs>
	</xsl:template>


	<!-- Convert strokeweight (Sw) in marker size (Ms) -->
	<xsl:template name="ConvertSwInMs">
		<xsl:param name="strokeweight" />
		<xsl:variable name="tmp">
			<xsl:call-template name="GetCipher">
				<xsl:with-param name="str" select="$strokeweight" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="$tmp = '' ">2.67</xsl:when> <!-- 0.75pt by default -->
				<xsl:when test="$tmp &lt;= 1">
					<xsl:value-of select="2 div $tmp" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string($result) != 'NaN' ">
				<xsl:value-of select="$result" />
			</xsl:when>
			<xsl:otherwise>2</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="CreateMarker">
		<xsl:param name="marker.size" select="1.7" />
		<xsl:param name="marker.type" select="classic" />
		<xsl:param name="marker.width" select="''" />
		<xsl:param name="marker.length" select="''" />
		<xsl:param name="marker.end" select="1" />
		<xsl:param name="marker.color" select="'black'" />
		<xsl:param name="marker.count" />
		<!-- marker.width -> ('narrow', '', 'wide' ) -->
		<!-- marker.length -> ('short', '', 'long' ) -->
		<xsl:variable name="koef.y">
			<xsl:choose>
				<xsl:when test="$marker.width = 'narrow' ">0.9</xsl:when>
				<xsl:when test="$marker.width = 'wide' ">2.1</xsl:when>
				<xsl:otherwise>1.3</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="koef.x">
			<xsl:choose>
				<xsl:when test="$marker.length = 'short' ">0.9</xsl:when>
				<xsl:when test="$marker.length = 'long' ">2.1</xsl:when>
				<xsl:otherwise>1.3</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<svg:marker markerUnits="strokeWidth" orient="auto">
			<!-- viewBox="0 0 100 100" refY="50" -->
			<xsl:attribute name="refY"><xsl:value-of select="50 * $koef.y" /></xsl:attribute>
			<xsl:attribute name="viewBox"><xsl:value-of
				select="concat('0 0 ', 100 * $koef.x, ' ', 100 * $koef.y )" /></xsl:attribute>
			<!-- markerWidth="8" markerHeight="6" -->
			<xsl:attribute name="markerWidth">
	        <xsl:choose>
	          <xsl:when test="$marker.type = 'open' "><xsl:value-of
				select="$marker.size * 5 * $koef.x * 0.7" /></xsl:when>
	          <xsl:otherwise><xsl:value-of
				select="$marker.size * 4 * $koef.x * 0.7" /></xsl:otherwise>
	        </xsl:choose>
	      </xsl:attribute>
			<xsl:attribute name="markerHeight">
	        <xsl:choose>
	          <xsl:when test="$marker.type = 'open' "><xsl:value-of
				select="$marker.size * 4 * $koef.y * 0.7" /></xsl:when>
	          <xsl:otherwise><xsl:value-of
				select="$marker.size * 3 * $koef.y * 0.7" /></xsl:otherwise>
	        </xsl:choose>
	      </xsl:attribute>
			<xsl:attribute name="stroke">
	        <xsl:value-of select="$marker.color" />
	      </xsl:attribute>
			<xsl:attribute name="fill">
	        <xsl:value-of select="$marker.color" />
	      </xsl:attribute>
			<xsl:choose>
				<xsl:when test="$marker.end=1">
					<xsl:attribute name="id">
	            <xsl:value-of select="concat('arrow-end', $marker.count)" />
	          </xsl:attribute>
					<xsl:choose>
						<xsl:when test="$marker.type='classic'">
							<xsl:attribute name="refX"><xsl:value-of
								select="50 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M 0 0 L ', 50 * $koef.x, ' ', 50 * $koef.y, ' L 0 ', 100 * $koef.y, ' L ', 100 * $koef.x, ' ', 50 * $koef.y, ' z' )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:when test="$marker.type='open'">
							<xsl:attribute name="refX"><xsl:value-of
								select="65 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M ', 10 * $koef.x, ' 0 L ', 100 * $koef.x, ' ', 50 * $koef.y,  ' L ', 10 * $koef.x, ' ', 100 * $koef.y, ' A ', 10 * $koef.x, ' ', 10 * $koef.y, ' 0 0 1 ', 5 * $koef.x, ' ', 80 * $koef.y, ' L ', 60 * $koef.x, ' ', 50 * $koef.y, ' L ', 5 * $koef.x, ' ', 20 * $koef.y, ' A ', 10 * $koef.x, ' ', 10 * $koef.y, ' 0 0 1 ', 10 * $koef.x, ' 0' )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:when test="$marker.type='diamond'">
							<xsl:attribute name="refX"><xsl:value-of
								select="20 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M 0 ', 50 * $koef.y, ' L ', 50 * $koef.x, ' 0 L ', 100 * $koef.x, ' ', 50 * $koef.y, ' L ', 50 * $koef.x, ' ', 100 * $koef.y, ' z' )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:when test="$marker.type='oval'">
							<xsl:attribute name="refX"><xsl:value-of
								select="20 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M 0 ', 50 * $koef.y, ' A ', 50 * $koef.x, ' ', 50 * $koef.y, ' 0 1 0 ', 100 * $koef.x, ' ', 50 * $koef.y, ' A ', 50 * $koef.x, ' ', 50 * $koef.y, ' 0 1 0 0 ', 50 * $koef.y )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="refX"><xsl:value-of
								select="50 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M 0 0 L ', 100 * $koef.x, ' ', 50 * $koef.y, ' L 0 ', 100 * $koef.y, ' z' )" /></xsl:attribute>
							</svg:path>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<!-- arrow for start point -->
					<xsl:attribute name="id">
	            		<xsl:value-of select="concat('arrow-start', $marker.count)" />
	          		</xsl:attribute>
					<xsl:choose>
						<xsl:when test="$marker.type='classic'">
							<xsl:attribute name="refX"><xsl:value-of
								select="50 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M ', 100 * $koef.x, ' 0 L ', 50 * $koef.x, ' ', 50 * $koef.y, ' L ', 100 * $koef.x, ' ', 100 * $koef.y, ' L 0 ', 50 * $koef.y, ' z' )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:when test="$marker.type='open'">
							<xsl:attribute name="refX"><xsl:value-of
								select="35 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M ', 90 * $koef.x, ' 0 L 0 ', 50 * $koef.y,  ' L ', 90 * $koef.x, ' ', 100 * $koef.y, ' A ', 10 * $koef.x, ' ', 10 * $koef.y, ' 0 0 0 ', 95 * $koef.x, ' ', 80 * $koef.y, ' L ', 40 * $koef.x, ' ', 50 * $koef.y, ' L ', 95 * $koef.x, ' ', 20 * $koef.y, ' A ', 10 * $koef.x, ' ', 10 * $koef.y, ' 0 0 0 ', 90 * $koef.x, ' 0' )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:when test="$marker.type='diamond'">
							<xsl:attribute name="refX"><xsl:value-of
								select="80 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M 0 ', 50 * $koef.y, ' L ', 50 * $koef.x, ' 0 L ', 100 * $koef.x, ' ', 50 * $koef.y, ' L ', 50 * $koef.x, ' ', 100 * $koef.y, ' z' )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:when test="$marker.type='oval'">
							<xsl:attribute name="refX"><xsl:value-of
								select="80 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M 0 ', 50 * $koef.y, ' A ', 50 * $koef.x, ' ', 50 * $koef.y, ' 0 1 0 ', 100 * $koef.x, ' ', 50 * $koef.y, ' A ', 50 * $koef.x, ' ', 50 * $koef.y, ' 0 1 0 0 ', 50 * $koef.y )" /></xsl:attribute>
							</svg:path>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="refX"><xsl:value-of
								select="50 * $koef.x" /></xsl:attribute>
							<svg:path>
								<xsl:attribute name="d"><xsl:value-of
									select="concat('M ', 100 * $koef.x, ' 0 L 0 ', 50 * $koef.y, ' L ', 100 * $koef.x, ' ', 100 * $koef.y, ' z' )" /></xsl:attribute>
							</svg:path>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</svg:marker>
	</xsl:template>

	<!-- Set transformation attributes for shape. -->
	<!-- style-string - string with CSS style properties -->
	<xsl:template name="ShapeTransform">
		<xsl:param name="style-string" select="@style" />
		<xsl:param name="figure" select="name(.)" />
		<xsl:variable name="from">
			<xsl:choose>
				<xsl:when test="$figure = 'v:line' ">
					<xsl:call-template name="Parse2D">
						<xsl:with-param name="string-2D" select="@from" />
						<xsl:with-param name="defaults" select="'0,0'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="to">
			<xsl:choose>
				<xsl:when test="$figure = 'v:line' ">
					<xsl:call-template name="Parse2D">
						<xsl:with-param name="string-2D" select="@to" />
						<xsl:with-param name="defaults" select="'10,10'" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- Calculation for line coordinates in svg units -->
		<xsl:variable name="x1">
			<xsl:call-template name="ConvertToUserUnits">
				<xsl:with-param name="value" select="substring-before($from,',')" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="y1">
			<xsl:call-template name="ConvertToUserUnits">
				<xsl:with-param name="value" select="substring-after($from,',')" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x2">
			<xsl:call-template name="ConvertToUserUnits">
				<xsl:with-param name="value" select="substring-before($to,',')" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="y2">
			<xsl:call-template name="ConvertToUserUnits">
				<xsl:with-param name="value" select="substring-after($to,',')" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="$figure = 'v:line' ">
					<xsl:value-of select="translate($x2 - $x1, '-', '' )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="temp">
						<xsl:call-template name="GetCSSProperty">
							<xsl:with-param name="css.string" select="$style-string" />
							<xsl:with-param name="css.property" select="'width'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="ConvertToUserUnits">
						<xsl:with-param name="value" select="$temp" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="height">
			<xsl:choose>
				<xsl:when test="$figure = 'v:line' ">
					<xsl:value-of select="translate($y2 - $y1, '-', '' )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="temp">
						<xsl:call-template name="GetCSSProperty">
							<xsl:with-param name="css.string" select="$style-string" />
							<xsl:with-param name="css.property" select="'height'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="ConvertToUserUnits">
						<xsl:with-param name="value" select="$temp" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="flip.width">
			<xsl:choose>
				<xsl:when test="$figure = 'v:line' ">
					<xsl:value-of select="$width + 2 * $x1 " />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$width" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="flip.height">
			<xsl:choose>
				<xsl:when test="$figure = 'v:line' ">
					<xsl:value-of select="$height + 2 * $y1 " />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$height" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- rotation -->
		<xsl:variable name="rotation">
			<xsl:call-template name="GetCSSProperty">
				<xsl:with-param name="css.string" select="$style-string" />
				<xsl:with-param name="css.property" select="'rotation'" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="rotation.transform">
			<xsl:if test="$rotation != '' ">
				<xsl:variable name="angle">
					<xsl:call-template name="ConvertAngle">
						<xsl:with-param name="angle" select="$rotation" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$figure = 'v:line' ">
						<xsl:variable name="x1.rot" select="($width div 2) + $x1 " />
						<xsl:variable name="y1.rot" select="($height div 2) + $y1 " />
						<xsl:value-of
							select="concat('translate(', $x1.rot, ', ', $y1.rot, ') rotate(', $angle, ') translate(-', $x1.rot, ', -', $y1.rot, ')' )" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="concat('translate(', $width div 2, ', ', $height div 2,
              ') rotate(', $angle, ') translate(-', $width div 2, ', -', $height div 2, ')' )" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<!-- flip -->
		<xsl:variable name="flip">
			<xsl:call-template name="GetCSSProperty">
				<xsl:with-param name="css.string" select="$style-string" />
				<xsl:with-param name="css.property" select="'flip'" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="flip.transform">
			<xsl:if test="$flip != '' ">
				<xsl:choose>
					<xsl:when test="$flip = 'x' ">
						<xsl:value-of
							select="concat('translate(', $flip.width, ', 0) scale(-1, 1)' )" />
					</xsl:when>
					<xsl:when test="$flip = 'y' ">
						<xsl:value-of
							select="concat('translate(0, ', $flip.height, ') scale(1, -1)' )" />
					</xsl:when>
					<xsl:when test="$flip = 'x y' ">
						<xsl:value-of
							select="concat('translate(', $flip.width, ', ' , $flip.height, ') scale(-1, -1)' )" />
					</xsl:when>
				</xsl:choose>
			</xsl:if>
		</xsl:variable>
		<xsl:if test="concat($rotation.transform, $flip.transform) != '' ">
			<xsl:attribute name="transform">
        <xsl:value-of
				select="concat($flip.transform, ' ', $rotation.transform)" />
      </xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!-- Parse value of 'path' attribute of 'shape' and 'shapetype' tags. -->
	<!-- path - string value of 'path' attribute to parse. -->
	<!-- base.x - base value, that need to be added to each absolute x coordinate -->
	<!-- base.y - base value, that need to be added to each absolute y coordinate -->
	<!-- koef.x - coefficient, that need to be multiplyed to each x coordinate -->
	<!-- koef.y - coefficient, that need to be multiplyed to each y coordinate -->
	<!-- filter - filter string. (possible values: 'all', 'nofill', 'nostroke', 
		'fill', 'stroke', 'fillstroke', 'nofillstroke', 'fillnostroke' ) -->
	<!-- last.command - param for recursive calls itself, last processed command. -->
	<!-- current.output - param for recursive calls itself, current output. -->
	<!-- nostroke - param for recursive calls itself, true if this segment is 
		nostroke. -->
	<!-- nofill - param for recursive calls itself, true if this segment is 
		nofill. -->
	<xsl:template name="ParsePath">
		<xsl:param name="path" select="''" />
		<xsl:param name="base.x" select="0" />
		<xsl:param name="base.y" select="0" />
		<xsl:param name="koef.x" select="1" />
		<xsl:param name="koef.y" select="1" />
		<xsl:param name="filter" select="'all'" />
		<xsl:param name="last.command" select="''" />
		<xsl:param name="current.output" select="''" />
		<xsl:param name="nostroke" select="'false'" />
		<xsl:param name="nofill" select="'false'" />
		<xsl:param name="current.x" select="0" />
		<xsl:param name="current.y" select="0" />
		<xsl:if test="string-length($path) > 0">
			<xsl:variable name="path.cleared">
				<xsl:choose>
					<xsl:when test="substring($path, 1, 1) = ',' ">
						<xsl:value-of select="substring($path, 2)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$path" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="tmp1">
				<xsl:call-template name="GetCommand">
					<xsl:with-param name="str"
						select="translate($path.cleared, '@', ',' )" />
				</xsl:call-template>
			</xsl:variable>
			<!-- Supported commands -->
			<xsl:variable name="tmp2">
				<xsl:choose>
					<xsl:when test="starts-with($tmp1, 'm' )">m</xsl:when> <!-- moveto -->
					<xsl:when test="starts-with($tmp1, 't' )">t</xsl:when> <!-- rmoveto -->
					<xsl:when test="starts-with($tmp1, 'l' )">l</xsl:when> <!-- lineto -->
					<xsl:when test="starts-with($tmp1, 'r' )">r</xsl:when> <!-- rlineto -->
					<xsl:when test="starts-with($tmp1, 'c' )">c</xsl:when> <!-- curveto -->
					<xsl:when test="starts-with($tmp1, 'v' )">v</xsl:when> <!-- rcurveto -->
					<xsl:when test="starts-with($tmp1, 'x' )">x</xsl:when> <!-- close -->
					<xsl:when test="starts-with($tmp1, 'e' )">e</xsl:when> <!-- end -->
					<xsl:when test="starts-with($tmp1, 'ae' )">ae</xsl:when> <!-- angleellipseto -->
					<xsl:when test="starts-with($tmp1, 'al' )">al</xsl:when> <!-- angleellipse -->
					<xsl:when test="starts-with($tmp1, 'at' )">at</xsl:when> <!-- arcto -->
					<xsl:when test="starts-with($tmp1, 'ar' )">ar</xsl:when> <!-- arc -->
					<xsl:when test="starts-with($tmp1, 'wa' )">wa</xsl:when> <!-- clockwisearcto -->
					<xsl:when test="starts-with($tmp1, 'wr' )">wr</xsl:when> <!-- clockwisearc -->
					<xsl:when test="starts-with($tmp1, 'nf' )">nf</xsl:when> <!-- nofill -->
					<xsl:when test="starts-with($tmp1, 'ns' )">ns</xsl:when> <!-- nostroke -->
					<xsl:when test="starts-with($tmp1, 'ha' )">ha</xsl:when> <!-- AutoLine -->
					<xsl:when test="starts-with($tmp1, 'hb' )">hb</xsl:when> <!-- AutoCurve -->
					<xsl:when test="starts-with($tmp1, 'hc' )">hc</xsl:when> <!-- CornerLine -->
					<xsl:when test="starts-with($tmp1, 'hd' )">hd</xsl:when> <!-- CornerCurve -->
					<xsl:when test="starts-with($tmp1, 'he' )">he</xsl:when> <!-- SmoothLine -->
					<xsl:when test="starts-with($tmp1, 'hf' )">hf</xsl:when> <!-- SmoothCurve -->
					<xsl:when test="starts-with($tmp1, 'hg' )">hg</xsl:when> <!-- SymmetricLine -->
					<xsl:when test="starts-with($tmp1, 'hh' )">hh</xsl:when> <!-- SymmetricCurve -->
					<xsl:when test="starts-with($tmp1, 'hi' )">hi</xsl:when> <!-- Freeform -->
					<xsl:when test="starts-with($tmp1, 'qx' )">qx</xsl:when> <!-- ellipticalqaudrantx -->
					<xsl:when test="starts-with($tmp1, 'qy' )">qy</xsl:when> <!-- ellipticalquadranty -->
					<xsl:when test="starts-with($tmp1, 'qb' )">qb</xsl:when> <!-- quadraticbezier -->
					<xsl:otherwise>
						<xsl:value-of select="$tmp1" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="command">
				<xsl:choose>
					<xsl:when test="$tmp2 != '' ">
						<xsl:value-of select="$tmp2" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$last.command = 'qx' ">qy</xsl:when> <!-- MS Word feature -->
							<xsl:when test="$last.command = 'qy' ">qx</xsl:when> <!-- MS Word feature -->
							<xsl:when test="$last.command = 'al' ">ae</xsl:when> <!-- MS Word feature -->
							<xsl:otherwise>
								<xsl:value-of select="$last.command" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="params">
				<xsl:choose>
					<xsl:when test="starts-with($path.cleared, $command)">
						<xsl:value-of select="substring-after($path.cleared, $command)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$path.cleared" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="output.tmp">
				<xsl:choose>
					<xsl:when test="$command = 'm' "> <!-- moveto -->
						<!-- Start a new sub-path at the given (x,y) coordinate. -->
						<xsl:text>M </xsl:text>
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="2" />
								<xsl:with-param name="add2param"
									select="concat($base.x, '|', $base.y, '|' )" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$arguments" />
						<xsl:value-of
							select="concat('|', substring-before($arguments, ' ' ), ',', substring-after($arguments, ' ' ) ) " />
					</xsl:when>
					<xsl:when test="$command = 't' "> <!-- rmoveto -->
						<!-- Start a new sub-path at the coordinate (cpx+x, cpy+y). -->
						<xsl:text>m </xsl:text>
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="2" />
								<xsl:with-param name="add2param" select="''" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$arguments" />
						<xsl:value-of
							select="concat('|', substring-before($arguments, ' ' ) + $current.x, ',', substring-after($arguments, ' ' ) + $current.y ) " />
					</xsl:when>
					<xsl:when test="$command = 'l' "> <!-- lineto -->
						<!-- Draw a line from the current point to the given (x,y) coordinate 
							which becomes the new current point. A number of coordinate pairs may be 
							specified to form a polyline. -->
						<xsl:text>L </xsl:text>
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="2" />
								<xsl:with-param name="add2param"
									select="concat($base.x, '|', $base.y, '|' )" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$arguments" />
						<xsl:value-of
							select="concat('|', substring-before($arguments, ' ' ), ',', substring-after($arguments, ' ' ) ) " />
					</xsl:when>
					<xsl:when test="$command = 'r' "> <!-- rlineto -->
						<!-- Draw a line from the current point to the given relative coordinate 
							(cpx+x, cpy+y). -->
						<xsl:text>l </xsl:text>
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="2" />
								<xsl:with-param name="add2param" select="''" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$arguments" />
						<xsl:value-of
							select="concat('|', substring-before($arguments, ' ' ) + $current.x, ',', substring-after($arguments, ' ' ) + $current.y ) " />
					</xsl:when>
					<xsl:when test="$command = 'c' "> <!-- curveto -->
						<!-- Draw a cubic bézier curve from the current point to the coordinate 
							given by the final two parameters, the control points given by the first 
							four parameters. The current point becomes the end point of the bézier.. -->
						<xsl:text>C </xsl:text>
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="6" />
								<xsl:with-param name="add2param"
									select="concat($base.x, '|', $base.y, '|', $base.x, '|', $base.y, '|', $base.x, '|', $base.y, '|' )" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$arguments" />
						<xsl:variable name="tmp">
							<xsl:call-template name="SubstringAfterExt">
								<xsl:with-param name="str" select="$arguments" />
								<xsl:with-param name="separator" select="' '" />
								<xsl:with-param name="count" select="4" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of
							select="concat('|', substring-before($tmp, ' ' ), ',', substring-after($tmp, ' ' )) " />
					</xsl:when>
					<xsl:when test="$command = 'v' "> <!-- rcurveto -->
						<!-- Cubic bézier curve using the given coordinate relative to the 
							current point. -->
						<xsl:text>c </xsl:text>
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="6" />
								<xsl:with-param name="add2param" select="''" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="$arguments" />
						<xsl:variable name="tmp">
							<xsl:call-template name="SubstringAfterExt">
								<xsl:with-param name="str" select="$arguments" />
								<xsl:with-param name="separator" select="' '" />
								<xsl:with-param name="count" select="4" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of
							select="concat('|', substring-before($tmp, ' ' ) + $current.x , ',', substring-after($tmp, ' ' ) + $current.y ) " />
					</xsl:when>
					<xsl:when test="$command = 'ae' or $command = 'al' "> <!-- angleellipseto or angleellipse -->
						<!-- Arguments: center (x,y) size(w,h) start-angle, end-angle. Draw 
							a segment of an ellipse as describes using these parameters. -->
						<!-- angleellipseto - "A straight line is drawn from the current point 
							to the start point of the segment." -->
						<!-- angleellipse - "An implied moveto the starting point of the segment." -->
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="6" />
								<xsl:with-param name="add2param"
									select="concat($base.x, '|', $base.y, '|', 0, '|', 0, '|', 0, '|', 0, '|' )" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|', 1, '|', 1, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="x.c"
							select="substring-before($arguments, ' ' )" />
						<xsl:variable name="arguments.tmp1"
							select="substring-after($arguments, ' ' )" />
						<xsl:variable name="y.c"
							select="substring-before($arguments.tmp1, ' ' )" />
						<xsl:variable name="arguments.tmp2"
							select="substring-after($arguments.tmp1, ' ' )" />
						<xsl:variable name="rx"
							select="substring-before($arguments.tmp2, ' ' )" />
						<xsl:variable name="arguments.tmp3"
							select="substring-after($arguments.tmp2, ' ' )" />
						<xsl:variable name="ry"
							select="substring-before($arguments.tmp3, ' ' )" />
						<xsl:variable name="arguments.tmp4"
							select="substring-after($arguments.tmp3, ' ' )" />
						<xsl:variable name="angle.start"
							select="substring-before($arguments.tmp4, ' ' )" />
						<xsl:variable name="arguments.tmp5"
							select="substring-after($arguments.tmp4, ' ' )" />
						<xsl:variable name="angle.end" select="$arguments.tmp5" />
						<!--<xsl:variable name="rx" select="$width"/> <xsl:variable name="ry" 
							select="$height"/> -->
						<xsl:variable name="angle.start.degree" select="$angle.start div 65536" />
						<xsl:variable name="angle.end.degree.tmp" select="$angle.end div 65536" />
						<!--<xsl:variable name="angle.end.degree.tmp2" select="$angle.start.degree 
							+ $angle.end.degree.tmp"/> -->
						<xsl:variable name="angle.end.degree">
							<xsl:call-template name="FixAngle">
								<xsl:with-param name="angle"
									select="$angle.start.degree + ($angle.end div 65536)" />
								<xsl:with-param name="base" select="180" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="k.start">
							<xsl:call-template name="Tan">
								<xsl:with-param name="x"
									select="$angle.start.degree * $pi div 180" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="k.end">
							<xsl:call-template name="Tan">
								<xsl:with-param name="x"
									select="$angle.end.degree * $pi div 180" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="x.start.module">
							<xsl:call-template name="Sqrt">
								<xsl:with-param name="numb"
									select="1 div ((1 div ($rx * $rx)) + (($k.start * $k.start) div ($ry * $ry)))" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="x.start.tmp">
							<xsl:choose>
								<xsl:when
									test="$angle.start.degree > -90 and 90 > $angle.start.degree">
									<xsl:value-of select="$x.start.module" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="0 - $x.start.module" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="x.start">
							<xsl:value-of select="$x.start.tmp + $x.c" />
						</xsl:variable>
						<xsl:variable name="y.start">
							<xsl:value-of select="$k.start * $x.start.tmp + $y.c" />
						</xsl:variable>
						<xsl:variable name="x.end.module">
							<xsl:call-template name="Sqrt">
								<xsl:with-param name="numb"
									select="1 div ((1 div ($rx * $rx)) + (($k.end * $k.end) div ($ry * $ry)))" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="x.end.tmp">
							<xsl:choose>
								<xsl:when test="$angle.end.degree > -90 and 90 > $angle.end.degree">
									<xsl:value-of select="$x.end.module" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="0 - $x.end.module" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="x.end">
							<xsl:value-of select="$x.end.tmp + $x.c" />
						</xsl:variable>
						<xsl:variable name="y.end">
							<xsl:value-of select="$k.end * $x.end.tmp + $y.c" />
						</xsl:variable>
						<xsl:variable name="x1" select="$x.start - $x.c" />
						<xsl:variable name="y1" select="$y.start - $y.c" />
						<xsl:variable name="x2" select="$x.end - $x.c" />
						<xsl:variable name="y2" select="$y.end - $y.c" />
						<xsl:variable name="angle.bigger.then.180"> <!-- Check if angle of arc is bigger than 180 degrees -->
							<!-- Angle between 2 vectors (from first to second in clockwise direction) 
								thats lie in 'x-y' plane is bigger than 180 degrees, if 'z' coordinate of 
								vector multiplication of them is negative -->
							<xsl:choose>
								<xsl:when test="(($x1 * $y2) - ($y1 * $x2)) > 0">
									false
								</xsl:when>
								<xsl:otherwise>
									true
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$command = 'ae'">
								<xsl:value-of select="concat('L ', $x.start, ' ', $y.start, ' ' )" />
							</xsl:when>
							<xsl:when test="$command = 'al'">
								<xsl:value-of select="concat('M ', $x.start, ' ', $y.start, ' ' )" />
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$angle.end.degree.tmp > 0"> <!-- Counterclockwise -->
								<xsl:choose> <!-- Variable 'angle.bigger.then.180' need to invert its value, because of 
										counterclockwise direction. -->
									<xsl:when test="$angle.bigger.then.180 = 'false' ">
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 1 0 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 0 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise> <!-- Clockwise -->
								<xsl:choose>
									<xsl:when test="$angle.bigger.then.180 = 'true' ">
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 1 1 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 1 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:value-of select="concat('|', $current.x, ',', $current.y ) " />
					</xsl:when>
					<xsl:when
						test="$command = 'at' or $command = 'ar' or $command = 'wa' or $command = 'wr' "> <!-- arcto or arc or clockwisearcto or clockwisearc -->
						<!-- left, top, right, bottom start(x,y) end(x,y). The first four values 
							define the bounding box of an ellipse. The last four define two radial vectors. 
							A segment of the ellipse is drawn which starts at the angle defined by the 
							start radius vector and ends at the angle defined by the end vector. -->
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="8" />
								<xsl:with-param name="add2param"
									select="concat($base.x, '|', $base.y, '|', $base.x, '|', $base.y, '|', $base.x, '|', $base.y, '|', $base.x, '|', $base.y, '|' )" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|', $koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="left"
							select="substring-before($arguments, ' ' )" />
						<xsl:variable name="arguments.tmp1"
							select="substring-after($arguments, ' ' )" />
						<xsl:variable name="top"
							select="substring-before($arguments.tmp1, ' ' )" />
						<xsl:variable name="arguments.tmp2"
							select="substring-after($arguments.tmp1, ' ' )" />
						<xsl:variable name="right"
							select="substring-before($arguments.tmp2, ' ' )" />
						<xsl:variable name="arguments.tmp3"
							select="substring-after($arguments.tmp2, ' ' )" />
						<xsl:variable name="bottom"
							select="substring-before($arguments.tmp3, ' ' )" />
						<xsl:variable name="arguments.tmp4"
							select="substring-after($arguments.tmp3, ' ' )" />
						<xsl:variable name="x.start"
							select="substring-before($arguments.tmp4, ' ' )" />
						<xsl:variable name="arguments.tmp5"
							select="substring-after($arguments.tmp4, ' ' )" />
						<xsl:variable name="y.start"
							select="substring-before($arguments.tmp5, ' ' )" />
						<xsl:variable name="arguments.tmp6"
							select="substring-after($arguments.tmp5, ' ' )" />
						<xsl:variable name="x.end"
							select="substring-before($arguments.tmp6, ' ' )" />
						<xsl:variable name="arguments.tmp7"
							select="substring-after($arguments.tmp6, ' ' )" />
						<xsl:variable name="y.end" select="$arguments.tmp7" />
						<xsl:variable name="rx" select="($right - $left) div 2" />
						<xsl:variable name="ry" select="($bottom - $top) div 2" />
						<xsl:variable name="x.c" select="$left + $rx" />
						<xsl:variable name="y.c" select="$top + $ry" />
						<xsl:variable name="x1" select="$x.start - $x.c" />
						<xsl:variable name="y1" select="$y.start - $y.c" />
						<xsl:variable name="x2" select="$x.end - $x.c" />
						<xsl:variable name="y2" select="$y.end - $y.c" />
						<xsl:variable name="angle.bigger.then.180"> <!-- Check if angle of arc is bigger than 180 degrees -->
							<!-- Angle between 2 vectors (from first to second in clockwise direction) 
								thats lie in 'x-y' plane is bigger than 180 degrees, if 'z' coordinate of 
								vector multiplication of them is negative -->
							<xsl:choose>
								<xsl:when test="(($x1 * $y2) - ($y1 * $x2)) > 0">
									false
								</xsl:when>
								<xsl:otherwise>
									true
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<!-- arcto and clockwisearcto - "A straight line is drawn from the 
								current point to the start of the arc." -->
							<xsl:when
								test="($command = 'at' or $command = 'wa' ) or ($command = 'ar' or $command = 'wr') and $tmp2 = '' "> <!-- MS Word feature -->
								<xsl:value-of select="concat('L ', $x.start, ' ', $y.start, ' ' )" />
							</xsl:when>
							<!-- arc and clockwisearc - "A new sub-path is started by an implied 
								moveto the start point of the arc." -->
							<xsl:when
								test="($command = 'ar' or $command = 'wr' ) and $tmp2 != '' "> <!-- MS Word feature -->
								<xsl:value-of select="concat('M ', $x.start, ' ', $y.start, ' ' )" />
							</xsl:when>
						</xsl:choose>
						<xsl:choose>
							<xsl:when test="$command = 'at' or $command = 'ar' "> <!-- arcto and arc - "The arc is always drawn in a counterclockwise direction." -->
								<xsl:choose> <!-- Variable 'angle.bigger.then.180' need to invert its value, because of 
										counterclockwise direction. -->
									<xsl:when test="$angle.bigger.then.180 = 'false' ">
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 1 0 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 0 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$command = 'wa' or $command = 'wr' "> <!-- clockwisearcto and clockwisearc - "The arc is drawn in a clockwise direction." -->
								<xsl:choose>
									<xsl:when test="$angle.bigger.then.180 = 'true' ">
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 1 1 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 1 ', $x.end, ' ', $y.end, ' ' )" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="concat('|', $x.end , ',', $y.end )" />
					</xsl:when>
					<xsl:when test="$command = 'qx' or $command = 'qy' "> <!-- ellipticalqaudrantx or ellipticalquadranty -->
						<!-- end(x,y). A quarter ellipse is drawn from the current point to 
							the given end point. -->
						<xsl:variable name="arguments">
							<xsl:call-template name="GetParams">
								<xsl:with-param name="str" select="$params" />
								<xsl:with-param name="count" select="2" />
								<xsl:with-param name="add2param"
									select="concat($base.x, '|', $base.y, '|' )" />
								<xsl:with-param name="mult2param"
									select="concat($koef.x, '|', $koef.y, '|' )" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:variable name="x"
							select="substring-before($arguments, ' ' ) " />
						<xsl:variable name="y"
							select="substring-after($arguments, ' ' ) " />
						<xsl:variable name="rx">
							<xsl:choose>
								<xsl:when test="$current.x > $x">
									<xsl:value-of select="$current.x - $x" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$x - $current.x" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="ry">
							<xsl:choose>
								<xsl:when test="$current.y > $y">
									<xsl:value-of select="$current.y - $y" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$y - $current.y" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="delta.x.y.equal.sign">
							<xsl:choose>
								<xsl:when
									test="($current.x > $x and $current.y > $y) or ($current.x &lt; $x and $current.y &lt; $y) ">
									true
								</xsl:when>
								<xsl:otherwise>
									false
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="$command = 'qx'">
								<xsl:choose>
									<xsl:when test="$delta.x.y.equal.sign = 'true' ">
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 1 ', $x, ' ', $y )" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 0 ', $x, ' ', $y )" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:when test="$command = 'qy'">
								<xsl:choose>
									<xsl:when test="$delta.x.y.equal.sign = 'true' ">
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 0 ', $x, ' ', $y )" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="concat('A ', $rx, ' ', $ry, ' 0 0 1 ', $x, ' ', $y )" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
						</xsl:choose>
						<xsl:value-of select="concat('|', $x , ',', $y )" />
						<!-- ellipticalqaudrantx - "The elliptical segment is initially tangential 
							to a line parallel to the x-axis. (i.e. the segment starts out horizontal)" -->
						<!-- ellipticalquadranty - "The elliptical segment is initially tangential 
							to a line parallel to the y-axis. (i.e. the segment starts out vertical)" -->
						<xsl:text> </xsl:text>
					</xsl:when>
					<xsl:when test="$command = 'qb' "> <!-- quadraticbezier -->
						<!-- (controlpoint(x,y))*, end(x,y) -->
						<!-- Defines one or more quadratic bézier curves by means of control 
							points and an end point. Intermediate (on-curve) points are obtained by interpolation 
							between successive control points as in the OpenType font specification. 
							The sub-path need not be started in which case the sub-path will be closed. 
							In this case the last point of the sub-path defines the start point of the 
							quadratic bézier. -->
						<xsl:text> </xsl:text>
						<xsl:value-of select="concat('|', $current.x, ',', $current.y ) " />
					</xsl:when>
					<xsl:when test="$command = 'x' "> <!-- close -->
						<!-- Close the current sub-path by drawing a straight line from the 
							current point to the original moveto point. -->
						<xsl:text>Z </xsl:text>
						<xsl:value-of select="concat('|', $current.x, ',', $current.y ) " />
					</xsl:when>
					<xsl:when test="$command = 'e' "> <!-- end -->
						<!-- End the current set of sub-paths. A given set of sub-paths (as 
							delimited by end) is filled using eofill. Subsequent sets of sub-paths are 
							filled independently and superimposed on existing ones. -->
						<xsl:text> </xsl:text>
						<xsl:value-of select="concat('|', $current.x, ',', $current.y ) " />
					</xsl:when>
					<xsl:when test="$command = 'nf' or $command = 'ns' "> <!-- nofill or nostroke -->
						<!-- All of it have 0 (zero) arguments. -->
						<!-- The current set of sub-paths (delimited by end - e) will not be 
							filled. -->
						<xsl:text> </xsl:text>
						<xsl:value-of select="concat('|', $current.x, ',', $current.y ) " />
					</xsl:when>
					<!-- AutoLine or AutoCurve or CornerLine or CornerCurve or SmoothLine 
						or SmoothCurve or SymmetricLine or SymmetricCurve or Freeform -->
					<xsl:when
						test="$command = 'ha' or $command = 'hb' or $command = 'hc' or $command = 'hd' or $command = 'he' 
            or $command = 'hf' or $command = 'hg' or $command = 'hh' or $command = 'hi'  ">
						<!-- All of it have 0 (zero) arguments. -->
						<xsl:text> </xsl:text>
						<xsl:value-of select="concat('|', $current.x, ',', $current.y ) " />
					</xsl:when>
					<xsl:otherwise> <!-- other commands -->
						<xsl:value-of select="$command" />
						<xsl:value-of select="concat('|', $current.x, ',', $current.y ) " />
						<xsl:message terminate="yes">
							Unsupported command in value of 'path' attribute of 'v:shape' or
							'v:shapetype' tags.
						</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="output" select="substring-before($output.tmp, '|' )" />
			<xsl:variable name="new.current.point" select="substring-after($output.tmp, '|' )" />
			<xsl:variable name="number.arguments">
				<xsl:choose>
					<!-- moveto & rmoveto & lineto & rlineto & ellipticalqaudrantx & ellipticalquadranty 
						commands with 2 arguments -->
					<xsl:when
						test="$command = 't' or $command = 'm' or $command = 'l' or $command = 'r' or $command = 'qx' or $command = 'qy'">
						<xsl:text>2</xsl:text>
					</xsl:when>
					<!-- quadraticbezier command with 4 arguments -->
					<xsl:when test="$command = 'qb' ">
						<xsl:text>4</xsl:text>
					</xsl:when>
					<!-- curveto & rcurveto & angleellipseto & angleellipse commands with 
						6 arguments -->
					<xsl:when
						test="$command = 'c' or $command = 'v' or $command = 'ae' or $command = 'al' ">
						<xsl:text>6</xsl:text>
					</xsl:when>
					<!-- arcto & arc & clockwisearcto & clockwisearc command with 8 arguments -->
					<xsl:when
						test="$command = 'at' or $command = 'ar' or $command = 'wa' or $command = 'wr' ">
						<xsl:text>8</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>0</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="remainder.tmp">
				<xsl:call-template name="SubstringAfterExt">
					<xsl:with-param name="str">
						<xsl:choose>
							<xsl:when test="starts-with($params, '@' )">
								<xsl:value-of select="translate(substring($params, 2), '@', ',' )" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="translate($params, '@', ',' )" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
					<xsl:with-param name="count" select="$number.arguments - 1" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="remainder"
				select="substring($params, string-length($params) - string-length($remainder.tmp) + 1 )" />
			<xsl:variable name="numb">
				<xsl:choose>
					<xsl:when test="starts-with($remainder, '@' )">
						<xsl:variable name="numb.tmp">
							<xsl:call-template name="GetCipher">
								<xsl:with-param name="str" select="substring($remainder, 2)" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="concat('@', $numb.tmp)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="GetCipher">
							<xsl:with-param name="str" select="$remainder" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$command = 'e' or substring-after($remainder, $numb) = '' "> <!-- end -->
					<xsl:variable name="display">
						<xsl:choose>
							<xsl:when test="$filter = 'all' ">true</xsl:when>
							<xsl:when test="$filter = 'nostroke' and $nostroke = 'true' ">true</xsl:when>
							<xsl:when test="$filter = 'nofill' and $nofill = 'true' ">true</xsl:when>
							<xsl:when test="$filter = 'fill' and $nofill != 'true' ">true</xsl:when>
							<xsl:when test="$filter = 'stroke' and $nostroke != 'true' ">true</xsl:when>
							<xsl:when test="$filter = 'fillstroke' and $nostroke != 'true' and $nofill != 'true' ">true</xsl:when>
							<xsl:when test="$filter = 'nofillstroke' and $nostroke != 'true' and $nofill = 'true' ">true</xsl:when>
							<xsl:when test="$filter = 'fillnostroke' and $nostroke = 'true' and $nofill != 'true' ">true</xsl:when>
							<xsl:otherwise>false</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:if test="$display = 'true' ">
						<xsl:value-of select="$current.output" />
					</xsl:if>
					<xsl:call-template name="ParsePath">
						<xsl:with-param name="path"
							select="substring-after($remainder, $numb)" />
						<xsl:with-param name="base.x" select="$base.x" />
						<xsl:with-param name="base.y" select="$base.y" />
						<xsl:with-param name="koef.x" select="$koef.x" />
						<xsl:with-param name="koef.y" select="$koef.y" />
						<xsl:with-param name="last.command" select="$command" />
						<xsl:with-param name="filter" select="$filter" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="is.nostroke">
						<xsl:choose>
							<xsl:when test="$command = 'ns' ">
								true
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$nostroke" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="is.nofill">
						<xsl:choose>
							<xsl:when test="$command = 'nf' ">
								true
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$nofill" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:call-template name="ParsePath">
						<xsl:with-param name="path"
							select="substring-after($remainder, $numb)" />
						<xsl:with-param name="base.x" select="$base.x" />
						<xsl:with-param name="base.y" select="$base.y" />
						<xsl:with-param name="koef.x" select="$koef.x" />
						<xsl:with-param name="koef.y" select="$koef.y" />
						<xsl:with-param name="filter" select="$filter" />
						<xsl:with-param name="last.command" select="$command" />
						<xsl:with-param name="current.output"
							select="concat($current.output, $output)" />
						<xsl:with-param name="nostroke" select="$is.nostroke" />
						<xsl:with-param name="nofill" select="$is.nofill" />
						<xsl:with-param name="current.x"
							select="substring-before($new.current.point, ',' )" />
						<xsl:with-param name="current.y"
							select="substring-after($new.current.point, ',' )" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Get portion from source string before separator and without specified symbols. -->
	<!-- str - source string. -->
	<!-- separator - symbol or string separator. -->
	<!-- truncated.symbols - symbols, that need to be trancated. -->
	<xsl:template name="GetCommand">
		<xsl:param name="str" select="''" />
		<xsl:param name="separator" select="','" />
		<xsl:param name="truncated.symbols" select="'1234567890.-@'" />
		<xsl:if test="string-length($str) > 0">
			<xsl:choose>
				<xsl:when test="contains($str, $separator )">
					<xsl:value-of
						select="translate(substring-before($str, $separator), $truncated.symbols, '' )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="translate($str, $truncated.symbols, '' )" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Get specified number of portions from source string. -->
	<!-- str - source string.  -->
	<!-- count - number of portions need to get. -->
	<!-- separator - symbol or string separator. -->
	<!-- display.sep - symbol or string that will be separate found portions in output string. -->
	<!-- add2param - string with numbers that need to be added to found portions. For example "10|11|" - that's mean to add 10 to first portion and 11 to second. -->
	<!-- mult2param - string with numbers that need to be multiplyed to found portions. For example "10|11|" - that's mean to multiply 10 to first portion and 11 to second. -->
	<xsl:template name="GetParams">
		<xsl:param name="str" select="''" />
		<xsl:param name="count" select="2" />
		<xsl:param name="separator" select="','" />
		<xsl:param name="display.sep" select="' '" />
		<xsl:param name="add2param" select="''" />
		<xsl:param name="mult2param" select="''" />
		<xsl:variable name="res">
			<xsl:call-template name="GetParams2">
				<xsl:with-param name="str" select="$str" />
				<xsl:with-param name="count" select="$count" />
				<xsl:with-param name="separator" select="$separator" />
				<xsl:with-param name="display.sep" select="$display.sep" />
				<xsl:with-param name="add2param" select="$add2param" />
				<xsl:with-param name="mult2param" select="$mult2param" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="normalize-space($res)" />
	</xsl:template>

	<xsl:template name="GetParams2">
		<xsl:param name="str" select="''" />
		<xsl:param name="count" select="2" />
		<xsl:param name="separator" select="','" />
		<xsl:param name="display.sep" select="' '" />
		<xsl:param name="add2param" select="''" />
		<xsl:param name="mult2param" select="''" />
		<xsl:if test="$str != '' and $count > 0">
			<xsl:variable name="before">
				<xsl:choose>
					<xsl:when test="starts-with($str, '@' )"> <!-- It's a formula -->
						<xsl:variable name="tmp">
							<xsl:call-template name="GetCipher">
								<xsl:with-param name="str" select="substring($str, 2)" />
							</xsl:call-template>
						</xsl:variable>
						<xsl:value-of select="concat('@', $tmp)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-before($str, $separator)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="after">
				<xsl:choose>
					<xsl:when test="starts-with($str, '@' )">
						<xsl:choose>
							<xsl:when
								test="starts-with(substring-after($str, $before), $separator)">
								<xsl:value-of
									select="substring-after(substring-after($str, $before), $separator)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="substring-after($str, $before)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="substring-after($str, $separator)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$before = '' and $after = '' "> <!-- Separator not found -->
					<xsl:variable name="numb.tmp">
						<xsl:call-template name="GetArg">
							<xsl:with-param name="str" select="$str" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="numb">
						<xsl:choose>
							<xsl:when test="contains($numb.tmp, '|' )">
								<xsl:value-of select="substring-before($numb.tmp, '|' )" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$numb.tmp" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="remainder.tmp">
						<xsl:choose>
							<xsl:when test="contains($numb.tmp, '|' )">
								<xsl:value-of select="substring-after($numb.tmp, '|')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$numb" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:call-template name="Add2Base">
						<xsl:with-param name="num">
							<xsl:call-template name="Mult2Koef">
								<xsl:with-param name="num" select="$numb" />
								<xsl:with-param name="koef" select="substring-before($mult2param, '|')" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="base"
							select="substring-before($add2param, '|')" />
					</xsl:call-template>
					<xsl:value-of select="$display.sep" />
					<xsl:call-template name="GetParams2">
						<xsl:with-param name="str" select="substring-after($str, $remainder.tmp)" />
						<xsl:with-param name="count" select="$count - 1" />
						<xsl:with-param name="separator" select="$separator" />
						<xsl:with-param name="display.sep" select="$display.sep" />
						<xsl:with-param name="add2param" select="substring-after($add2param, '|')" />
						<xsl:with-param name="mult2param" select="substring-after($mult2param, '|')" />
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise> <!-- Separator found -->
					<xsl:variable name="numb.tmp">
						<xsl:call-template name="GetArg">
							<xsl:with-param name="str" select="$before" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="numb">
						<xsl:choose>
							<xsl:when test="contains($numb.tmp, '|' )">
								<xsl:value-of select="substring-before($numb.tmp, '|' )" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$numb.tmp" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:variable name="remainder.tmp">
						<xsl:choose>
							<xsl:when test="contains($numb.tmp, '|' )">
								<xsl:value-of select="substring-after($numb.tmp, '|')" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$numb" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:call-template name="Add2Base">
						<xsl:with-param name="num">
							<xsl:call-template name="Mult2Koef">
								<xsl:with-param name="num" select="$numb" />
								<xsl:with-param name="koef" select="substring-before($mult2param, '|')" />
							</xsl:call-template>
						</xsl:with-param>
						<xsl:with-param name="base"
							select="substring-before($add2param, '|')" />
					</xsl:call-template>
					<xsl:value-of select="$display.sep" />
					<xsl:call-template name="GetParams2">
						<xsl:with-param name="str">
							<xsl:choose>
								<xsl:when test="starts-with(substring-after($str, $remainder.tmp), $separator)">
									<xsl:value-of select="$after" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="substring-after($str, $remainder.tmp)" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="count" select="$count - 1" />
						<xsl:with-param name="separator" select="$separator" />
						<xsl:with-param name="display.sep" select="$display.sep" />
						<xsl:with-param name="add2param" select="substring-after($add2param, '|')" />
						<xsl:with-param name="mult2param" select="substring-after($mult2param, '|')" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- Get argument. Argument may be a number or formula. -->
	<xsl:template name="GetArg">
		<xsl:param name="str" />
		<xsl:param name="shape" select="." />
		<xsl:variable name="res">
			<xsl:choose>
				<xsl:when test="starts-with($str, '@' )"> <!-- It's a formula. -->
					<xsl:variable name="tmp">
						<xsl:call-template name="GetCipher">
							<xsl:with-param name="str" select="substring($str, 2)" />
							<xsl:with-param name="cipher.symbols" select="'1234567890.-'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="type" select="substring($shape/@type, 2)" />
					<xsl:apply-templates select="//v:shapetype[ @id = $type ]/v:formulas/v:f[$tmp + 1]" mode="formulas">
						<xsl:with-param name="adj">
							<xsl:choose>
								<xsl:when test="$shape/@adj">
									<xsl:value-of select="$shape/@adj" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="//v:shapetype[ @id = $type ]/@adj" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:with-param>
						<xsl:with-param name="style" select="$shape/@style" />
					</xsl:apply-templates>
					<xsl:value-of select="concat('|@', $tmp )" />
				</xsl:when>
				<xsl:otherwise> <!-- It's a number. -->
					<xsl:call-template name="GetCipher">
						<xsl:with-param name="str" select="$str" />
						<xsl:with-param name="cipher.symbols" select="'1234567890.-'" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$res != 'NaN' ">
				<xsl:value-of select="$res" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>0</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Get substring from beginning to first non cipher symbol. -->
	<xsl:template name="GetCipher">
		<xsl:param name="str" select="''" />
		<xsl:param name="cipher.symbols" select="'1234567890.-'" />
		<xsl:variable name="non.cipher"
			select="translate($str, $cipher.symbols, '' )" />
		<xsl:choose>
			<xsl:when test="$non.cipher != '' ">
				<xsl:value-of select="substring-before($str, substring($non.cipher, 1, 1))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Add number to base value. Both may be empty string. -->
	<xsl:template name="Add2Base">
		<xsl:param name="num" select="0" />
		<xsl:param name="base" select="0" />
		<xsl:choose>
			<xsl:when test="$num = '' and $base = '' ">
				0
			</xsl:when>
			<xsl:when test="$num = '' and $base != ''">
				<xsl:value-of select="$base" />
			</xsl:when>
			<xsl:when test="$num != '' and $base = ''">
				<xsl:value-of select="$num" />
			</xsl:when>
			<xsl:when test="$num != '' and $base != ''">
				<xsl:value-of select="$base + $num" />
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Multiply number to coefficient. Both may be empty string. -->
	<xsl:template name="Mult2Koef">
		<xsl:param name="num" select="0" />
		<xsl:param name="koef" select="1" />
		<xsl:param name="need.round" select="'true'" />
		<xsl:choose>
			<xsl:when test="$num = '' ">0</xsl:when>
			<xsl:when test="$num != '' and $koef = ''">
				<xsl:value-of select="$num" />
			</xsl:when>
			<xsl:when test="$num != '' and $koef != ''">
				<xsl:choose>
					<xsl:when test="$need.round = 'true' ">
						<xsl:value-of select="round($koef * $num)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$koef * $num" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- Returns effect of multiple applying function substring-after to source string. -->
	<xsl:template name="SubstringAfterExt">
		<xsl:param name="str" select="''" />
		<xsl:param name="separator" select="','" />
		<xsl:param name="count" select="1" />
		<xsl:choose>
			<xsl:when test="$str != '' and $count > 0 and contains($str, $separator)">
				<xsl:call-template name="SubstringAfterExt">
					<xsl:with-param name="str" select="substring-after($str, $separator)" />
					<xsl:with-param name="separator" select="$separator" />
					<xsl:with-param name="count" select="$count - 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$str" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Convert angle value to degree. -->
	<xsl:template name="ConvertAngle">
		<xsl:param name="angle" select="0" />
		<xsl:variable name="unit" select="translate($angle, '0123456789.-', '')" />
		<xsl:choose>
			<xsl:when test="not($unit)">
				<xsl:value-of select="$angle" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="numeric-value" select="number(substring-before($angle, $unit))" />
				<xsl:choose>
					<xsl:when test="$unit = 'fd' ">
						<xsl:value-of select="round($numeric-value div 65536)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$numeric-value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Convert opacity value in value from range [0..1], 0 - fully transparent, 1 - fully opaque. -->
	<xsl:template name="ConvertOpacity">
		<xsl:param name="opacity" select="0" />
		<xsl:variable name="unit"
			select="translate($opacity, '0123456789.-', '')" />
		<xsl:choose>
			<xsl:when test="$unit = '' ">
				<xsl:value-of select="$opacity" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="numeric-value"
					select="number(substring-before($opacity, $unit))" />
				<xsl:choose>
					<xsl:when test="$unit = 'f' ">
						<xsl:value-of select="$numeric-value div 65536" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$numeric-value" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Get value of CSS property from CSS string. -->
	<xsl:template name="GetCSSProperty">
		<xsl:param name="css.string" select="''" />
		<xsl:param name="css.property" select="''" />
		<xsl:param name="separator.property" select=" ';' " />
		<xsl:param name="separator.value" select=" ':' " />
		<xsl:variable name="substring">
			<xsl:choose>
				<xsl:when test="starts-with($css.string, concat($css.property, $separator.value) )">
					<xsl:value-of select="substring-after($css.string, concat($css.property, $separator.value) )" />
				</xsl:when>
				<xsl:when test="contains($css.string, concat($separator.property, $css.property, $separator.value) )">
					<xsl:value-of select="substring-after($css.string, concat($separator.property, $css.property, $separator.value) )" />
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="contains($substring,  $separator.property)">
				<xsl:value-of select="substring-before($substring,  $separator.property)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$substring" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Processing of formula. -->
	<xsl:template match="v:f" mode="formulas">
		<xsl:param name="adj" />
		<xsl:param name="style" select="''" />
		<xsl:variable name="formula" select="./@eqn" />
		<xsl:variable name="operation" select="substring-before($formula, ' ' )" />
		<xsl:variable name="tmp1" select="substring-after($formula, ' ' )" />
		<xsl:variable name="operand1">
			<xsl:choose>
				<xsl:when test="contains($tmp1, ' ')">
					<xsl:value-of select="substring-before($tmp1, ' ' )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tmp1" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="tmp2" select="substring-after($tmp1, ' ' )" />
		<xsl:variable name="operand2">
			<xsl:choose>
				<xsl:when test="contains($tmp2, ' ')">
					<xsl:value-of select="substring-before($tmp2, ' ' )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tmp2" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="operand3" select="substring-after($tmp2, ' ' )" />
		<xsl:variable name="p1">
			<xsl:call-template name="GetOperand">
				<xsl:with-param name="operand" select="$operand1" />
				<xsl:with-param name="adj" select="$adj" />
				<xsl:with-param name="style" select="$style" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="p2">
			<xsl:call-template name="GetOperand">
				<xsl:with-param name="operand" select="$operand2" />
				<xsl:with-param name="adj" select="$adj" />
				<xsl:with-param name="style" select="$style" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="p3">
			<xsl:call-template name="GetOperand">
				<xsl:with-param name="operand" select="$operand3" />
				<xsl:with-param name="adj" select="$adj" />
				<xsl:with-param name="style" select="$style" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="res">
			<xsl:choose>
				<xsl:when test="$operation = 'val' ">
					<xsl:value-of select="$p1" />
				</xsl:when>
				<xsl:when test="$operation = 'sum' ">
					<xsl:value-of select="$p1 + $p2 - $p3" />
				</xsl:when>
				<xsl:when test="$operation = 'prod' ">
					<xsl:value-of select="$p1 * $p2 div $p3" />
				</xsl:when>
				<xsl:when test="$operation = 'mid' ">
					<xsl:value-of select="($p1 + $p2) div 2" />
				</xsl:when>
				<xsl:when test="$operation = 'abs' ">
					<xsl:choose>
						<xsl:when test="$p1 &lt; 0">
							<xsl:value-of select="0 - $p1" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$p1" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$operation = 'min' ">
					<xsl:choose>
						<xsl:when test="$p1 > $p2">
							<xsl:value-of select="$p2" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$p1" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$operation = 'max' ">
					<xsl:choose>
						<xsl:when test="$p1 > $p2">
							<xsl:value-of select="$p1" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$p2" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$operation = 'if' ">
					<xsl:choose>
						<xsl:when test="$p1 > 0">
							<xsl:value-of select="$p2" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$p3" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$operation = 'mod' ">
					<xsl:call-template name="Sqrt">
						<xsl:with-param name="numb"
							select="$p1 * $p1 + $p2 * $p2 + $p3 * $p3" />
					</xsl:call-template>
				</xsl:when>
				<xsl:when test="$operation = 'sqrt' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="Sqrt">
							<xsl:with-param name="numb" select="$p1" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="floor($tmp)" /> <!-- rounds down ? -->
				</xsl:when>
				<xsl:when test="$operation = 'sumangle' ">
					<xsl:value-of select="$p1 + $p2 * 65536 - $p3 * 65536" />
				</xsl:when>
				<xsl:when test="$operation = 'ellipse' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="Sqrt">
							<xsl:with-param name="numb"
								select="1 - ($p1 div $p2) * ($p1 div $p2)" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$p3 * $tmp" />
				</xsl:when>
				<xsl:when test="$operation = 'sin' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="Sin">
							<xsl:with-param name="x" select="$p2 div 65536 * $pi div 180" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$tmp * $p1" />
				</xsl:when>
				<xsl:when test="$operation = 'cos' ">
					<xsl:variable name="tmp">
						<xsl:call-template name="Cos">
							<xsl:with-param name="x" select="$p2 div 65536 * $pi div 180" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$tmp * $p1" />
				</xsl:when>
				<xsl:when test="$operation = 'tan' ">
					<xsl:variable name="sin">
						<xsl:call-template name="Sin">
							<xsl:with-param name="x" select="$p2 div 65536 * $pi div 180" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="cos">
						<xsl:call-template name="Cos">
							<xsl:with-param name="x" select="$p2 div 65536 * $pi div 180" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$sin div $cos * $p1" />
				</xsl:when>
				<xsl:when test="$operation = 'atan2' ">
					<xsl:variable name="atan2">
						<xsl:call-template name="ArcTan2">
							<xsl:with-param name="y" select="$p2" />
							<xsl:with-param name="x" select="$p1" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$atan2 * 180 div $pi * 65536" />
				</xsl:when>
				<xsl:when test="$operation = 'cosatan2' ">
					<xsl:variable name="atan2">
						<xsl:call-template name="ArcTan2">
							<xsl:with-param name="y" select="$p3" />
							<xsl:with-param name="x" select="$p2" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="cos">
						<xsl:call-template name="Cos">
							<xsl:with-param name="x" select="$atan2" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$cos * $p1" />
				</xsl:when>
				<xsl:when test="$operation = 'sinatan2' ">
					<xsl:variable name="atan2">
						<xsl:call-template name="ArcTan2">
							<xsl:with-param name="y" select="$p3" />
							<xsl:with-param name="x" select="$p2" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="sin">
						<xsl:call-template name="Sin">
							<xsl:with-param name="x" select="$atan2" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$sin * $p1" />
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$res != 'NaN' ">
				<xsl:value-of select="$res" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>0</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- Processing formula operand. Operand may be another formula, argument 
		from 'adj', number or some special word (for example 'width') -->
	<xsl:template name="GetOperand">
		<xsl:param name="operand" />
		<xsl:param name="adj" />
		<xsl:param name="style" select="''" />
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="starts-with($operand, '@' )"> <!-- Link to another formula. -->
					<xsl:apply-templates select="../v:f[substring($operand, 2) + 1]" mode="formulas">
						<xsl:with-param name="adj" select="$adj" />
						<xsl:with-param name="style" select="$style" />
					</xsl:apply-templates>
				</xsl:when>
				<xsl:when test="starts-with($operand, '#' )"> <!-- Arguments from 'adj' attribute. -->
					<xsl:variable name="tmp">
						<xsl:call-template name="SubstringAfterExt">
							<xsl:with-param name="str" select="$adj" />
							<xsl:with-param name="count" select="substring($operand, 2)" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="tmp2">
						<xsl:choose>
							<xsl:when test="contains($tmp, ',' )">
								<xsl:value-of select="substring-before($tmp, ',' )" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$tmp" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:choose>
						<xsl:when test="$tmp2 != '' ">
							<xsl:value-of select="$tmp2" />
						</xsl:when>
						<xsl:otherwise> <!-- If argument in adj is omitted, then need to use default value from shapetype -->
							<xsl:variable name="tmp3">
								<xsl:call-template name="SubstringAfterExt">
									<xsl:with-param name="str" select="../../@adj" />
									<xsl:with-param name="count" select="substring($operand, 2)" />
								</xsl:call-template>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="contains($tmp3, ',' )">
									<xsl:value-of select="substring-before($tmp3, ',' )" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$tmp3" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="$operand = 'width' ">
					<xsl:value-of select="substring-before(../../@coordsize, ',' )" /> 
				</xsl:when>
				<xsl:when test="$operand = 'height' ">
					<xsl:value-of select="substring-after(../../@coordsize, ',' )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$operand" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$result != '' ">
				<xsl:value-of select="$result" />
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Retrieve number from string, exclude measure-unit name -->
	<xsl:template name="ToNumber">
		<xsl:param name="Val" />
		<xsl:choose>
			<xsl:when test="string-length($Val)>0">
				<xsl:value-of select="number(translate($Val, 'ptxcinme ', ''))" />
			</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Convert value to specified unit -->
	<xsl:template name="ConvertInto">
		<xsl:param name="value" />
		<xsl:param name="dest-unit" select="'in'" />
		<!-- 1st of all convert to 1/360 of mm -->
		<xsl:variable name="value.basic">
			<xsl:call-template name="convert-to-basic-units">
				<xsl:with-param name="length" select="$value" />
			</xsl:call-template>
		</xsl:variable>
		<!-- scale factor for destination unit -->
		<xsl:variable name="scale.dest">
			<xsl:call-template name="get-unit-scaling-factor">
				<xsl:with-param name="unit" select="$dest-unit" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$value.basic div $scale.dest" />
	</xsl:template>

	<!-- Convert fractional value into number -->
	<xsl:template name="ConvertFractionalValue">
		<xsl:param name="fractional-value" />
		<xsl:choose>
			<xsl:when test="contains($fractional-value, 'f')">
				<xsl:value-of select="1.5 * concat('0.', format-number(substring-before($fractional-value, 'f'), '00000' ))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$fractional-value" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- ====================== -->
	<!-- Mathematical functions -->
	<!-- ====================== -->

	<!-- Calculating square root. Used Newtonian algorithm. -->
	<xsl:template name="Sqrt">
		<xsl:param name="numb" select="0" />
		<xsl:choose>
			<xsl:when test="$numb &lt;= 0">0</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="inv">
					<xsl:choose>
						<xsl:when test="$numb &lt; 1">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="tmp">
					<xsl:choose>
						<xsl:when test="$numb &lt; 1">
							<xsl:value-of select="1 div $numb" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="$numb" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="tmp2">
					<xsl:call-template name="WhileDivision">
						<xsl:with-param name="numb" select="$tmp" />
						<xsl:with-param name="divisor" select="16" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="x" select="substring-before($tmp2, '|' )" />
				<xsl:variable name="sp" select="substring-after($tmp2, '|' )" />
				<xsl:variable name="newton">
					<xsl:call-template name="NewtonianAlgorithm">
						<xsl:with-param name="x" select="$x" />
						<xsl:with-param name="a" select="2" />
						<xsl:with-param name="count" select="5" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="base">
					<xsl:call-template name="RaiseToPower">
						<xsl:with-param name="source" select="4" />
						<xsl:with-param name="power" select="$sp" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="res1" select="$newton * $base" />
				<xsl:choose>
					<xsl:when test="$inv = '1' ">
						<xsl:value-of select="1 div $res1" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$res1" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 'while' cycle for serial division some value by specified divisor while this value are greater then divisor. -->
	<!-- Returns residue of division and count of iteration. -->
	<xsl:template name="WhileDivision">
		<xsl:param name="numb" />
		<xsl:param name="divisor" />
		<xsl:param name="iteration" select="0" />
		<xsl:choose>
			<xsl:when test="$numb > $divisor">
				<xsl:call-template name="WhileDivision">
					<xsl:with-param name="numb" select="$numb div $divisor" />
					<xsl:with-param name="divisor" select="$divisor" />
					<xsl:with-param name="iteration" select="$iteration + 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($numb, '|', $iteration)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- 'while' cycle for serial subtraction some value by specified subtrahend while this value are greater then subtrahend. -->
	<!-- Returns and count of iteration. -->
	<xsl:template name="WhileSubtraction">
		<xsl:param name="numb" />
		<xsl:param name="subtr" />
		<xsl:param name="iteration" select="0" />
		<xsl:choose>
			<xsl:when test="$numb >= $subtr">
				<xsl:call-template name="WhileSubtraction">
					<xsl:with-param name="numb" select="$numb - $subtr" />
					<xsl:with-param name="subtr" select="$subtr" />
					<xsl:with-param name="iteration" select="$iteration + 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($numb, '|', $iteration)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Newtonian algorithm using for calculating square root -->
	<xsl:template name="NewtonianAlgorithm">
		<xsl:param name="x" />
		<xsl:param name="a" />
		<xsl:param name="count" select="0" />
		<xsl:choose>
			<xsl:when test="$count > 0">
				<xsl:call-template name="NewtonianAlgorithm">
					<xsl:with-param name="x" select="$x" />
					<xsl:with-param name="a" select="($a + $x div $a) * 0.5" />
					<xsl:with-param name="count" select="$count - 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$a" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Calculating sine. Used Taylor series. -->
	<xsl:template name="Sin">
		<xsl:param name="x" />
		<xsl:param name="precision" select="5" />
		<xsl:call-template name="SinCycle">
			<xsl:with-param name="x">
				<xsl:call-template name="FixAngle">
					<xsl:with-param name="angle" select="$x" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="precision" select="$precision" />
		</xsl:call-template>
	</xsl:template>

	<!-- Bringing angle value to interval [-180, 180] (degrees) or [-pi, pi] 
		(radians) or some base value [-value, value], based on periodicity of trigonometrical 
		functions. -->
	<xsl:template name="FixAngle">
		<xsl:param name="angle" />
		<xsl:param name="base" select="$pi" />
		<xsl:variable name="angle.tmp2">
			<xsl:choose>
				<xsl:when test="$angle >= 2 * $base">
					<xsl:variable name="angle.tmp">
						<xsl:call-template name="WhileSubtraction">
							<xsl:with-param name="numb" select="$angle" />
							<xsl:with-param name="subtr" select="2 * $base" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="substring-before($angle.tmp, '|' )" />
				</xsl:when>
				<xsl:when test="$angle &lt;= (0 - 2 * $base)">
					<xsl:variable name="angle.tmp">
						<xsl:call-template name="WhileSubtraction">
							<xsl:with-param name="numb" select="0 - $angle" />
							<xsl:with-param name="subtr" select="2 * $base" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="0 - substring-before($angle.tmp, '|' )" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$angle" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$angle.tmp2 > $base">
				<xsl:value-of select="$base - $angle.tmp2" />
			</xsl:when>
			<xsl:when test="$angle.tmp2 &lt; (0 - $base)">
				<xsl:value-of select="0 - $angle.tmp2 - $base" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$angle.tmp2" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Used for calculating sine -->
	<xsl:template name="SinCycle">
		<xsl:param name="x" />
		<xsl:param name="precision" select="5" />
		<xsl:choose>
			<xsl:when test="$precision > 0">
				<xsl:variable name="next">
					<xsl:call-template name="SinCycle">
						<xsl:with-param name="x" select="$x" />
						<xsl:with-param name="precision" select="$precision - 1" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="sign">
					<xsl:call-template name="RaiseToPower">
						<xsl:with-param name="source" select="-1" />
						<xsl:with-param name="power" select="$precision" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="tmp1">
					<xsl:call-template name="RaiseToPower">
						<xsl:with-param name="source" select="$x" />
						<xsl:with-param name="power" select="2 * $precision + 1" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="tmp2">
					<xsl:call-template name="Factorial">
						<xsl:with-param name="x" select="2 * $precision + 1" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$sign * $tmp1 div $tmp2 + $next" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$x" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Calculating cosine. Used Taylor series. -->
	<xsl:template name="Cos">
		<xsl:param name="x" />
		<xsl:param name="precision" select="5" />
		<xsl:call-template name="CosCycle">
			<xsl:with-param name="x">
				<xsl:call-template name="FixAngle">
					<xsl:with-param name="angle" select="$x" />
				</xsl:call-template>
			</xsl:with-param>
			<xsl:with-param name="precision" select="$precision" />
		</xsl:call-template>
	</xsl:template>

	<!-- Auxiliary. Used for calculating cosine -->
	<xsl:template name="CosCycle">
		<xsl:param name="x" />
		<xsl:param name="precision" select="5" />
		<xsl:choose>
			<xsl:when test="$precision > 0">
				<xsl:variable name="next">
					<xsl:call-template name="CosCycle">
						<xsl:with-param name="x" select="$x" />
						<xsl:with-param name="precision" select="$precision - 1" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="sign">
					<xsl:call-template name="RaiseToPower">
						<xsl:with-param name="source" select="-1" />
						<xsl:with-param name="power" select="$precision" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="tmp1">
					<xsl:call-template name="RaiseToPower">
						<xsl:with-param name="source" select="$x" />
						<xsl:with-param name="power" select="2 * $precision" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="tmp2">
					<xsl:call-template name="Factorial">
						<xsl:with-param name="x" select="2 * $precision" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$sign * $tmp1 div $tmp2 + $next" />
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Calculating tangent. Used Taylor series. -->
	<xsl:template name="Tan">
		<xsl:param name="x" />
		<xsl:param name="precision" select="5" />
		<xsl:variable name="sin">
			<xsl:call-template name="Sin">
				<xsl:with-param name="x" select="$x" />
				<xsl:with-param name="precision" select="$precision" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="cos">
			<xsl:call-template name="Cos">
				<xsl:with-param name="x" select="$x" />
				<xsl:with-param name="precision" select="$precision" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:value-of select="$sin div $cos" />
	</xsl:template>

	<!-- Calculating factorial. -->
	<xsl:template name="Factorial">
		<xsl:param name="x" />
		<xsl:choose>
			<xsl:when test="$x > 0">
				<xsl:variable name="tmp">
					<xsl:call-template name="Factorial">
						<xsl:with-param name="x" select="$x - 1" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$x * $tmp" />
			</xsl:when>
			<xsl:otherwise>1</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Calculating arctangent. -->
	<xsl:template name="ArcTan">
		<xsl:param name="numb" />
		<xsl:variable name="pi.div.12" select="$pi div 12" />
		<xsl:variable name="pi.div.6" select="$pi div 6" />
		<xsl:variable name="pi.div.2" select="$pi div 2" />
		<xsl:variable name="inv.sign">
			<xsl:choose>
				<xsl:when test="$numb &lt; 0">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="tmp">
			<xsl:choose>
				<xsl:when test="$numb &lt; 0">
					<xsl:value-of select="0 - $numb" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$numb" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="inv.val">
			<xsl:choose>
				<xsl:when test="$tmp > 1">1</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="tmp2">
			<xsl:choose>
				<xsl:when test="$tmp > 1">
					<xsl:value-of select="1 div $tmp" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$tmp" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="tmp3">
			<xsl:call-template name="ArcTanCycle">
				<xsl:with-param name="numb" select="$tmp2" />
				<xsl:with-param name="min" select="$pi.div.12" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="x" select="substring-before($tmp3, '|' )" />
		<xsl:variable name="sp" select="substring-after($tmp3, '|' )" />
		<xsl:variable name="a"
			select="((0.55913709 div ($x * $x + 1.4087812)) + 0.60310579 - 0.05160454 * $x * $x) * $x + $pi.div.6 * $sp" />
		<xsl:variable name="res.tmp">
			<xsl:choose>
				<xsl:when test="$inv.val = 1">
					<xsl:value-of select="$pi.div.2 - $a" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$a" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$inv.sign = 1">
				<xsl:value-of select="0 - $res.tmp" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$res.tmp" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Auxiliary. Used in arctangent calculating. -->
	<xsl:template name="ArcTanCycle">
		<xsl:param name="numb" />
		<xsl:param name="min" select="0" />
		<xsl:param name="count" select="0" />
		<xsl:choose>
			<xsl:when test="$numb > $min">
				<xsl:variable name="sqrt3" select="1.732050807569" /> <!-- square root of 3 -->
				<xsl:call-template name="ArcTanCycle">
					<xsl:with-param name="numb"
						select="(1 div ($numb + $sqrt3)) * ($numb * $sqrt3 - 1)" />
					<xsl:with-param name="min" select="$min" />
					<xsl:with-param name="count" select="$count + 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($numb, '|', $count)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Calculating arctangent2. -->
	<!-- Returns angle in radians -->
	<xsl:template name="ArcTan2">
		<xsl:param name="y" />
		<xsl:param name="x" />
		<xsl:choose>
			<xsl:when test="$x = 0 and $y = 0"></xsl:when>
			<xsl:when test="$x = 0">
				<xsl:choose>
					<xsl:when test="$y > 0">
						<xsl:value-of select="$pi div 2" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="0 - $pi div 2" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$y = 0">
				<xsl:choose>
					<xsl:when test="$x > 0">0</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$pi" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="atan">
					<xsl:call-template name="ArcTan">
						<xsl:with-param name="numb" select="$y div $x" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="$x > 0">
						<xsl:value-of select="$atan" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test="$y > 0">
								<xsl:value-of select="$atan + $pi" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$atan - $pi" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Raise number to specified power. -->
	<!-- NOT SUPPORTED: power between 0 to 1 -->
	<xsl:template name="RaiseToPower">
		<xsl:param name="source" />
		<xsl:param name="power" />
		<xsl:choose>
			<xsl:when test="$power &lt; 0">
				<xsl:variable name="next">
					<xsl:call-template name="RaiseToPower">
						<xsl:with-param name="source" select="$source" />
						<xsl:with-param name="power" select="0 - $power" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="1 div $next" />
			</xsl:when>
			<xsl:when test="$power = 0">
				<xsl:value-of select="number(1)" />
			</xsl:when>
			<xsl:when test="$power &lt;= 1">
				<xsl:value-of select="$source" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="next">
					<xsl:call-template name="RaiseToPower">
						<xsl:with-param name="source" select="$source" />
						<xsl:with-param name="power" select="$power - 1" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$next * $source" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
  
</xsl:stylesheet>
