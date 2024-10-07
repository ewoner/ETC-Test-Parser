function Read-ModNumber {
    [CmdletBinding()]
    param (
        [string]$ConfigDirectoryPath = $(Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'Config')  # Default path where module configuration files are stored
    )
    
    # Get a list of valid module numbers from the configuration files in the directory
    $validModules = Get-ChildItem -Path $ConfigDirectoryPath -Filter 'mod*.conf' | ForEach-Object {
        if ($_.BaseName -match '^mod(\d+)$') {
            [int]$matches[1]
        }
    } | Sort-Object  # Sort module numbers

    # If no valid modules are found, exit the function
    if (-not $validModules) {
        Write-Host "No valid module configuration files found in $ConfigDirectoryPath."
        return $null
    }

    # Display a sorted menu of valid module numbers
    while ($true) {
        Write-Host "Available module numbers:"
        $validModules | ForEach-Object { Write-Host "Mod $_" }
        
        # Prompt the user to enter a module number
        $modNumber = Read-Host "Enter module number"
        
        # Try to convert the input to an integer
        if (-not [int]::TryParse($modNumber, [ref]$null)) {
            Write-Host "Invalid input. Please enter a valid number."
            continue
        }
        
        # Convert the input to an integer
        $modNumber = $modNumber -as [int]
        
        # Check if the input is one of the valid module numbers
        if ($validModules -contains $modNumber) {
            Write-Host "Valid module number entered: $modNumber"
            return $modNumber
        } else {
            Write-Host "Invalid module number. Please enter a number from the list above."
        }
    }
}
