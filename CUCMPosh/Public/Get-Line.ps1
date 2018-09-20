Function Get-Line {
	<#
	.SYNOPSIS
		Queries CUCM and returns lines

	.DESCRIPTION
		Queries CUCM and returns lines

	.PARAMETER DNorPattern
		Filter line results by DN or Pattern

	.PARAMETER Description
		Filter by description wildcard. Case sensitive.

	.EXAMPLE
		Get-Line -DNorPattern 1234

		# Returns all devices with x1234 line association

	.EXAMPLE
		Get-Line -Description Marketing

		# Returns all lines that match *Marketing* in phone description
	#>
	param(
		[Parameter(ValueFromPipelineByPropertyName)][String]$DNorPattern,
		[Parameter(ValueFromPipelineByPropertyName)][String]$Description
	)

	$ConfigFile = Get-SettingsFile

	$Query =
@"
	SELECT d.name,d.description,n.dnorpattern as DN,rp.name as partition
	FROM device as d
	INNER JOIN devicenumplanmap as dmap on dmap.fkdevice=d.pkid
	INNER JOIN numplan as n on dmap.fknumplan=n.pkid
	INNER JOIN routepartition as rp on n.fkroutepartition=rp.pkid
	WHERE d.tkclass=1 $(if($DNorPattern){"AND n.dnorpattern = '$DNorPattern'"}) $(if($Description){"AND d.description LIKE '%$Description%'"})
	ORDER BY d.name
"@

	return Invoke-CUCMSQLQuery -Query $Query
}
