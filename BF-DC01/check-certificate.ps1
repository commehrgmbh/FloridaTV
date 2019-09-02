#==========================================================
# LANG : Powershell
# NAME : nm-check-certificate-expiration.ps1
# AUTHOR : Patrick Ogenstad
# VERSION : 1.0
# DATE : 2014-02-09
# Description : Checks to see a certificate is about to
# expire.
#
# Information: The Script is part of Nelmon (NetworkLore
# Monitoring Pack for Nagios)
# http://networklore.com/nelmon/
#
# Guidelines and updates:
# http://networklore.com/windows-certificate-expiration/
#
# Feedback: Please send feedback:
# http://networklore.com/contact/
#
# Update 2019-04-23 Nora Troll
#
#==========================================================
#==========================================================

Param(
 [int]$critical = 20,
 [switch]$help,
 [int]$warning = 30
)

$scriptversion = "1.0"

$CERTDIR = "Cert:\LocalMachine\My"

$bReturnOK = $TRUE
$bReturnCritical = $FALSE
$bReturnWarning = $FALSE
$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3
$nWarning = $warning
$nCritical = $critical
$exclu = "-CA"

$dtCurrent = Get-Date

$strCritical = " "
$strWarning = " "
$strOk = "Keine Auffaelligkeiten"

if ($help)
{
 Write-Output ""
 Write-Output "---------------------------------------------"
 Write-Output "nm-check-certificate-expiration.ps1 v.$scriptversion"
 Write-Output "---------------------------------------------"
 Write-Output ""
 Write-Output "Options:"
 Write-Output "-c or -critical (number)"
 Write-Output "-h or -help display help"
 Write-Output "-w or -warning (number)"
 Write-Output "" 
 Write-Output "Example:"
 Write-Output ".\nm-check-certificate-expiration.ps1 -c 4 -w 10"
 Write-Output ""
 Write-Output "For more information visit:"
 Write-Output "http://networklore.com/nelmon/"
 Write-Output "http://networklore.com/windows-certificate-expiration/"
 Write-Output ""
 exit $returnStateUnknown
}

$objCertificates = Get-Childitem $CERTDIR

if (-Not $objCertificates)
{ 
 Write-Output $strOk
 exit $returnStateOK
}

foreach ($objCertificate in $objCertificates)
{
	$dtRemain =  $objCertificate.NotAfter - $dtCurrent
	$nRemainDays = $dtRemain.Days
	
	if ($objCertificate.SubjectName.Name.ToString() -match $exclu)
	{
		$strOk = $strOk + " - Ein -CA-Zertifikat gefunden - nicht zu beachten"
	}Else{
		if ($nRemainDays -lt 0){
			$strCritical = $strCritical + "EXPIRED " + $objCertificate.SubjectName.Name.ToString() + " expired " + $objCertificate.NotAfter.ToString() + "`n"
			$bReturnCritical = $TRUE
		}Elseif ( $nRemainDays -lt $nCritical){
		  $strCritical = $strCritical +  "Critical " + $objCertificate.SubjectName.Name.ToString() + " expires " + $objCertificate.NotAfter.ToString() + "`n"
		  $bReturnCritical = $TRUE
		}Elseif ( $nRemainDays -lt $nWarning) {
			$strWarning = $strWarning + "Warning " + $objCertificate.SubjectName.Name.ToString() + " expires " + $objCertificate.NotAfter.ToString() + "`n"
			$bReturnWarning = $TRUE
		}Else{
			#nothing - Certificates which match here are OK
		}
	}
}

if ($bReturnCritical)
{
 write-output $strCritical
 write-output $strWarning
 exit $returnStateCritical
} elseif ($bReturnWarning)
{
 write-output $strWarning
 exit $returnStateWarning
} else
{ 
 write-output $strOk
 exit $returnStateOK
}
