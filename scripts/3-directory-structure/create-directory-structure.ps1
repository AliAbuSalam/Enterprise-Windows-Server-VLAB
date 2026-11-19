$configFilePath = Join-Path -Path $PSScriptRoot -ChildPath 'directory-structure-config.json'
$configFile = Get-Content $configFilePath | ConvertFrom-Json

$domain = ($configFile.domain.Split(".") | ForEach-Object {("DC=$($_)")}) -join ","

$OUTree = $configFile.organizationalUnits

# Scan the config file to list the OUs to add
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

$OUHashArray = @(
  $OUList | ForEach-Object -Process {
    $currentHash = @{}
    foreach($property in $_.PSObject.Properties){
      $currentHash[$property.name] = $property.value
    }
    $currentHash
  }
)

$OUHashArray | ForEach-Object -Process {
  $params = $_
  $existingOU = Get-ADOrganizationalUnit -Filter "Name -eq '$($params.Name)'" -SearchBase $params.Path -SearchScope OneLevel
  if($null -eq $existingOU){
    New-ADOrganizationalUnit @params
  } else {
    Write-Host "Creation of $($params.Name) OU is skipped. Already exist."
  }
} | Out-Host