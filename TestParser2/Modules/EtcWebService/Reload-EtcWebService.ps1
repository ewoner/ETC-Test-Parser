<#
.SYNOPSIS
    Reloads the EtcWebService module, sets aliases, and retrieves user and course data.

.DESCRIPTION
    This script sets the location to the EtcWebService module path, imports the module with force, sets up useful aliases, retrieves user data, and, if the user data is valid, retrieves course and quiz data from the EtcWebService module.

.PARAMETER None
    No parameters are required for this script.

.EXAMPLE
    .\Reload-EtcWebService.ps1

.NOTES
    Author: Brion Lang
    Date: 08/01/2024
#>

[CmdletBinding()]
param ()

# Set location to the EtcWebService module directory
if ( $PSCmdlet.ShouldProcess( "Set Location and Import Module" ) ) {
    Write-Host "Setting location to module path and importing EtcWebService module"
    Set-Location -Path "C:\Users\Brion.Lang\Documents\WindowsPowerShell\Modules\EtcWebService\"
    Import-Module EtcWebService -Force
	Import-Module TestParser -force
    Write-Host "Module EtcWebService imported successfully"
}

# Set up useful aliases
if ( $PSCmdlet.ShouldProcess( "Set Aliases" ) ) {
    Write-Host "Setting up aliases"
    Set-Alias -Name np -Value 'C:\Program Files\Notepad++\notepad++.exe'
    Set-Alias -Name ier -Value Invoke-EtcRestMethod
    Write-Host "Aliases set: np for Notepad++ and ier for Invoke-EtcRestMethod"
}

# Retrieve user data
if ( $PSCmdlet.ShouldProcess( "Retrieve User Data" ) ) {
    Write-Host "Retrieving user data"
    $user = Get-EtcUser
    if ( $user -ne $null ) {
        Write-Host "User data retrieved: $($user.UserName)"
        
        # Retrieve course and quiz data only if user data is valid
        if ( $PSCmdlet.ShouldProcess( "Retrieve Course and Quiz Data" ) ) {
            Write-Host "Retrieving course and quiz data"
            Get-EtcCourseData | Out-Null
            $course = $user.courses[0]
            Write-Host "Course data retrieved for course: $($course.CourseName)"
            
            Get-EtcQuizData -All
            $quiz = $course.quizzes[0]
            Write-Host "Quiz data retrieved for quiz: $($quiz.QuizName)"
			Get-EtcGradeItem -courseid 1249 -Classname 24320
			Write-Host "Grade Items retrieved for Cousrse: $($course.fullname)"
			$student = $course.students | ? -Property fullname -match "spencer$"
			$gradeItem = $course.gradeitems |? -Property studentid -eq $student.userid
			$id = Get-EtcAttemptid -quizid $quiz.id -userid $student.userid
			$review = Get-EtcAttemptReview -attemptid $id
        }
    } else {
        Write-Error "Failed to retrieve user data."
    }
}
