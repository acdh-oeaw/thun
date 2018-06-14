<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="tei:ref[@target]">
        <xsl:choose>
            <xsl:when test="starts-with(data(./@target), '#')">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <ref>
                    <xsl:attribute name="target">
                        <xsl:value-of select="translate(lower-case(data(./@target)), '_', '-')"/>
                    </xsl:attribute>
                    <xsl:value-of select="./text()"/>
                </ref>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>