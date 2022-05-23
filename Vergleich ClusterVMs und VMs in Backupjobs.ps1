# Skript zum Vergleich der Cluster-VMs und der in VeeamBackupJobs befindlichen Cluster-VMs
# Stannek GmbH - v.1.2 - 23.05.2022 - E.Sauerbier

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

# Vergleich der VMNamen, Referenzobjekt sind die Hyper-V VMs
$output = Compare-Object -ReferenceObject $NameClusterVM -DifferenceObject $Jobobjects -Property Name

# Bildschirm ausgabe leeren
Clear-Host

# Ergebnis in der Shell ausgeben
Write-Host "Referenzobjekt sind Hyper-V VMs"
Write-Host ($output | Out-String)

# Ergebnis in eine Datei schreiben
"Referenzobjekt sind Hyper-V VMs:" > $FileOutput
$output.Name >> $FileOutput

# Ergebnis in der Shell ausgeben
Write-Host "Die Ausgaben wurde in folgende Datei geschrieben $FileOutput `n"

# Aufforderung zum beenden des Skripts
Read-Host "Zum beenden beliebige Taste drücken"