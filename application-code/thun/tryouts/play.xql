xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

for $title in collection(concat($config:app-root, '/data/editions/'))//tei:TEI[.//*[@ref='#place_f0cb899d2f50889980d12f59807d7ae0']]
return
    $title