xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

(:person: hodza-michal:)
(:place: place_2de2d8a3097bf8f9e05f9156b669a8dd:)
 
(:~
 : Takes an xml:id and looks up an entity in your index files. The function returns a map containign the found element, the type of the element and a printable name
 : @param $ref a string matching any xml:id of any of your entities
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)

let $searchkey := 'Personalfragen'
for $x in collection($app:editions)//tei:TEI[.//tei:term[contains(./text(), $searchkey)]] 
return
    $x