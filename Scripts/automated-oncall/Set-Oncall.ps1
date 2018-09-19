###############################################################################
# Cisco UCM - On Call Changer
# NAME: Set-OnCall.ps1
###############################################################################

Import-Module PSExcel
Import-Module CUCMPosh

############################### CONFIG SETTINGS ###############################
<#
NOTE: Please modify the email body for notifications at the end of this script.
#>

# Import Config
[xml]$ConfigFile = Get-SettingsFile

# SET VARIABLES
$URI = $ConfigFile.Settings.CUCM.uri
$file = $ConfigFile.Settings.SHAREPOINT.schedule
$dfile = $ConfigFile.Settings.SHAREPOINT.cache
$sp_cred = Import-CliXml -Path $ConfigFile.Settings.SHAREPOINT.auth
$cucm_cred = Import-CliXml -Path $ConfigFile.Settings.CUCM.auth
###############################################################################

# DOWNLOAD FILE
Write-Host "Downloading latest version of On-Call Schedule..."
$WebClient = New-Object System.Net.WebClient
$WebClient.Credentials = $sp_cred
$WebClient.DownloadFile( $file, $dfile )

# IMPORT STAFF MEMBER CONTACT LIST CSV FILE
# CONVERT TO CSV FOR PARSING
# TODO: Pull user info csv from sharepoint, lock down perms to just IT
$OncallList = Import-XLSX -Path $dfile -Header "Start Date","Staff On Call"
$OncallList | % { $_."Start Date" = Get-Date ((Get-Date "12/31/1899").AddDays($_."Start Date" - 1)) -Format "dd-MMM-yy" }

# REMOVE OLD XLSX FILE
Remove-Item -Path $dfile

# GET DATES
$today = Get-Date -format dd-MMM-yy

# SEARCH ON-CALL FILE
Write-Host "Checking the dates..."
if (!($staffMember = ($OncallList | Where {$_."Start Date" -eq $today})."Staff On Call")) {
    Write-Warning "No match for today, not updating CUCM"
    exit
}
$staffContact = $OncallList | Where {$_.Name -eq $staffMember}

# Parse Contact Info
$staffName = $staffContact.Name
$staffName = "{1} {0}" -f $staffName.split(',')
$staffEmail = $staffContact.Email

Write-Host "On-Call Person of the Week is $($staffName) and will be reached at $($staffContact.Cell)"
Write-Host "Updating Call Forward for On-Call @ x$($ConfigFile.Settings.CUCM.ONCALL.ext)"

# GENERATE SOAP API REQUEST TO CUCM
$parms = @{
  'Pattern'        = $($ConfigFile.Settings.CUCM.ONCALL.ext)
  'routePartition' = $($ConfigFile.Settings.CUCM.ONCALL.pt)
  'destination'    = $($staffContact.Cell)
  'destinationCSS' = $($ConfigFile.Settings.CUCM.ONCALL.fw_css)
}

Add-LineForward @parms

Write-Host "Update Complete"

# SEND NOTIFICATION EMAIL TO STAFF MEMBER
Write-Host "Sending email to $staffName regarding on-call week"
$emailBody = @"
<font face='calibri'>
  <p>Hello $staffName,</p>
  <p>This week you are scheduled to be on-call. If you are unable to be on-call this week, please arrange for someone to cover for you.</p><p>You can be reached at $($ConfigFile.Settings.CUCM.ONCALL.fullnumber).</p>
  <p>Regards,<br>
    <strong><font color='orange'>AUTO</font></strong>Tasker
  </p>
</font>
"@
Send-MailMessage -To "$staffName <$staffEmail>" -From "$($ConfigFile.Settings.NOTIFY.fromName) <$($ConfigFile.Settings.NOTIFY.fromAddress)>" -Subject "$($ConfigFile.Settings.NOTIFY.subject)" -BodyAsHtml -Body "$emailBody" -SmtpServer $($ConfigFile.Settings.NOTIFY.SMTPServer) -Port $($ConfigFile.Settings.NOTIFY.SMTPPort)
