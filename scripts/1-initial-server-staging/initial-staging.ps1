$ErrorActionPreference = 'Stop'

#Checks whether the script is run with Admin Privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if( -not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
  throw "The script needs to be run with Admin Privileges. The script will exit now."
}

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
New-NetIPAddress -InterfaceAlias "Ethernet" `
  -IPAddress $configFile.IPAddress `
  -PrefixLength $configFile.prefixLength `
  -DefaultGateway $configFile.defaultGateway

#Set new DNSServer for the device
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "127.0.0.1"
Write-Host "The script has finished. The computer will restart to finalize change."
Pause
Restart-Computer

trap {
  Write-Host ""
  Write-Host "Error Occured" -ForegroundColor Red
  Write-Host "Error Message: $($_.Exception.Message)"
  Write-Host "Script Line: $($_.InvocationInfo.ScriptLineNumber)"
  Write-Host ""
  Read-Host "Press Enter to Exit:"
  exit 1
}