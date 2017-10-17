xquery version "3.1";
(: created 2017-10-17 DK Dario.Kampkaspar@oeaw.ac.at :)
(: modified 2017-10-17 peter.andorfer@oeaw.ac.at :)
declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";


let $in := doc('orig_listplace.xml')
let $main := doc('listplace-teihencerexport.xml')
let $out :=
<TEI xmlns="http://www.tei-c.org/ns/1.0">
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Ortsverzeichnis</title>
                <respStmt>
                    <resp>providing the content</resp>
                    <name>Christof Aichner</name>
                    <name>Tanja Kraler</name>
                </respStmt>
                <respStmt>
                    <resp>converted to XML encoding</resp>
                    <name>Peter Andorfer</name>
                </respStmt>
                <respStmt>
                    <resp>georeferenced</resp>
                    <name>Ivana Dobcheva</name>
                </respStmt>
            </titleStmt>
            <publicationStmt>
                <p></p>
            </publicationStmt>
            <sourceDesc>
                <p>Ortsverzeichnis der Thun-Korrespondenz</p>
            </sourceDesc>
        </fileDesc>
    </teiHeader>
    <text>
        <body>
            <div type="index_places">
    <listPlace>{
        (for $item in $main//tei:place
            let $id := $item/@xml:id
            let $myName := $item/tei:placeName
            let $merge := $in/id($id)
            return
                <place xml:id="{$id}">{
                    ($item/tei:placeName,
                    for $name in $merge/tei:placeName
                        return if ($name != $myName)
                        then $name
                        else (),
                    $item/tei:*[not(self::tei:placeName)]
                    )
                }</place>,
        for $item in $in//tei:place
            let $id := $item/@xml:id
            return if ($main/id($id)) then () else $item
        )
    }</listPlace>
    </div>
    </body>
    </text>
    </TEI>
    
    
    
let $st := xmldb:store($config:app-root||'/process/', 'listplace_merge.xml', $out)

return count(doc($st)//tei:place)