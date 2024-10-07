<#
.SYNOPSIS
    PowerShell module for Analyzing test data using ETCWebService and ImportExcel.

.DESCRIPTION
    This module contains functions to analyze test data using the ETCWebService and ImportExcel modules.

.VERSION
    1.0.0

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
    Description = 'PowerShell module for Analyzing test data using ETCWebService and ImportExcel.'
    FunctionsToExport = @(
        'Generate-TestResults'
        'Get-QuestionObjectiveNumber'
        'Import-ModConfiguration'
        'Invoke-TestAnalysis'
        'New-TestResults'
        'Process-Question'
        'Process-Test'
        'Read-ClassNumber'
        'Read-ModNumber'
    )
    RequiredModules = @(
        @{ ModuleName = 'ETCWebService'; ModuleVersion = '1.0.0' }
        @{ ModuleName = 'ImportExcel'; ModuleVersion = '7.8.0' }
    )
}
