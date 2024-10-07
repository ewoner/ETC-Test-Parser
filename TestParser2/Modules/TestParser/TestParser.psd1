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
