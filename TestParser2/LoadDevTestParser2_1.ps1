# Define paths
$SourcePath = "H:\Documents\Projects\TestParser2\V_1.1.0-dev1\TestParser2\Modules\TestParser2_1"
$DestinationPath = "C:\Users\Brion.Lang\Documents\WindowsPowerShell\Modules\TestParser"

# Clear the contents of the destination module folder (including subfolders)
if (Test-Path $DestinationPath) {
    # Get all items in the destination path and remove them
    Get-ChildItem -Path $DestinationPath -Recurse | Remove-Item -Recurse -Force
}

# Create the destination directory if it doesn't exist
New-Item -ItemType Directory -Path $DestinationPath -Force

# Copy the module to the destination path
Copy-Item -Recurse -Path "$SourcePath\*" -Destination $DestinationPath -Force

# Unblock the copied files
Get-ChildItem -Path $DestinationPath -Recurse | Unblock-File

# Remove the live module if it is loaded
Remove-Module TestParser -ErrorAction SilentlyContinue

# Import the development module
Import-Module TestParser -Force -verbose

# Verify the module is loaded
$loadedModule = Get-Module TestParser
if ($loadedModule) {
    Write-Host "Successfully loaded module: $($loadedModule.Name) version: $($loadedModule.Version)"
} else {
    Write-Host "Failed to load the module TestParser."
}

read-host "Hit Enter to close"