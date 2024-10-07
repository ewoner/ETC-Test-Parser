<#
.SYNOPSIS
    TestParser2.ps1
.DESCRIPTION
    This script processes ETC test data and generates Excel reports based on students' scores. For each student who failed the test, it creates a separate Excel sheet detailing the missed areas by module objective and a remediation sheet for distribution.
.VERSION
    2.2.1-dev2
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
    File Version: 2.2.1-dev2-2024-09-05
.PARAMETER debugParser
    Specifies the debugging level for the script. Options are "off", "on", or "full". Default is "off".
.PARAMETER devParser
    Specifies the development environment. Options are "off", "home", or "work". Default is "off".
.CHANGELOG
    2024-08-15 - Version 2.0.0-dev1
        - Initial release with basic functionality.
        - Added Load-Modules function to handle module loading and importing.
        - Integrated debugging settings based on command-line parameters.
        - Implemented clear screen and standard comment header.
    2024-08-16 - Version 2.0.0-dev1
        - Added Unblock-File functionality for EtcWebService and TestParser modules.
        - Removed redundant variables and streamlined code for verbosity and debugging.
    2024-08-23 - Version 2.1.0-dev2
        - Incorporated parameter handling from Dev 2 for debugParser and devParser options.
        - Updated debugging and development environment handling.
        - Refined script logic with improvements from Dev 2.
        - Added Select-UniqueGroup function to handle cases where multiple groups match the regex pattern.
        - Updated error handling for user data file and token retrieval.
        - Updated Load-Modules function to exclude copying and unblocking of ImportExcel module in "home" environment.
    2024-08-26 - Version 2.1.0-dev2
        - Added [CmdletBinding()] to Select-UniqueGroup and Load-Modules functions.
        - Updated paths for module saving and importing:
            - $saveModuleParentPath set to "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser2\Modules"
            - $ImportExcelPath set to "S:\Inst\Projects\VM-Builder\Modules"
        - Deleted the param block from Load-Modules function as $devParser and $debugParser are now parameters to the script.
        - Ensured that all placeholders were replaced with specific paths and values.
        - Updated Load-Modules function to handle paths and module loading appropriately based on the environment.
        - Added error handling to verify paths and module operations, with appropriate exit conditions.
    2024-08-29 - Version 2.2.0-dev2
        - Updated Select-UniqueGroup function to provide alphabetic choices for user selection, with support for up to 702 choices.
        - Added Get-Label function to generate labels for menu options dynamically.
        - Included verbose and debug output and comments for both Select-UniqueGroup and Get-Label functions.
        - Adjusted menu display to include a "Quit" option and properly handle user input for valid choices.
    2024-09-05 - Version 2.2.1-dev2
        - Added logging mechanism to rotate logs and backup previous logs.
        - Integrated Write-Log function to capture log messages consistently.
        - Implemented error handling function Handle-Error to capture and log errors along with variable statuses in JSON format.
        - Updated verbose/debugging and comments throughout the whole code.
        - Load-Modules was incorrect. Updated to include both development environments. More improvements may still be needed here.
#>


# Parameters
param (
    [Parameter(Position = 0)]
    [ValidateSet("off", "on", "full")]
    [string]$debugParser = "off",  # Default value is 'off'

    [Parameter(Position = 1)]
    [ValidateSet("off", "home", "work")]
    [string]$devParser = "off"  # Default value is 'off'
)
# Function to log messages with timestamps to a specified log file.
# Parameters:
#   [string]$logEntry - The message to be logged. This parameter is mandatory.
#   [switch]$NoNewline - Optional switch to append log entry on the same line as the previous entry.
function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$logEntry,

        [switch]$NoNewline
    )

    Write-Verbose "Entering Write-Log function with log entry: $logEntry."

    try {
        # Get the current timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Verbose "Timestamp for log entry: $timestamp."

        if ($NoNewline) {
            # Read the last line from the log file if it exists
            if (Test-Path $currentLog) {
                $lastLine = Get-Content -Path $currentLog -Tail 1
                # Remove the newline from the last line if it exists
                $lastLine = $lastLine.TrimEnd()
                # Construct the log entry without adding a new line
                $formattedLogEntry = "$lastLine $logEntry"
            } else {
                # If log file does not exist, start a new line with the log entry
                $formattedLogEntry = $logEntry
            }
        } else {
            # Include timestamp with log entry
            $formattedLogEntry = "$timestamp - $logEntry"
        }

        # Append the log entry to the current log file
        $formattedLogEntry | Out-File -FilePath $currentLog -Append -ErrorAction Stop -Encoding UTF8
        Write-Debug "Logged entry to ${currentLog}: $formattedLogEntry."

    } catch {
        # Handle any errors that occur during logging
        $errorMessage = "Failed to write to log file. Error: $_"
        Write-Error $errorMessage
        Write-Log -logEntry $errorMessage
    }
}

# Define paths for logs and errors
$logDir = ".\logs"
$errorDir = ".\errors"
$currentLog = Join-Path -Path $logDir -ChildPath "TestParser.log"
$backupLog = Join-Path -Path $logDir -ChildPath "TestParser.bak"
$lastLog = Join-Path -Path $logDir -ChildPath "TestParser.last"

# Rotate log files to keep history
if (Test-Path -Path $backupLog) {
    Write-Verbose "Backing up current log file to $backupLog."
    Write-Log "Backing up current log file to $backupLog."
    Move-Item -Path $backupLog -Destination $lastLog -Force
}

if (Test-Path -Path $currentLog) {
    Write-Verbose "Moving current log file to $backupLog."
    Write-Log "Moving current log file to $backupLog."
    Move-Item -Path $currentLog -Destination $backupLog -Force
}

# Create a new log file for the current session
New-Item -Path $currentLog -ItemType File -Force | Out-Null
Write-Verbose "Created new log file at $currentLog."
Write-Log "Created new log file at $currentLog."





# Function to convert a hashtable to a dictionary, handling nested hashtables and collections.
# Parameters:
#   [hashtable]$hashtable - The hashtable to be converted to a dictionary.
# Returns:
#   [hashtable] - A dictionary representation of the input hashtable.
function Convert-HashtableToDictionary {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$hashtable
    )

    Write-Verbose "Entering Convert-HashtableToDictionary function."

    # Initialize an empty dictionary
    $dictionary = @{}
    Write-Verbose "Initialized empty dictionary."

    foreach ($key in $hashtable.Keys) {
        $value = $hashtable[$key]

        Write-Verbose "Processing key: $key with value: $value."

        if ($value -is [hashtable]) {
            Write-Verbose "Value for key '$key' is a hashtable. Recursively converting."
            $dictionary[$key] = Convert-HashtableToDictionary -hashtable $value
        } elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            # If value is a collection (not a string), convert it to an array for serialization
            Write-Verbose "Value for key '$key' is a collection. Converting to array."
            $dictionary[$key] = @($value)
        } else {
            Write-Verbose "Value for key '$key' is of type $($value.GetType().Name). Adding to dictionary."
            $dictionary[$key] = $value
        }
    }

    Write-Debug "Converted dictionary: $dictionary"
    return $dictionary
}

# Function to convert a hashtable of variables to a dictionary format suitable for JSON serialization.
# Parameters:
#   [hashtable]$variables - The hashtable containing variables to be converted.
# Returns:
#   [hashtable] - A dictionary representation of the input variables, suitable for JSON serialization.
function Convert-VariablesToJson {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    Write-Verbose "Entering Convert-VariablesToJson function."

    # Initialize an empty hashtable for the converted variables
    $convertedVariables = @{}
    Write-Verbose "Initialized empty hashtable for converted variables."

    foreach ($variable in $variables.Keys) {
        try {
            $value = $variables[$variable]

            Write-Verbose "Processing variable: $variable with value: $value."

            if ($value -is [hashtable]) {
                Write-Verbose "Value for variable '$variable' is a hashtable. Converting to dictionary."
                $convertedVariables[$variable] = Convert-HashtableToDictionary -hashtable $value
            } elseif ($value -is [System.Collections.ListDictionaryInternal]) {
                # Skip unsupported types
                Write-Verbose "Skipping variable '$variable' due to unsupported type: ListDictionaryInternal."
            } elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
                # Convert collections to arrays for serialization
                Write-Verbose "Value for variable '$variable' is a collection. Converting to array."
                $convertedVariables[$variable] = @($value)
            } else {
                Write-Verbose "Value for variable '$variable' is of type $($value.GetType().Name). Adding to converted variables."
                $convertedVariables[$variable] = $value
            }
        } catch {
            Write-Verbose "Failed to convert variable '$variable': $_"
        }
    }

    Write-Debug "Converted variables: $convertedVariables"
    return $convertedVariables
}


# Function to handle errors by logging details and halting execution.
# Parameters:
#   [string]$errorMessage - The error message to be logged. This parameter is mandatory.
function Handle-Error {
    param (
        [Parameter(Mandatory = $true)]
        [string]$errorMessage,
		[string]$lineNumber,
		[switch]$donotexit
    )

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
<#
        # Gather current variable states for debugging
        $variables = @{}
        Get-Variable | Where-Object { 
            $_.Name -notmatch 'ErrorVariable|true' -and 
            ($_.Value -isnot [System.Object[]]) -and 
            ($_.Value -is [hashtable] -or $_.Value -is [psobject] -or $_.Value -is [string] -or $_.Value -is [int] -or $_.Value -is [bool]) 
        } | ForEach-Object {
            $variables[$_.Name] = $_.Value
        }

        # Convert variables to JSON and save to file
        try {
            $convertedVariables = Convert-VariablesToJson -variables $variables
            $convertedVariables | ConvertTo-Json -Depth 10 | Out-File -FilePath $statusFile
            Write-Verbose "Variable state saved to $statusFile."
        } catch {
            Write-Host "Error saving variable state to JSON: $_"
        }
#>
    } catch {
        Write-Host "Critical error in Handle-Error function: $_"
    }
	if ( -not $donotexit ) {
		# Prompt user to close the script
		Read-Host -Prompt "Hit Enter to close"
		exit 1
	}
}
# Function to convert an integer index to a corresponding label using letters A-Z.
# Parameters:
#   [int]$index - The index to be converted to a label. The index is zero-based.
function Get-Label {
    param (
        [Parameter(Mandatory = $true)]
        [int]$index
    )

    Write-Verbose "Entering Get-Label function with index: $index."

    # Define letters to use in labels
    $letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $label = ""

    do {
        # Get the current character for the given index
        $currentChar = $letters[$index % 26]
        Write-Debug "Current character for index $index is $currentChar."
        $label = $currentChar + $label

        # Update index for the next character
        $index = [math]::Floor($index / 26) - 1
        Write-Debug "Updated index to $index."

    } while ($index -ge 0)

    Write-Verbose "Generated label: $label."
    return $label
}

# Function to select a unique group from a list based on the class number.
# Parameters:
#   [array]$groups - An array of group objects to search through.
#   [string]$classNumber - The class number to match groups against.
function Select-UniqueGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$groups,

        [Parameter(Mandatory = $true)]
        [string]$classNumber
    )

    Write-Log "Entering Select-UniqueGroup function with classNumber: $classNumber."
    Write-Verbose "Searching for groups with class number: $classNumber."

    # Find groups that match the class number
    $matchingGroups = $groups | Where-Object { $_.name -match $classNumber }
    Write-Log "Found matching groups: $($matchingGroups.Count)."
    Write-Verbose "Matching groups: $($matchingGroups | ForEach-Object { $_.name })"

    if ($matchingGroups.Count -eq 1) {
        Write-Log "Exactly one group matched the class number: $($matchingGroups[0].name)."
        Write-Verbose "Returning the single matching group."
        return $matchingGroups[0]
    } elseif ($matchingGroups.Count -gt 1) {
        $counter = 0
        $menuOptions = @()

        foreach ($group in $matchingGroups) {
            $label = Get-Label -index $counter
            $menuOptions += [PSCustomObject]@{ Label = $label; Group = $group }
            Write-Log "Added menu option with label: $label for group: $($group.name)."
            Write-Debug "Menu option: Label = $label, Group = $($group.name)."
            $counter++
        }

        $menuOptions += [PSCustomObject]@{ Label = "0"; Group = $null; Description = "Quit" }

        do {
            Write-Log "Displaying menu options for multiple groups."
            Write-Verbose "Displaying menu options."
            Write-Host "Multiple groups match the class number. Please select one:"
            
            foreach ($option in $menuOptions) {
                if ($option.Description) {
                    Write-Host "$($option.Label): $($option.Description)"
                } else {
                    Write-Host "$($option.Label): $($option.Group.name)"
                }
            }

            $selectedLabel = Read-Host "Enter the label of the group you want to use"
            Write-Log "User selected label: $selectedLabel."
            Write-Debug "User input: $selectedLabel."

            $selectedOption = $menuOptions | Where-Object { $_.Label -eq $selectedLabel }

            if ($selectedOption) {
                if ($selectedOption.Group) {
                    Write-Log "User selected group: $($selectedOption.Group.name)."
                    Write-Verbose "Returning selected group: $($selectedOption.Group.name)."
                    return $selectedOption.Group
                } else {
                    Write-Log "User chose to quit."
                    Write-Verbose "User chose to quit."
                    return $null
                }
            } else {
                Write-Log "Invalid selection by user: $selectedLabel."
                Write-Verbose "Invalid selection. Prompting user to try again."
                Write-Host "Invalid selection. Please try again."
            }
        } while ($true)
    } else {
        Write-Log "No groups matched the class number."
        Write-Verbose "No matching groups found."
        return $null
    }
}
<#
.SYNOPSIS
Loads specified PowerShell modules from given paths, checking for required modules and their versions.

.PARAMETER approvedModulePath
The parent directory where all approved and signed modules reside.

.PARAMETER developmentModulePath
The parent directory with personal development modules that are not yet signed.

.PARAMETER devAtHome
A switch to indicate if the operation is being run in a development environment at home.

.EXAMPLE
Load-Modules -approvedModulePath "C:\ApprovedModules" -developmentModulePath "C:\DevModules" -devAtHome
#>

function Load-Modules_new {
    param (
        [Parameter(Mandatory = $true)]
        [string]$approvedModulePath,

        [Parameter(Mandatory = $true)]
        [string]$developmentModulePath,

        [switch]$devAtHome
    )

    $modules = @(
        @{ Name = "TestParser"; Path = "$developmentModulePath\TestParser" }
    )
    
    foreach ($module in $modules) {
        $destinationPathName = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($module.Name)"
        
        try {
            $testParserModule = Get-Module -Name "TestParser" -ListAvailable | Select-Object -First 1
            if ($testParserModule) {
                $requiredModules = $testParserModule.RequiredModules
            }

            $installedModule = Get-Module -Name $module.Name -ListAvailable | Select-Object -First 1
            if ($installedModule -and [version]$installedModule.Version -lt [version]$testParserModule.Version) {
                Write-Verbose "Copying module '$($module.Name)' to update it."
                Write-Log "Copying module '$($module.Name)' to update it."
                Copy-Item -Path "$developmentModulePath\$($module.Name)" -Destination $destinationPathName -Recurse -ErrorAction Stop
                if (-not $devAtHome) {
                    Write-Verbose "Unblocking files for module '$($module.Name)' in '$destinationPathName'."
                    Write-Log "Unblocking files for module '$($module.Name)' in '$destinationPathName'."
                    Get-ChildItem -Path $destinationPathName -Recurse | Unblock-File -ErrorAction Stop
                }
            }

foreach ($requiredModule in $requiredModules) {
    $modulePath = "$developmentModulePath\$($requiredModule.ModuleName)"
    
    if (-not (Test-Path -Path $modulePath)) {
        $modulePath = "$approvedModulePath\$($requiredModule.ModuleName)"
    }

    if (-not (Test-Path -Path $modulePath)) {
        Handle-Error "$($requiredModule.ModuleName) could not be located!" $PSCmdlet.MyInvocation.ScriptLineNumber
    } else {
        # Manually check the installed module's version based on the path
        $installedModuleVersion = if (Test-Path -Path $modulePath) {
            # Load the module to check its version, if it exists
            $moduleVersion = (Get-Item $modulePath).Version
        } else {
            $null
        }

        if (-not $installedModuleVersion -or [version]$installedModuleVersion -lt [version]$requiredModule.ModuleVersion) {
            if (-not $devAtHome -and $modulePath -eq "$approvedModulePath\$($requiredModule.ModuleName)") {
                Write-Verbose "Copying module '$($requiredModule.ModuleName)' as it is not loaded or outdated."
                Write-Log "Copying module '$($requiredModule.ModuleName)' as it is not loaded or outdated."
                Copy-Item -Path $modulePath -Destination "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($requiredModule.ModuleName)" -Recurse -ErrorAction Stop
                Write-Verbose "Unblocking files for module '$($requiredModule.ModuleName)' in '$destinationPathName'."
                Write-Log "Unblocking files for module '$($requiredModule.ModuleName)' in '$destinationPathName'."
                Get-ChildItem -Path $destinationPathName -Recurse | Unblock-File -ErrorAction Stop
            } elseif ($modulePath -eq "$developmentModulePath\$($requiredModule.ModuleName)") {
                Write-Verbose "Copying module '$($requiredModule.ModuleName)' from development path."
                Write-Log "Copying module '$($requiredModule.ModuleName)' from development path."
                Copy-Item -Path $modulePath -Destination "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($requiredModule.ModuleName)" -Recurse -force -ErrorAction Stop
            }
        }
    }
}



            Write-Verbose "Importing module '$($module.Name)'."
            Write-Log "Importing module '$($module.Name)'."
            Import-Module $module.Name -Force -ErrorAction Stop
            Write-Debug "Successfully imported module '$($module.Name)'."
            Write-Log "Successfully imported module '$($module.Name)'."
        }
        catch {
            Handle-Error -errorMessage "Failed to process module '$($module.Name)': $_" -lineNumber $_.scriptstacktrace
        }
    }
}

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
# Function to prompt the user to change the save directory and file name.
function Set-SaveLocation {

	$filename = $modConfig.GetFileName($classNumber)
    # Prompt user to change the save directory and file name
    $changeSaveDir = Read-Host -Prompt "Output will be saved as $($filename) in the directory $($modConfig.SaveDirStr)`nDo you wish to change these settings (y/N)"
    Write-Verbose "User prompted to change save settings."
    Write-Debug "User input for changing save settings: $changeSaveDir"
    Write-Log -logEntry "User prompted to change save settings."

    if ($changeSaveDir -eq 'y') {
        try {
            # Load Windows Forms assembly
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        } catch {
            $errorMessage = "Failed to load Windows Forms assembly. Using default directory and file name."
            Write-Host $errorMessage
            Write-Log -logEntry $errorMessage
            Handle-Error -errorMessage "$errorMessage Error details: $_" -donotexit $_.scriptstacktrace
            return
        }

        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Filter = "Excel files (*.xlsx)|*.xlsx|All Files (*.*)|*.*"
        Write-Verbose "File dialog initialized with filter settings."
        Write-Debug "File dialog filter set to: $($dialog.Filter)"
        Write-Log -logEntry "File dialog initialized with filter settings."

        # Set the initial directory based on the environment
        if ($devParser -eq 'off') {
            $dialog.InitialDirectory = $modConfig.SaveDirStr
        }
        else {
            $dialog.InitialDirectory = "C:\Users\$env:USERNAME\Downloads"
        }
        Write-Verbose "Initial directory set to $($dialog.InitialDirectory)."
        Write-Log -logEntry "Initial directory set to $($dialog.InitialDirectory)."

        # Set the default file name and show the dialog
        $dialog.FileName = $modConfig.GetFileName($classNumber)

        try {
            $dialogResult = $dialog.ShowDialog()
        } catch {
            $errorMessage = "Failed to show SaveFileDialog. Using default directory and file name."
            Write-Host $errorMessage
            Write-Log -logEntry $errorMessage
            Handle-Error -errorMessage "$errorMessage Error details: $_" -donotexit $_.scriptstacktrace
            return
        }
        Write-Verbose "SaveFileDialog shown."
        Write-Debug "SaveFileDialog result: $dialogResult"
        Write-Log -logEntry "SaveFileDialog shown. Result: $dialogResult."

        if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
            # Retrieve the selected path and file name
            $selectedPath = [System.IO.Path]::GetDirectoryName($dialog.FileName)
            $selectedFileName = [System.IO.Path]::GetFileName($dialog.FileName)
            Write-Verbose "User selected file: $($dialog.FileName)."
            Write-Debug "Selected path: $selectedPath, selected file name: $selectedFileName"
            Write-Log -logEntry "User selected file: $($dialog.FileName)."

            try {
                if (-Not (Test-Path -Path $selectedPath)) {
                    # Directory does not exist, use default values
                    $errorMessage = "The selected directory does not exist. Using the default directory: $($modConfig.SaveDirStr) and file name: $($modConfig.GetFileName($classNumber))."
                    Write-Host $errorMessage
                    Write-Verbose "Selected directory does not exist. Reverting to default directory and file name."
                    Write-Log -logEntry $errorMessage
                }
                else {
                    # Update the configuration with the selected path and file name
                    $modConfig.SaveDirStr = $selectedPath
                    $modConfig.SaveFileName = $selectedFileName
                    Write-Verbose "Updated save directory to $selectedPath and file name to $selectedFileName."
                    Write-Log -logEntry "Updated save directory to $selectedPath and file name to $selectedFileName."
                }
            } catch {
                $errorMessage = "Error checking or updating path. Using default directory and file name."
                Write-Host $errorMessage
                Write-Log -logEntry $errorMessage
                Handle-Error -errorMessage "$errorMessage Error details: $_" -donotexit $_.scriptstacktrace
            }
        }
        else {
            # File save operation was canceled
            $errorMessage = "File save operation was canceled. Using default directory: $($modConfig.SaveDirStr) and file name: $($modConfig.GetFileName($classNumber))."
            Write-Host $errorMessage
            Write-Verbose "File save operation was canceled. Using default directory and file name."
            Write-Log -logEntry $errorMessage
        }
    }
	else {
		$modConfig.SaveFileName = $filename
	}
}


# Log script start
Write-Log "Script started."
Write-Verbose "Verbose logging is $VerbosePreference."
Write-Log "Verbose logging is $VerbosePreference."
Write-Debug "Debug logging is $DebugPreference."
Write-Log "Debug logging is $DebugPreference."

# Clear the screen
if ( $devParser -ne "off" ) {
	Clear-Host
	Write-Verbose "Screen cleared."
	write-Log "Screen cleared."
}

# Set debugging and verbosity preferences
$VerbosePreference = if ($debugParser -eq "full") { "Continue" } elseif ($debugParser -eq "on" -or $devParser -ne "off") { "Continue" } else { "SilentlyContinue" }
$DebugPreference = if ($debugParser -eq "full") { "Inquire" } elseif ($debugParser -eq "on" -or $devParser -ne "off") { "Continue" } else { "SilentlyContinue" }

# Define path for saving modules
$saveModuleParentPath = if ($devParser -eq "home") { "D:\projects\TestParser2\Modules" } else { "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser2\Modules" }
$ImportExcelPath = "S:\Inst\Projects\VM-Builder\Modules"
Write-Verbose "Module parent path set to $saveModuleParentPath."
Write-Log "Module parent path set to $saveModuleParentPath."

# Load necessary modules
Write-Verbose "Loading modules..."
Write-Log "Loading modules..."
if ($devParser -eq "home") {
    Load-Modules $ImportExcelPath $saveModuleParentPath  -DevAtHome
} else {
    Load-Modules $ImportExcelPath $saveModuleParentPath 
}


# Retrieve user data
Write-Verbose "Retrieving user data..."
Write-Log "Retrieving user data..."
$user = Get-EtcUser -force
if (-not $user) {
    Write-Host "The ETC user was not loaded correctly. Please try again."
	exit 0
}

# Fetch course data
Get-EtcCourseData | Out-Null
$courses = $user.courses | Where-Object { $_.fullname -Match "Test" -and $_.retired -eq $false } | Sort-Object
if (-not $courses) {
    Handle-Error -errorMessage "Failed to find any courses assigned to the user." $PSCmdlet.MyInvocation.ScriptLineNumber
}

# Read module number and import configuration
$modNumber = Read-modNumber
Write-Log "Module number read as $modNumber."
try {
    $ModConfig = Import-ModConfiguration -modNumber $modNumber
    if (-not $ModConfig) {
        throw "`$ModConfig is '$null' after Importing."
    }
}
catch { 
    Handle-Error -errorMessage "Critical error loading the module configuration. (Error from Import-ModConfiguration: $_)." $_.scriptstacktrace
}

# Find the course matching the module number
$course = $courses | Where-Object { $_.fullname -Match "^$modNumber" -and -not $_.retired }
if (-not $course) {
    Handle-Error -errorMessage "A course for the module $modNumber could not be found." $PSCmdlet.MyInvocation.ScriptLineNumber
}
elseif ( $course.count -ne 1 ) {
	Handle-Error -errorMessage "Found more than a single course for $modNumer.  Exiting." $PSCmdlet.MyInvocation.ScriptLineNumber
}

# Retrieve quiz data for the course
Get-EtcQuizData -courseid $course.id | Out-Null
try {
    $quiz = $course.quizzes[0]
}
catch {
    Handle-Error -errorMessage "A quiz for course $($course.fullname) could not be found." $_.scriptstacktrace
}

# Retrieve group data for the course
Try {
    Get-EtcGroupData -courseid $course.Id
}
catch { 
    Handle-Error -errorMessage "Error loading group data. Get-EtcGroupData error: $_" $_.scriptstacktrace
}

# Process class numbers and select a unique group
$group = $null
while (-not $group) {
    $classNumber = Read-ClassNumber
    Write-Log "Class number read as $classNumber."
    
    if ($classNumber -eq 99999 -and $modNumber -eq 3) {
        $classNumber = "24440"
    }
    elseif ($classNumber -eq 99999 -and $modNumber -eq 10) {
        $classNumber = "24300"
    }
    
    $group = Select-UniqueGroup -classNumber $classNumber -groups $course.groups
    if ($group) {
        Write-Verbose "Selected group: $($group.name)"
        Write-Log "Selected group: $($group.name)"
        break
    }
    else {
        Write-Host "No groups found containing $classNumber."
        Write-Log "No groups found containing $classNumber."
        $answer = Read-Host "Try entering a new class number (y/N)"
        Write-Log "User response to retry prompt: $answer"
        if ($answer -eq 'N') {
            Handle-Error -errorMessage "No group found for $classNumber." $PSCmdlet.MyInvocation.ScriptLineNumber
        }
    }
}

# Retrieve grade items and process them
try {
    Get-EtcGradeItem -courseid $course.id -groupid $group.id | Out-Null
}
catch { 
    Handle-Error -errorMessage "Error retrieving grade data. Get-EtcGradeItem error: $_" $_.scriptstacktrace
}

# NEW CODE below
Set-SaveLocation
# END OF NEW CODE




Write-Host "The $($group.name) has $($course.gradeitems.Count) tests to process..."
Write-Log "The $($group.name) has $($course.gradeitems.Count) tests to process..."

$gradeCount = 1
foreach ($gradeItem in $course.gradeitems) {
    # Log the grade number and value
    Write-Host "Grade #$gradeCount is $($gradeItem.graderaw)" -NoNewline
    Write-Log "Grade #$gradeCount is $($gradeItem.graderaw)" -NoNewline
    
    # Check if grade is below the passing threshold
    if ($gradeItem.graderaw -lt 74.5 -and $gradeItem.graderaw -ne 0.0 ) {
        Write-Host -ForegroundColor Red "  FAILURE." -NoNewline
        Write-Log "Grade #$gradeCount is $($gradeItem.graderaw). FAILURE."
        Write-Host "--->  Getting test data..."
        Write-Log "Getting test data for grade item."

        try {
            # Retrieve and process test data
            $attemptId = Get-EtcAttemptId -quizid $quiz.id -userid $gradeItem.studentid
            $test = Get-EtcAttemptReview -attemptid $attemptId
            $student = $course.students | Where-Object -Property userid -eq $gradeItem.studentid
            New-TestResults -test $test -student $student -verbose
        }
        catch {
            Handle-Error -errorMessage "Critical error processing grade item for student $($gradeItem.studentid). Error: $_" $_.scriptstacktrace
        }
    }
	else { 
		write-Host
		Write-log " "
	}
	# Increment grade count for the next item
    $gradeCount += 1
}


# Prompt user to close the script
Read-Host -Prompt "Press Enter to close"
Write-Log "User prompted to close the script."

# Log script completion
Write-Log "Script finished."
