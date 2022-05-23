# Skript zum Anzeigen der in VeeamBackupJobs befindlichen Cluster-VMs
# Stannek GmbH - v.1.1 - 23.05.2022 - E.Sauerbier

# Parameter
$FileOutputName = "Cluster-VMs in Backupjobs.csv"

# Nur für Veeam 10 und älter
#Add-PSSnapin VeeamPSSnapin

# Powershell Modul importieren
Import-Module Veeam.Backup.PowerShell

# Skriptpfad auslesen und Ausgabedatei erzeugen
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$FileOutput = $PSScriptRoot + "\" + $FileOutputName

# Alle aktiven Backupjobs auslesen
$Jobnames = Get-VBRJob | Where-Object {($_.JobType -eq "Backup") -and ($_.IsScheduleEnabled -eq "True")} | Select-Object Name 
# Namen der in dem Jobs befindlichen VMs auslesen
$Jobobjects = foreach ($Jobname in $Jobnames) {Get-VBRJobObject -Job $Jobname.Name | Select Name}

# Ergebnis in CSV ausgeben
$JobObjects | Export-Csv -path $FileOutput

# Bildschirmausgabe leeren
Clear-Host

# Ergebnis in der Shell ausgeben
Write-Host "Folgende Hyper-V Cluster Maschinen ("$JobObjects.Count "Stück) sind aktuell in aktiven Backup-Jobs."
Write-Host ($Jobobjects | Out-String)
Read-Host "Zum beenden beliebige Taste drücken"