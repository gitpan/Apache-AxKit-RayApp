<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/page">
<page>
<HEAD>
<TITLE><xsl:value-of select="/page/title"/></TITLE>
</HEAD>
<BODY>
The result of search <xsl:value-of select="searchid"/>.
<BR/>
<xsl:apply-templates match="results"/>
</BODY>
</page>
</xsl:template>

<xsl:template match="results">
	<UL>
	<xsl:for-each select="row"><LI><link href="test.xml">
		<xsl:attribute name="title">
			<xsl:value-of select="name/text()"/>
		</xsl:attribute>
		<id><xsl:value-of select="id"/></id>
		<num><xsl:value-of select="@num"/></num>
	</link></LI>
	<xsl:text> 
	</xsl:text></xsl:for-each>
	</UL>
</xsl:template>

</xsl:stylesheet>

