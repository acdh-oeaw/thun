xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace acdh="https://vocabs.acdh.oeaw.ac.at/schema#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace util = "http://exist-db.org/xquery/util";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $about := doc($app:data||'/project.rdf')/rdf:RDF
let $project := $about//acdh:Project[1]
let $topCollection := $about//acdh:Collection[not(acdh:isPartOf)]
let $childCollections := $about//acdh:Collection[acdh:isPartOf]


let $baseID := 'https://id.acdh.oeaw.ac.at/'
let $RDF := 
    <rdf:RDF
        xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
        xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
        xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
        xmlns:acdhi="https://id.acdh.oeaw.ac.at/"
        xmlns:foaf="http://xmlns.com/foaf/spec/#"
        xml:base="https://id.acdh.oeaw.ac.at/">
        
        
            {$project}
            {$topCollection}
            {$childCollections}
            {
            for $x in $childCollections
                let $collID := data($x/@rdf:about)
                let $collName := tokenize($collID, '/')[last()]
                let $collection-uri := $app:data||'/'||$collName
                let $document-names := xmldb:get-child-resources($collection-uri)
                let $sample := subsequence($document-names, 1, 5)
                for $doc in $sample
                let $resID := string-join(($collection-uri, $doc), '/')
                let $node := try {
                        doc($resID)
                    } catch * {
                        false()
                    }
                let $title := try {
                        <acdh:hasTitle>{normalize-space(string-join($node//tei:titleStmt/tei:title//text(), ' '))}</acdh:hasTitle>
                    } catch * {
                        <acdh:hasTitle>{$doc}</acdh:hasTitle>
                    }
               
               let $startDate := if($collName = "editions" and data($node//tei:date/@when)[1] castable as xs:date) then 
                    <acdh:hasCoverageStartDate>{data($node//tei:date/@when)[1]}</acdh:hasCoverageStartDate>
                    else ()
               
               let $description := if ($node//tei:msContents//text()) then
                    <acdh:hasDescription>{normalize-space(string-join($node//tei:msContents//text()))}</acdh:hasDescription>
                    else ()
               let $persons := if($collName = 'editions') then
                    for $per in $node//tei:listPerson//tei:person[./tei:idno[@type="URL"]]
                         let $pername := $per//tei:surname[1]/text()
                         let $firstname := $per//tei:forename[1]/text()
                         let $perID := $per//tei:idno[@type="URL"][1]
                         return
                             <acdh:hasActor>
                                 <acdh:Person rdf:about="{$perID}">
                                     <acdh:hasLastName>{$pername}</acdh:hasLastName>
                                     <acdh:hasFirstName>{$firstname}</acdh:hasFirstName>
                                 </acdh:Person>
                             </acdh:hasActor>
                    else ()
                let $places := if($collName = 'editions') then
                    for $item in $node//tei:listPlace//tei:place[./tei:idno]
                         let $placename := $item//tei:placeName[1]/text()
                         let $itemID := $item//tei:idno[1]
                         return
                             <acdh:hasSpatialCoverage>
                                 <acdh:Place rdf:about="{$itemID}">
                                     <acdh:hasTitle>{$placename}</acdh:hasTitle>
                                 </acdh:Place>
                             </acdh:hasSpatialCoverage>
                    else ()
                let $orgs := if($collName = 'editions') then
                    for $item in $node//tei:listOrg//tei:org[./tei:idno[@subtype='GND']/text()]
                         let $itemname := $item//tei:orgName[1]/text()
                         let $itemID := $item//tei:idno[1]
                         return
                             <acdh:hasActor>
                                 <acdh:Organisation rdf:about="{$itemID}">
                                     <acdh:hasTitle>{$itemname}</acdh:hasTitle>
                                 </acdh:Organisation>
                             </acdh:hasActor>
                    else ()
                
                let $next :=
                    if(exists($node/tei:TEI/@prev)) then
                        <acdh:continues rdf:resource="{data($node/tei:TEI/@prev)}"/>
                    else
                        ()
                
                let $prev :=
                    if(exists($node/tei:TEI/@next)) then
                        <acdh:isContinuedBy rdf:resource="{data($node/tei:TEI/@next)}"/>
                    else
                        ()
                    
                
                let $author := 
                        if($collName = "editions") then 
                        <acdh:authors>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="http://d-nb.info/gnd/107360859X"/>
                            </acdh:hasAuthor>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="https://id.acdh.oeaw.ac.at/thun/kraler-tanja"/>
                            </acdh:hasAuthor>
                        </acdh:authors>
                         else if($collName = 'meta') then
                         <acdh:authors>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="http://d-nb.info/gnd/107360859X"/>
                            </acdh:hasAuthor>
                          </acdh:authors>
                          else if($doc = 'listorg.xml') then
                          <acdh:authors>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="https://orcid.org/0000-0001-7081-2280"/>
                            </acdh:hasAuthor>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="http://d-nb.info/gnd/1043833846"/>
                            </acdh:hasAuthor>
                          </acdh:authors>
                          else if($doc = 'cmfi.xml') then
                          <acdh:authors>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="http://d-nb.info/gnd/1043833846"/>
                            </acdh:hasAuthor>
                          </acdh:authors>
                          
                          else if($doc = 'listplace.xml') then
                          <acdh:authors>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="https://orcid.org/0000-0003-2388-1114"/>
                            </acdh:hasAuthor>
                          </acdh:authors>
                          else
                            <acdh:authors>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="http://d-nb.info/gnd/107360859X"/>
                            </acdh:hasAuthor>
                            <acdh:hasAuthor>
                                <acdh:Person rdf:about="https://id.acdh.oeaw.ac.at/thun/kraler-tanja"/>
                            </acdh:hasAuthor>
                        </acdh:authors>
                        
                return
                    <acdh:Resource rdf:about="{string-join(($collID, $doc), '/')}">
                        {$title}
                        {$startDate}
                        {$description}
                        {$persons}
                        {$places}
                        {$orgs}
                        {for $x in $author//acdh:hasAuthor return $x}
                        {$prev}
                        {$next}
                        <acdh:isPartOf rdf:resource="{$collID}"/>
                    </acdh:Resource>
        }

    </rdf:RDF>
    
return
    $RDF