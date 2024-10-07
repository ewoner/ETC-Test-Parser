<#
.SYNOPSIS
Loads specified PowerShell modules from given paths, checking for required modules and their versions.

.DESCRIPTION
This function loads specified PowerShell modules from given paths, ensuring that all required modules are present and meet version specifications. It distinguishes between approved modules that are signed and personal development modules that may not yet be signed.

.VERSION
1.0.0

.AUTHOR
Brion Lang

.NOTES
Versioning specification: https://semver.org/
See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for a complete description, current updates, and future plans.

.PARAMETER approvedModulePath
The parent directory where all approved and signed modules reside.

.PARAMETER developmentModulePath
The parent directory containing personal development modules that are not yet signed.

.PARAMETER devAtHome
A switch to indicate if the operation is being run in a development environment at home.

.EXAMPLE
Load-Modules -approvedModulePath "C:\ApprovedModules" -developmentModulePath "C:\DevModules" -devAtHome

This example loads modules from the specified approved and development paths while indicating that the operation is performed in a development environment.

.INPUTS
[System.String] $approvedModulePath
The path to the directory containing approved and signed modules.

[System.String] $developmentModulePath
The path to the directory containing personal development modules that are not yet signed.

[System.Management.Automation.SwitchParameter] $devAtHome
A switch that specifies if the operation is being run in a development environment at home.

.OUTPUTS
None

.FUNCTIONALITY
TestParser

.LINK
https://github.com/ewoner/ETC-Test-Parser

.COMPONENT
TestParser

.ROLE
TestParser
#>

function Load-Modules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$approvedModulePath,

        [Parameter(Mandatory = $true)]
        [string]$developmentModulePath,

        [Parameter()]
        [switch]$devAtHome
    )

    # Start of the module loading process
    Write-Verbose "Starting module loading process..."

    # Check if the approved module path exists
    if (-Not (Test-Path -Path $approvedModulePath)) {
        Write-Error "Approved module path does not exist: $approvedModulePath"
        return
    }
    
    Write-Verbose "Approved module path found: $approvedModulePath"

    # Check if the development module path exists
    if (-Not (Test-Path -Path $developmentModulePath)) {
        Write-Error "Development module path does not exist: $developmentModulePath"
        return
    }
    
    Write-Verbose "Development module path found: $developmentModulePath"

    # Load approved modules
    $approvedModules = Get-ChildItem -Path $approvedModulePath -Filter '*.psm1'
    foreach ($module in $approvedModules) {
        Write-Verbose "Loading approved module: $($module.FullName)"
        try {
            Import-Module -Name $module.FullName -Force
            Write-Verbose "Successfully loaded module: $($module.Name)"
        } catch {
            Write-Error "Failed to load module: $($module.Name). Error: $_"
        }
    }

    # Load development modules if in dev environment
    if ($devAtHome) {
        $developmentModules = Get-ChildItem -Path $developmentModulePath -Filter '*.psm1'
        foreach ($module in $developmentModules) {
            Write-Verbose "Loading development module: $($module.FullName)"
            try {
                Import-Module -Name $module.FullName -Force
                Write-Verbose "Successfully loaded module: $($module.Name)"
            } catch {
                Write-Error "Failed to load module: $($module.Name). Error: $_"
            }
        }
    } else {
        Write-Verbose "Skipping development module loading since 'devAtHome' switch is not set."
    }

    # End of the module loading process
    Write-Verbose "Module loading process completed."
}
