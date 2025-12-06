<#-- Common FreeMarker utilities -->
<#function fmtDate val pat>
    <#-- If it's a date/time (util/sql/JSR 310 wrapped), format directly -->
    <#if val?is_date>
        <#return val?string(pat)>
    <#elseif val?is_string>
        <#attempt>
            <#-- Try full datetime first -->
            <#return val?datetime("yyyy-MM-dd'T'HH:mm:ss")?string(pat)>
        <#recover>
            <#attempt>
                <#-- Try datetime without seconds -->
                <#return val?datetime("yyyy-MM-dd'T'HH:mm")?string(pat)>
            <#recover>
                <#attempt>
                    <#-- Try date-only -->
                    <#return val?date("yyyy-MM-dd")?string(pat)>
                <#recover>
                    <#return val>
                </#attempt>
            </#recover>
        </#attempt>
    <#else>
        <#-- As a last resort, coerce to string (toString) -->
        <#return val?string>
    </#if>
</#function>
