# Automated On-Call

Do you have an on-call rotation that you have to manually update periodically? Do you have SharePoint? You can keep the schedule in a shared Excel spreadsheet hosted on SharePoint and use PowerShell to read that schedule and update the line forward in Call Manager automatically.

This script compares today's date with that listed in a spreadsheet-based schedule stored on SharePoint. If the dates match it continues the script and updates the line forward in CUCM.

*NOTE: Currently only supports lines and not hunt pilots, feel free to create a PR to implement that feature.*

## Recommended Usage
### SharePoint Setup
If you don't have a file library in SharePoint where you want the schedule to be stored, create that first. Create an Excel Workbook that contains two columns, date and name, in the format `dd-MMM-yy` and `Lastname, Firstname` and save it.

### Script Setup
Determine a Windows server you want to use, normally a utility server of some kind.

1. Create the directory `C:\AdminTools\CUCM\Oncall` and copy `Set-Oncall.ps1` and `user_list.csv` into that directory.
2. Edit `user_list.csv` and fill out the contact list with the appropriate details for the people in the on-call rotation. Then Save.
    - COL A: Lastname, Firstname
    - COL B: Cell phone or whichever will be forwarded to in the format required for outbound dialing from CUCM
    - COL C: User's email
3. Add/Copy `PSExcel` and `CUCMPosh` to the global `WindowsPowerShell` modules directory, assuming running via `NT Authority\SYSTEM` user.
4. Open a new PowerShell instance on the server and run the following:

```ps1
Import-Module CUCMPosh
Get-SettingsFile # this will return an xml object if you already have a config or run through the setup if it doesn't find one.
Add-OncallConfig # this will run through setup on configuring settings required for script.
Copy-SettingsToSystem # this will copy new/updated config to SYSTEM profile
```

5. Open `Task Scheduler` or another task manager such as [VisualCron](https://www.visualcron.com/) and create a new job at an interval that makes sense to run the script, e.g. daily.
6. Test the job and make sure everything looks right.
