$configFilePath = Join-Path -Path $PSScriptRoot -ChildPath "initial-staging-config.json"
$configFile = Get-Content $configFilePath | ConvertFrom-Json

#Checks whether the device has ethernet connection
$ethernetInterfaces = Get-NetAdapter "Ethernet" -ErrorAction SilentlyContinue
if($null -eq $ethernetInterfaces) {
  Write-Error -Message "Can't detect any ethernet connection. Make sure the device has ethernet connection."
  Pause
  Return
}

#renaming pc to $ConfigFile.Hostname
$configFile.Hostname
Rename-Computer $configFile.Hostname

#Set new IPAddress, prefixLength, and default gateway for the device
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress $configFile.IPAddress -PrefixLength $configFile.prefixLength -DefaultGateway $configFile.defaultGateway

#Set new DNSServer for the device
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses $configFile.DNSServer
Pause
Write-Host "The script has finished. The computer will restart to finalize change."
Restart-Computer