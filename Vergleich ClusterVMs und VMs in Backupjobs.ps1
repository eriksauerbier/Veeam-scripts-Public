# Skript zum Vergleich der Cluster-VMs und der in VeeamBackupJobs befindlichen Cluster-VMs
# Stannek GmbH - v.1.1 - 23.05.2022 - E.Sauerbier

# Parameter
$FileOutputName = "Compare-Cluster-Veeam.txt"

# Nur für Veeam 10 und älter
#Add-PSSnapin VeeamPSSnapin

# Powershell Modul importieren
Import-Module Veeam.Backup.PowerShell

# Skriptpfad auslesen und Ausgabedatei erzeugen
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$FileOutput = $PSScriptRoot + "\" + $FileOutputName

# Alle aktiven Backupjobs auslesen
$Jobnames = Get-VBRJob | Where-Object {$_.JobType -eq "Backup" -and ($_.IsScheduleEnabled -eq "True")} | Select-Object Name 
# Namen der in dem Jobs befindlichen VMs auslesen
$Jobobjects = foreach ($Jobname in $Jobnames) {Get-VBRJobObject -Job $Jobname.Name | Select Name}

# Alle ClusterVMs auslesen
$ClusterVM = Get-ClusterResource -Cluster RZCLuster | Where ResourceType -eq "Virtual Machine" | Select OwnerGroup

# Name der Cluster VMs auslesen
$NameClusterVM = $ClusterVM | ForEach-Object {$_.OwnerGroup}

# Vergleich der VMNamen
$output = Compare-Object -ReferenceObject $NameClusterVM.Name -DifferenceObject $Jobobjects.Name 

# Ergebnis in der Shell ausgeben
Write-Host ($output | Out-String)

# Ergebnis in eine Datei schreiben
$output.InputObject > $FileOutput

# Aufforderung zum beenden des Skripts
Write-Host "Die Ausgaben wurde in folgende Datei geschrieben $FileOutput 'n"
Read-Host "Zum beenden beliebige Taste drücken"