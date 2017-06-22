xquery version "3.0";

module namespace api="http://www.digital-archiv.at/ns/thun/api";
import module namespace request="http://exist-db.org/xquery/request";
declare namespace rest = "http://exquery.org/ns/restxq";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
import module namespace functx = "http://www.functx.com";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "app.xql";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "config.xqm";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace http = "http://expath.org/ns/http-client";

declare variable $api:JSON := 
<rest:response>
    <http:response>
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="application/json; charset=utf-8"/>
    </http:response>
    <output:serialization-parameters>
    <output:method value='json'/>
      <output:media-type value='application/json'/>
    </output:serialization-parameters>
 </rest:response>;

declare variable $api:XML := 
<rest:response>
    <http:response>
      <http:header name="Content-Language" value="en"/>
      <http:header name="Content-Type" value="application/xml; charset=utf-8"/>
    </http:response>
    <output:serialization-parameters>
    <output:method value='xml'/>
      <output:media-type value='application/xml'/>
    </output:serialization-parameters>
 </rest:response>;


(:~ lists content of collection ~:)
declare 
    %rest:GET
    %rest:path("/thun/{$collection}/{$format}")
function api:list-documents($collection, $format) {
let $result:= api:list-collection-content($collection)

let $serialization := switch($format)
    case('xml') return $api:XML
    default return $api:JSON
        return 
            ($serialization, $result)
};

declare 
    %rest:GET
    %rest:path("/thun/{$collection}/{$id}/{$format}")
function api:show-document-api($collection, $id, $format) {
    let $result := api:show-document($collection, $id)
    let $serialization := switch($format)
    case('xml') return $api:XML
    default return $api:JSON
    return 
       ($serialization, $result)
};


declare %private function api:list-collection-content($collection as xs:string){
    let $self := rest:uri()
    let $base := functx:substring-before-last($self,'/')
    let $result:= 
        <result>
            <links>
                <self>{$self}</self>
            </links>
           
            {for $doc in collection($config:app-root||'/data/'||$collection)//tei:TEI
            
            let $path := functx:substring-before-last(document-uri(root($doc)),'/')
            let $id := app:getDocName($doc)
            let $path2me := string-join(($base, $id, 'xml'), '/')
                return
                    <data>
                        <type>TEI-Document</type>
                        <id>{$id}</id>
                        <attributes>
                            <title>{normalize-space(string-join($doc//tei:title[1]//text(), ' '))}</title>
                        </attributes>
                        <links>
                            <self>{$path2me}</self>
                        </links>
                    </data>
             }
        </result>
        return 
            $result
};

declare %private function api:show-document($collection as xs:string, $id as xs:string){
    let $doc := doc($config:app-root||'/data/'||$collection||'/'||$id)
    return 
        $doc
};