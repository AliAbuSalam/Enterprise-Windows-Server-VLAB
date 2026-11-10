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
} elseif($addsInstallState.InstallState -eq "available") {
  Write-Host "Installing Windows Feature AD Domain Services..."
  Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
  Write-Host "Finished Installing AD-Domain-Services."
} else {
  Write-Host "AD Domain Services Feature is already installed on this device."
}

$computerInfo = Get-CimInstance -Classname Win32_ComputerSystem
if($computerInfo.DomainRole -ge 4){
  Write-Host "This device is already a domain controller."
  Read-Host "Press Enter to stop the script."
  return
} elseif ($computerInfo.DomainRole -lt 2){
  throw "The device needs to run Windows Server OS to act as Domain controller"
} elseif ($computerInfo.DomainRole -eq 3){
  throw "The Windows OS cannot be a member of another AD Domain Services"
}

Write-Host "Installing ADDS Forest..."
Install-ADDSForest -DomainName $configFile.domainName `
  -DomainNetBiosName $configFile.domainNetBIOSName `
  -ForestMode $configFile.forestMode `
  -DomainMode $configFile.domainMode `
  -NoRebootOnCompletion
Write-Host "Finished installing ADDS Forest."
Write-Host "The computer will restart now to apply changes made to the device."
Read-Host "Press Enter to Continue:"
Restart-Computer

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