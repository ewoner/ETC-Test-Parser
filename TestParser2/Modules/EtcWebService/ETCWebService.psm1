# Import additional classes
Write-Verbose "Importing class files..."
. (Join-Path -Path $PSScriptRoot -ChildPath 'classes\etccourse.ps1') -Verbose
. (Join-Path -Path $PSScriptRoot -ChildPath 'classes\etcuser.ps1') -Verbose
. (Join-Path -Path $PSScriptRoot -ChildPath 'classes\MoodleWSConfiguration.ps1') -Verbose

# Import additional functions
Write-Verbose "Importing function files..."
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcToken.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcUser.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcSiteInfo.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Invoke-EtcRestMethod.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcCourseData.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcCourseCategories.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcQuizData.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcGroupData.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcGradeItem.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcAttemptId.ps1')
. (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\Get-EtcAttemptReview.ps1')

# Script scoped variables
Write-Verbose "Setting up script scoped variables..."
$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath 'Config.conf'
$script:User = $null
$script:config = [MoodleWSConfiguration]::new()  # Renamed ModuleConfiguration to MoodleWSConfiguration
$script:EtcData = [EtcData]::new()

# Check if etcusers.txt exists; create if not
Write-Verbose "Checking for existence of etcusers.txt..."
if (-not (Test-Path -Path $script:config.UserDataPath -PathType Leaf)) {  # Updated to use $script:config.UserDataPath
    try {
        New-Item -Path $(Join-Path -Path $env:LOCALAPPDATA -ChildPath "ETC") -ItemType Directory -Force
        New-Item -Path $script:config.UserDataPath -Value "" -Force
        Write-Host "Created etcusers.txt file at $($script:config.UserDataPath)"  # Updated to use $($script:config.UserDataPath)
    } catch {
        Write-Error "Failed to create etcusers.txt file: $_"
    }
} else {
    Write-Verbose "etcusers.txt already exists."
}

# Load configuration from Config.conf
Write-Verbose "Loading configuration from Config.conf..."
if (Test-Path -Path $ConfigPath) {
    $configContent = Get-Content -Path $ConfigPath
    foreach ($line in $configContent) {
        if ($line -match "^\s*(\w+)\s*=\s*(.+)\s*$") {
            $script:config.SetConfig($matches[1], $matches[2])
        }
    }
    Write-Verbose "Configuration loaded successfully."
} else {
    throw "Config.conf not found. Please ensure it exists in the module root directory."
}
Remove-Variable -Name line, ConfigPath, configContent

# Export functions from module
Write-Verbose "Exporting functions..."
Export-ModuleMember -Function 'Invoke-EtcRestMethod'
Export-ModuleMember -Function 'Get-EtcToken'
Export-ModuleMember -Function 'Get-EtcUser'
Export-ModuleMember -Function 'Get-EtcSiteInfo'
Export-ModuleMember -Function 'Get-EtcCourseData'
Export-ModuleMember -Function 'Get-EtcCourseCategories'
Export-ModuleMember -Function 'Get-EtcQuizData'
Export-ModuleMember -Function 'Get-EtcGroupData'
Export-ModuleMember -Function 'Get-EtcGradeItem'
Export-ModuleMember -Function 'Get-EtcAttemptId'
Export-ModuleMember -Function 'Get-EtcAttemptReview'
