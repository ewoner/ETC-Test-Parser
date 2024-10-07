<#
.SYNOPSIS
    Retrieves grade information for a specific course, group, and student from Moodle.
.DESCRIPTION
    This function fetches grade items for a given course and optionally filters by group and student ID. It processes the response to return a collection of student grade information.
.PARAMETER courseid
    The ID of the course for which to retrieve grade information.
.PARAMETER groupid
    Optional parameter to filter grades by group ID.
.PARAMETER studentid
    Optional parameter to filter grades by student ID.
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

function Get-EtcGrade {
    param(
        [int]$courseid,
        [int]$groupid,
        [int]$studentid
    )
    
    $wsFunction = 'gradereport_user_get_grade_items'
    
    # Check if course ID is provided
    if (-not $courseid) {
        Write-Host "Must supply a course ID to use Get-EtcGrade."
        return
    }
    
    # Prepare parameters for the web service call
    $param = @{ courseid = $courseid }
    if ($groupid) {
        $param.Add("groupid", $groupid)
    }
    if ($studentid) {
        $param.Add("userid", $studentid)
    }

    # Debug message for parameters
    Write-Debug "Calling web service function '$wsFunction' with parameters: $param"
    
    # Call the web service to get the grade information
    $response = Invoke-EtcRestMethod -wsFunction $wsFunction -Parameters $param
    
    # Process the response
    if ($response) {
        $students = @()
        $response.usergrades | ForEach-Object {
            Write-Debug "Processing grade data for student ID $($_.userid)"
            [EtcStudent]$student = [EtcStudent]::new($_.userid, $_.userfullname, $groupid)
            $students += $student
        }
        Write-Verbose "Processed grades for $($students.Count) students."
        return $students
    } else {
        Write-Verbose "No grades found for the specified parameters."
        return @()
    }
}
