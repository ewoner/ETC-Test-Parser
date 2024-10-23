<#
.SYNOPSIS
Loads specified PowerShell modules from given paths, checking for required modules and their versions.

.PARAMETER approvedModulePath
The parent directory where all approved and signed modules reside.

.PARAMETER developmentModulePath
The parent directory with personal development modules that are not yet signed.

.PARAMETER devAtHome
A switch to indicate if the operation is being run in a development environment at home.

.EXAMPLE
Load-Modules -approvedModulePath "C:\ApprovedModules" -developmentModulePath "C:\DevModules" -devAtHome
#>

function Load-Modules_new {
    param (
        [Parameter(Mandatory = $true)]
        [string]$approvedModulePath,

        [Parameter(Mandatory = $true)]
        [string]$developmentModulePath,

        [switch]$devAtHome
    )

    $modules = @(
        @{ Name = "TestParser"; Path = "$developmentModulePath\TestParser" }
    )
    
    foreach ($module in $modules) {
        $destinationPathName = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($module.Name)"
        
        try {
            $testParserModule = Get-Module -Name "TestParser" -ListAvailable | Select-Object -First 1
            if ($testParserModule) {
                $requiredModules = $testParserModule.RequiredModules
            }

            $installedModule = Get-Module -Name $module.Name -ListAvailable | Select-Object -First 1
            if ($installedModule -and [version]$installedModule.Version -lt [version]$testParserModule.Version) {
                Write-Verbose "Copying module '$($module.Name)' to update it."
                Write-Log "Copying module '$($module.Name)' to update it."
                Copy-Item -Path "$developmentModulePath\$($module.Name)" -Destination $destinationPathName -Recurse -ErrorAction Stop
                if (-not $devAtHome) {
                    Write-Verbose "Unblocking files for module '$($module.Name)' in '$destinationPathName'."
                    Write-Log "Unblocking files for module '$($module.Name)' in '$destinationPathName'."
                    Get-ChildItem -Path $destinationPathName -Recurse | Unblock-File -ErrorAction Stop
                }
            }

foreach ($requiredModule in $requiredModules) {
    $modulePath = "$developmentModulePath\$($requiredModule.ModuleName)"
    
    if (-not (Test-Path -Path $modulePath)) {
        $modulePath = "$approvedModulePath\$($requiredModule.ModuleName)"
    }

    if (-not (Test-Path -Path $modulePath)) {
        Handle-Error "$($requiredModule.ModuleName) could not be located!" $PSCmdlet.MyInvocation.ScriptLineNumber
    } else {
        # Manually check the installed module's version based on the path
        $installedModuleVersion = if (Test-Path -Path $modulePath) {
            # Load the module to check its version, if it exists
            $moduleVersion = (Get-Item $modulePath).Version
        } else {
            $null
        }

        if (-not $installedModuleVersion -or [version]$installedModuleVersion -lt [version]$requiredModule.ModuleVersion) {
            if (-not $devAtHome -and $modulePath -eq "$approvedModulePath\$($requiredModule.ModuleName)") {
                Write-Verbose "Copying module '$($requiredModule.ModuleName)' as it is not loaded or outdated."
                Write-Log "Copying module '$($requiredModule.ModuleName)' as it is not loaded or outdated."
                Copy-Item -Path $modulePath -Destination "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($requiredModule.ModuleName)" -Recurse -ErrorAction Stop
                Write-Verbose "Unblocking files for module '$($requiredModule.ModuleName)' in '$destinationPathName'."
                Write-Log "Unblocking files for module '$($requiredModule.ModuleName)' in '$destinationPathName'."
                Get-ChildItem -Path $destinationPathName -Recurse | Unblock-File -ErrorAction Stop
            } elseif ($modulePath -eq "$developmentModulePath\$($requiredModule.ModuleName)") {
                Write-Verbose "Copying module '$($requiredModule.ModuleName)' from development path."
                Write-Log "Copying module '$($requiredModule.ModuleName)' from development path."
                Copy-Item -Path $modulePath -Destination "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($requiredModule.ModuleName)" -Recurse -force -ErrorAction Stop
            }
        }
    }
}



            Write-Verbose "Importing module '$($module.Name)'."
            Write-Log "Importing module '$($module.Name)'."
            Import-Module $module.Name -Force -ErrorAction Stop
            Write-Debug "Successfully imported module '$($module.Name)'."
            Write-Log "Successfully imported module '$($module.Name)'."
        }
        catch {
            Handle-Error -errorMessage "Failed to process module '$($module.Name)': $_" -lineNumber $_.scriptstacktrace
        }
    }
}