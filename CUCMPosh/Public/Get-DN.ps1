Function Get-DN {
    <#
    .SYNOPSIS
        List directory numbers

    .DESCRIPTION
        List directory numbers, filter by DN, Description, and availability. Wildcard compatible.

    .PARAMETER DN
        Directory Number. Use '%' for wildcard.

    .PARAMETER Description
        DN Description. Use '%' for wildcard.

    .PARAMETER Available
        Switch. Return list of DNs with no line assignment. Filter with -DN and -Description.
    #>
    param(
		[Parameter(ValueFromPipelineByPropertyName)][String]$DN,
        [Parameter(ValueFromPipelineByPropertyName)][String]$Description,
        [switch]$Available
	)

	$ConfigFile = Get-SettingsFile

    <#
    TODO: if -Available, check if the DN is configured, return true if no line assignment
    #>

    if ($Available) {
        $Query = @"
        SELECT n.dnorpattern as dn,rp.name as partition,n.description
        FROM numplan n left
        OUTER JOIN devicenumplanmap m on m.fkdevice = n.pkid
        INNER JOIN routepartition as rp on n.fkroutepartition=rp.pkid
        WHERE m.fkdevice is null AND n.tkpatternusage = 2 $(if($DN){"AND n.dnorpattern LIKE '$DN'"})
        ORDER BY n.dnorpattern
"@
        return Invoke-CUCMSQLQuery -Query $Query
    } else {
        $SOAP = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="$($ConfigFile.Settings.CUCM.version)">
    <soapenv:Header/>
    <soapenv:Body>
      <ns:listLine sequence="?">
         <searchCriteria>
            <pattern>$(if($DN){"$DN"}else{"%"})</pattern>
            <description>$(if($Description){"$Description"}else{"%"})</description>
         </searchCriteria>
         <returnedTags>
            <pattern/>
            <description/>
            <usage/>
            <routePartitionName/>
            <aarNeighborhoodName/>
            <aarDestinationMask/>
            <aarKeepCallHistory/>
            <aarVoiceMailEnabled/>
            <callPickupGroupName/>
            <autoAnswer/>
            <networkHoldMohAudioSourceId/>
            <userHoldMohAudioSourceId/>
            <alertingName/>
            <asciiAlertingName/>
            <presenceGroupName/>
            <shareLineAppearanceCssName/>
            <voiceMailProfileName/>
            <patternPrecedence/>
            <releaseClause/>
            <hrDuration/>
            <hrInterval/>
            <cfaCssPolicy/>
            <defaultActivatedDeviceName/>
            <parkMonForwardNoRetrieveDn/>
            <parkMonForwardNoRetrieveIntDn/>
            <parkMonForwardNoRetrieveVmEnabled/>
            <parkMonForwardNoRetrieveIntVmEnabled/>
            <parkMonForwardNoRetrieveCssName/>
            <parkMonForwardNoRetrieveIntCssName/>
            <parkMonReversionTimer/>
            <partyEntranceTone/>
            <allowCtiControlFlag/>
            <rejectAnonymousCall/>
         </returnedTags>
      </ns:listLine>
   </soapenv:Body>
</soapenv:Envelope>
"@
        $response = [xml](Invoke-CUCMAPIRequest -Request $SOAP).Content
        return $response.Envelope.Body.listLineResponse.return.line
    }
}
