# #############################################################################
# Cisco UCM - MODULE
# NAME: CiscoUCM.psm1
# #############################################################################

$cucm_path = "$($env:userprofile)\AppData\Local\AdminTools\CUCM"
if (-Not (Test-Path -Path $cucm_path)) { New-Item -Path $cucm_path -ItemType Directory }

function Copy-SettingsToSystem {
	if (!(Test-Path -Path "$cucm_path\Settings.xml")) {
		Write-Warning "Unable to copy 'Settings.xml', file does not exist. Please run 'Get-SettingsFile' to generate config."
		break
	}

	$sys_path = "C:\Windows\System32\Config\systemprofile\AppData\Local\AdminTools\CUCM"
	if (-Not (Test-Path -Path $sys_path)) { New-Item -Path $sys_path -ItemType Directory | Out-Null }
	Copy-Item "$cucm_path\Settings.xml" "$sys_path\Settings.xml"
	return "File(s) copied."
}

function Get-SettingsFile {
	param(
		[switch]$Force
	)
	if (!(Test-Path -Path "$cucm_path\Settings.xml") -or $Force) {
		if (-not $Force) {
			Write-Warning "Unable to find '$cucm_path\Settings.xml' file"
			$createone = Read-Host "Would you like to create a new settings file? [Y/N]"
		} else { $createone = "Y" }
		if ($createone -eq "Y") {
			[string]$CUCMURI        = Read-Host "Enter URI of Cisco UCM AXL"
			[string]$CUCMAxlVersion = Read-Host "Enter AXL Version (e.g. 10.5)"
			$CUCMAxlVersion = 'http://www.cisco.com/AXL/API/' + $CUCMAxlVersion
			if ($CUCMCredential = $host.ui.PromptForCredential('Cisco UCM Credentials Required', 'Please enter credentials for Cisco Unified Communications Manager.', '', "")){} else {
				Write-Warning "Need CUCM credentials in order to proceed.`r`nPlease re-run script and enter the appropriate credentials."
				break
			}
			$CUCMCredential | Export-CliXml -Path "$cucm_path\cucm.cred"

			Write-Host "Generating XML File..."
			$mod_path = Split-Path (Get-Module CiscoUCM).Path
			[xml]$ConfigFile = (Get-Content "$mod_path\SettingsTemplate.xml")
			$ConfigFile.Settings.CUCM.uri     = $CUCMURI
			$ConfigFile.Settings.CUCM.version = $CUCMAxlVersion
			$ConfigFile.Settings.CUCM.auth    = "$cucm_path\cucm.cred"
			$ConfigFile.Save("$cucm_path\Settings.xml") | Out-Null

			Write-Host "File Created in '$cucm_path'"
		} else {
			Write-Warning "Need a settings.xml file in order to proceed`nQuitting..."
			exit
		}
	}

	[xml]$ConfigFile = Get-Content "$cucm_path\Settings.xml"
	return $ConfigFile
}

function Invoke-CUCMAPIRequest {
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

function Set-LineForward {
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

function Add-OncallConfig {
	[xml]$ConfigFile = Get-SettingsFile

	# CUCM
	$ConfigFile.Settings.CUCM.ONCALL.ext     = [string](Read-Host "Enter an extension for forward")
	$ConfigFile.Settings.CUCM.ONCALL.full    = [string](Read-Host "Enter full 10-digit phone number for forward")
	$ConfigFile.Settings.CUCM.ONCALL.pt      = [string](Read-Host "Enter the route partition name")
	$ConfigFile.Settings.CUCM.ONCALL.fw_css  = [string](Read-Host "Enter calling search space name")
	# END CUCM

	# SHAREPOINT
	$ConfigFile.Settings.SHAREPOINT.schedule = [string](Read-Host "Enter or paste URL to schedule xlsx")
	$ConfigFile.Settings.SHAREPOINT.cache    = "$($env:userprofile)\AppData\Local\Temp\oncall_latest.xlsx"
	# CREDENTIAL
	if ($SPCredential = $host.ui.PromptForCredential('SharePoint Credentials Required', 'Please enter credentials for SharePoint.', '', "")){} else {
		Write-Warning "Need SharePoint credentials in order to proceed.`r`nPlease re-run script and enter the appropriate credentials."
		break
	}
	$SPCredential | Export-CliXml -Path "$cucm_path\sp.cred"
	$ConfigFile.Settings.SHAREPOINT.auth     = "$cucm_path\sp.cred"
	# END CREDENTIAL
	# END SHAREPOINT

	# NOTIFICATIONS
	$ConfigFile.Settings.NOTIFY.SMTPServer 	 = [string](Read-Host "Enter SMTP server (e.g. exch01.domain.com)")
	$ConfigFile.Settings.NOTIFY.SMTPPort     = [string](Read-Host "Enter SMTP Port")

	# SMTP CREDENTIAL
	$authenticate = Read-Host "Does SMTP server require authentication? [Y/N]"
	switch ($authenticate) {
		Y {
			$ConfigFile.Settings.NOTIFY.authenticate = 'TRUE'
			if ($SMTPCredential = $host.ui.PromptForCredential('SMTP Server Credentials Required', 'Please enter credentials for SMTP Server.', '', "")){} else {
				Write-Warning "Need SMTP credentials in order to proceed.`r`nPlease re-run script or command and enter the appropriate credentials."
				break
			}
			$SMTPCredential | Export-CliXml -Path "$cucm_path\smtp.cred"
			$ConfigFile.Settings.NOTIFY.auth  = "$cucm_path\smtp.cred"
		}
		N {$ConfigFile.Settings.NOTIFY.authenticate = 'FALSE'; $ConfigFile.Settings.NOTIFY.auth = ''}
		Default {$ConfigFile.Settings.NOTIFY.authenticate = 'FALSE'; $ConfigFile.Settings.NOTIFY.auth = ''}
	}
	# END SMTP CREDENTIAL

	$ConfigFile.Settings.NOTIFY.fromName    = [string](Read-Host "Enter from name for notifications")
	$ConfigFile.Settings.NOTIFY.fromAddress = [string](Read-Host "Enter from email for notifications")
	$ConfigFile.Settings.NOTIFY.subject     = [string](Read-Host "Enter desired subject line")
	# END NOTIFICATIONS

	$ConfigFile.Save("$cucm_path\Settings.xml") | Out-Null

	return $ConfigFile
}
