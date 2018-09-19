Function Get-SettingsFile {
  <#
  .SYNOPSIS
    Generates config file if not exist

  .DESCRIPTION
    Runs through Q&A to create config file and store in AppData

  .PARAMETER Force
    Switch True/False

    # Toggles check if file exists, if used, ignores existing and creates new.

  .EXAMPLE
    Get-SettingsFile

    # Returns settings from XML file if exists, else creates new then returns

  .EXAMPLE
    Get-SettingsFile -Force

    # Creates new settings XML file
  #>
	param(
		[switch]$Force
  )

  $cucm_path = $MyInvocation.MyCommand.Module.PrivateData['cucm_path']
  $mod_path  = $MyInvocation.MyCommand.Module.ModuleBase

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
			# $mod_path = Split-Path (Get-Module CUCMPosh).Path
			[xml]$ConfigFile = (Get-Content "$mod_path\bin\SettingsTemplate.xml")
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
