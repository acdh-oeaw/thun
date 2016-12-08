xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace gefx = "http://gexf.net/data/hello-world.gexf";
declare namespace util = "http://exist-db.org/xquery/util";

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";
<gexf xmlns="http://www.gexf.net/1.2draft" version="1.2">
    <meta lastmodifieddate="{current-date()}">
        <creator>thun-net.xql</creator>
        <description>A network of persons mentioned in the Thun-Korpus</description>
    </meta>
    <graph mode="static" defaultedgetype="directed">
        <nodes>
        {
(:          for $person in doc($config:app-root || "/data/indices/listperson.xml")//tei:person[exists(@xml:id)]:)
(:            let $key := data($person/@xml:id):)
(:            let $label := $person//tei:surname || " " || $person//tei:forename:)
(:                return:)
(:                <node id="{$key}" label="{$label}"/>:)
            for $key in distinct-values(collection($config:app-root || "/data/editions/")//tei:TEI[.//tei:persName[@role="sender"]]//tei:persName/@key)
              return
                  <node id="{$key}" label="{$key}"/>
 
        }
        </nodes>
        <edges>
        {
            for $doc in collection($config:app-root || "/data/editions/")//tei:TEI[.//tei:persName[@role="sender"]]
            let $sender := $doc//tei:persName[@role="sender"]
            for $person in $doc//tei:persName[exists(@key)]
            where $sender/@key != $person/@key
                    return
                        <edge id="{util:uuid()}" source="{data($sender/@key)}" target="{data($person/@key)}" />
        }

            
        </edges>
    </graph>
</gexf>

