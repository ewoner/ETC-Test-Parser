# Function to load specified modules, copying them to the local modules directory if necessary,
# and unblocking the files if required.
# Parameters:
#   [string]$importExcelPath - The path to the ImportExcel module.
#   [string]$saveModuleParentPath - The base path for the EtcWebService and TestParser modules.
#   [switch]$devAtHome - If set, the ImportExcel module is not copied or unblocked.
function Load-Modules {
    param (
        [Parameter(Mandatory = $true)]
        [string]$importExcelPath,

        [Parameter(Mandatory = $true)]
        [string]$saveModuleParentPath,

        [switch]$devAtHome
    )

    # Define the module details
    $modules = @(
        @{ Name = "ImportExcel"; Path = "$importExcelPath\ImportExcel" },
        @{ Name = "EtcWebService"; Path = "$saveModuleParentPath\EtcWebService" },
        @{ Name = "TestParser"; Path = "$saveModuleParentPath\TestParser" }
    )
    
    foreach ($module in $modules) {
        $destinationPathName = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($module.Name)"
        
        try {
            # Check if the module needs to be copied
            if (-not $devAtHome -and -not (Test-Path -Path $destinationPathName)) {
                Write-Verbose "Copying module '$($module.Name)' from '$($module.Path)' to '$destinationPathName'."
                Copy-Item -Path $module.Path -Destination $destinationPathName -Recurse -ErrorAction Stop
            } elseif ($devAtHome) {
                Write-Verbose "DevAtHome switch is set. Skipping copy for module '$($module.Name)'."
            }
			
            # Check if the module needs to be unblocked
            if (($module.Name -eq "EtcWebService" -or $module.Name -eq "TestParser") -and (-not $devAtHome)) {
                Write-Verbose "Unblocking files for module '$($module.Name)' in '$destinationPathName'."
                Get-ChildItem -Path $destinationPathName -Recurse | Unblock-File -ErrorAction Stop
            }

            # Import the module
            Write-Verbose "Importing module '$($module.Name)'."
            Import-Module $module.Name -Force -ErrorAction Stop
            Write-Debug "Successfully imported module '$($module.Name)'."
        }
        catch {
            Handle-Error "Failed to process module '$($module.Name)': $_"  $_.scriptstacktrace
        }
    }
}