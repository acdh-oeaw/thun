xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace config="http://www.digital-archiv.at/ns/thun/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/thun/templates" at "../modules/app.xql";
import module namespace request="http://exist-db.org/xquery/request";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $pageSize := request:get-parameter("pageSize", 25)
let $sequence := collection($app:data)//tei:rs[exists(@ref) and not(starts-with(@ref, '#'))]
let $items := for $x in subsequence($sequence, 1, $pageSize)
    let $old_ref := data($x/@ref)
    let $new_ref := '#'||$old_ref
    return $x
return
    <result>
        <nohash>{count($sequence)}</nohash>
        <display>{$pageSize}</display>
        {$items}
    </result>