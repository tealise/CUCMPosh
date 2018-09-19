Function Set-OncallSettings {
  <#
  .SYNOPSIS
    Update the settings file with on-call properties

  .DESCRIPTION
    Update the settings file with on-call properties. Runs through a Q&A to generate the file.
  #>
	[xml]$ConfigFile = Get-SettingsFile
  $cucm_path = $MyInvocation.MyCommand.Module.PrivateData['cucm_path']

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
