xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {

   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;

declare function local:slugify_refs( $arg as xs:string)  as xs:string {
   let $arg := lower-case(replace($arg, '[\[\]\(\)#/\?]', ""))
   let $arg := replace($arg, "[\]_\s*“„,;\.:]", "-")
   let $arg := replace($arg, "['`´]", "-")
   let $arg := replace($arg, "--*", "-")
   return $arg
 } ;
let $listOrg := 

<listOrg>{
    for $org in collection(concat($config:app-root, '/data/editions'))//tei:orgName
    let $string := string-join($org//text(), ' ')
    let $xmlID := 'org_'||util:hash($string, 'md5')
    let $ref := '#'||$xmlID
(:    let $addedRef := update insert attribute ref {$ref} into $place:)
    group by $xmlID
    where $string != ''
    return 
        <org xml:id="{$xmlID}">
            <orgName type="pref">{normalize-space($string[1])}</orgName>
        </org>
}</listOrg>

return $listOrg