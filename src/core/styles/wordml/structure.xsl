<?xml version="1.0" encoding="UTF-8"?>

<!-- ====================================================================

This stylesheet defines presentation and structure of contents of the
resulting document. It contains templates to convert Word structures into their
equivalents in XSL-FO.

Copyright (c) 2011 LeanPulse. All rights reserved.

Author: Aurélien PROST (a.prost@leanpulse.com)

==================================================================== -->

<xsl:stylesheet xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:w="http://schemas.microsoft.com/office/word/2003/wordml"
    xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml"
    xmlns:wx="http://schemas.microsoft.com/office/word/2003/auxHint"
    xmlns:aml="http://schemas.microsoft.com/aml/2001/core"
    xmlns:w10="urn:schemas-microsoft-com:office:word"
    xmlns:dt="uuid:C2F41010-65B3-11d1-A29F-00AA00C14882"
    xmlns:st1="urn:schemas-microsoft-com:office:smarttags"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:syd="http://www.leanpulse.com/schemas/syd/2011/core"
    version="2.0">

    <xsl:variable name="tab.width.default" select="705"/>
    
    <!-- Document's content -->
    <xsl:template match="w:body">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- Headers and Footers content -->
    <xsl:template match="w:hdr">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    <xsl:template match="w:ftr">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- Represents a container for document sections. -->
    <xsl:template name="wx:sect">
        <xsl:param name="context"/>
        <xsl:element name="{$section-block-name}" namespace="{$section-block-namespace}">
            <!-- Set default properties. -->
            <xsl:call-template name="SetDefaultAttributes"/>
            <!-- Apply formatting properties for columns. -->
            <xsl:if test="$section-block-name='rx:flow-section'">
                <xsl:apply-templates select="$context/descendant-or-self::w:sectPr/w:cols"/>
            </xsl:if>
            <xsl:variable name="body-content">
                <xsl:call-template name="AnalyzeHighlevelContent">
                    <xsl:with-param name="current-node" select="$context"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:copy-of select="$body-content"/>
        </xsl:element>
    </xsl:template>
    
    <!-- This template analyzes "high-level" content (sections and subsections) -->
    <xsl:template name="AnalyzeHighlevelContent">
        <!-- current-node is wx:sect or wx:sub-section -->
        <xsl:param name="current-node"/>
        <xsl:variable name="two.table.in.one.row">
            <xsl:for-each select="$current-node/self::*">
                <xsl:if test="name(.) = 'w:tbl' ">
                    <xsl:variable name="pos" select="position()"/>
                    <xsl:for-each select="$current-node/self::*">
                        <xsl:if test="position() = $pos +1 and name(.) = 'w:tbl' ">
                            <xsl:text>true</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <!-- Get into Linearize template only if condition for two tables in row is true -->
            <xsl:when test="$two.table.in.one.row = 'true'">
                <xsl:call-template name="Linearize">
                    <xsl:with-param name="current-node" select="$current-node"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
        <xsl:apply-templates select="$current-node/self::*[ not(self::wx:sub-section) and not(self::w:sectPr) ]"/>
                <xsl:for-each select="$current-node/self::wx:sub-section">
                    <xsl:variable name="pos" select="position()"/>
                    <fo:block id="{generate-id()}">
                        <xsl:call-template name="AnalyzeHighlevelContent">
                            <xsl:with-param name="current-node" select="node()"/>
                        </xsl:call-template>
                    </fo:block>
                </xsl:for-each>
                <xsl:apply-templates select="$current-node/self::w:sectPr"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="Linearize">
        <xsl:param name="current-node"/>
        <xsl:choose>
            <xsl:when test="$current-node/self::w:p">
                <xsl:for-each select="$current-node/self::w:p">
                    <xsl:variable name="preceding-siblings" select="preceding-sibling::*"/>
                    <xsl:variable name="current-portion" select="$preceding-siblings[count(following-sibling::w:p[1] | current()) = 1 and not(self::w:p) and not(self::w:proofErr)]"/>
                    <xsl:call-template name="BreakContentIntoOneRowTable">
                        <xsl:with-param name="content" select="$current-portion"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="current()"/>
                    <xsl:if test="position() = last()">
                        <xsl:call-template name="BreakContentIntoOneRowTable">
                            <xsl:with-param name="content" select="following-sibling::*[not(self::w:sectPr | self::w:proofErr)]"/>
                        </xsl:call-template>
                        <xsl:apply-templates select="following-sibling::w:sectPr"/>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="$current-node/self::w:p[last()]/w:pPr/w:sectPr">
                    <fo:block break-after="page"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="BreakContentIntoOneRowTable">
                    <xsl:with-param name="content" select="$current-node/self::*[not(self::w:sectPr | self::w:proofErr)]"/>
                </xsl:call-template>
                <xsl:apply-templates select="$current-node/self::w:sectPr"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="BreakContentIntoOneRowTable">
        <!-- content is a node-set -->
        <xsl:param name="content"/>
        <xsl:if test="$content">
            <fo:block>
                <fo:table padding-before="5pt" padding-after="5pt">
                    <fo:table-body>
                        <fo:table-row>
                            <xsl:for-each select="$content">
                                <fo:table-cell padding-start="10pt" padding-end="10pt">
                                    <fo:block>
                                        <xsl:apply-templates select="current()"/>
                                    </fo:block>
                                </fo:table-cell>
                            </xsl:for-each>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <!-- Represents a document subsection. -->
    <!-- Parent elements: wx:sect. -->
    <xsl:template match="wx:sub-section">
        <xsl:if test="(position() = 1) and parent::node()[name()='wx:sub-section' or name()='wx:sect']">
            <xsl:apply-templates select="parent::node()"/>
        </xsl:if>
        <fo:block id="{generate-id()}"/>
    </xsl:template>
    
    <xsl:template match="wx:sect">
        <fo:block id="{generate-id()}"/>
    </xsl:template>

    <!-- wx:pBdrGroup element holds borders on a group of blocks. -->
    <xsl:template match="wx:pBdrGroup" name="wx:pBdrGroup">
        <xsl:if test="w:p[1]/w:pPr/w:sectPr">
            <fo:block break-before="page"/>
        </xsl:if>
        <fo:block>
            <!-- borders on the group of blocks -->
            <xsl:apply-templates select="wx:borders/*"/>
            <!-- background-color -->
            <xsl:apply-templates select="wx:shd"/>
            <!-- left and right paddings -->
            <xsl:apply-templates select="wx:margin-left | wx:margin-right"/>
            <xsl:variable name="first-paragraph" select="w:p[position()=1]"/>
            <xsl:variable name="last-paragraph" select="w:p[position()=last()]"/>
            <!-- set space-before from the first child paragraph -->
            <!-- default paragraph style -->
            <xsl:apply-templates select="$default-paragraph-style">
                <xsl:with-param name="specific-attribute" select="'w:spacing'"/>
                <xsl:with-param name="mode" select="'before'"/>
            </xsl:apply-templates>
            <!-- style-level (pStyle)-->
            <xsl:apply-templates select="key('styles', $first-paragraph/w:pPr/w:pStyle/@w:val, ancestor::w:wordDocument)[@w:type='paragraph']">
                <xsl:with-param name="specific-attribute" select="'w:spacing'"/>
                <xsl:with-param name="mode" select="'before'"/>
            </xsl:apply-templates>
            <!-- p-level (direct; override style-level) -->
            <xsl:apply-templates select="$first-paragraph/w:pPr/w:spacing">
                <xsl:with-param name="mode" select="'before'"/>
            </xsl:apply-templates>
            <!-- set space-after from the last child paragrapg -->
            <!-- default paragraph style -->
            <xsl:apply-templates select="$default-paragraph-style">
                <xsl:with-param name="specific-attribute" select="'w:spacing'"/>
                <xsl:with-param name="mode" select="'after'"/>
            </xsl:apply-templates>
            <!-- style-level (pStyle)-->
            <xsl:apply-templates select="key('styles', $last-paragraph/w:pPr/w:pStyle/@w:val, ancestor::w:wordDocument)[@w:type='paragraph']">
                <xsl:with-param name="specific-attribute" select="'w:spacing'"/>
                <xsl:with-param name="mode" select="'after'"/>
            </xsl:apply-templates>
            <!-- p-level (direct; override style-level) -->
            <xsl:apply-templates select="$last-paragraph/w:pPr/w:spacing">
                <xsl:with-param name="mode" select="'after'"/>
            </xsl:apply-templates>
            <!-- Set start-indent attribute from the first child paragraph. It's necessary to indent around paragraph's content (i.e. borders, shading etc) -->
            <!-- style-level (pStyle)-->
            <xsl:apply-templates select="key('styles', $last-paragraph/w:pPr/w:pStyle/@w:val, ancestor::w:wordDocument)[@w:type='paragraph']">
                <xsl:with-param name="specific-attribute" select="'w:ind'"/>
                <xsl:with-param name="mode" select="'left'"/>
            </xsl:apply-templates>
            <!-- p-level (direct; override style-level) -->
            <xsl:apply-templates select="$last-paragraph/w:pPr/w:ind">
                <xsl:with-param name="mode" select="'left'"/>
            </xsl:apply-templates>
            <!-- the group content -->
            <xsl:apply-templates select="*[not(self::wx:borders) and not(self::wx:apo) and not(self::wx:shd)
                and not(self::wx:margin-left) and not(self::wx:margin-right)]"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="wx:sub-section/wx:pBdrGroup[1] | wx:sect/wx:pBdrGroup[1]">
        <xsl:if test="../*[1] = .">
            <xsl:apply-templates select="parent::node()"/>
        </xsl:if>
        <xsl:call-template name="wx:pBdrGroup"/>
    </xsl:template>    
    
    <!-- Represents a paragraph element. -->
    <xsl:template match="wx:sub-section/w:p[1] | wx:sect/w:p[1]">
        <xsl:if test="../*[1] = .">
            <xsl:apply-templates select="parent::node()"/>
        </xsl:if>
        <xsl:call-template name="w:p"/>
    </xsl:template>
    
    <xsl:template match="w:p" name="w:p">
        <xsl:variable name="isList" select="w:pPr/w:listPr"/>
        <xsl:variable name="isFootnote" select="parent::w:footnote"/>
        <xsl:choose>
            <xsl:when test="$isList and (w:r or not(w:pPr/w:sectPr))"> <!-- If paragraph is empty - it's not a list -->
                <fo:list-block>
                    <fo:list-item>
                        <xsl:call-template name="ApplyParaProperties"/>
                        <!-- Display a list-item-label element. -->
                        <xsl:apply-templates select="w:pPr/w:listPr"/>
                        <!-- Display a list-item-body element. -->
                        <fo:list-item-body>
                            <!-- Set explicit end-indent on list-item-body to avoid a warning. -->
                            <xsl:attribute name="end-indent">inherit</xsl:attribute>
                            <xsl:variable name="start-indent">
                                <xsl:choose>
                                    <xsl:when test="w:pPr/w:ind/@w:left">
                                        <xsl:value-of select="w:pPr/w:ind/@w:left div 20"/>
                                    </xsl:when>
                                    <xsl:when test="w:pPr/w:tabs/w:tab[@w:val='list']">
                                        <xsl:value-of select="w:pPr/w:tabs/w:tab[@w:val='list']/@w:pos div 20"/>
                                    </xsl:when>
                                    <xsl:when test="w:pPr/w:tabs/w:tab[@w:val='clear']"> <!-- The value clear enables tab stops defined in an associated paragraph style to be explicitly cleared -->
                                        <xsl:value-of select="w:pPr/w:tabs/w:tab[@w:val='clear']/@w:pos div 20"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:variable name="style" select="key('styles', w:pPr/w:pStyle/@w:val, ancestor::w:wordDocument)"/>
                                        
                                        <xsl:variable name="list" select="key('lists', w:pPr/w:listPr/w:ilfo/@w:val, ancestor::w:wordDocument)"/>
                                        <xsl:variable name="ilfo.temp"> <!-- w:listPr can be not only in current style and else in style on which current style is based on (@w:styleId = current()/w:basedOn/@w:val) -->
                                            <xsl:call-template name="GetIlfoFromStyle">
                                                <xsl:with-param name="style" select="$style"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:variable name="ilfo" select="substring-before($ilfo.temp, '|' )"/>
                                        <xsl:variable name="style.id" select="substring-after($ilfo.temp, '|' )"/>
                                        <xsl:variable name="list.style" select="key('lists', $ilfo, ancestor::w:wordDocument)"/>
                                        <!--<xsl:variable name="list">
                                            <xsl:choose>
                                                <xsl:when test="w:pPr/w:listPr/w:ilfo/@w:val"><xsl:value-of select="key('lists', w:pPr/w:listPr/w:ilfo/@w:val, ancestor::w:wordDocument)"/></xsl:when>
                                                <xsl:when test="w:pStyle/@w:val"><xsl:value-of select="key('lists', $style/w:rPr/w:listPr/w:ilfo/@w:val, ancestor::w:wordDocument)"/></xsl:when>
                                            </xsl:choose>
                                        </xsl:variable>-->
                                        
                                        <xsl:variable name="level">
                                            <xsl:choose>
                                                <xsl:when test="w:pPr/w:listPr/w:ilfo/@w:val"><xsl:value-of select="current()/w:pPr/w:listPr/w:ilvl/@w:val"/></xsl:when>
                                                <xsl:when test="w:pPr/w:pStyle/@w:val">
                                                    <!-- xsl:value-of select="$style/w:pPr/w:outlineLvl/@w:val"/ -->
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:variable>
                                        
                                        <!--<xsl:variable name="tab" select="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl=current()/w:pPr/w:listPr/w:ilvl/@w:val]/w:pPr/w:tabs/w:tab[@w:val='list']"/>-->
                                        <xsl:variable name="tab">
                                            <xsl:choose>
                                                <xsl:when test="w:pPr/w:listPr/w:ilfo/@w:val">
                                                    <xsl:if test="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)">
                                                    	<xsl:choose>
                                                			<xsl:when test="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl=$level]/w:pPr/w:ind">
                                                				<xsl:value-of select="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl=$level]/w:pPr/w:ind/@w:left"/>
                                                			</xsl:when>
                                                			<xsl:otherwise>
                                                				<xsl:value-of select="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl=$level]/w:pPr/w:tabs/w:tab[@w:val='list']/@w:pos"/>
                                                			</xsl:otherwise>
                                                		</xsl:choose>
                                                    </xsl:if>
                                                </xsl:when>
                                                <xsl:when test="w:pPr/w:pStyle/@w:val">
                                                    <!-- xsl:value-of select="key('list-properties', $list.style/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl=$level]/w:pPr/w:tabs/w:tab[@w:val='list']/@w:pos"/ -->
                                                    <xsl:value-of select="key('list-properties', $list.style/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[w:pStyle/@w:val=$style.id]/w:pPr/w:tabs/w:tab[@w:val='list']/@w:pos"/>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <!--<xsl:variable name="tab" select="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl=$level]/w:pPr/w:tabs/w:tab[@w:val='list']"/>-->
                                        
                                        <xsl:choose>
                                            <xsl:when test="w:pPr/w:listPr/wx:t">
                                            	<xsl:choose>
                                                    <xsl:when test="normalize-space($tab) != ''"><xsl:value-of select="$tab div 20"/></xsl:when>
                                                    <xsl:otherwise>0</xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:choose>
                                                    <xsl:when test="normalize-space($tab) != ''">
                                                        <xsl:value-of select="$tab div 20"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>0</xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            
                            <!-- xsl:variable name="bullet-size">
                                <xsl:choose>
                                    <xsl:when test="not(w:pPr/w:listPr/wx:t)">
                                        <!- - bullet is an image - ->
                                        <xsl:variable name="level-value" select="w:pPr/w:listPr/w:ilvl/@w:val"/>
                                        <xsl:variable name="list" select="key('lists', w:pPr/w:listPr/w:ilfo/@w:val, ancestor::w:wordDocument)"/>
                                        <xsl:variable name="list-def" select="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)"/>
                                        <xsl:variable name="bullet-pic" select="key('list-picture-bullets', $list-def/w:lvl[@w:ilvl = $level-value]/w:lvlPicBulletId/@w:val, ancestor::w:wordDocument)"/>
                                        <xsl:variable name="font-size">
                                            <xsl:call-template name="GetFontSizeForParaInHalfPts">
                                                <xsl:with-param name="para-el" select="."/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:variable name="image-width">
                                            <xsl:call-template name="GetWidthFromCSSStyle">
                                                <xsl:with-param name="style" select="$bullet-pic/w:pict/v:shape/@style"/>
                                                <xsl:with-param name="object" select="'image'"/>
                                                <xsl:with-param name="factor" select="$font-size div ($default-font-size.list-label * 2)"/>
                                            </xsl:call-template>
                                        </xsl:variable>
                                        <xsl:variable name="units" select="translate($image-width, '0123456789.', '')"/>
                                        <xsl:variable name="numeric-value">
                                            <xsl:choose>
                                                <xsl:when test="not($units)">
                                                    <xsl:value-of select="$image-width"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="substring-before($image-width, $units)"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:choose>
                                            <xsl:when test="$numeric-value != '' ">
                                                <xsl:value-of select="$numeric-value"/>
                                            </xsl:when>
                                            <xsl:otherwise>0</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <!- - bullet is a "symbol" (actually, svg equiavalent of it) - ->
                                        <xsl:call-template name="GetBulletActualSize">
                                            <xsl:with-param name="font-size">
                                                <xsl:call-template name="GetFontSizeForParaInHalfPts">
                                                    <xsl:with-param name="para-el" select="."/>
                                                    <xsl:with-param name="default" select="$default-font-size.list-label"/>
                                                </xsl:call-template>
                                            </xsl:with-param>
                                            <xsl:with-param name="factor" select="$default-factor-for-bullets"/>
                                            </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable -->
                            
                            <xsl:attribute name="start-indent">
                                <!-- xsl:value-of select="$start-indent + $bullet-size"/ -->
                                <xsl:value-of select="$start-indent"/>
                                <xsl:text>pt</xsl:text>
                            </xsl:attribute>
                            <!-- text-indent -->
                            <xsl:choose>
                                <xsl:when test="./w:pPr/w:ind[@w:first-line or @w:first-line-chars or @w:hanging or @w:hanging-chars]">
                                    <xsl:apply-templates select="./w:pPr/w:ind">
                                        <xsl:with-param name="mode" select="text-indent"/>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise><xsl:attribute name="text-indent">0pt</xsl:attribute></xsl:otherwise>
                            </xsl:choose>
                            <fo:block>
                                <!-- xsl:call-template name="ApplyParaProperties"/ -->
                                <xsl:apply-templates select="*[not(self::w:pPr)]"/>
                                <xsl:if test="not(w:r)">
                                    <fo:leader/>
                                </xsl:if>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </xsl:when>
            <xsl:when test="$isFootnote">
                <fo:footnote>
                    <xsl:apply-templates select="w:r[w:footnoteRef]"/>
                    <fo:footnote-body>
                        <fo:block start-indent="0" text-indent="0" font-size="10pt" padding-before="3pt">
                            <!-- Set properties -->
                            <xsl:call-template name="ApplyParaProperties"/>
                            <fo:inline keep-together.within-line="always" font-size="66.7%" baseline-shift="super">
                                <xsl:number level="any" count="w:footnote"
                                    from="/w:wordDocument/w:body" format="1"/>
                            </fo:inline>
                            <xsl:apply-templates select="*[not(w:footnoteRef) and not(self::w:pPr)]"/>
                        </fo:block>
                    </fo:footnote-body>
                </fo:footnote>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="w:r or not(w:pPr/w:sectPr)"> <!-- If paragraph is empty and it has w:sectPr - we ignore such paragraph -->
                <fo:block>
                    <xsl:call-template name="ApplyParaProperties"/>
                    <xsl:choose>
                        <!-- If the paragraph doesn't contains runs - -->
                        <!-- it acts as a paragraph break element.     -->
                        <xsl:when test="count(*[not(self::w:pPr)])=0 and not(wx:allowEmptyCollapse)">
                            <!-- Set inline-level properties -->
                            <xsl:apply-templates select="w:pPr/w:rPr/*[not(self::w:rStyle)]"/>
                            <fo:leader/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Display run-level elements. -->
                            <xsl:apply-templates select="*[not(self::w:pPr)]">
                                <xsl:sort data-type="number" select="concat(substring-before(substring-after(.//node()[starts-with(@style, 'z-index:') and contains(substring-after(@style, 'z-index:'), ';')]/@style, 'z-index:'), ';' )
                                    , substring-after(.//node()[starts-with(@style, 'z-index:') and not(contains(substring-after(@style, 'z-index:'), ';'))]/@style, 'z-index:')
                                    , substring-before(substring-after(.//node()[contains(@style, ';z-index:') and contains(substring-after(@style, ';z-index:'), ';')]/@style, ';z-index:'), ';' )
                                    , substring-after(.//node()[contains(@style, ';z-index:') and not(contains(substring-after(@style, ';z-index:'), ';'))]/@style, ';z-index:') ) "/>
                            </xsl:apply-templates>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Represents a run element. -->
    <!-- Parent elements: w:p.     -->
    <xsl:template match="w:r">
        <!-- Don't generate inline area, if the run contains the following: -->
        <!-- 1. footnote -->
        <!-- 2. endnote -->
        <!-- 3. field-delimiting character -->
        <!-- 4. field instruction -->
        <xsl:if test="not(w:footnote) and not(w:endnote) and not(w:fldChar) and not(w:instrText)">
            <fo:inline>
                <!-- Set properties -->
                <xsl:call-template name="ApplyRunProperties"/>
                <!-- Display text elements. -->
                <xsl:apply-templates select="*[not(self::w:rPr)]"/>
            </fo:inline>
        </xsl:if>
        <!-- Display a footnote -->
        <xsl:apply-templates select="w:footnote"/>
        <!-- Field instructions are enclosed in field-delimiting characters. -->
        <!-- Apply a field-delimiting character to process field instruction content. -->
        <xsl:apply-templates select="w:fldChar"/>
    </xsl:template>
    
    <!-- Represents text content. -->
    <!-- Parent elements: w:r.    -->
    <xsl:template match="w:t">
        <!-- Preserve initial whitespace characters. -->
        <!-- fo:leader with zero lenght affects on white-space-treatment:   -->
        <!-- initial white-space characters are not surround line-feed now. -->
        <fo:leader leader-length="0pt"/>
        <!-- text content -->
        <xsl:choose>
            <xsl:when test="ancestor::w:fldSimple">
                <xsl:call-template name="ApplyFieldInstruction">
                    <xsl:with-param name="instruction" select="normalize-space(ancestor::w:fldSimple/@w:instr)"/>
                    <xsl:with-param name="default-text" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="../preceding-sibling::w:r[1][w:fldChar/@w:fldCharType='separate']">
                <xsl:call-template name="ApplyFieldInstruction">
                    <xsl:with-param name="instruction">
                        <xsl:call-template name="ConcatInstruction">
                            <xsl:with-param name="current-run-element" select="parent::w:r"/>
                        </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="default-text" select="."/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Represents a symbol character. -->
    <!-- Parent elements: w:r.          -->
    <xsl:template match="w:sym">
        <xsl:call-template name="ConvertSymbol">
            <xsl:with-param name="symbol" select="@w:char"/>
            <xsl:with-param name="font-family" select="@w:font"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- Lists and their properties -->
    <xsl:template match="w:listPr">
        <fo:list-item-label>
            <!-- some properties inherited from parent tag and it is incorrect, for example font-weight and font-style -->
            <!--<xsl:attribute name="font-weight">normal</xsl:attribute>
            <xsl:attribute name="font-style">normal</xsl:attribute>-->
            
            <!-- Applying style properties -->
            <!-- xsl:apply-templates select="key('styles', ../w:pStyle/@w:val, ancestor::w:wordDocument[1])[@w:type='paragraph']"/ -->
            <xsl:apply-templates select="key('styles', ../w:pStyle/@w:val, ancestor::w:wordDocument)[@w:type='paragraph']/w:rPr/*[name(.) = 'w:rFonts'  or name(.) = 'w:sz' or name(.) = 'w:sz-cs' ]"/> <!--  or name(.) = 'wx:font' -->

            <!-- xsl:attribute name="font-size">
                <xsl:value-of select="$default-font-size.list-label"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute -->
            
            <xsl:apply-templates select="../w:rPr"/>
            
            <!-- list-item-label properties at list definition level-->
            <!-- Implemented situation with style using (@ilfo should be found in style definition) -->
            <xsl:choose>
                <xsl:when test="w:ilfo/@w:val">
                    <xsl:apply-templates select="key('lists', w:ilfo/@w:val, ancestor::w:wordDocument)">
                        <xsl:with-param name="list-level" select="w:ilvl/@w:val"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="../w:pStyle/@w:val">
                    <xsl:variable name="ilfo.temp"> <!-- w:listPr can be not only in current style and else in style on which current style is based on (@w:styleId = current()/w:basedOn/@w:val) -->
                        <xsl:call-template name="GetIlfoFromStyle">
                            <xsl:with-param name="style" select="key('styles', ../w:pStyle/@w:val, ancestor::w:wordDocument)"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="ilfo" select="substring-before($ilfo.temp, '|' )"/>
                    <xsl:variable name="style.id" select="substring-after($ilfo.temp, '|' )"/>
                    <xsl:variable name="list.style" select="key('lists', $ilfo, ancestor::w:wordDocument)"/>
                    <xsl:apply-templates select="key('lists', $ilfo, ancestor::w:wordDocument)">
                        <xsl:with-param name="list-level" select="key('list-properties', $list.style/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[w:pStyle/@w:val=$style.id]/@w:ilvl"/>
                    </xsl:apply-templates>                    
                </xsl:when>
            </xsl:choose>
            
            <!-- direct list-item-label properties -->
            <xsl:apply-templates select="*[not(self::ilvl) and not(self::w:ilfo) and not(self::wx:t) and not(self::wx:font)]"/>
            
            <xsl:attribute name="text-indent">
                <xsl:text>0pt</xsl:text>
            </xsl:attribute>
            
            <!-- redefine start-indent -->
            <xsl:attribute name="start-indent">
                <xsl:choose>
                    <xsl:when test="wx:t/@wx:wTabBefore">
                        <xsl:value-of select="wx:t/@wx:wTabBefore div 20"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="list" select="key('lists', w:ilfo/@w:val, ancestor::w:wordDocument)"/>
                        <xsl:variable name="lvl" select="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl = current()/w:ilvl/@w:val]"/>
                        <xsl:variable name="item-body-start-indent">
                            <xsl:choose>
                                <xsl:when test="$lvl/w:pPr/w:tabs/w:tab[@w:val = 'list']/@w:pos">
                                    <xsl:value-of select="$lvl/w:pPr/w:tabs/w:tab[@w:val = 'list']/@w:pos div 20"/>
                                </xsl:when>
                                <xsl:when test="$lvl/w:pPr/w:ind/@w:left">
                                    <xsl:value-of select="$lvl/w:pPr/w:ind/@w:left div 20"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$default-list-item-body-indent"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="$item-body-start-indent - $default-internal-gap.list-item"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>

            <!-- list-item-label-content -->
            <xsl:apply-templates select="wx:t"/>
            <!-- if there is no wx:t child, it means that the bullet is a picture -->
            <xsl:if test="not(wx:t)">
                <xsl:variable name="level-value" select="w:ilvl/@w:val"/>
                <xsl:variable name="list" select="key('lists', w:ilfo/@w:val, ancestor::w:wordDocument)"/>
                <xsl:variable name="list-def" select="key('list-properties', $list/w:ilst/@w:val, ancestor::w:wordDocument)"/>
                <xsl:variable name="bullet-pic" select="key('list-picture-bullets', $list-def/w:lvl[@w:ilvl = $level-value]/w:lvlPicBulletId/@w:val, ancestor::w:wordDocument)"/>
                <xsl:variable name="font-size">
                    <xsl:call-template name="GetFontSizeForParaInHalfPts">
                        <xsl:with-param name="para-el" select="ancestor::w:p[1]"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:apply-templates select="$bullet-pic">
                    <!-- default font size is in pts, whereas in WordML font-sizes are in half-points -->
                    <xsl:with-param name="x-factor" select="$font-size div ($default-font-size.list-label * 2)"/>
                    <xsl:with-param name="y-factor" select="$font-size div ($default-font-size.list-label * 2)"/>
                </xsl:apply-templates>
            </xsl:if>
        </fo:list-item-label>
    </xsl:template>

    <xsl:template match="w:list">
        <xsl:param name="list-level"/>
        <!-- list properties defined inside an appropriate w:listDef element -->
        <xsl:apply-templates select="key('list-properties', w:ilst/@w:val, ancestor::w:wordDocument)/w:lvl[@w:ilvl=$list-level]"/>
        <!-- overriden list properties -->
        <xsl:apply-templates select="w:lvlOverride">
            <xsl:with-param name="list-level" select="$list-level"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="w:lvl">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="w:lvlOverride">
        <xsl:param name="list-level"/>
        <xsl:apply-templates select="w:lvl[@w:ilvl=$list-level]"/>
    </xsl:template>
    
    <!-- list-item-label content.            -->
    <!-- Parent elements: w:listPr.          -->
    <xsl:template match="wx:t">
        <fo:block>
            <xsl:call-template name="ConvertBulletsToSVG">
                <xsl:with-param name="label" select="@wx:val"/>
                <xsl:with-param name="font-family" select="../wx:font/@wx:val"/>
                <xsl:with-param name="font-size">
                    <xsl:call-template name="GetFontSizeForParaInHalfPts">
                        <xsl:with-param name="para-el" select="ancestor::w:p[1]"/>
                        <xsl:with-param name="default" select="$default-font-size.list-label"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:call-template>
        </fo:block>
    </xsl:template>

    <xsl:template match="w:listPicBullet">
        <xsl:param name="x-factor" select="1"/>
        <xsl:param name="y-factor" select="1"/>
        <fo:block>
            <xsl:apply-templates select="*">
                <xsl:with-param name="x-factor" select="$x-factor"/>
                <xsl:with-param name="y-factor" select="$y-factor"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>
    
    
    <!-- ================ -->
    <!-- Tabular elements -->
    <!-- ================ -->
    
    <!-- Represents the table element. -->
    <xsl:template match="w:tbl">
        <!-- Internal links -->
        <xsl:apply-templates select="aml:annotation"/>
        <fo:table>
            <!-- Set default-style table properties -->
            <xsl:apply-templates select="$default-table-style"/>
            <!-- Set style-level table properties -->
            <xsl:apply-templates select="key('styles', w:tblPr/w:tblStyle/@w:val, ancestor::w:wordDocument)[@w:type='table']"/>
            <!-- Set direct table properties -->
            <xsl:apply-templates select="w:tblPr/*[not(self::w:tblStyle) and not(self::w:tblCellMar)]"/>
            <!-- Set table columns -->
            <xsl:apply-templates select="w:tblGrid"/>
            <!-- table-header -->
            <xsl:variable name="header-rows" select="w:tr[w:trPr/w:tblHeader[not(@w:val='off')]]"/>
            <xsl:if test="$header-rows">
                <fo:table-header start-indent="0pt" end-indent="0pt">
                    <xsl:apply-templates select="$header-rows"/>
                </fo:table-header>
            </xsl:if>
            <fo:table-body start-indent="0pt" end-indent="0pt">
                <!-- There are situations when child of w:tbl is not from standard namespace.-->
                <!-- Currently style sheet does not support rendering of such elements. -->
                <!-- e.g. Smart-tag can contain w:tr element.   -->
                <xsl:apply-templates select="*[self::w:tr[not(w:trPr/w:tblHeader) or w:trPr/w:tblHeader/@w:val='off'] or not(contains($standard-namespace-prefixes, concat(' ', substring-before(name(), ':'), ' ')))]"/>
            </fo:table-body>
        </fo:table>
    </xsl:template>
    
    <!-- Parent element: w:tbl. -->
    <xsl:template match="w:tblGrid">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- Represents a table column. -->
    <!-- Parent element: w:tblGrid. -->
    <xsl:template match="w:gridCol">
        <fo:table-column>
            <xsl:attribute name="column-number">
                <xsl:number count="w:gridCol"/>
            </xsl:attribute>
            <xsl:attribute name="column-width">
                <xsl:value-of select="@w:w div 20"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>
        </fo:table-column>
    </xsl:template>
    
    <!-- Represents a table row. -->
    <!-- Parent element: w:tbl.  -->
    <xsl:template match="w:tr">
        <fo:table-row>
            <xsl:variable name="table-properties" select="ancestor::w:tbl/w:tblPr"/>
            <!-- xsl:if test="w:trPr/w:trHeight/@w:h-rule = 'exact'" -->
            <xsl:if test="w:trPr/w:trHeight/@w:h-rule = 'exact'">
              <xsl:attribute name="height"><xsl:value-of select="concat(w:trPr/w:trHeight/@w:val div 20, 'pt' )"/></xsl:attribute>
            </xsl:if>
            <!-- Set default-style table-row properties -->
            <xsl:apply-templates select="$default-table-style" mode="table-rows"/>
            <!-- Set style-level table-row properties -->
            <xsl:apply-templates
                select="key('styles', $table-properties/w:tblStyle/@w:val, ancestor::w:wordDocument)[@w:type='table']" mode="table-rows"/>
            <!-- Overriden table properties for the row -->
            <xsl:apply-templates select="w:tblPrEx/*"/>
            <!-- Set direct table-row properties -->
            <xsl:apply-templates select="w:trPr/*"/>
            <!-- Generate table cells -->
            <xsl:apply-templates select="w:tc"/>
        </fo:table-row>
    </xsl:template>
    
    <!-- Represents a table cell. -->
    <!-- Parent element: w:tr.    -->
    <xsl:template match="w:tc">
        <!-- should not generate fo:table-cell when the w:tc is spanned cell -->
        <xsl:if test="(not(w:tcPr/w:hmerge) or w:tcPr/w:hmerge/@w:val='restart') and (not(w:tcPr/w:vmerge) or w:tcPr/w:vmerge/@w:val='restart')">
            <fo:table-cell>
                <xsl:variable name="table-properties" select="ancestor::w:tbl[1]/w:tblPr"/>
                <xsl:variable name="table-properties-ex" select="ancestor::w:tr[1]/w:tblPrEx"/>
                <!-- Set default-style table-cell properties -->
                <!-- xsl:if test="w:tcPr/w:tcW/@w:w">
                  <xsl:attribute name="width"><xsl:value-of select="concat(w:tcPr/w:tcW/@w:w div 20, 'pt' )"/></xsl:attribute>
                </xsl:if -->
                <xsl:if test="../w:trPr/w:trHeight/@w:h-rule = 'exact'">
                  <xsl:attribute name="height"><xsl:value-of select="concat(../w:trPr/w:trHeight/@w:val div 20, 'pt' )"/></xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="$default-table-style" mode="table-cells">
                    <xsl:with-param name="cell" select="."/>
                </xsl:apply-templates>
                <!-- Set style-level table-cell properties -->
                <xsl:apply-templates
                    select="key('styles', $table-properties/w:tblStyle/@w:val, ancestor::w:wordDocument)[@w:type='table']" mode="table-cells">
                    <xsl:with-param name="cell" select="."/>
                </xsl:apply-templates>
                <!-- Apply direct table-cell properties defined on table level -->
                <xsl:apply-templates select="$table-properties/w:tblBorders/*">
                    <xsl:with-param name="cell" select="."/>
                </xsl:apply-templates>
                <xsl:apply-templates select="$table-properties-ex/w:tblBorders/*">
                    <xsl:with-param name="cell" select="."/>
                </xsl:apply-templates>
                <xsl:apply-templates select="$table-properties/w:tblCellMar"/>
                <!-- Set direct table-cell properties -->
                <xsl:apply-templates select="w:tcPr/*">
                    <xsl:with-param name="cell" select="."/>
                </xsl:apply-templates>

                <fo:block-container>

                    <xsl:if test="w:tcPr/w:textFlow/@w:val = 'bt-lr' or w:tcPr/w:textFlow/@w:val = 'tb-rl' ">
                        <xsl:attribute name="width"><xsl:value-of select="concat(../w:trPr/w:trHeight/@w:val div 20, 'pt' )"/></xsl:attribute>
                        <xsl:attribute name="reference-orientation">
                            <xsl:choose>
                                <xsl:when test="w:tcPr/w:textFlow/@w:val = 'bt-lr' ">90</xsl:when>
                                <xsl:when test="w:tcPr/w:textFlow/@w:val = 'tb-rl' ">-90</xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>

                <!-- The table cell content -->
                <xsl:apply-templates select="*[not(self::w:tcPr)]"/>

                </fo:block-container>

            </fo:table-cell>
        </xsl:if>
    </xsl:template>
    
    
    <!-- ========== -->
    <!-- Tabulation -->
    <!-- ========== -->
    
    <!-- Represents tab stop list. -->
    <!-- Parent elements: w:pPr    -->
    <xsl:template match="w:tabs">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- Represents a tab stop.  -->
    <!-- Parent elements: w:tabs -->
    <xsl:template match="w:tabs/w:tab"/>
    
    <!-- Represents a tab character.  -->
    <!-- Parent elements: w:r         -->
    <xsl:template match="w:tab">
        <!-- Draw leader only if the paragraph contains visible text content. -->
        <xsl:if test="ancestor::w:p[w:r/w:t or w:hlink or w:fldSimple or w:subDoc]">

            <xsl:choose>
                <xsl:when test="@wx:wTab">
                    <xsl:call-template name="EmulateTabulation">
                        <xsl:with-param name="tabdef-leader" select="@wx:tlc"/>
                        <xsl:with-param name="tabdef-len" select="@wx:wTab"/>
                    </xsl:call-template>
                </xsl:when>
                <!-- in case of incorrectly saved tag w:tab (without attributes) -->
                <xsl:otherwise>
                    <xsl:call-template name="EmulateTabulation">
                        <xsl:with-param name="tabdef-leader" select="'none'"/>
                        <xsl:with-param name="tabdef-len" select="$tab.width.default"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:if>
    </xsl:template>
    
    <!-- Emulate tabulation with fo:leader -->
    <xsl:template name="EmulateTabulation">
        <xsl:param name="tabdef-leader"/>
        <xsl:param name="tabdef-len"/>
        <fo:leader>

            <xsl:attribute name="leader-pattern">
                <xsl:text>use-content</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="leader-length">
                <xsl:value-of select="$tabdef-len div 20"/>
                <xsl:text>pt</xsl:text>
            </xsl:attribute>

            <xsl:choose>
                <xsl:when test="$tabdef-leader='underscore'">
                    <xsl:text>_</xsl:text>
                </xsl:when>
                <xsl:when test="$tabdef-leader='hyphen'">
                    <xsl:text>-</xsl:text>
                </xsl:when>
                <xsl:when test="$tabdef-leader='dot'">
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>&#160;</xsl:text>
                </xsl:otherwise>
            </xsl:choose>

        </fo:leader>
    </xsl:template>


    <!-- ======== -->
    <!-- Graphics -->
    <!-- ======== -->
    
    <!-- Represents a picture or other binary object that appears at this point in the document. -->
    <!-- Parent elements: w:r                        -->
    <xsl:template match="w:pict">
        <xsl:param name="x-factor" select="1"/>
        <xsl:param name="y-factor" select="1"/>

        <xsl:variable name="binary-data" select="w:binData | w:movie | w:background | w:applet | w:scriptAnchor | w:ocx | w:msAccessHTML"/>
        <xsl:apply-templates select="v:shape">
            <xsl:with-param name="binary-data" select="$binary-data"/>
            <xsl:with-param name="x-factor" select="$x-factor"/>
            <xsl:with-param name="y-factor" select="$y-factor"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <!-- Containes the reference to this object. -->
    <xsl:template match="v:shape">
        <xsl:param name="binary-data"/>
        <xsl:param name="x-factor" select="1"/>
        <xsl:param name="y-factor" select="1"/>

        <xsl:if test="v:imagedata">
            <xsl:choose>
                <xsl:when test="name(..) = 'v:group' and ../@editas = 'canvas' ">
                    <xsl:apply-templates select="." mode="svg.image">
                        <xsl:with-param name="binary-data" select="$binary-data"/>
                        <xsl:with-param name="x-factor" select="$x-factor"/>
                        <xsl:with-param name="y-factor" select="$y-factor"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <fo:external-graphic>
                        <!-- content-width, content-height -->
                        <xsl:call-template name="ParsingCSSStyle">
                            <xsl:with-param name="style" select="@style"/>
                            <xsl:with-param name="object" select="'image'"/>
                            <xsl:with-param name="x-factor" select="$x-factor"/>
                            <xsl:with-param name="y-factor" select="$y-factor"/>
                        </xsl:call-template>
                        <!-- scaling and etc. -->
                        <xsl:apply-templates select="o:lock"/>
                        <!-- border styles and border widths -->
                        <xsl:apply-templates select="w10:bordertop|w10:borderbottom|w10:borderleft|w10:borderright"/>
                        <!-- border colors -->
                        <xsl:apply-templates select="@o:bordertopcolor|@o:borderleftcolor|@o:borderbottomcolor|@o:borderrightcolor"/>
                        <xsl:attribute name="src">
                            <xsl:choose>
                                <xsl:when test="$binary-data">
                                    <!-- Embedded object -->
                                    <xsl:apply-templates select="$binary-data"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Linked object -->
                                    <xsl:variable name="src" select="v:imagedata/@src"/>
                                    <xsl:choose>
                                        <xsl:when test="starts-with($src, 'wordml://')">
                                            <!--Internal link (in the same document) -->
                                            <xsl:apply-templates select="ancestor::w:body//*[(self::w:binData or self::w:movie) and @w:name = $src]"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <!-- external link -->
                                            <xsl:value-of select="concat('url(&quot;', v:imagedata/@src, '&quot;)')"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </fo:external-graphic>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <!-- Contains the binary data representing this object. -->
    <!-- Parent elements: w:pict, w:bgPict                  -->
    <xsl:template match="w:binData">
        <xsl:variable name="media-type">
            <xsl:text>image/</xsl:text>
            <xsl:call-template name="RetrieveMediaSubtype">
                <xsl:with-param name="name" select="@w:name"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat('url(&quot;data:', $media-type, ';base64,', ., '&quot;)')"/>
    </xsl:template>
    
    <!-- Auxiliary information for image processing. -->
    <xsl:template match="o:lock">
        <xsl:if test="@aspectratio">
            <xsl:attribute name="scaling">
                <xsl:choose>
                    <xsl:when test="@aspectratio='f'">
                        <xsl:text>non-uniform</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>uniform</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    
    <!-- ========== -->
    <!-- Hyperlinks -->
    <!-- ========== -->
    
    <!-- Represents a hyperlink element. -->
    <!-- Parent elements: w:p, w:hlink.  -->
    <xsl:template match="w:hlink">
        <fo:basic-link>
            <xsl:choose>
                <xsl:when test="@w:dest">
                    <xsl:attribute name="external-destination">
                        <xsl:value-of select="concat('url(&quot;', @w:dest, '&quot;)')"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="*"/>
                </xsl:when>
                <xsl:when test="@w:bookmark">
                    <xsl:attribute name="internal-destination">
                        <xsl:value-of select="concat(ancestor::syd:system[1]/@path, ancestor::syd:comment/@name, @w:bookmark)"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="*"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </fo:basic-link>
    </xsl:template>
    
    <!-- Represents a tracked insertion, deletion, formatting change, -->
    <!-- comment, or bookmark (internal link) in a document.          -->
    <!-- block-level context -->
    <xsl:template match="aml:annotation">
        <xsl:choose>
            <xsl:when test="@w:type='Word.Bookmark.Start'">
                <fo:block id="{concat(ancestor::syd:system[1]/@path, ancestor::syd:comment/@name, @w:name)}"/>
            </xsl:when>
            <xsl:when test="@w:type='Word.Insertion' ">
                <xsl:apply-templates select="aml:content/*"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- inline-level context -->
    <xsl:template match="aml:annotation[ancestor::w:p]" priority="1">
        <xsl:choose>
            <xsl:when test="@w:type='Word.Bookmark.Start'">
                <fo:inline id="{concat(ancestor::syd:system[1]/@path, ancestor::syd:comment/@name, @w:name)}"/>
            </xsl:when>
            <xsl:when test="@w:type='Word.Insertion' ">
                <xsl:apply-templates select="aml:content/*"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    <!-- block-level context -->
    <xsl:template match="aml:annotation[ancestor::w:footnote]" priority="2">
        <xsl:choose>
            <xsl:when test="@w:type='Word.Bookmark.Start'">
                <fo:block id="{concat(ancestor::syd:system[1]/@path, ancestor::syd:comment/@name, @w:name)}"/>
            </xsl:when>
            <xsl:when test="@w:type='Word.Insertion' ">
                <xsl:apply-templates select="aml:content/*"/>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- ========= -->
    <!-- Footnotes -->
    <!-- ========= -->
    
    <!-- Represents a footnote that appears at this point in the document. -->
    <!-- Parent elements: w:r                                              -->
    <xsl:template match="w:footnote">
        <xsl:apply-templates select="w:p"/>
    </xsl:template>
    
    <!-- Represents a footnote reference mark. -->
    <!-- Parent elements: w:r                  -->
    <xsl:template match="w:footnoteRef">
        <!-- Set keep-with-previous.within-line -->
        <!-- It's default behaviour of MS Word. -->
        <xsl:attribute name="keep-with-previous.within-line">
            <xsl:text>always</xsl:text>
        </xsl:attribute>
        <xsl:number level="any" count="/w:wordDocument/w:body//w:footnote" format="1"/>
    </xsl:template>
    
    
    <!-- ============================= -->
    <!-- Page, column, and line breaks -->
    <!-- ============================= -->
    
    <!-- Represents a text-wrapping break. @w:type specifies the break type. -->
    <!-- Parent elements: w:r                                                -->
    <xsl:template match="w:br">
        <!-- defines a page, column, or text-wrapping break -->
        <xsl:choose>
            <xsl:when test="@w:type='page'">
              <fo:leader/>
              <xsl:if test="not(ancestor::w:tc)">
                <fo:block break-before="page"/>
              </xsl:if>
              <!-- fo:leader/><fo:block break-before="page"/ -->
            </xsl:when>
            <xsl:when test="@w:type='column'">
              <fo:leader/><fo:block break-before="column"/>
            </xsl:when>
            <!-- if @w:type="text-wrapping" or omitted - it's a new-line break -->
            <xsl:otherwise>
              <fo:leader/><fo:block/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- ======= -->
    <!-- Hyphens -->
    <!-- ======= -->
    
    <!-- Represents a soft-hyphen (optional hyphen). -->
    <xsl:template match="w:softHyphen">
        <xsl:text>&#x00AD;</xsl:text>
    </xsl:template>
    
    <!-- Represents a non-breaking hyphen. -->
    <xsl:template match="w:noBreakHyphen">
        <xsl:text>&#2011;</xsl:text>
    </xsl:template>
    
    
    <!-- ====== -->
    <!-- Fields -->
    <!-- ====== -->
    
    <!-- Represents a simple Word field (with plain text instructions). -->
    <!-- Simple fields are run-time calculated entities in Word         -->
    <!-- (for example, page numbers).                                   -->
    <!-- Parent elements: w:p, w:hlink, w:fldSimple.                    -->
    <xsl:template match="w:fldSimple">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <!-- Apply an instruction for a field. -->
    <xsl:template name="ApplyFieldInstruction">
        <xsl:param name="instruction"/>
        <xsl:param name="default-text"/>
        <xsl:choose>
            <xsl:when test="$instruction='PAGE' or starts-with($instruction, 'PAGE ')"> <!-- Instances like 'PAGEREF' should be excluded. -->
                <fo:page-number/>
            </xsl:when>
            <xsl:when test="$instruction='NUMPAGES' or starts-with($instruction, 'NUMPAGES ')">
                <fo:page-number-citation ref-id="{generate-id(/)}"/>
            </xsl:when>
            <xsl:when test="$instruction='REF' or starts-with($instruction, 'REF ')">
                <fo:basic-link>
                    <xsl:attribute name="internal-destination">
                        <xsl:choose>
                            <xsl:when test="contains($instruction, '\')">
                                <xsl:value-of select="normalize-space(substring-after(substring-before($instruction, '\'), 'REF'))"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="normalize-space(substring-after($instruction, 'REF'))"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="$default-text"/>
                </fo:basic-link>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default-text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Maps list-label symbols to svg objects -->
    <xsl:template name="ConvertBulletsToSVG">
        <xsl:param name="label"/>
        <xsl:param name="font-family"/>
        <xsl:param name="font-size"/>
        <xsl:param name="factor" select="$default-factor-for-bullets"/>

        <xsl:variable name="actual-size-in-pts">
            <xsl:call-template name="GetBulletActualSize">
               <xsl:with-param name="font-size" select="$font-size"/>
               <xsl:with-param name="factor" select="$factor"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="radius" select="round($actual-size-in-pts div 2)"/>
        <xsl:choose>
            <xsl:when test="$font-family = 'Symbol'">
                <xsl:choose>
                    <xsl:when test="$label = '&#xb7;'">
                        <fo:block>
                                <fo:instream-foreign-object display-align="center">
                                    <svg:svg width="{$actual-size-in-pts}pt" height="{$actual-size-in-pts}pt">
                                        <svg:circle cx="{$radius}pt" cy="{$radius}pt"
                                            r="{$radius - 1}pt" fill="black"/>
                                    </svg:svg>
                                </fo:instream-foreign-object>
                        </fo:block>
                    </xsl:when>
                    <!-- for others of Symbol -->
                    <xsl:otherwise>
                        <fo:instream-foreign-object display-align="center">
                            <svg:svg width="{$actual-size-in-pts}pt" height="{$actual-size-in-pts}pt">
                                <svg:circle cx="{$radius}pt" cy="{$radius}pt"
                                    r="{$radius - 1}pt" fill="black"/>
                            </svg:svg>
                        </fo:instream-foreign-object>
                    </xsl:otherwise>
                    </xsl:choose>
                <!-- <xsl:call-template name="ConvertString">
                    <xsl:with-param name="string" select="$label"/>
                    <xsl:with-param name="font-family" select="$font-family"/>
                </xsl:call-template> -->
            </xsl:when>
            <!--<xsl:when test="starts-with($font-family, 'Courier')">
                <xsl:choose>
                    <xsl:when test="$label = 'o'">
                        <fo:block>
                                <fo:instream-foreign-object display-align="center">
                                    <svg:svg width="{$actual-size-in-pts}pt" height="{$actual-size-in-pts}pt">
                                        <svg:circle cx="{$radius}pt" cy="{$radius}pt"
                                            r="{$radius - 1}pt" fill="none" stroke="black" stroke-width="1"/>
                                    </svg:svg>
                                </fo:instream-foreign-object>
                        </fo:block>
                    </xsl:when>
                    <!- - for others of Courier XXXXX - ->
                    <xsl:otherwise>
                        <fo:instream-foreign-object display-align="center">
                            <svg:svg width="{$actual-size-in-pts}pt" height="{$actual-size-in-pts}pt">
                                <svg:circle cx="{$radius}pt" cy="{$radius}pt"
                                    r="{$radius - 1}pt" fill="black"/>
                            </svg:svg>
                        </fo:instream-foreign-object>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>-->
            <xsl:when test="$font-family = 'Wingdings'">
                <xsl:choose>
                    <xsl:when test="$label = '&#xa7;'">
                        <fo:block>
                                <fo:instream-foreign-object display-align="center">
                                    <svg:svg width="{$actual-size-in-pts}pt" height="{$actual-size-in-pts}pt">
                                        <svg:rect x="1" y="1" width="{$actual-size-in-pts - 1}pt"
                                            height="{$actual-size-in-pts - 1}pt" fill="black"/>
                                    </svg:svg>
                                </fo:instream-foreign-object>
                        </fo:block>
                    </xsl:when>
                    <!-- for others of Wingdings -->
                    <xsl:otherwise>
                        <fo:instream-foreign-object display-align="center">
                            <svg:svg width="{$actual-size-in-pts}pt" height="{$actual-size-in-pts}pt">
                                <svg:circle cx="{$radius}pt" cy="{$radius}pt"
                                    r="{$radius - 1}pt" fill="black"/>
                            </svg:svg>
                        </fo:instream-foreign-object>
                    </xsl:otherwise>
                    </xsl:choose>
                <!--<xsl:call-template name="ConvertString">
                    <xsl:with-param name="string" select="$label"/>
                    <xsl:with-param name="font-family" select="$font-family"/>
                </xsl:call-template>-->
            </xsl:when>
            <xsl:otherwise>
                <!--<xsl:choose>
                    <xsl:when test="string-length($label) &gt; 1">-->
                        <!-- do not touch -->
                        <fo:inline>
                            <xsl:value-of select="$label"/>
                        </fo:inline>
                    <!--</xsl:when>
                    <xsl:otherwise>
                        <!- - put the default bullet - ->
                        <fo:block>
                                <fo:instream-foreign-object display-align="center">
                                    <svg:svg width="{$actual-size-in-pts}pt" height="{$actual-size-in-pts}pt">
                                        <svg:circle cx="{$radius}pt" cy="{$radius}pt"
                                            r="{$radius - 1}pt" fill="black"/>
                                    </svg:svg>
                                </fo:instream-foreign-object>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Fetches font size for list item. -->
    <xsl:template name="GetFontSizeForParaInHalfPts">
        <xsl:param name="para-el"/>
        <xsl:param name="default" select="24"/>

        <!-- Return number, without "pt" -->
        <xsl:choose>
            <xsl:when test="not($para-el)">
                <xsl:value-of select="$default"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="p-style" select="key('styles', 'Normal', ancestor::w:wordDocument)[@w:type = 'paragraph' and @w:default = 'on']"/>
                <!-- <xsl:variable name="p-style" select="/w:wordDocument/w:styles/w:style[@w:type = 'paragraph' and @w:default = 'on']"/>  -->
                <xsl:variable name="font-size">
                	<xsl:value-of select="$default"/>
                    <!-- try to get font size from styles -->
                    <xsl:value-of select="$p-style/w:pPr[1]/w:rPr/w:sz/@w:val"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$p-style/w:rPr[1]/w:sz/@w:val"/>
                    <xsl:text>,</xsl:text>
                    <!-- try to get font size from the p element -->
                    <xsl:value-of select="$para-el/w:pPr[1]/w:rPr/w:sz/@w:val"/>
                    <xsl:text>,</xsl:text>
                    <xsl:value-of select="$para-el/w:r[1]/w:rPr/w:sz/@w:val"/>
                </xsl:variable>
                <xsl:call-template name="AnalyzeOverridings">
                    <xsl:with-param name="list" select="$font-size"/>
                    <xsl:with-param name="sep" select="','"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="GetBulletActualSize">
        <xsl:param name="font-size"/>
        <xsl:param name="factor" select="$default-factor-for-bullets"/>
        <xsl:choose>
            <!-- If it is 0 (for example, if $font-size is blank), $font-size can not be used in figure, because the result will be NaN -->
            <xsl:when test="not($font-size) or string-length($font-size) = 0">
                <xsl:value-of select="$factor * $default-font-size.list-label"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- font size is in half-points -->
                <xsl:value-of select="round($factor * $font-size div 2)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- ========== -->
    <!-- Smart tags -->
    <!-- ========== -->
    <xsl:template match="st1:*">
        <xsl:apply-templates select="*"/>
    </xsl:template>
    
    <xsl:template name="GetIlfoFromStyle">
        <xsl:param name="style"/>
        <!-- xsl:variable name="list.style" select="key('lists', $style/w:pPr/w:listPr/w:ilfo/@w:val, ancestor::w:wordDocument)"/ --> 
        <!-- w:listPr can be not only in current style and else in style on which current style is based on (@w:styleId = current()/w:basedOn/@w:val) -->
        <xsl:choose>
            <xsl:when test="$style/w:pPr/w:listPr/w:ilfo/@w:val">
                <xsl:value-of select="$style/w:pPr/w:listPr/w:ilfo/@w:val"/><xsl:text>|</xsl:text><xsl:value-of select="$style/@w:styleId"/>
            </xsl:when>
            <xsl:when test="$style/w:basedOn/@w:val">
                <xsl:call-template name="GetIlfoFromStyle">
                    <xsl:with-param name="style" select="key('styles', $style/w:basedOn/@w:val, ancestor::w:wordDocument)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>0|</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
