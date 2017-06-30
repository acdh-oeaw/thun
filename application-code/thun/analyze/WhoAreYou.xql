xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
declare namespace repo = "http://exist-db.org/xquery/repo";
declare namespace dct = "http://purl.org/dc/terms/";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace owl = "http://www.w3.org/2002/07/owl#";
declare namespace xsd = "http://www.w3.org/2001/XMLSchema#";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdfs = "http://www.w3.org/2000/01/rdf-schema#";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace foaf = "http://xmlns.com/foaf/spec/#";
declare namespace dc = "http://purl.org/dc/elements/1.1/"; 
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace util = "http://exist-db.org/xquery/util";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $RDF := 
<rdf:RDF xmlns="https://vocabs.acdh.oeaw.ac.at/#"
    xml:base="https://vocabs.acdh.oeaw.ac.at/"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
    xmlns:foaf="http://xmlns.com/foaf/spec/#"
    xmlns:dc="http://purl.org/dc/elements/1.1/">
    
        <rdf:Description rdf:about="{$config:expath-ns}">
            <dc:title>{$config:app-title}</dc:title>
            <dc:description>{$config:repo-description/text()}</dc:description>
            {
                for $x in $config:repo-descriptor//repo:author
                return
                    <dct:contributor>
                        <rdf:Description>
                            <rdf:type rdf:resource="foaf:Agent"/>
                            <foaf:name>{$x/text()}</foaf:name>
                        </rdf:Description>
                    </dct:contributor>
            }
            <dct:hasPart>
                <rdf:Description>
                    <dc:title>data</dc:title>
                    <rdf:type rdf:resource="acdh:Collection"/>
                    <acdh:locationPath>data</acdh:locationPath>
                    {
                        for $x in xmldb:get-child-collections($config:data-root) 
                        return 
                            <dct:hasPart>
                                <rdf:Description>
                                    <dc:title>{'data/'||$x}</dc:title>
                                    <acdh:locationPath>{'data/'||$x}</acdh:locationPath>
                                    <rdf:type rdf:resource="acdh:Collection"/>
                                    {
                                        for $doc in xmldb:get-child-resources($config:data-root||'/'||$x)
                                        let $node := doc(string-join(($config:data-root, $x, $doc), '/'))
                                        return
                                            <dct:hasPart>
                                                <rdf:Description>
                                                    <dc:title>{normalize-space(string-join($node//tei:titleStmt/tei:title//text(), ' '))}</dc:title>
                                                    <rdf:type rdf:resource="acdh:ContentResource"/>
                                                    <dct:format>{xmldb:get-mime-type(document-uri($node))}</dct:format>
                                                    <acdh:locationPath>{string-join(('data', $x, $doc), '/')}</acdh:locationPath>
                                                </rdf:Description>
                                            </dct:hasPart>
                                    }
                                </rdf:Description>
                            </dct:hasPart>
                    }
                </rdf:Description>
            </dct:hasPart>
        </rdf:Description>
        
    </rdf:RDF>
    
return
    $RDF