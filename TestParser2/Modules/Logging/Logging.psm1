# Import the Write-Log function from the Write-Log.ps1 file
. "$PSScriptRoot\Logging\Functions\Write-Log.ps1"

# Import the Handle-Error function from the Handle-Error.ps1 file
. "$PSScriptRoot\Logging\Functions\New-ErrorLog.ps1"

# Define the error directory
$sctript:errorDir = "$PSScriptRoot\errors\"

Export-ModuleMember -Function Write-Log, New-ErrorLog