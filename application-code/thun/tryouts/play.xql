xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

for $person in doc(concat($config:app-root, '/data/editions/andriewicz-an-thun_1859-11-05_A3-XXI-D524.xml'))//tei:persName
let $before := $person/preceding::text()[1]
let $after := $person/following::text()[1]

return
    <table>
        <tr>
            <td>{$before}</td>
            <td>{$person/text()}</td>
            <td>{$after}</td>
        </tr>
    </table>
