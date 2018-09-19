# #############################################################################
# Cisco UCM - MODULE
# NAME: CiscoUCM.psm1
# #############################################################################

$cucm_path = "$($env:userprofile)\AppData\Local\AdminTools\CUCM"
if (-Not (Test-Path -Path $cucm_path)) { New-Item -Path $cucm_path -ItemType Directory }

#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    } Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Read in or create an initial config file and variable
# $ConfigFile = Get-SettingsFile

# Export public functions
Export-ModuleMember -Function $Public.Basename
