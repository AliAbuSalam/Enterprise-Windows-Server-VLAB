$configFilePath = Join-Path -Path $PSScriptRoot -ChildPath "server-installation-config.json"
$configFile = Get-Content $configFilePath | ConvertFrom-Json

$addsInstallState = Get-WindowsFeature -Name "AD-Domain-Services"

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if($isAdmin -eq $false){
  throw "You need an admin privileges to run this script"
}

if($addsInstallState.InstallState -eq "removed"){
  Write-Error -Message "Active Directory Domain Services Feature is removed from this device"
  Pause
  Return
}

if($addsInstallState.InstallState -eq "available"){
  Write-Host -Message "ADDS is available to install"
}