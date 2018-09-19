Function Invoke-CUCMAPIRequest {
  <#
  .SYNOPSIS
    Makes API call to Cisco UCM AXL Web Service

  .DESCRIPTION
    Accepts SOAP XML as parameter and POSTs it to the Cisco UCM AXL Web Service

  .PARAMETER Request
    SOAP XML Query

  .EXAMPLE
    Invoke-CUCMAPIRequest -Request $SOAP

    # Submits SOAP request to CUCM AXL Service
  #>
	param(
		[parameter(Mandatory)]$Request
	)

	$ConfigFile = Get-SettingsFile
	$cred = Import-CliXml -Path "$cucm_path\cucm.cred"

	[System.Net.ServicePointManager]::ServerCertificateValidationCallback={$True}
	$parms  = @{
		'Uri' = $ConfigFile.Settings.CUCM.uri
		'Body' = $Request
		'ContentType' = 'text/xml'
		'Method' = 'POST'
		'Credential' = $cred
	}
	return "Completed with status: $((Invoke-WebRequest @parms).StatusDescription)"
}
