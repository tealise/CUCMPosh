# CUCMPosh Module and Scripts

A PowerShell module and scripts to facilitate AXL SOAP requests to Cisco Unified Communications Manager.

## About
Automate all the things. This PowerShell module is for interfacing with CUCM and was initially developed for automating an on-call schedule and then built from there. Our department has a DID assigned for on-call which rotates weekly whose cell it forwards to.

## Getting Started

To get started with this module, you need to download a copy of the [latest source](https://github.com/joshuanasiatka/CUCMPosh/archive/master.zip) and unzip the contents to a working directory, e.g. `C:\Dev\CUCM\`. The repository contains scripts and the module. To use the module without specifying path, copy the `CUCMPosh` subdirectory to your PowerShell Modules folder:    
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

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## To-Do List
- Better handling of returns from POSTs
- Read Queries
    - Get-Line
    - Get-Phone
    - Get-User
    - Get-HuntPilot
    - Get-HuntList
    - Get-LineGroup
    - Get-RoutePlanReport
- System Requests
    - Sync-LDAP

## Authors

* **Joshua Nasiatka** - [Github](https://github.com/JoshuaNasiatka) | [Home](https://www.joshuanasiatka.com/)

See also the list of [contributors](https://github.com/joshuanasiatka/CUCMPosh/contributors) who participated in this project.

## License

This project is licensed under the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0.html) - see the [LICENSE](LICENSE) file for details

## Acknowledgments

* Thanks to  [@Tervis-Tumbler](https://github.com/Tervis-Tumbler/CUCMPowerShell) for inspiration and helping me understand CUCM SOAP requests.
