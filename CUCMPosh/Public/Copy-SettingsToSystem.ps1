Function Copy-SettingsToSystem {
  <#
  .SYNOPSIS
    Copies Settings.xml file from RunAs user's AppData to the NT AUTHORITY\System account's AppData

  .DESCRIPTION
    Copies Settings.xml file from RunAs user's AppData to the NT AUTHORITY\System account's AppData. Use if running scripts as BUILTIN\SYSTEM account.
  #>

  $cucm_path = $MyInvocation.MyCommand.Module.PrivateData['cucm_path']

	if (!(Test-Path -Path "$cucm_path\Settings.xml")) {
		Write-Warning "Unable to copy 'Settings.xml', file does not exist. Please run 'Get-SettingsFile' to generate config."
		break
	}

	$sys_path = "C:\Windows\System32\Config\systemprofile\AppData\Local\AdminTools\CUCM"
	if (-Not (Test-Path -Path $sys_path)) { New-Item -Path $sys_path -ItemType Directory | Out-Null }
	Copy-Item "$cucm_path\Settings.xml" "$sys_path\Settings.xml"
	return "File(s) copied."
}
