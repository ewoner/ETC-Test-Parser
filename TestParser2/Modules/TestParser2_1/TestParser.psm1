<#
.SYNOPSIS
    PowerShell module for parsing test data using the ETCWebService module.

.DESCRIPTION
    This module contains functions to generate test results and process question objectives for the ETCWebService module.

.VERSION
    1.1.0

.AUTHOR
    Brion Lang

.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.

.FUNCTIONALITY
    TestParser

.LINK
    https://github.com/ewoner/ETC-Test-Parser

.COMPONENT
    TestParser

.ROLE
    TestParser

#>

@{
    RootModule = 'TestParser.psm1'
    ModuleVersion = '1.1.0'
    Author = 'Brion Lang'
    Description = 'PowerShell module for parsing test data using the ETCWebService module.'
    FunctionsToExport = @(
        'Get-QuestionObjectiveNumber'
        'Import-ModConfiguration'
        'New-TestResults'
        'Read-ClassNumber'
        'Read-ModNumber'
    )
    RequiredModules = @(
        @{ ModuleName = 'ETCWebService'; ModuleVersion = '1.0.0' }
        @{ ModuleName = 'ImportExcel'; ModuleVersion = '7.8.0' }
    )
}

Import-Module ETCWebService

# Import additional classes and functions
$PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

. (Join-Path -Path $PSScriptRoot -ChildPath 'classes\Objective.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'classes\ModConfiguration.ps1') 

# Import exporting functions
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-QuestionObjectiveNumber.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Import-ModConfiguration.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\New-TestResults.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Read-ClassNumber.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Read-ModNumber.ps1')

# Import additional functions
#. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Load-Module.ps1')
