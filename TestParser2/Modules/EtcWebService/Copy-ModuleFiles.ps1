<#
.SYNOPSIS
    Copies the EtcWebService module files between the source path and the module path, with optional backup and reverse switches.

.DESCRIPTION
    This script copies files between the specified source path and the module path. It creates the module path if it doesn't exist and maintains the directory structure. Optionally, it can create a backup of the existing files in the module path before copying or copy files from the module path back to the source path.

.PARAMETER ModulePath
    The path to the EtcWebService module. Default is "C:\Users\Brion.Lang\Documents\WindowsPowerShell\Modules\EtcWebService".

.PARAMETER SourcePath
    The path to the source files for the EtcWebService module. Default is "H:\Documents\Projects\TestParser\TestParser2\EtcWebService".

.PARAMETER Backup
    Switch parameter to create a backup of the existing files in the destination path before copying new files.

.PARAMETER Reverse
    Switch parameter to copy files from the module path to the source path instead of the other way around.

.EXAMPLE
    .\Copy-ModuleFiles.ps1 -SourcePath "D:\Custom\SourcePath"
    Copies files from a custom source path to the default module path, without creating a backup or using the reverse option.

.EXAMPLE
    .\Copy-ModuleFiles.ps1 -ModulePath "C:\Custom\ModulePath"
    Copies files from the default source path to a custom module path, without creating a backup or using the reverse option.

.EXAMPLE
    .\Copy-ModuleFiles.ps1 -Backup
    Creates a backup of the existing files in the destination path before copying new files, using the default source and module paths.

.EXAMPLE
    .\Copy-ModuleFiles.ps1 -Reverse
    Copies files from the module path to the source path, without creating a backup.

.EXAMPLE
    .\Copy-ModuleFiles.ps1 -SourcePath "D:\Custom\SourcePath" -ModulePath "C:\Custom\ModulePath" -Backup
    Copies files from a custom source path to a custom module path, creating a backup of the existing files before copying.


.NOTES
    Author: Brion Lang
    Date: 08/02/2024
    Module Version: 2.0.0-dev1
    File Version: 0.3.0-240802
    Versioning Specification: https://semver.org/
    GitHub Repository: https://github.com/ewoner/ETC-Test-Parser
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param (
    [string]$ModulePath = "C:\Users\Brion.Lang\Documents\WindowsPowerShell\Modules\EtcWebService",
    [string]$SourcePath = "H:\Documents\Projects\TestParser\TestParser2\EtcWebService",
    [switch]$Backup,
    [switch]$Reverse
)

# Determine the source and destination paths based on the -Reverse switch
if ($Reverse) {
    $source = $ModulePath
    $destination = $SourcePath
} else {
    $source = $SourcePath
    $destination = $ModulePath
}

# Check if SourcePath exists
if (-not (Test-Path -Path $SourcePath)) {
    Write-Error "Source path not found: $SourcePath"
    exit
}

# Check if ModulePath exists
if ($PSCmdlet.ShouldProcess("Check Module Path")) {
    if (-not (Test-Path -Path $ModulePath)) {
        if ($PSCmdlet.ShouldProcess("Create Module Path")) {
            try {
                New-Item -Path $ModulePath -ItemType Directory -Force | Out-Null
                Write-Host "Created module path: $ModulePath"
            } catch {
                Write-Error "Failed to create module path: $($_.Exception.Message)"
            }
        }
    } else {
        Write-Verbose "Module path exists: $ModulePath"
    }
}

# Backup existing files if the -Backup switch is specified
if ($Backup -and $PSCmdlet.ShouldProcess("Backup Files")) {
    $backupPath = "$destination\Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    try {
        Copy-Item -Path "$destination\*" -Destination $backupPath -Recurse
        Write-Host "Backup completed successfully to: $backupPath"
    } catch {
        Write-Error "Failed to create backup: $($_.Exception.Message)"
    }
}

# Copy files from source to destination, maintaining directory structure
if ($PSCmdlet.ShouldProcess("Copy Module Files")) {
    Write-Host "Copying files from $source to $destination"
    try {
        Get-ChildItem -Path $source -Recurse | ForEach-Object {
            $destPath = $_.FullName -replace [regex]::Escape($source), [regex]::Escape($destination)
            if ($_.PSIsContainer) {
                if ($PSCmdlet.ShouldProcess("Create Directory")) {
                    if (-not (Test-Path -Path $destPath)) {
                        try {
                            New-Item -Path $destPath -ItemType Directory | Out-Null
                            Write-Host "Created directory: $destPath"
                        } catch {
                            Write-Error "Failed to create directory: $($_.Exception.Message)"
                        }
                    }
                }
            } else {
                if ($PSCmdlet.ShouldProcess("Copy File")) {
                    try {
                        Copy-Item -Path $_.FullName -Destination $destPath -Force
                        Write-Verbose "Copied file: $($_.FullName) to $destPath"
                    } catch {
                        Write-Error "Failed to copy file: $($_.FullName) to $destPath - $($_.Exception.Message)"
                    }
                }
            }
        }
        Write-Host "Files copied successfully from $source to $destination"
    } catch {
        Write-Error "Failed during file copy operation: $($_.Exception.Message)"
    }
}

# Set location and reload module
if( -not $Reverse ) {
	try {
		Set-Location -Path $ModulePath
		. .\Reload-EtcWebService.ps1
		Write-Host "Reload script executed: .\Reload-EtcWebService.ps1"
	} catch {
		Write-Error "Failed to execute reload script: $($_.Exception.Message)"
	}
}

# Check for any errors after script execution
if ($Error.Count -gt 0) {
    Write-Host "Errors occurred during script execution:"
    $Error | ForEach-Object { Write-Host $_.Exception.Message }
    Pause
}
