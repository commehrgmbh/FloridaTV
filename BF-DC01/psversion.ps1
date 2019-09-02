###########################################
<#
Authors: Nora Troll
Title: Ps-Version-Check (called by DalterParams.ps1)
Version: 2018-11-23
Description / purpose:
- returns Warning if current PS-Version is lower than $Ps_Version_Ok (specify the ok-Version in $Ps_Version_Ok)
- run from ini-file or command prompt:
powershell.exe -ExecutionPolicy Bypass -command "c:\check_mk\Bonnyprints\scripts\psversion.ps1 -Ps_Version_Ok '5.0'
#>
###########################################

param( [System.Version] $Ps_Version_Ok)

$returnStateOK = 0
$returnStateWarning = 1
$returnStateUnknown = 3

$Rueckgabewert = $returnStateUnknown
$Rueckgabetext = "Unbekannter Fehler! + '`r`n' + Powershell-Versionspruefung wurde gestartet, wurde aber nicht korrekt ausgefuehrt"

if(!$Ps_Version_Ok){$Ps_Version_Ok = "4.0"}
[System.Version]$Ps_Version = $PSVersionTable.PSVersion

if($Ps_Version -lt $Ps_Version_Ok ){
	$Rueckgabetext = "Powershell-Version $Ps_Version ist kleiner als erfordert (Version $Ps_Version_Ok)"
	$Rueckgabewert = $returnStateWarning
}else{
	$Rueckgabetext =  "Powershell-Version $Ps_Version ist ok (ok ab Version $Ps_Version_Ok)"
	$Rueckgabewert = $returnStateOK
}

write-output $Rueckgabetext
set-executionpolicy restricted -Scope Process
exit $Rueckgabewert