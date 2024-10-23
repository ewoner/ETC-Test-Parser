# Function to compare files
function Compare-Files {
    param (
        [string]$fileName,
        [string]$livePath = "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser2\",
        [string]$dev2Path = "C:\Users\Brion.Lang\Documents\WindowsPowerShell\Scripts"
    )
    $liveFilePath = Join-Path -Path $liveBasePath -ChildPath $fileName
    $dev2FilePath = Join-Path -Path $dev2BasePath -ChildPath $fileName

    # Check if both files exist
    if (-Not (Test-Path $liveFilePath)) {
        Write-Host "Live version file not found: $liveFilePath"
        return
    }
    if (-Not (Test-Path $dev2FilePath)) {
        Write-Host "Dev2 version file not found: $dev2FilePath"
        return
    }

    # Compare the files
    $comparison = Compare-Object (Get-Content $liveFilePath) (Get-Content $dev2FilePath) -SyncWindow 0

    if ($comparison) {
        Write-Host "Differences found between the files:"
        $comparison | Format-Table -Wrap
    } else {
        Write-Host "The files are identical."
    }
}

# Example usage:
# Replace 'your\relative\file.ps1' with the relative path to the file you want to compare
#$relativeFilePath = "your\relative\file.ps1"
#Compare-Files -relativeFilePath $relativeFilePath
