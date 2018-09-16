xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $all := count(collection($app:editions)//tei:TEI[.//tei:orgName])
let $result := 
    <result>
        <count>{$all}</count>
    {
        for $x in collection($app:editions)//tei:TEI[.//tei:orgName]
            return <item>{base-uri($x)}</item>
    }
    </result>
return $result