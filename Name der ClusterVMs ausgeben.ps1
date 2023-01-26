# Skript zum Ausgeben der vorhandenen Cluster VMs
# Stannek GmbH - v.1.2 - 25.01.2023 - E.Sauerbier

# Parameter
$FileOutputName = "Name Cluster-VMs.csv"

# Skriptpfad auslesen und Ausgabepfad erzeugen
$PSScriptRoot = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$FileOutput = $PSScriptRoot + "\" + $FileOutputName

# Cluster auslesen
$Cluster = Get-Cluster -Domain $env:UserDomain

# Alle Cluster VMs auslesen und in CSV exportieren
Get-ClusterResource -Cluster $Cluster | Where ResourceType -eq "Virtual Machine" | Select OwnerGroup | Export-Csv -path $FileOutput

# Alle Cluster VMs auslesen und in Shell ausgeben
Get-ClusterResource -Cluster $ClusterName | Where ResourceType -eq "Virtual Machine" | Select OwnerGroup, Name

# Aufforderung zum beenden des Skripts
Read-Host "`nZum beenden beliebige Taste drücken"