xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $baseURL := request:get-parameter("baseURL", "https://thun-korrespondenz.acdh.oeaw.ac.at")

(: create the CMFI document:)
let $CMFI := 
<tei:TEI>
    <teiHeader>
        <fileDesc>
            <titleStmt>
                <title>Correspondence Metadata Interchange Format for: {$config:app-title}</title>
                {for $x in $config:app-authors return 
                    <editor>{$x/text()}</editor>
                }
            </titleStmt>
            <publicationStmt>
                <publisher>
                    <ref target="{$baseURL}">{$config:app-title}</ref>
                </publisher>
                <idno type="url">{$baseURL}</idno>
                <date when="{current-date()}"/>
                <availability>
                    <licence target="https://creativecommons.org/licenses/by-sa/4.0/">CC-BY 4.0</licence>
                </availability>
            </publicationStmt>
            <sourceDesc>
                <bibl type="online">
                    {$config:app-title} <ref target="{$baseURL}">{$baseURL}</ref>
                </bibl>
            </sourceDesc>
        </fileDesc>
        <profileDesc>

{
let $baseURL := "https://someStableRepo/thun/"
for $corrspDesc in collection($app:editions)//tei:correspDesc
let $ref := app:getDocName($corrspDesc)
return
    <tei:correspDesc ref="{$ref}">{$corrspDesc}</tei:correspDesc>
}
        </profileDesc>
    </teiHeader>
</tei:TEI>

(: create a 'temp' collection:)
let $temp := xmldb:create-collection($config:app-root, 'temp')
(: store CMFI into temp-collection:)
let $stored := xmldb:store($temp, 'cmfi-temp.xml', $CMFI)

for $person in doc($stored)//tei:correspAction/tei:persName
let $oldID := substring-after(data($person/@ref), '#')
return $oldID

