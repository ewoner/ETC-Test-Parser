@{
    # Path to the main module file
    RootModule = 'ETCWebService.psm1'
    
    # Version of the module (Must be of type [System.Version])
    ModuleVersion = '1.0.0.2'  # Development version: 1.0.0-dev2
    
    # Author of the module
    Author = 'Brion Lang'
    
    # Description of the module
    Description = 'PowerShell module for interacting with Moodle-based ETC application.'
    
    # List of functions to export from the module
    FunctionsToExport = @(
        'Get-EtcAttemptId',
        'Get-EtcAttemptReview',
        'Get-EtcCourseCategories',
        'Get-EtcCourseData',
        'Get-EtcGradeItem',
        'Get-EtcGroupData',
        'Get-EtcQuizData',
        'Get-EtcSiteInfo',
        'Get-EtcToken',
        'Get-EtcUser',
        'Invoke-EtcRestMethod'
    )
}

