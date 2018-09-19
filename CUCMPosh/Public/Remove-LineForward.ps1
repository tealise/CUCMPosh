Function Remove-LineForward {
	<#
	.SYNOPSIS
		Removes the "ForwardAll" settings for a specified extension

	.DESCRIPTION
		Removes the "ForwardAll" settings for a specified extension

	.PARAMETER Pattern
		Line DN for forward. Must exist already in CUCM.

	.PARAMETER routePartition
		Route partition where the line DN is configured

	.PARAMETER Voicemail
		Switch. If specified, toggles Voicemail off but leaves any configured forward number

	.EXAMPLE
		Remove-LineForward -Pattern 1234 -RoutePartition 0_Internal_pt

		# Removes any ForwardAll settings for x1234 in partition 0_Internal_pt

	.EXAMPLE
		Remove-LineForward -Pattern 4321 -RoutePartition 0_Internal_pt -Voicemail

		# Turns ForwardAll to Voicemail off for x4321 in partition 0_Internal_pt
	#>
	param(
		[Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$pattern,
		[Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$routePartition,
		[switch]$Voicemail
	)

	$ConfigFile = Get-SettingsFile

	$SOAP = @"
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns="$($ConfigFile.Settings.CUCM.version)">
   <soapenv:Header/>
   <soapenv:Body>
      <ns:updateLine sequence="?">
         <pattern>$pattern</pattern>
         <routePartitionName>$routePartition</routePartitionName>
         <callForwardAll>
              <forwardToVoiceMail>f</forwardToVoiceMail>
			  $(if(-not $Voicemail) {
				  @"
				  <destination></destination>
				  <callingSearchSpaceName></callingSearchSpaceName>
"@
			  })
         </callForwardAll>
      </ns:updateLine>
   </soapenv:Body>
</soapenv:Envelope>
"@
	return Invoke-CUCMAPIRequest -Request $SOAP
}
