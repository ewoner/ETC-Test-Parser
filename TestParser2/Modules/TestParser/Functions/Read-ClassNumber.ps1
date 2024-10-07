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
