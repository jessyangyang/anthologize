<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:regexp="http://exslt.org/regular-expressions"
  extension-element-prefixes="regexp" version="1.0">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jul 29, 2010</xd:p>
      <xd:p><xd:b>Author:</xd:b> Patrick Rashleigh</xd:p>
      <xd:p>A sample stylesheet to transform TEI to HTML for eventual ePub
        inclusion</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:output method="xml" encoding="UTF-16"/>
  <xsl:variable name="images-directory" select="'images'"/>
  <xsl:template match="/">
    <!--<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">-->
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <title>
          <xsl:value-of
            select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"
          />
        </title>
        <!--<link href="stylesheet.css" type="text/css" rel="stylesheet" />-->
        <!--<style type="text/css">-->
<!--
          this to be filled in-->
        <!--</style>-->
        <link rel="stylesheet" type="application/vnd.adobe-page-template+xml"
          href="page-template.xpgt"/>
      </head>
      <body>
        <div id="title-page">
          <h1>
            <xsl:value-of
              select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title"
            />
          </h1>
        </div>
        <!-- <div id="publication-statement"></div>-->
        <!-- <div class="book-description">
        <xsl:copy-of select="/TEI/teiHeader/fileDesc/sourceDesc"/> -->

        <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:div[@type='part']">
          <div class="chapter" id="epub-chapter-{position()}">
            <h2 class="chapter-title">
              <xsl:value-of select="tei:head/tei:title"/>
            </h2>
            <div class="chapter-content">
              <xsl:for-each select="./tei:div[@type='libraryItem']">
                <!--
              <p class="post-description">&#8594; Source: <span
                style="font-family: monospace"><xsl:value-of select="tei:link"
                /></span>, published on <xsl:value-of select="tei:pubDate"/> by
                  <xsl:value-of select="dc:creator"/>. </p>-->
                <div class="post-content">
                  <xsl:apply-templates select="html:body"/>
                </div>
              </xsl:for-each>
            </div>
          </div>
        </xsl:for-each>
      </body>
    </html>
  </xsl:template>

  <!-- Skip through HTML body tags -->

  <xsl:template match="html:body">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- Filter out script tags, but pass through noscript -->

  <xsl:template match="html:script"/>
  <xsl:template match="html:noscript">
    <xsl:copy-of select="*"/>
  </xsl:template>

  <!-- Pass-through subset of XHTML that is recognised by ePub format -->

  <xsl:template
    match="html:abbr|html:acronym|html:address|html:blockquote|html:br|html:cite|html:code|html:dfn|html:div|html:em|html:h1|html:h2|html:h3|html:h4|html:h5|html:h6|html:kbd|html:p|html:pre|html:q|html:samp|html:span|html:strong|html:var|html:dl|html:dt|html:dd|html:ol|html:ul|html:li|html:a|html:object|html:param|html:b|html:big|html:hr|html:i|html:small|html:sub|html:sup|html:tt|html:del|html:ins|html:bdo|html:caption|html:col|html:colgroup|html:table|html:tbody|html:td|html:tfoot|html:th|html:thead|html:tr|html:area|html:map|html:style|html:img">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Pass-through attributes of html tags and text nodes -->

  <xsl:template match="html:*/@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Object tag http://www.idpf.org/2007/ops/OPS_2.0_final_spec.html#Section2.3.6 
  
    When adding objects whose data media type is not drawn from the OPS Core Media Type list
    or which reference an object implementation using the classid attribute, 
    the object element must specify fallback information for the object, 
    such as another object, an img element, or descriptive text. 
    Inline fallback information is provided as OPS content appearing immediately after 
    the final param element that refers to the parent object. 
    Descriptive text for the object, using inline content, an included OPS Content Document, 
    or some other method, should be provided to allow access for people who are not able 
    to access non-textual content.
  
  -->

  <!-- FOR NOW: Pass through -->

  <xsl:template match="html:object">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!--
  <xsl:template match="html:object">
    <xsl:if test="html:object"
  </xsl:template> -->

  <!-- 
    Images have to have their URLs rewritten to make them relative and in the ePub image directory 
    take off everything before the LAST slash
  -->

  <xsl:template match="html:img/@src">
    <xsl:attribute name="src">
      <xsl:variable name="img-url-filename-only">
        <xsl:call-template name="strip-url-of-directories">
          <xsl:with-param name="url" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of
        select="concat($images-directory, '/', $img-url-filename-only)"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="strip-url-of-directories">
    <xsl:param name="url"/>
    <xsl:choose>
      <xsl:when test="contains($url,'/')">
        <xsl:call-template name="strip-url-of-directories">
          <xsl:with-param name="url" select="substring-after($url,'/')"/>
        </xsl:call-template>
        <!--<xsl:value-of select="substring-after(.,'/')"/>|
        <xsl:value-of select="substring-after(substring-after(.,'/'), '/')"/>-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$url"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
  <xsl:template name="get-author-info">
    <xsl:param name="author-id"/>
  </xsl:template>-->
</xsl:stylesheet>