xquery version "3.0";
module namespace app="http://www.digital-archiv.at/ns/thun/templates";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace functx = 'http://www.functx.com';
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "config.xqm";
import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

declare function functx:contains-case-insensitive
  ( $arg as xs:string? ,
    $substring as xs:string )  as xs:boolean? {

   contains(upper-case($arg), upper-case($substring))
 } ;

 declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {
    replace ($arg,concat('^.*',$delim),'')
 };
 
 declare function functx:substring-before-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;



(:~
 : This is a sample templating function. It will be called by the templating module if
 : it encounters an HTML element with an attribute data-template="app:test" 
 : or class="app:test" (deprecated). The function has to take at least 2 default
 : parameters. Additional parameters will be mapped to matching request or session parameters.
 : 
 : @param $node the HTML node with the attribute which triggered this call
 : @param $model a map containing arbitrary data - used to pass information between template calls
 :)
declare function app:test($node as node(), $model as map(*)) {
    <p>Dummy template output generated by function app:test at {current-dateTime()}. The templating
        function was triggered by the data-template attribute <code>data-template="app:test"</code>.</p>
};

(:~
: returns the name of the document of the node passed to this function.
:)
declare function app:getDocName($node as node()){
let $name := functx:substring-after-last(document-uri(root($node)), '/')
    return $name
};

(:~
 : href to document.
 :)
declare function app:hrefToDoc($node as node()){
let $name := functx:substring-after-last($node, '/')
let $href := concat('show.html','?document=', app:getDocName($node))
    return $href
};

(:~
 : a fulltext-search function
 :)
 declare function app:ft_search($node as node(), $model as map (*)) {
 if (request:get-parameter("searchexpr", "") !="") then
 let $searchterm as xs:string:= request:get-parameter("searchexpr", "")
 for $hit in collection(concat($config:app-root, '/data/editions/'))//*[.//tei:p[ft:query(.,$searchterm)]|.//tei:cell[ft:query(.,$searchterm)]]
    let $href := concat(app:hrefToDoc($hit), "&amp;searchexpr=", $searchterm) 
    let $score as xs:float := ft:score($hit)
    order by $score descending
    return
    <tr>
        <td>{$score}</td>
        <td class="KWIC">{kwic:summarize($hit, <config width="40" link="{$href}" />)}</td>
        <td>{app:getDocName($hit)}</td>
    </tr>
 else
    <div>Nothing to search for</div>
 };

(:~
 : fetches all documents which contain the searched person or place
 :)
declare function app:indexSearch_hits($node as node(), $model as map(*), $searchkey as xs:string?, $path as xs:string?)
{
    for $hit in collection(concat($config:app-root, '/data/editions/'))//tei:TEI[.//tei:placeName[functx:contains-case-insensitive(./text(), $searchkey)] | .//tei:placeName[@key=$searchkey] | .//tei:persName[@key=$searchkey]]
    let $doc := document-uri(root($hit)) 
    return
    <li>
        <a href="{app:hrefToDoc($hit)}">{app:getDocName($hit)}</a>
    </li> 
 };
 
 
(:~
 : creates a basic person-index derived from the  '/data/indices/listperson.xml'
 :)
declare function app:listPers($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $person in doc(concat($config:app-root, '/data/indices/listperson.xml'))//tei:listPerson/tei:person
        return
        <li><a href="{concat($hitHtml,data($person/@xml:id))}">{$person/tei:persName}</a></li>
};

(:~
 : creates a basic place-index derived from the  '/data/indices/listplace.xml'
 :)
declare function app:listPlace($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $place in doc(concat($config:app-root, '/data/indices/listplace.xml'))//tei:listPlace/tei:place
        return
        <li><a href="{concat($hitHtml,data($place/@xml:id))}">{$place/tei:placeName}</a></li>
};

(:~
 : creates a basic table of content derived from the documents stored in '/data/editions'
 :)
declare function app:toc($node as node(), $model as map(*)) {
    for $title in collection(concat($config:app-root, '/data/editions/'))//tei:TEI
    let $sender := fn:normalize-space($title//tei:persName[@role=contains($title//tei:persName/@role,'sender') and 1]/text())
        let $sender_nn := if(fn:exists($title//tei:persName[@role=contains($title//tei:persName/@role,'sender') and 1]/text()))
                            then concat(functx:substring-after-last($sender,' '), ", ")
                            else "ohne Absender"
        let $sender_vn := functx:substring-before-last($sender,' ')
        let $empfänger := fn:normalize-space($title//tei:persName[@role=contains($title//tei:persName/@role,'recipient') and 1]/text())
        let $empfänger_nn := if(fn:exists($title//tei:persName[@role=contains($title//tei:persName/@role,'recipient') and 1]/text()))
                                then concat(functx:substring-after-last($empfänger,' '), ", ")
                                else "ohne Empfänger"
        let $empfänger_vn := functx:substring-before-last($empfänger,' ')
        let $wo := if(fn:exists($title//tei:title/tei:placeName[2]/text()))
                     then concat($title//tei:title/tei:placeName[1]/text()," und ", $title//tei:title/tei:placeName[2]/text())
                     else $title//tei:title/tei:placeName[1]/text()
        let $wann := data($title//tei:date/@when)[1]
        let $zitat := $title//tei:msIdentifier
        return
        <tr>
           <td>{$sender_nn}{$sender_vn}</td>
           <td>{$empfänger_nn}{$empfänger_vn}</td>
           <td align="center">{$wo}</td>
           <td align="center"><abbr title="{$zitat}">{$wann}</abbr></td>
            <td>
                <a href="{app:hrefToDoc($title)}">{app:getDocName($title)}</a>
            </td>
        </tr>   
};

(:~
 : perfoms an XSLT transformation
:)
declare function app:XMLtoHTML ($node as node(), $model as map (*), $query as xs:string?) {
let $ref := xs:string(request:get-parameter("document", ""))
let $xmlPath := concat(xs:string(request:get-parameter("directory", "editions")), '/')
let $xml := doc(replace(concat($config:app-root,'/data/', $xmlPath, $ref), '/exist/', '/db/'))
let $xslPath := concat(xs:string(request:get-parameter("stylesheet", "xmlToHtml")), '.xsl')
let $xsl := doc(replace(concat($config:app-root,'/resources/xslt/', $xslPath), '/exist/', '/db/'))
let $params := 
<parameters>
   {for $p in request:get-parameter-names()
    let $val := request:get-parameter($p,())
    where  not($p = ("document","directory","stylesheet"))
    return
       <param name="{$p}"  value="{$val}"/>
   }
</parameters>
return 
    transform:transform($xml, $xsl, $params)
};