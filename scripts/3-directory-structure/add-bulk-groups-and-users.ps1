param(
  [securestring]$DefaultPassword,
  [boolean]$UseDefaultPasswordFromConfig = $false,
  [boolean]$SkipDefaultPassword
)

$ConfigFilePath = Join-Path -Path $PSscriptRoot -ChildPath "add-bulk-groups-and-users-config.json"
$ConfigFile = Get-Content -Path $ConfigFilePath | ConvertFrom-Json

$GroupsObjectsArray = @(Import-Csv -Path $ConfigFile.groupsCSV)
$UsersObjectArray = @(Import-Csv -Path $ConfigFile.usersCSV)

$GroupsCount = $GroupsObjectArray.Count
$UsersCount = $UsersObjectArray.Count

function AssignDefaultPassword {
  param(
    [SecureString]$DefaultPass,
    [String]$PassFromConfig,
    [Int]$MinPassLength = 7
  )

  # Define the source of default password
  $DefaultPasswordFromConfigFileExist = $null -ne $PassFromConfig
  if($null -ne $DefaultPass -and $DefaultPass.Length -ge $MinimumLength){
    return $DefaultPass
  } elseif(
      $null -ne $PassFromConfig -and
      $PassFromConfig.length -ge $MinimumLength
    ) {
    return ConvertTo-SecureString -String $PassFromConfig -AsPlainText -Force
  } else {  
    if($DefaultPasswordFromConfigFileExist -and 
      $ConfigFile.DefaultPassword -lt $MinimumLength
    ){
      Write-Warning "Default Password is too short."
    } else {
      Write-Warning "Default Password for Users creation is not found."
    }
    $IsCredentialValid = $false
    While(-not $IsCredentialValid){
      $PassObj = PasswordPrompt
      $TempId1 = [PSCredential]::New('temp', $PassObj.PassInput)
      $TempId2 = [PSCredential]::New('temp2', $PassObj.PassCOnfirm)
      if($TempId1.GetNetworkCredential().Password -ceq $TempId2.GetNetworkCredential().Password){
        $IsCredentialValid = $true
        return $TempId1.GetNetworkCredential().Password
      } else {
        Write-Warning "The password you put in the first and second time is not the same. Please re-enter password."
      }
    }
  }
}
function CheckPasswordValidity {
  param(
    [Parameter(Mandatory)]
    [securestring]$Password,
    [int]$MinimumLength
  )
  if($null -eq $password){
    return $false
  }
  if($password.Length -lt $MinimumLength){
    return $false
  }
  return $true
}

function PasswordPrompt {
  $DefaultPassInput = Read-Host "Please enter default password: " -AsSecureString
  $IsPasswordValid = CheckPasswordValidity -Password $DefaultPassInput -MinimumLength $MinimumLength
  while(-not $IsPasswordValid){
    Write-Warning "Password cannot be empty and need a minimum length of $MinimumLength."
    $DefaultPassInput = Read-Host "Enter Password: " -AsSecureString
    if($null -ne $DefaultPassInput){
      $IsPasswordValid = CheckPasswordValidity -Password $DefaultPassInput -MinimumLength $MinimumLength
    }
  }
  $DefaultPassConfirmation = Read-Host "Confirm your password: " -AsSecureString
  return @{
    PassInput = $DefaultPassInput
    PassConfirm = $DefaultPassConfirmation
  }
}

if($UsersCount -gt 0){
  if($SkipDefaultPassword){
    Write-Warning "Default password is skipped. Make sure every users have password set up."
  } else {
    $PassFromConfig = $null
    if($UseDefaultPasswordFromConfig -and $ConfigFile.DefaultPassword -is [string]){
      $PassFromConfig = $ConfigFile.DefaultPassword
    }
    [int]$MinLength
    [int]::TryParse($ConfigFile.MinimumPasswordLength, [ref]$MinLength)
    $DefaultPass = AssignDefaultPassword -DefaultPass $DefaultPassword -PassFromConfig $PassFromConfig -MinPassLength $MinLength
  }
}

# Create Groups from $GroupsArray
$Summary = [PSCustomObject]@{
  Groups = {
    Created = 0
    Skipped = 0
    Failed = 0
  }
  Users = {
    Created = 0
    Skipped = 0
    Failed = 0
  }
}

function ConvertObjectsToHashTables {  # convert Array of objects to Array of Hashtables
  param(
    [PSObject[]]$ArrayOfObjects
  )
  return @(
    $ArrayOfObjects | ForEach-Object {
      $currentHash = @{}
      foreach($property in $_.PSObject.Properties){
        $currentHash[$property.name] = $property.value
      }
      $currentHash
    }
  )
}

if($GroupsCount -gt 0){
  $GroupsArray = ConvertObjectsToHashTables($GroupsObjectsArray)
  
  $GroupsArray | ForEach-Object {
    $params = $_
  
    # Returns an error if name or path parameter is empty.
    if([string]::IsNullOrWhiteSpace($params.Name) -or [string]::IsNullOrWhiteSpace($params.Path)){
      Write-Error "Name or Path cannot be empty!"
      $Summary.Groups.Failed++
      return
    }
  
    $existingGroup = Get-ADGroup -Filter "Name -eq '$($params.Name)'" -SearchBase $params.Path -SearchScope OneLevel
  
    # Skip the group creation if group with the same name and path already exist.
    if(-not [string]::IsNullOrWhiteSpace($existingGroup)){ 
      Write-Host "Skipped creation of Group $($params.Name). Already exist."
      $Summary.Groups.Skipped++
    } else {
      # Create the group
      try {
        New-ADGroup @params
      } catch {
        Write-Error "Creation of group with parameter below has failed. Reasons: $PSItem"
        $params | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor "Yellow" 
        $Summary.Groups.Failed++
        return
      }
      Write-Host "created!!!!"
      Write-Host "index: $index"
      $Summary.Groups.Created++
    }
  }
} else {
  Write-Host "No Groups or Groups CSV detected. Skipping Groups Creation"
}

if($UsersCount -gt 0){
  $UsersArray = ConvertObjectsToHashTables($UsersObjectArray)

  $UsersArray | ForEach-Object {
    $params = $_
    $params["Name"] = "$($_.GivenName) $($_.Surname)"
    $params["DisplayName"] = $params["Name"]
    $params["UserPrincipalName"] = "$($params.SAMAccountName)@$($ConfigFile.domain)"
  }
}

# Write-Host "The script finished running. Summary: "
# $Summary | Format-Table | Out-Host