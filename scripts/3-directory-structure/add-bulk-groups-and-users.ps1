$GroupsObjectsArray = @(Import-Csv -Path "$PSscriptRoot\add-groups.csv")

# convert Array of objects to Array of Hashtables
$GroupsArray = @(
  $GroupsObjectsArray | ForEach-Object {
    $currentHash = @{}
    foreach($property in $_.PSObject.Properties){
      $currentHash[$property.name] = $property.value
    }
    $currentHash
  }
)

# Create Groups from $GroupsArray
$Summary = [PSCustomObject]@{
  Created = 0
  Skipped = 0
  Failed = 0
}
$GroupsArray | ForEach-Object {
  $params = $_

  # Returns an error if name or path parameter is empty.
  if([string]::IsNullOrWhiteSpace($params.Name) -or [string]::IsNullOrWhiteSpace($params.Path)){
    Write-Error "Name or Path cannot be empty!"
    $Summary.Failed++
    return
  }

  $existingGroup = Get-ADGroup -Filter "Name -eq '$($params.Name)'" -SearchBase $params.Path -SearchScope OneLevel

  # Skip the group creation if group with the same name and path already exist.
  if(-not [string]::IsNullOrWhiteSpace($existingGroup)){ 
    Write-Host "Skipped creation of Group $($params.Name). Already exist."
    $Summary.Skipped++
  } else {
    # Create the group
    try {
      New-ADGroup @params
    } catch {
      Write-Error "Creation of group with parameter below has failed. Reasons: $PSItem"
      $params | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor "Yellow" 
      $Summary.Failed++
      return
    }
    Write-Host "created!!!!"
    Write-Host "index: $index"
    $Summary.Created++
  }
}

Write-Host "The script finished running. Summary: "
$Summary | Format-Table | Out-Host