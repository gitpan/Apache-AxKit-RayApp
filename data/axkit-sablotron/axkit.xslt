<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/data">
<HTMLPAGE>
<HEAD>
<TITLE><xsl:value-of select="title/text()"/></TITLE>
</HEAD>
<BODY>
	<P>
	And here's the real content.
	</P>
	<xsl:apply-templates select="para"/>
</BODY>
</HTMLPAGE>
</xsl:template>

<xsl:template match="para">
	<P>
	<xsl:apply-templates/>
	</P>
</xsl:template>

<xsl:template match="bold">
	<STRONG><xsl:apply-templates/></STRONG>
</xsl:template>


</xsl:stylesheet>

