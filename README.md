# CUCMPosh Module and Scripts

A PowerShell module and scripts to facilitate AXL SOAP requests to Cisco Unified Communications Manager.

## About
Automate all the things. This PowerShell module is for interfacing with CUCM and was initially developed for automating an on-call schedule and then built from there. Our department has a DID assigned for on-call which rotates weekly whose cell it forwards to.

## Getting Started

To get started with this module, you need to download a copy of the [latest release](https://github.com/joshuanasiatka/CUCMPosh/releases/latest) and unzip the contents to a working directory, e.g. `C:\Dev\CUCM\`. The repository contains scripts and the module. To use the module without specifying path, copy the `CUCMPosh` subdirectory to your PowerShell Modules folder:    
- User Only: `C:\Users\YourUserName\My Documents\WindowsPowerShell\Modules`  
- Global: `C:\Windows\System32\WindowsPowerShell\v1.0\Modules`

### Prerequisites

A few of the scripts rely on third party PowerShell modules, you may need the following added to one of the Module directories (dependent on the scope you're running at).  
- ActiveDirectory (Included with RSAT, [Windows 7](https://www.microsoft.com/en-us/download/details.aspx?id=7887) or [Windows 10](https://www.microsoft.com/en-us/download/details.aspx?id=45520))
- PSExcel ([Github](https://github.com/RamblingCookieMonster/PSExcel/) or [PowerShell Gallery](https://www.powershellgallery.com/packages/PSExcel/))

## Usage

After installing into the modules directory, to use the included functions just `Import-Module CUCMPosh` from a PowerShell instance. To use any of the scripts, copy the folder to a directory that makes sense or extract only what you need. Make sure to modify the settings to fit your environment - script variables should be at the top of every script unless specified.

### Scripts
- [Automated On-Call Scheduler](Scripts/automated-oncall) - Uses `Set-LineForward` function against a schedule hosted on SharePoint to automatically update a specified line at a set interval.

### Sample Commands

#### Basic Queries

Get basic/common phone information by name.

```powershell
PS \> Get-Phone -Name SEP00EBD6543210 -Basic
```

```plain
name                   : SEP00EBD6543210
description            : 4321 James Smith
model                  : Cisco 8851
class                  : Phone
protocol               : SIP
ownerUserName          : jsmith
mobilityUserIdName     :
lines                  : {line, line, line}
speedDials             : {speeddial, speeddial, speeddial, speeddial...}
cssName                : National_css
locationName           : MainOffice_loc
devicePool             : MainOffice_dp
commonDeviceConfigName : StndKeysNoMOH_cp
commonPhoneConfigName  : Standard Common Phone Profile
phoneTemplateName      : SEP00EBD6543210-SIP-Individual Template
userLocale             : English United States
networkLocale          : United States
softkeyTemplateName    : Standard
dndStatus              : false
uuid                   : {03231B3F-9B7E-C31A-ECF1-A1B2C3D4E5F6}
loadInformation        : sip88xx.12-1-1SR1-4
```

Check if DN exists by Pattern or Description.

```powershell
PS \> Get-DN -DN 4321
```

```plain
uuid                                 : {F4D81158-B1AC-C5C4-FF4B-A1B2C3D4E5F6}
pattern                              : 4321
description                          : Script Test
usage                                : Device
routePartitionName                   : routePartitionName
aarNeighborhoodName                  :
aarDestinationMask                   :
aarKeepCallHistory                   : true
aarVoiceMailEnabled                  : false
callPickupGroupName                  :
autoAnswer                           : Auto Answer Off
networkHoldMohAudioSourceId          :
userHoldMohAudioSourceId             :
alertingName                         : CUCM Script Test
asciiAlertingName                    : CUCM Script Test
presenceGroupName                    : presenceGroupName
shareLineAppearanceCssName           :
voiceMailProfileName                 : voiceMailProfileName
patternPrecedence                    : Default
releaseClause                        : No Error
hrDuration                           :
hrInterval                           :
cfaCssPolicy                         : Use System Default
defaultActivatedDeviceName           :
parkMonForwardNoRetrieveDn           :
parkMonForwardNoRetrieveIntDn        :
parkMonForwardNoRetrieveVmEnabled    : false
parkMonForwardNoRetrieveIntVmEnabled : false
parkMonForwardNoRetrieveCssName      :
parkMonForwardNoRetrieveIntCssName   :
parkMonReversionTimer                :
partyEntranceTone                    : Default
```

Get line association by DN/Pattern, Description, and/or Route Partition

```powershell
PS \> Get-Line -DNorPattern 4321 -RoutePartition 0_Internal_pt
```

```plain
name            description          dn   partition
----            -----------          --   ---------
SEP00EBD6543210 4321 James Smith     4321 0_Internal_pt
```

##### Setting Information

Forward all calls for DN to Voicemail.

```powershell
PS \> Add-LineForward -Pattern 1234 -RoutePartition 0_Internal_pt -Voicemail
```

Stop forwarding all calls for DN to Voicemail.

```powershell
PS \> Remove-LineForward -Pattern 1234 -RoutePartition 0_Internal_pt -Voicemail
```

Forward all calls for DN to cell phone.

```powershell
PS \> Add-LineForward -Pattern 1234 -RoutePartition 0_Internal_pt -Destination 815085551234 -DestinationCSS National_css
```

Remove all ForwardAll settings for DN.

```powershell
PS \> Remove-LineForward -Pattern 1234 -RoutePartition 0_Internal_pt
```

#### Advanced Queries

Get the phone information for each line returned from a `Get-Line` by DN/Pattern, Description, and/or Route Partition result.

```powershell
PS \> Get-Line -DNorPattern 4321 | %{ Get-Phone -Name $_.name -Basic }
```

```plain
name                   : SEP00EBD6543210
description            : 4321 James Smith
model                  : Cisco 8851
class                  : Phone
protocol               : SIP
ownerUserName          : jsmith
mobilityUserIdName     :
lines                  : {line, line, line}
speedDials             : {speeddial, speeddial, speeddial, speeddial...}
cssName                : National_css
locationName           : MainOffice_loc
devicePool             : MainOffice_dp
commonDeviceConfigName : StndKeysNoMOH_cp
commonPhoneConfigName  : Standard Common Phone Profile
phoneTemplateName      : SEP00EBD6543210-SIP-Individual Template
userLocale             : English United States
networkLocale          : United States
softkeyTemplateName    : Standard
dndStatus              : false
uuid                   : {03231B3F-9B7E-C31A-ECF1-A1B2C3D4E5F6}
loadInformation        : sip88xx.12-1-1SR1-4
```

Get configured speed dials for a phone.

```powershell
PS \> $ph = Get-Line -DNorPattern 4321 | %{ Get-Phone -Name $_.name -Basic }
PS \> $ph.speedDials
```
```plain
dirn                      label                     index
----                      -----                     -----
818665551234              ABC Company, Inc.         1
818009995555              XYZ Communications, LLC.  2
818668884321,,1,5555#,#   Weekly MSP Check-in       3
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## To-Do List
- Better handling of returns from POSTs
- Read Queries and respective Sets
    - Get-User
    - Get-HuntPilot
    - Get-HuntList
    - Get-LineGroup
    - Get-RoutePlanReport
- System Requests
    - Sync-LDAP

## Change Log
Changes between releases are noted in the [release notes](https://github.com/joshuanasiatka/CUCMPosh/releases). For a complete list of changes, see the [CHANGELOG.md](CHANGELOG.md).

## Authors

* **Joshua Nasiatka** - [Github](https://github.com/JoshuaNasiatka) | [Home](https://www.joshuanasiatka.com/)

See also the list of [contributors](https://github.com/joshuanasiatka/CUCMPosh/contributors) who participated in this project.

## License

This project is licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0.html) - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to  [@Tervis-Tumbler](https://github.com/Tervis-Tumbler/CUCMPowerShell) for inspiration and helping me understand CUCM SOAP requests.
