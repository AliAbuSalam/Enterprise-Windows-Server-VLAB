$configFilePath = Join-Path -Path $PSScriptRoot -ChildPath "server-installation-config.json"
$configFile = Get-Content $configFilePath | ConvertFrom-Json

$addsInstallState = Get-WindowsFeature -Name "AD-Domain-Services"

if($addsInstallState.InstallState -eq "removed"){
  Write-Error -Message "Active Directory Domain Services Feature is removed from this device"
  Pause
  Return
}

if($addsInstallState.InstallState -eq "available"){
  Write-Host -Message "ADDS is available to install"
}