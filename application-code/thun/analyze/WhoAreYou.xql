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
declare namespace acdh= "https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace acdhi = "https://id.acdh.oeaw.ac.at/";
declare namespace foaf = "http://xmlns.com/foaf/spec/#";
declare namespace dc =  "http://purl.org/dc/elements/1.1/"; 
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace util = "http://exist-db.org/xquery/util";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $RDF := 
<rdf:RDF xmlns="https://vocabs.acdh.oeaw.ac.at/#"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
    xmlns:acdhi="https://id.acdh.oeaw.ac.at/"
    xmlns:foaf="http://xmlns.com/foaf/spec/#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xml:base="https://id.acdh.oeaw.ac.at/">
    
        <acdh:Project rdf:ID="{$config:app-name}">
            <dct:identifier>{$config:app-name}</dct:identifier>
            <dc:title>{$config:app-title}</dc:title>
            <dc:description>{$config:repo-description/text()}</dc:description>
            <dct:contributor>
            <foaf:Agent rdf:ID="pandorfer">
                <dct:identifier>Peter Andorfer</dct:identifier>
                <dc:title>Peter Andorfer</dc:title>
                <foaf:name>Peter Andorfer</foaf:name>
            </foaf:Agent>
            </dct:contributor>           
            <dct:hasPart>
                <acdh:Collection rdf:ID="{string-join(($config:app-name, 'data'), '/')}">
                    <dc:title>{string-join(($config:app-name, 'data'), '/')}</dc:title>
                    <acdh:locationPath>{string-join(($config:app-name, 'data'), '/')}</acdh:locationPath>
                    <dct:hasPart>
                    {
                        for $x in xmldb:get-child-collections($config:data-root) 
                        return
                            <acdh:Collection rdf:ID="{string-join(($config:app-name, 'data', $x), '/')}">
                                <dct:identifier>{string-join(($config:app-name, 'data', $x), '/')}</dct:identifier>
                                <dc:title>{string-join(($config:app-name, 'data', $x), '/')}</dc:title>
                                <dct:hasPart>
                                {
                                    for $doc in xmldb:get-child-resources($config:data-root||'/'||$x)
                                    let $node := doc(string-join(($config:data-root, $x, $doc), '/'))
                                    let $filename := string-join(($config:app-name, 'data', $x, $doc), '/')
                                    return
                                        <acdh:Resource rdf:ID="{$filename}">
                                            <dc:title>{normalize-space(string-join($node//tei:titleStmt/tei:title//text(), ' '))}</dc:title>
                                            <dct:format>{xmldb:get-mime-type(document-uri($node))}</dct:format>
                                            <acdh:locationPath>{string-join(('data', $x, $doc), '/')}</acdh:locationPath>
                                        </acdh:Resource>
                                    }
                                </dct:hasPart>
                            </acdh:Collection>
                    }    
                    </dct:hasPart>
                </acdh:Collection>
            </dct:hasPart>
        </acdh:Project>
        
    </rdf:RDF>
    
return
    $RDF