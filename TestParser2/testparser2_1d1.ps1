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
