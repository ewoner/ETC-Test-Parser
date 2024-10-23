# Test-NewErrorLog.ps1
Import-Module TestParser

# Import the New-ErrorLog function
. "$PSScriptRoot\Functions\New-ErrorLog.ps1"

# Define a test error message
$errorMessage = "This is a test error message"

# Define a test line number
$lineNumber = 10

# Call the New-ErrorLog function
New-ErrorLog -errorMessage $errorMessage -lineNumber $lineNumber

# Check if the error log file was created
$errorLogFile = Get-ChildItem -Path $errorDir -Filter "*-ERROR.LOG"
if ($errorLogFile) {
    Write-Host "Error log file created successfully"
} else {
    Write-Host "Error log file not created"
}

# Check the contents of the error log file
$errorLogContents = Get-Content -Path $errorLogFile.FullName
if ($errorLogContents -like "*$errorMessage*") {
    Write-Host "Error message logged successfully"
} else {
    Write-Host "Error message not logged"
}