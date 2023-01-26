# Skript zum Vergleich der Cluster-VMs und der in VeeamBackupJobs befindlichen Cluster-VMs
# Stannek GmbH - v.1.3 - 26.01.2023 - E.Sauerbier

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

# Namen der in dem Jobs befindlichen VMs auslesen und sortieren
$Jobobjects = foreach ($Jobname in $Jobnames) {Get-VBRJobObject -Job $Jobname.Name | Select Name}
$Jobobjects = $Jobobjects | Sort-Object Name

# Cluster auslesen
$Cluster = Get-Cluster -Domain $env:UserDomain

# Alle ClusterVMs auslesen
$ClusterVM = Get-ClusterResource -Cluster $Cluster | Where ResourceType -eq "Virtual Machine" | Select OwnerGroup

# Name der Cluster VMs auslesen
$NameClusterVM = $ClusterVM | ForEach-Object {$_.OwnerGroup}

# Vergleich der VMNamen, Referenzobjekt sind die Hyper-V VMs
$Compare = Compare-Object -ReferenceObject $NameClusterVM -DifferenceObject $Jobobjects

# Ausgabe generieren
$NoBackup = $Compare | Where-Object SideIndicator -eq "<=" | Select-Object -ExpandProperty InputObject 
$MultiBackup = $Compare | Where-Object SideIndicator -eq "=>" | Select-Object -ExpandProperty InputObject 

# Ausgabetext generieren
If ($Compare.Count -eq "0") {$OutputText = "Das Hyper-V Cluster hat "+ $NameClusterVM.Count +" VMs und davon werden "+ $Jobobjects.Count +" Cluster-VMs gesichert"}
Else {
    If ($Null -ne $NoBackup) {$OutputText = "Folgende VMs werden nicht gesichert: $NoBackup"}
    Else {$OutputText = "Folgende VMs werden mehrfach gesichert: $MultiBackup"}
    }


# Bildschirm ausgabe leeren
Clear-Host

# Ergebnis in der Shell ausgeben
Write-Host ($OutputText | Out-String)

# Ergebnis in eine Datei schreiben
$OutputText > $FileOutput

# Ergebnis in der Shell ausgeben
Write-Host "Die Ausgaben wurde in folgende Datei geschrieben $FileOutput `n"

# Aufforderung zum beenden des Skripts
Read-Host "Zum beenden beliebige Taste drücken"