@{
    ModuleVersion = '1.0.0'
    RootModule = 'Logging.psm1'
    Author = 'Brion Lang'
    Description = 'A module for logging functions'
    FunctionsToExport = @(
        'Write-Log',
        'New-ErrorLog'
    )
}