<#
.SYNOPSIS
Prompts the user to enter a class number and validates it against existing directories.

.DESCRIPTION
This function prompts the user for a class number, validates its length and format, 
and checks for corresponding directories in the specified path. 
Handles special cases for "None" and "99999".

.VERSION
1.0.0

.AUTHOR
Brion Lang

.NOTES
Versioning specification: https://semver.org/
See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.

.PARAMETER DirectoryPath
The path where class directories are stored.

.EXAMPLE
Read-ClassNumber -DirectoryPath "S:\Student\"

.INPUTS
[System.String] $DirectoryPath
The path where class directories are stored.

.OUTPUTS
[System.String]
The validated class number or special value.

.FUNCTIONALITY
ClassNumberReader

.LINK
https://github.com/ewoner/ETC-Test-Parser

.COMPONENT
ClassNumberReader

.ROLE
ClassNumberReader
#>

function Read-ClassNumber {
    [CmdletBinding()]
    param (
        [string]$DirectoryPath = 's:\Student\'  # Default path where class directories are stored
    )
    
    while ($true) {
        # Prompt the user to enter a class number
        $classNumber = Read-Host "Enter class number"
        
        # Check for special cases
        if ($classNumber -eq "None") {
            Write-Host "Special case 'None' detected. Returning 99999."
            return 99999
        }
        
        # Validate that the class number has at least 5 characters
        if ($classNumber.Length -lt 5) {
            Write-Host "Class number must be at least 5 characters long."
            continue
        }
        
        # Extract the first 5 characters from the class number
        $classPrefix = $classNumber.Substring(0, 5)
        
        # Check for the special case '99999'
        if ($classPrefix -eq "99999") {
            Write-Host "Special case '99999' detected."
            return 99999
        }
        
        # Construct the path to check if the directory for the class prefix exists
        $directoryPathToCheck = Join-Path -Path $DirectoryPath -ChildPath $classPrefix
        $directoryExists = Test-Path -Path $directoryPathToCheck -PathType Container
        
        if ($directoryExists) {
            Write-Host "Directory for class prefix '$classPrefix' exists."
            return $classPrefix
        } else {
            Write-Host "No directory found for class prefix '$classPrefix'. Please try again."
        }
    }
}
