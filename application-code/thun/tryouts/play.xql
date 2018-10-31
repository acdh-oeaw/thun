xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";

import module namespace  api="http://www.digital-archiv.at/ns/thun/api" at "../modules/api.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $pageNumber := 1
let $pageSize := 50
let $format := 'xml'
let $self := "/hansi/xml/"

let $endpoints := 
<result>
    <ep>
        <url>/dsebaseapp/api/collections</url>
        <name>list collections</name>
        <description>API-Endpoint to list all child collections of the app's data collection</description>
        <group>collections</group>
    </ep>
    <ep>
        <url>{"/dsebaseapp/api/collections/{$collection}"}</url>
        <name>list documents per collection</name>
        <description>API-Endpoint to list all documents stored in the passed in collection</description>
        <group>documents</group>
    </ep>
    <ep>
        <url>{"/collections/{collectionId}/{$id}"}</url>
        <name>show document</name>
        <description>Get an XML/TEI version of a document.</description>
        <group>documents</group>
    </ep>
    <ep>
        <url>{"/entity-types"}</url>
        <name>list entity types</name>
        <description>List all entity-types</description>
        <group>entities</group>
    </ep>
    <ep>
        <url>{"/entity-types"}</url>
        <name>list entities</name>
        <description>List all entities located in the app's indices collections.</description>
        <group>entities</group>
    </ep>
    <ep>
        <url>{"/entities/{$id}"}</url>
        <name>show entity</name>
        <description>API-Endpoint for an entity</description>
        <group>entities</group>
    </ep>
</result>
let $sequence := for $x in $endpoints/ep return $x

let $paginator := api:utils-paginator($self, $pageNumber, $pageSize, $sequence)

let $content := for $x in $paginator?sequence
    let $id := $x/url
    let $title := $x/name
    let $self := string-join(($paginator?endpoint, $id), '/')
    return
            <data>
                <type>{name($x)}</type>
                <id>{$id}</id>
                <attributes>
                    <title>{$title}</title>
                </attributes>
                <links>
                    <self>
                        {$self}
                    </self>
                </links>
            </data>

let $result := 
        <result>
            {$paginator?meta}
            {$content}
        </result>
return $result
