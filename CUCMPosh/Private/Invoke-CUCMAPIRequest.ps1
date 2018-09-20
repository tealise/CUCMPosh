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
	$cucm_path = $MyInvocation.MyCommand.Module.PrivateData['cucm_path']
	$cred = Import-CliXml -Path "$cucm_path\cucm.cred"

	[System.Net.ServicePointManager]::ServerCertificateValidationCallback={$True}
	$parms  = @{
		'Uri' = $ConfigFile.Settings.CUCM.uri
		'Body' = $Request
		'ContentType' = 'text/xml'
		'Method' = 'POST'
		'Credential' = $cred
	}

	try {
	    return Invoke-WebRequest @parms
    } catch {
	    $result = $_.Exception.Response.GetResponseStream()
	    $reader = New-Object System.IO.StreamReader($result)
	    $reader.BaseStream.Position = 0
	    $reader.DiscardBufferedData()
		$content = $reader.ReadToEnd()
		$xml = [xml]$content
		$fault = $xml.Envelope.Body.Fault

		$message = @{
			'faultcode'      = $fault.faultcode
			'faultstring'    = $fault.faultstring
			'detail_message' = $fault.detail.AxlError.axlMessage
			'detail_request' = $fault.detail.AxlError.request
		}

		Write-Host "Failed with fault code '$($message.faultcode)' for request '$($message.detail_request)' - $($message.detail_message)"

	    return $xml
    }
}
