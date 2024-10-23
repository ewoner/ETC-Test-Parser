# Function to select a unique group from a list based on the class number.
# Parameters:
#   [array]$groups - An array of group objects to search through.
#   [string]$classNumber - The class number to match groups against.
function Select-UniqueGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$groups,

        [Parameter(Mandatory = $true)]
        [string]$classNumber
    )

    Write-Log "Entering Select-UniqueGroup function with classNumber: $classNumber."
    Write-Verbose "Searching for groups with class number: $classNumber."

    # Find groups that match the class number
    $matchingGroups = $groups | Where-Object { $_.name -match $classNumber }
    Write-Log "Found matching groups: $($matchingGroups.Count)."
    Write-Verbose "Matching groups: $($matchingGroups | ForEach-Object { $_.name })"

    if ($matchingGroups.Count -eq 1) {
        Write-Log "Exactly one group matched the class number: $($matchingGroups[0].name)."
        Write-Verbose "Returning the single matching group."
        return $matchingGroups[0]
    } elseif ($matchingGroups.Count -gt 1) {
        $counter = 0
        $menuOptions = @()

        foreach ($group in $matchingGroups) {
            $label = Get-Label -index $counter
            $menuOptions += [PSCustomObject]@{ Label = $label; Group = $group }
            Write-Log "Added menu option with label: $label for group: $($group.name)."
            Write-Debug "Menu option: Label = $label, Group = $($group.name)."
            $counter++
        }

        $menuOptions += [PSCustomObject]@{ Label = "0"; Group = $null; Description = "Quit" }

        do {
            Write-Log "Displaying menu options for multiple groups."
            Write-Verbose "Displaying menu options."
            Write-Host "Multiple groups match the class number. Please select one:"
            
            foreach ($option in $menuOptions) {
                if ($option.Description) {
                    Write-Host "$($option.Label): $($option.Description)"
                } else {
                    Write-Host "$($option.Label): $($option.Group.name)"
                }
            }

            $selectedLabel = Read-Host "Enter the label of the group you want to use"
            Write-Log "User selected label: $selectedLabel."
            Write-Debug "User input: $selectedLabel."

            $selectedOption = $menuOptions | Where-Object { $_.Label -eq $selectedLabel }

            if ($selectedOption) {
                if ($selectedOption.Group) {
                    Write-Log "User selected group: $($selectedOption.Group.name)."
                    Write-Verbose "Returning selected group: $($selectedOption.Group.name)."
                    return $selectedOption.Group
                } else {
                    Write-Log "User chose to quit."
                    Write-Verbose "User chose to quit."
                    return $null
                }
            } else {
                Write-Log "Invalid selection by user: $selectedLabel."
                Write-Verbose "Invalid selection. Prompting user to try again."
                Write-Host "Invalid selection. Please try again."
            }
        } while ($true)
    } else {
        Write-Log "No groups matched the class number."
        Write-Verbose "No matching groups found."
        return $null
    }
}