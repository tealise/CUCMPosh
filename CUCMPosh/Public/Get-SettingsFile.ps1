Function Get-SettingsFile {
	<#
	.SYNOPSIS
		Generates config file if not exist

	.DESCRIPTION
		Runs through Q&A to create config file and store in AppData.
		If Settings.xml or .cred file is in the current working directory those will
		supercede when Get-SettingsFile is called.

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

	# If Settings.xml is in current directory, use that instead of AppData version
	if (-not (Get-ChildItem Settings.xml -ErrorAction SilentlyContinue)) {
		$cucm_path = $MyInvocation.MyCommand.Module.PrivateData['cucm_path']
	} else {
		$cucm_path = (Get-Location).Path
	}

	# Get absolute path to module
	$mod_path  = $MyInvocation.MyCommand.Module.ModuleBase

	# If Settings.xml doesn't exist, run through Q&A for setup
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

	# Import Settings XML File
	[xml]$ConfigFile = Get-Content "$cucm_path\Settings.xml"

	# If *.cred files are in current path, replace creds in $ConfigFile instance with those
	$whereAmI = (Get-Location).Path
	if (Test-Path -Path "$whereAmI\*.cred") {
		if (Test-Path -Path "$whereAmI\cucm.cred") {
			$ConfigFile.Settings.CUCM.auth = "$whereAmI\cucm.cred"
		}
		if (Test-Path -Path "$whereAmI\sp.cred") {
			$ConfigFile.Settings.SHAREPOINT.auth = "$whereAmI\sp.cred"
		}
	}

	return $ConfigFile
}
