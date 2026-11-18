$configFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'directory-structure-config.json'
$configFile = Get-Content $configFilePath | ConvertFrom-Json

$domain = ($configFile.domain.Split(".") | ForEach-Object {("DC=$($_)")}) -join ","

$OUTree = $configFile.organizationalUnits

function Get-OUListRecursive {
  param (
    [string]$Name,
    [string]$PreviousPath,
    [object]$ChildTrees
  )
  if(-not [string]::IsNullOrEmpty($Name)){
    $CurrentPath = "OU=$($Name),$($PreviousPath)"
    $OUArray = @(
      [PSCustomObject]@{
        Name = $Name
        Path = $PreviousPath
      }
    )
  } else {
    $CurrentPath = $PreviousPath
    $OUArray = @()
  }
  if($null -ne $ChildTrees){
    $ChildTrees | 
    ForEach-Object -Process {
      $returnObject = Get-OUListRecursive -Name $_.name -PreviousPath $CurrentPath -ChildTrees $_.child
      $OUArray += $returnObject
    }
  }
  return $OUArray 
}
$OUList = @()
$OUList = Get-OUListRecursive -PreviousPath $domain -ChildTrees $OUTree
Write-Host "OUList result: "
$OUList | Format-Table -AutoSize | Out-Host