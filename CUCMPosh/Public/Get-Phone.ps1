Function Get-Phone {
    <#
    .SYNOPSIS
        Queries CUCM for phone and returns error or result

    .DESCRIPTION
        Queries CUCM for phone and returns error or result

    .PARAMETER Name
        Name of phone, e.g. SEPE8B7480316D6

    .PARAMETER Basic
        Switch. If specified, outputs only common information.
    #>
    param(
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$Name,
        [switch]$Basic
    )

    $ConfigFile = Get-SettingsFile

    $SOAP = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="$($ConfigFile.Settings.CUCM.version)">
    <soapenv:Header/>
    <soapenv:Body>
        <ns:getPhone sequence="?">
            <name>$Name</name>
        </ns:getPhone>
    </soapenv:Body>
</soapenv:Envelope>
"@

    $response = [xml](Invoke-CUCMAPIRequest -Request $SOAP).Content #.Envelope.Body.getPhoneResponse.return.phone
    $phone = $response.Envelope.Body.getPhoneResponse.return.phone

    if (-not $response) { break }

    if ($Basic) {
        $hash = [ordered]@{
            'name'                   = $phone.name
            'description'            = $phone.description
            'model'                  = $phone.model
            'class'                  = $phone.class
            'protocol'               = $phone.protocol
            'ownerUserName'          = $phone.ownerUserName.'#text'
            'mobilityUserIdName'     = $phone.mobilityUserIdName
            'lines'                  = $phone.lines.line
            'speedDials'             = $phone.speeddials.speeddial
            'cssName'                = $phone.callingSearchSpaceName.'#text'
            'locationName'           = $phone.locationName.'#text'
            'devicePool'             = $phone.devicePoolName.'#text'
            'commonDeviceConfigName' = $phone.commonDeviceConfigName.'#text'
            'commonPhoneConfigName'  = $phone.commonPhoneConfigName.'#text'
            'phoneTemplateName'      = $phone.phoneTemplateName.'#text'
            'userLocale'             = $phone.userLocale
            'networkLocale'          = $phone.networkLocale
            'softkeyTemplateName'    = $phone.softkeyTemplateName.'#text'
            'dndStatus'              = $phone.dndStatus
            'uuid'                   = $phone.uuid
            'loadInformation'        = $phone.loadInformation.'#text'
        }

        $result = New-Object PSObject -Property $hash
        return $result
    } else {
        return $phone
    }
}
