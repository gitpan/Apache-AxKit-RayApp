<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/page">
<page>
<HEAD>
<TITLE>Current time</TITLE>
</HEAD>
<BODY>
<P>
Current local time is <xsl:value-of select="day"/>. <xsl:value-of select="month"/>. <xsl:value-of select="year"/>
<xsl:text> </xsl:text>
<xsl:value-of select="hour"/>:<xsl:value-of select="minute"/>:<xsl:value-of select="second"/>.
<xsl:if test="dst/text() = '1'">
It is a daylight saving time.
</xsl:if>
</P>
</BODY>
</page>
</xsl:template>

</xsl:stylesheet>

