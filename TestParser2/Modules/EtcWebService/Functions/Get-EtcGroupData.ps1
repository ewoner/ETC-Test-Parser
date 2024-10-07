<#
.SYNOPSIS
    Retrieves group data for specified courses from Moodle.
.DESCRIPTION
    This function fetches group data for either a single course, all courses, or multiple specified courses. It supports options to force-refresh the data and return raw responses.
.PARAMETER courseid
    The ID of the course for which to retrieve group data. Required for the 'SingleCourse' parameter set.
.PARAMETER All
    Switch parameter to retrieve group data for all courses. Used in the 'AllCourses' parameter set.
.PARAMETER courseids
    Array of course IDs for which to retrieve group data. Required for the 'MultipleCourses' parameter set.
.PARAMETER force
    Switch parameter to force-refresh group data, clearing any existing groups.
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

function Get-EtcGroupData {
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
    $wsfunction = "core_group_get_course_groups"
    
    [int[]]$coursesToGet = @()
    
    # Determine which courses to retrieve based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'SingleCourse' {
            Write-Verbose "Retrieving Group data for course ID: $courseid"
            $coursesToGet += $courseid
        }
        'AllCourses' {
            Write-Verbose "Retrieving Group data for all courses"
            $coursesToGet += $courses.id
        }
        'MultipleCourses' {
            Write-Verbose "Retrieving Group data for course IDs: $($courseids -join ', ')"
            $coursesToGet += $courseids
        }
        default {
            throw "Invalid parameter set."
        }
    }
    
    # Initialize array for raw responses
    $rv = @()
    
    # Process each course ID
    foreach ($id in $coursesToGet) {
        if ($id -in $($courses.id)) {
            $course = $courses | Where-Object -Property id -eq $id
            
            # If force-refresh is requested, clear existing groups
            if ($force) {
                Write-Verbose "Forcing refresh of groups for course ID: $id"
                $course.groups = @()
            }
            
            # Retrieve and process group data if not already present
            if ($course.groups.Count -eq 0) {
                Write-Debug "Fetching group data for course ID: $id"
                $response = Invoke-EtcRestMethod -wsFunction $wsfunction -Parameters @{ courseid = $course.id }
                
                if ($raw) {
                    $rv += $response
                }
                
                foreach ($item in $response) {
                    Write-Debug "Processing group ID: $($item.id) with name: $($item.name)"
                    $group = [EtcGroup]::new($item.id, $item.name)
                    $course.addGroup($group)
                }
            }
        }
    }
    
    # Return raw response if requested
    if ($raw) {
        Write-Verbose "Returning raw response data."
        return $rv
    }
    
    Write-Verbose "Group data retrieval completed."
    return
}
