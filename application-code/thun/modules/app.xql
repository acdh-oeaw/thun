xquery version "3.1";
module namespace app="http://www.digital-archiv.at/ns/thun/templates";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace functx = 'http://www.functx.com';
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "config.xqm";
import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";

declare variable $app:data := $config:app-root||'/data';
declare variable  $app:editions := $config:app-root||'/data/editions';
declare variable  $app:indices := $config:app-root||'/data/indices';
declare variable $app:placeIndex := $config:app-root||'/data/indices/listplace.xml';
declare variable $app:personIndex := $config:app-root||'/data/indices/listperson.xml';
declare variable $app:orgIndex := $config:app-root||'/data/indices/listorg.xml';


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
 
 declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {

   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;

declare function app:fetchEntity($ref as xs:string){
    let $entity := collection($config:app-root||'/data/indices')//*[@xml:id=$ref]
    let $type: = if (contains(node-name($entity), 'place')) then 'place'
        else if  (contains(node-name($entity), 'person')) then 'person'
        else 'unkown'
    let $viewName := if($type eq 'place') then(string-join($entity/tei:placeName[1]//text(), ', '))
        else if ($type eq 'person' and exists($entity/tei:persName/tei:forename)) then string-join(($entity/tei:persName/tei:surname/text(), $entity/tei:persName/tei:forename/text()), ', ')
        else if ($type eq 'person') then $entity/tei:placeName/tei:surname/text()
        else 'no name'
    let $viewName := normalize-space($viewName)
    
    return 
        ($viewName, $type, $entity)
};

declare function local:everything2string($entity as node()){
    let $texts := normalize-space(string-join($entity//text(), ' '))
    return 
        $texts
};

declare function local:viewName($entity as node()){
    let $name := node-name($entity)
    return
        $name
};


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
: returns the concatenated child nodes of a fetched placeName or persName element.
:)
declare function app:nameOfIndexEntry($node as node(), $model as map (*)){

    let $searchkey := xs:string(request:get-parameter("searchkey", "No search key provided"))
    let $withHash:= '#'||$searchkey
    let $entities := collection($app:editions)//tei:TEI//*[@ref=$withHash]
    let $terms := (collection($app:editions)//tei:TEI[.//tei:term[./text() eq substring-after($withHash, '#')]])
    let $noOfterms := count(($entities, $terms))
    let $hit := collection($app:indices)//*[@xml:id=$searchkey]
    let $name := if (contains(node-name($hit), 'person')) 
        then 
            <a class="reference" data-type="listperson.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:persName[1], ', '))}</a>
        else if (contains(node-name($hit), 'place'))
        then
            <a class="reference" data-type="listplace.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:placeName[1], ', '))}</a>
        else if (contains(node-name($hit), 'org'))
        then
            <a class="reference" data-type="listorg.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:orgName[1], ', '))}</a>
        else
            functx:capitalize-first($searchkey)
    return
    <h1 style="text-align:center;">
        <small>
            <span id="hitcount"/>{$noOfterms} Treffer für</small>
        <br/>
        <strong>
            {$name}
        </strong>
    </h1>
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
        <td class="KWIC">{kwic:summarize($hit, <config width="40" link="{$href}" />)}</td>
        <td><a href="{$href}">{app:getDocName($hit)}</a></td>
    </tr>
 else
    <div>Nothing to search for</div>
 };

declare function app:indexSearch_hits($node as node(), $model as map(*),  $searchkey as xs:string?, $path as xs:string?){
let $indexSerachKey := $searchkey
let $searchkey:= '#'||$searchkey
let $entities := collection($app:editions)//tei:TEI[.//*/@ref=$searchkey]
let $terms := collection($app:editions)//tei:TEI[.//tei:term[./text() eq substring-after($searchkey, '#')]] 
for $title in ($entities, $terms)
let $hits := if (count(root($title)//*[@ref=$searchkey]) = 0) then 1 else count(root($title)//*[@ref=$searchkey])
let $snippet := 
    for $entity in root($title)//*[@ref=$searchkey]
            let $before := $entity/preceding::text()[1]
            let $after := $entity/following::text()[1]
            return
                <p>... {$before} <strong><a href="{concat(app:hrefToDoc($title), "&amp;searchkey=", $indexSerachKey)}"> {$entity/text()}</a></strong> {$after}...<br/></p>
let $sender := fn:normalize-space($title//tei:rs[@role=contains($title//tei:rs/@role,'sender') and 1]/text()[1])
let $sender_nn := if(fn:exists($title//tei:rs[@role=contains($title//tei:rs/@role,'sender') and 1]/text()))
                            then concat(functx:substring-after-last($sender,' '), ", ")
                            else "ohne Absender"
let $sender_vn := functx:substring-before-last($sender,' ')
let $empfänger := fn:normalize-space($title//tei:rs[@role=contains($title//tei:rs/@role,'recipient') and 1]/text()[1])
let $empfänger_nn := if(fn:exists($title//tei:rs[@role=contains($title//tei:rs/@role,'recipient') and 1]/text()))
                                then concat(functx:substring-after-last($empfänger,' '), ", ")
                                else "ohne Empfänger"
let $empfänger_vn := functx:substring-before-last($empfänger,' ')
let $wo := if(fn:exists($title//tei:title//tei:rs[@type='place']))
                     then $title//tei:title//tei:rs[@type='place']//text()
                     else 'no place'
let $wann := data($title//tei:date/@when)[1]
let $zitat := $title//tei:msIdentifier
return 
        <tr>
           <td>{$sender_nn}{$sender_vn}</td>
           <td>{$empfänger_nn}{$empfänger_vn}</td>
           <td align="center">{$wo}</td>
           <td align="center"><abbr title="{$zitat}">{$wann}</abbr></td>
           <td>{$hits}</td>
           <td>{$snippet}<p style="text-align:right">({<a href="{concat(app:hrefToDoc($title), "&amp;searchkey=", $indexSerachKey)}">{app:getDocName($title)}</a>})</p></td>
        </tr>   
};

(:~
 : creates a basic org-index
 :)
declare function app:listOrg($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $org in doc($app:orgIndex)//tei:org
        let $idno := $org/tei:idno
        return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($org/@xml:id))}">{$org/tei:orgName}</a>
            </td>
            <td><a href="{$idno}">{$idno}</a></td>
        </tr>
};
 
(:~
 : creates a basic person-index derived from the  '/data/indices/listperson.xml'
 :)
declare function app:listPers($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $person in doc($app:personIndex)//tei:listPerson/tei:person
    let $gnd := $person/tei:note/tei:p[3]/text()
    let $gnd_link := if ($gnd != "no gnd provided") then
        <a href="{$gnd}">{$gnd}</a>
        else
        "-"
        return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($person/@xml:id))}">{$person/tei:persName/tei:surname}</a>
            </td>
            <td>
                {$person/tei:persName/tei:forename}
            </td>
            <td>
                {$gnd_link}
            </td>
        </tr>
};

(:~
 : creates a basic place-index derived from the  '/data/indices/listplace.xml'
 :)
declare function app:listPlace($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $place in doc($app:placeIndex)//tei:listPlace/tei:place
    let $lat := tokenize($place//tei:geo/text(), ' ')[1]
    let $lng := tokenize($place//tei:geo/text(), ' ')[2]
    let $idno := $place//tei:idno[1]
    let $normdata := if($idno) then <a href="{$idno}">{$idno}</a> else '-'
        return
        <tr>
            <td>
                <a href="{concat($hitHtml, data($place/@xml:id))}">{$place/tei:placeName[1]}</a>
            </td>
            <td>{for $altName in $place//tei:placeName return <li>{$altName}</li>}</td>
            <td>{$normdata}</td>
            <td>{$lat}</td>
            <td>{$lng}</td>
        </tr>
};
(:~
 : creates a basic term-index derived from the all documents stored in collection'/data/editions'
 :)
declare function app:listTerms($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $term in distinct-values(collection(concat($config:app-root, '/data/editions/'))//tei:term)
    order by $term
    return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($term))}">{$term}</a>
            </td>
        </tr>
 };
(:~
 : creates a basic table of content derived from the documents stored in '/data/editions'
 :)
declare function app:toc($node as node(), $model as map(*)) {

    let $bestand := request:get-parameter("bestand", "")
    let $docs := if ($bestand = "nachlass")
        then 
            collection(concat($config:app-root, '/data/editions/'))[contains(.//tei:repository, 'Linie Tetschen, Nachlass Leo')]
        else if ($bestand = "gesamt")
        then 
            collection(concat($config:app-root, '/data/editions/'))//tei:TEI
        else 
            collection(concat($config:app-root, '/data/editions/'))[not(contains(.//tei:repository, 'Linie Tetschen, Nachlass Leo'))]
    for $title in $docs
    let $sender := fn:normalize-space($title//tei:rs[@role=contains($title//tei:rs/@role,'sender') and 1]/text()[1])
        let $sender_nn := if(fn:exists($title//tei:rs[@role=contains($title//tei:rs/@role,'sender') and 1]/text()))
                            then concat(functx:substring-after-last($sender,' '), ", ")
                            else "ohne Absender"
        let $sender_vn := functx:substring-before-last($sender,' ')
        let $empfänger := fn:normalize-space($title//tei:rs[@role=contains($title//tei:rs/@role,'recipient') and 1]/text()[1])
        let $empfänger_nn := if(fn:exists($title//tei:rs[@role=contains($title//tei:rs/@role,'recipient') and 1]/text()))
                                then concat(functx:substring-after-last($empfänger,' '), ", ")
                                else "ohne Empfänger"
        let $empfänger_vn := functx:substring-before-last($empfänger,' ')
        let $wo := if(fn:exists($title//tei:title//tei:rs[@type='place']))
                     then $title//tei:title//tei:rs[@type='place']//text()
                     else 'no place'
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
let $collection := functx:substring-after-last(util:collection-name($xml), '/')
let $path2source := string-join(('../../../../exist/restxq', 'thun-korrespondenz/api/collections', $collection, $ref), '/')
let $params := 
<parameters>
    <param name="app-name" value="{$config:app-name}"/>
    <param name="collection-name" value="{$collection}"/>
    <param name="path2source" value="{$path2source}"/>
   {for $p in request:get-parameter-names()
    let $val := request:get-parameter($p,())
   (: where  not($p = ("document","directory","stylesheet")):)
    return
       <param name="{$p}"  value="{$val}"/>
   }
</parameters>
return 
    transform:transform($xml, $xsl, $params)
};