<#
.SYNOPSIS
    TestParser.ps1
.DESCRIPTION
    This program will read in a number of HTML test report files from ETC and parse the number of questions wrong and compile reports based on the parsing. Current works with both even if the HTML review document only shows the missed questions.
.VERSION
    2.2.0-dev2
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
    File Version: 2.1.0-dev2
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
        - Incorporated parameter handling from Dev 2 for `debugParser` and `devParser` options.
        - Updated debugging and development environment handling.
        - Refined script logic with improvements from Dev 2.
        - Added Select-UniqueGroup function to handle cases where multiple groups match the regex pattern.
        - Updated error handling for user data file and token retrieval.
        - Updated Load-Modules function to exclude copying and unblocking of `ImportExcel` module in "home" environment.
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
# Handle debugging
if ($debugParser -eq "full") {
    $VerbosePreference = "Continue"
    $DebugPreference = "Inquire"
} elseif ($debugParser -eq "on" -or $devParser -ne "off") {
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
} else {
    $VerbosePreference = "SilentlyContinue"
    $DebugPreference = "SilentlyContinue"
}

# Set the parent folder path for saving modules based on the $dev parameter
if ($devParser -eq "home") {
    $saveModuleParentPath = "D:\projects\TestParser2\Modules"
} else {
    $saveModuleParentPath = "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser2\Modules"
}
Write-Verbose "Module parent path set to $saveModuleParentPath."

function Get-Label {
    param (
        [int]$index  # Index to convert to a label
    )

    Write-Verbose "Generating label for index $index."

    $letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $label = ""

    do {
        # Determine the current character to add to the label
        $currentChar = $letters[$index % 26]
        $label = $currentChar + $label

        # Update the index for the next iteration
        $index = [math]::Floor($index / 26) - 1

        Write-Debug "Current label: $label, Updated index: $index"
    } while ($index -ge 0)

    Write-Verbose "Generated label: $label."
    Write-Debug "Final label: $label"

    return $label
}

function Select-UniqueGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$groups,  # Array of EtcGroup objects

        [Parameter(Mandatory = $true)]
        [string]$classNumber  # Class number to match group names
    )

    Write-Verbose "Selecting unique group with class number $classNumber from $($groups.Count) groups."

    # Retrieve the matching groups
    $matchingGroups = $groups | Where-Object { $_.name -match $classNumber }

    # Check the number of matching groups
    if ($matchingGroups.Count -eq 1) {
        # Only one match, select it
        Write-Verbose "One group found matching the class number: $($matchingGroups[0].name)"
        Write-Debug "Returning the group: $($matchingGroups[0].name)"
        return $matchingGroups[0]
    } elseif ($matchingGroups.Count -gt 1) {
        # Multiple matches, prompt user to select one
        $counter = 0
        $menuOptions = @()

        foreach ($group in $matchingGroups) {
            $label = Get-Label -index $counter
            $menuOptions += [PSCustomObject]@{ Label = $label; Group = $group }
            $counter++
        }

        # Add Quit option to the menu
        $menuOptions += [PSCustomObject]@{ Label = "0"; Group = $null; Description = "Quit" }

        do {
            Write-Host "Multiple groups match the class number. Please select one:"
            
            # Display menu options
            foreach ($option in $menuOptions) {
                if ($option.Description) {
                    Write-Host "$($option.Label): $($option.Description)"
                } else {
                    Write-Host "$($option.Label): $($option.Group.name)"
                }
            }

            $selectedLabel = Read-Host "Enter the label of the group you want to use"

            # Check if the selected label matches any menu option
            $selectedOption = $menuOptions | Where-Object { $_.Label -eq $selectedLabel }

            if ($selectedOption) {
                if ($selectedOption.Group) {
                    Write-Verbose "User selected group: $($selectedOption.Group.name)"
                    Write-Debug "Returning the group: $($selectedOption.Group.name)"
                    return $selectedOption.Group
                } else {
                    Write-Host "Quitting selection process."
                    Write-Debug "User selected Quit option."
                    return $null
                }
            } else {
                Write-Host "Invalid selection. Please choose a valid label."
                Write-Debug "User made an invalid selection: $selectedLabel"
            }
        } while ($true)
    } else {
        # No matches found
        Write-Host "No groups found matching the class number: $classNumber"
        Write-Debug "No groups found for class number: $classNumber"
        return $null
    }
}



# Function to load modules
function Load-Modules {
    # Define the parent path for the modules on the network drive
    $saveModuleParentPath = "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser2\Modules"
    
    # Define the specific path for the ImportExcel module
    $ImportExcelPath = "S:\Inst\Projects\VM-Builder\Modules"
    
    # Define the modules to be loaded with their paths
    $modules = @(
        @{ Name = "ImportExcel"; Path = "$ImportExcelPath\ImportExcel" },
        @{ Name = "EtcWebService"; Path = "$saveModuleParentPath\EtcWebService" },
        @{ Name = "TestParser"; Path = "$saveModuleParentPath\TestParser" }
    )
    
    foreach ($module in $modules) {
        $destinationPathName = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\$($module.Name)"
        
        Try {
            # Check if the module already exists locally; if not, copy it from the network drive
            if (-not (Test-Path -Path $destinationPathName)) {
                # Copy the module from the network drive to the local directory
                Copy-Item -Path $module.Path -Destination $destinationPathName -Recurse -ErrorAction Stop
                
                # Log the successful copy operation
                Write-Verbose "Copied module $($module.Name) to $destinationPathName"
                Write-Debug "Module copied from $($module.Path) to $destinationPathName"
            } else {
                # Log that the module already exists
                Write-Verbose "Module $($module.Name) already exists at $destinationPathName"
                Write-Debug "Skipped copying $($module.Name) because it already exists"
            }

            # Unblock all files in the EtcWebService and TestParser module folders
            if ($module.Name -eq "EtcWebService" -or $module.Name -eq "TestParser") {
                Write-Verbose "Unblocking files in module $($module.Name)..."
                Get-ChildItem -Path $destinationPathName -Recurse | Unblock-File -ErrorAction Stop
                Write-Verbose "Unblocked files in module $($module.Name)"
            }
            
            # Import the module into the current session
            Import-Module $module.Name -Force -ErrorAction Stop
            
            # Log the successful import operation
            Write-Verbose "Imported module $($module.Name)"
            Write-Debug "Module $($module.Name) imported successfully"
        }
        Catch {
            # Log the error during copying, unblocking, or importing
            Write-Error "Failed to process module $($module.Name): $_"
            Write-Debug "Error occurred while processing module $($module.Name) with path $($module.Path)"
        }
    }
}


# Clear the screen
Clear-Host
Write-Verbose "Screen cleared."
Write-Verbose "Debug and verbose preferences set: Debug = $DebugPreference, Verbose = $VerbosePreference."

# Example usage of the Load-Modules function
Write-Verbose "Loading modules..."
Load-Modules

# Script logic
Write-Verbose "Retrieving user data..."
$user = Get-EtcUser -force
Get-EtcCourseData | Out-Null
$courses = $user.courses | Where-Object -Property fullname -Match "Test" | Sort-Object
$modNumber = Read-modNumber
Write-Verbose "Module number read as $modNumber."
$ModConfig = Import-ModConfiguration -modNumber $modNumber
$course = $courses | Where-Object -Property fullname -Match "^$modNumber"
Write-Verbose "Retrieved course: $($course.fullname)."
Get-EtcQuizData -courseid $course.id | Out-Null
$quiz = $course.quizzes[0]
Get-EtcGroupData -courseid $course.Id
$classNumber = Read-ClassNumber
Write-Verbose "Class number read as $classNumber."
if ($classNumber -eq 99999) {
    $classNumber = "24440"  # Keeping the original fallback value from Dev 1
}

# Use the new Select-UniqueGroup function to find a unique group
Write-Verbose "Selecting unique group..."
$group = Select-UniqueGroup -classNumber $classNumber -groups $course.groups

# Proceed with further processing if a group was found
if ($group) {
    Write-Verbose "Selected group: $($group.name)"
    Get-EtcGradeItem -courseid $course.id -groupid $group.id | Out-Null
} else {
    Write-Host "No unique group selected/found for class number $classNumber in course $($course.fullname)."
}

foreach ($gradeItem in $course.gradeitems) {
    Write-Verbose "Processing grade item with ID $($gradeItem.id) and grade $($gradeItem.graderaw)."
    Write-Host "Grade is $($gradeItem.graderaw)"
    if ($gradeItem.graderaw -lt 74.50) {
        Write-Host "Getting test...."
        $test = Get-EtcAttemptReview -attemptid $(Get-EtcAttemptId -quizid $quiz.id -userid $gradeItem.studentid)
        $student = $course.students | Where-Object -Property userid -eq $gradeItem.studentid
        Process-test -test $test -student $student -classnumber $classNumber
    }
}

Write-Verbose "$classNumber and $modNumber and $($course.Id) $($course.fullname)"
Read-Host -prompt "Press Enter to close"
