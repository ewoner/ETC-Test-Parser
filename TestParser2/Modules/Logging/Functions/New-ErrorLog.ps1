function New-ErrorLog {
    param (
        [Parameter(Mandatory = $true)]
        [string]$errorMessage,
        [string]$lineNumber,
        [switch]$donotexit
    )
    $currentLog = "$PSScriptRoot\current.log"
    $errorDir = "$PSScriptRoot\errors\"
    Write-Host -BackgroundColor Black -ForegroundColor Red "Gathering data due to an error..."

    try {
        # Define timestamp for log file naming
        $timestamp = Get-Date -Format "yyyy-MM-dd-HHmm"
        $errorLog = Join-Path -Path $errorDir -ChildPath "$timestamp-ERROR.LOG"
        $statusFile = Join-Path -Path $errorDir -ChildPath "$timestamp-ERROR.json"

        # Ensure error directory exists
        if (-not (Test-Path -Path $errorDir)) {
            New-Item -Path $errorDir -ItemType Directory | Out-Null
        }

        # Copy the current log file to error log directory
        if (Test-Path -Path $currentLog) {
            Copy-Item -Path $currentLog -Destination $errorLog -Force
        }

        # Log the error message with timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Out-File -FilePath $errorLog -Append -InputObject "$timestamp - ERROR @ $lineNumber : $errorMessage" -Encoding ASCII
        Write-Verbose "Error message logged to $errorLog."

        # Gather current variable states for debugging
        $modules = @(
            Get-Module -Name TestParser
            Get-Module -Name EtcWebService
            Get-Module -Name Logging
        )

        # Get script variables from testparser2d2-beta_test.ps1
        $scriptVariables = Get-Variable -Scope Script -Name *

        # Create a new hashtable to store the variables
        $variables = @{
            Modules         = $modules
            #ScriptVariables = $scriptVariables
        }

        # Save the variables to the $statusFile as JSON
        $variables | ConvertTo-Json -Depth 10 | Out-File -FilePath $statusFile
    }
    catch {
        Write-Host "Critical error in New-ErrorLog function: $($_.Exception.line)"
    }
    if ( -not $donotexit ) {
        # Prompt user to close the script
        Read-Host -Prompt "Hit Enter to close"
        exit 1
    }
}