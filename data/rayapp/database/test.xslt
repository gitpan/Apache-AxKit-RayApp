<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/page">
<page>
<HEAD>
<TITLE><xsl:value-of select="/page/title"/></TITLE>
</HEAD>
<BODY>
<xsl:text>
</xsl:text>
<xsl:apply-templates select="user_data|list_of_users"/>
<xsl:text>
</xsl:text>
</BODY>
</page>
</xsl:template>

<xsl:template match="user_data">
	<xsl:if test="user_id != ''">
	User <xsl:value-of select="login"/> has password
	<xsl:value-of select="password"/>.
	</xsl:if>
</xsl:template>

<xsl:template match="list_of_users">
    <xsl:if test="/page/user_data/user_id = ''">
	<xsl:if test="count(users/row) = 0">
		No users in the database.
	</xsl:if>
	<UL>
	<xsl:for-each select="users/row">
	<xsl:text>
	</xsl:text>
	<LI><link>
		<xsl:attribute name="title">
			<xsl:value-of select="login/text()"/>
		</xsl:attribute>
		<user_id><xsl:value-of select="user_id"/></user_id>
		</link></LI>
	</xsl:for-each>
	</UL>
    </xsl:if>
</xsl:template>

</xsl:stylesheet>

