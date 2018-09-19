Function Set-LineForward {
  <#
  .SYNOPSIS
    Sets the "ForwardAll" for a specified extension to another number

  .DESCRIPTION
    Sets the "ForwardAll" for a specified extension to another number or toggle forward all to voicemail.

  .PARAMETER Pattern
    Line DN for forward. Must exist already in CUCM.

  .PARAMETER routePartition
    Route partition where the line DN is configured

  .PARAMETER Destination
    Number to forward DN to including outbound prefix, e.g. 81, if outbound forward

  .PARAMETER destinationCSS
    Calling Search Space of destination number

  .PARAMETER Voicemail
    Switch. If specified, the line DN will be forwarded to Voicemail.

  .EXAMPLE
    Set-LineForward -Pattern 1234 -RoutePartition 0_Internal_pt -Voicemail

    # Forwards all calls to voicemail for x1234 in partition 0_Internal_pt

  .EXAMPLE
    Set-LineForward -Pattern 4567 -RoutePartition Executive_pt -Destination 815085551234 -DestinationCSS National_css

    # Forwards all calls to 8 1(508)555-1234 for extension 4567 in partition Executive_pt
  #>
	param(
		[Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$pattern,
		[Parameter(Mandatory,ValueFromPipelineByPropertyName)][String]$routePartition,
		[Parameter(ValueFromPipelineByPropertyName)][String]$destination,
		[Parameter(ValueFromPipelineByPropertyName)][String]$destinationCSS,
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
            $(if($Voicemail) {
              "<forwardToVoiceMail>t</forwardToVoiceMail>"
            } else {
              @"
              <forwardToVoiceMail>f</forwardToVoiceMail>
              <destination>$destination</destination>
              <callingSearchSpaceName uuid="?">$destinationCSS</callingSearchSpaceName>
"@
            })
         </callForwardAll>
      </ns:updateLine>
   </soapenv:Body>
</soapenv:Envelope>
"@
	return Invoke-CUCMAPIRequest -Request $SOAP
}
