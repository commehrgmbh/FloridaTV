#################################################################################################################
###
### Gibt fürs Monitoring aktuelle Infos zu Windows Schattenkopie zurueck
### (keine Unterscheidung fuer Warn-/Krit-Status - liefert immer "OK")
###
###	Nora Troll / 14.05.2018
#################################################################################################################

$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3

$daten = @(Get-WmiObject -Class Win32_ShadowStorage |
  Select-Object PSComputername, @{n='Drive';e={([wmi]$_.Volume).DriveLetter}},
                AllocatedSpace, UsedSpace,
                @{n='NextRunTime';e={
                  $volume = ([wmi]$_.Volume).DeviceId -replace '[\\?]'
                  (Get-ScheduledTaskInfo "ShadowCopy$volume").NextRunTime
                }}
)

$Rechner = (Get-WmiObject -Class Win32_ComputerSystem -Property Name).Name
$PsVersion = $PSVersionTable.PSVersion
$BsName = (Get-WmiObject Win32_OperatingSystem).Caption
$BsNummerMajor = [System.Environment]::OSVersion.Version.major
$BsNummerMinor = [System.Environment]::OSVersion.Version.Minor
$BsNummerBuild = [System.Environment]::OSVersion.Version.build
$BsNummerRevision = [System.Environment]::OSVersion.Version.Revision
[string]$BsNummer = "$BsNummerMajor (Major); $BsNummerMinor (Minor); $BsNummerBuild (Build); Rev$BsNummerRevision"
$Bit = (Get-WmiObject Win32_OperatingSystem).OSArchitecture

$aktiviertauf = " "
$nichtaktiviertauf = " "

foreach($datensatz in $daten){
	if (!$daten[0]){
		
		$aktiv_pro_laufwerk = "keine Schattenkopie aktiviert auf " + $Rechner
		
		if($nichtaktiviertauf -eq " "){
			$nichtaktiviertauf = $datensatz.Drive
		}else{
			$nichtaktiviertauf = $nichtaktiviertauf + ", " + $datensatz.Drive
		}
		$schattenkopie_aktiv = 0
	}else{
	
		$zugewiesen = $datensatz.AllocatedSpace
		$zugewiesen1 = [math]::round($zugewiesen / 1GB, 3)
		$Zugew = "zugewiesen: " + $zugewiesen1 + "GB"

		if($zugewiesen -eq 0){
			$aktiv_pro_laufwerk = "keine Schattenkopie aktiviert auf " + $datensatz.Drive
			if($nichtaktiviertauf -eq " "){$nichtaktiviertauf = $datensatz.Drive}else{$nichtaktiviertauf = $nichtaktiviertauf + ", " + $datensatz.Drive}
		}else{
			$aktiv_pro_laufwerk = "Schattenkopie aktiviert auf " + $datensatz.Drive
			$Laufwerk = "Laufwerk: " + $datensatz.Drive

			<#
			$genutzt = $datensatz.UsedSpace
			$genutzt1 = [math]::round($zugewiesen / 1GB, 3)
			$Genu = "genutzt: " + $genutzt1 + "GB"
			#>
		
			$naechste = "naechste Laufzeit:" + '{0:dd.MM.yyyy HH:mm}' -f ($datensatz.NextRunTime)

			### BERECHNE LAUFWERKSGROESSE UND FREIEN PLATZ DES AKTUELLEN LAUFWERKS
			$filter = $datensatz.Drive
			Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DeviceID -eq $filter} | Foreach-Object {$size=$_.Size;$free=$_.FreeSpace}
			$size1 = [math]::round($size / 1GB, 3)
			$free1 = [math]::round($free / 1GB, 3)

			if($aktiviertauf -eq " "){$aktiviertauf = $datensatz.Drive}else{$aktiviertauf = $aktiviertauf + ", " + $datensatz.Drive}
			$schattenkopie_aktiv = 1

			}

	}
	$TextProLaufwerk = "`r`n" + $aktiv_pro_laufwerk
	if($schattenkopie_aktiv -eq 1){$TextProLaufwerk = $TextProLaufwerk + "`r`n" + $Zugew + "`r`n" + $naechste}
	$TextimForeach = $TextimForeach + "`r`n" + $TextProLaufwerk
}

if($aktiviertauf -eq " "){$aktiviertauf = "keine"}
if($nichtaktiviertauf -eq " "){$nichtaktiviertauf = "keine"}

$Rechnerdaten = "auf: " + $Rechner + "; OS: " + $BsNummer + " / " + $Bit
$TextGesamtInfoUnten = "Pruefung durchgefuehrt: " + '{0:dd.MM.yyyy HH:mm}' -f (Get-Date) + " von " + $Env:USERNAME + "`r`n" + "Powershell-Version: " + $PsVersion + "`r`n" + $Rechnerdaten + "`r`n" + $BsName
#$TextGesamt = "Rechner: " + $Rechner + $TextimForeach + "`r`n" + "`r`n" + $TextGesamtInfoUnten
$TextGesamt = "aktiv auf: " + $aktiviertauf + "  =///=  nicht aktiv auf: " + $nichtaktiviertauf + $TextimForeach + "`r`n" + "`r`n" + $TextGesamtInfoUnten

$Rueckgabewert = $returnStateOK
write-output $TextGesamt

exit $Rueckgabewert