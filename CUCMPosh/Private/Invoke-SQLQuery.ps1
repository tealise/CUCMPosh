Function Invoke-CUCMSQLQuery {
	<#
	.SYNOPSIS
		Queries CUCM and returns error or result

	.DESCRIPTION
		Queries CUCM and returns error or result

	.PARAMETER Query
		SQL Query
	#>
	param(
		[Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$Query
	)

	$ConfigFile = Get-SettingsFile

	$SOAP = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="$($ConfigFile.Settings.CUCM.version)">
	<soapenv:Header/>
	<soapenv:Body>
		<ns:executeSQLQuery>
			<sql>$Query</sql>
		</ns:executeSQLQuery>
	</soapenv:Body>
</soapenv:Envelope>
"@

	$response = [xml](Invoke-CUCMAPIRequest -Request $SOAP).Content
	return $response.Envelope.Body.executeSQLQueryResponse.return.row
}
