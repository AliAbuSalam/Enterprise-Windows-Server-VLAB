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
  throw "Can't detect any ethernet connection. Make sure the device has ethernet connection."
}

#Checks whether the current hostname is the same as hostname in configFile
$currentHostName = $env:COMPUTERNAME
$needToRestart = $false
if($currentHostName -ne $configFile.Hostname){
  #renaming pc to $ConfigFile.Hostname
  $configFile.Hostname
  Rename-Computer $configFile.Hostname
  $needToRestart = $true
  Write-Host "Renamed Hostname to $($configFile.Hostname)."
} else {
  Write-Host "Skipped changing Hostname. No need to change."
}

#Checks current ip address, prefix length, and default gateway
$currentIPAddress = Get-NetIPAddress -InterfaceAlias "Ethernet" -AddressFamily IPv4 -ErrorAction SilentlyContinue
$currentDefaultGateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -InterfaceAlias "Ethernet" -ErrorAction SilentlyContinue

#Set new ip address and prefix length if needed
if($currentIPAddress.IPAddress -ne $configFile.IPAddress -or $currentIPAddress.PrefixLength -ne $configFile.prefixLength){
  Remove-NetIPAddress $currentIPAddress -ErrorAction SilentlyContinue
  New-NetIPAddress -InterfaceAlias "Ethernet" `
    -IPAddress $configFile.IPAddress `
    -PrefixLength $configFile.prefixLength `
  Write-Host "Changed IP Address to $($configFile.IPAddress)/$($configFile.prefixLength)."
} else {
  Write-Host "Skipped changing IP Address and prefix length. No need to change. "
}

#Set new default gateway if needed
if($currentDefaultGateway.NextHop -ne $configFile.defaultGateway){
  Remove-NetRoute $currentDefaultGateway -ErrorAction SilentlyContinue
  New-NetRoute -InterfaceAlias "Ethernet" -DestinationPrefix "0.0.0.0/0" -NextHop $configFile.defaultGateway
  Write-Host "Changed Default Gateway to $($configFile.defaultGateway)."
} else {
  Write-Host "Skipped changing Default Gateway. No need to change."
}

#Set new DNSServer for the device
Set-DNSClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "127.0.0.1"
if($needToRestart -eq $true){
  Read-Host "The script has finished. The computer will restart to finalize change. Press enter to continue."
  Restart-Computer
} else {
  Read-Host "The script has finished. Press Enter to continue."
}

trap {
  Write-Host ""
  Write-Host "Error Occured" -ForegroundColor Red
  Write-Host "Error Message: $($_.Exception.Message)" -ForegroundColor Yellow
  Write-Host "Command: $($_.InvocationInfo.MyCommand)" 
  Write-Host "Script Line: $($_.InvocationInfo.ScriptLineNumber)"
  Write-Host ""
  Read-Host "Press Enter to Exit:"
  exit 1
}