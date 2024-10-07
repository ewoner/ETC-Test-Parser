<#
.SYNOPSIS
    Retrieves quiz data for specified courses from Moodle.
.DESCRIPTION
    This function fetches quiz data for either a single course, all courses, or multiple specified courses. It supports options to force-refresh the data and return raw responses.
.PARAMETER courseid
    The ID of the course for which to retrieve quiz data. Required for the 'SingleCourse' parameter set.
.PARAMETER All
    Switch parameter to retrieve quiz data for all courses. Used in the 'AllCourses' parameter set.
.PARAMETER courseids
    Array of course IDs for which to retrieve quiz data. Required for the 'MultipleCourses' parameter set.
.PARAMETER force
    Switch parameter to force-refresh quiz data, clearing any existing quizzes.
.PARAMETER raw
    Switch parameter to return raw web service responses instead of processing them into objects.
.VERSION
    1.0.0-dev1
.FILE_VERSION
    1.0.0-dev1-240815
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
#>

function Get-EtcQuizData {
	[CmdletBinding(DefaultParameterSetName = 'SingleCourse')]
    param (
        [Parameter(ParameterSetName = 'SingleCourse', Mandatory = $true)]
        [int]$courseid,

        [Parameter(ParameterSetName = 'AllCourses', Mandatory = $true)]
        [switch]$All,

        [Parameter(ParameterSetName = 'MultipleCourses', Mandatory = $true)]
        [int[]]$courseids,
		
		[switch]$force,
		[switch]$raw
    )
    $courses = $script:user.courses
	$user = $script:user
	
	$wsfunction = "mod_quiz_get_quizzes_by_courses"
	
	[int[]]$coursesToGet = @()
	
    switch ($PSCmdlet.ParameterSetName) {
        'SingleCourse' {
			Write-Host "Retrieving quiz data for course ID: $courseid"
			$coursesToGet +=  $courseid
        }
        'AllCourses' {
            Write-Host "Retrieving quiz data for all courses"
            $coursesToGet +=  $courses.id
        }
        'MultipleCourses' {
            Write-Host "Retrieving quiz data for course IDs: $($courseids -join ', ')"
            $coursesToGet += $courseids
        }
        default {
            throw "Invalid parameter set."
        }
    }
	if ( $force ) {
		foreach ( $item in $courses ) {
			$item.quizzes = @()
		}
	}
	$count = 0
	$courseidsHT = @{}
	foreach ( $id in $coursesToGet ) {
		if ( $id -in $($courses.id) ) {
			$course = $courses | Where-object -property id -eq $id
			if ( $force ) {
				$course.quizzes = @()
			}
			if ( $course.quizzes.length -eq 0 ) {
				$courseidsHT.add( "courseids[$count]", $id )
				$count += 1
			}
		}
	}
	if ( $count -gt 0 ) {
		$response = Invoke-EtcRestMethod -wsfunction $wsfunction -Parameters $courseidsHT
		if ( $raw ) {
			return $response
		}
		foreach ( $item in $response.quizzes ) {
			$quiz = [EtcQuiz]::new($item.id,$item.coursemodule,$item.course, $item.name,$item.visible)
			foreach( $course in $courses ) {
				if ( $course.id -eq $quiz.course ) {
					$course.addQuiz( $quiz )
					$quiz = $null
					break
				}
			}
			if ( $quiz ) {
				throw "$($Quiz.name) is not assigned to a course.id ($($quiz.course)) of the current user!  Get-EtcQuizData stopped!"
			}
		}
	}
	return 
}