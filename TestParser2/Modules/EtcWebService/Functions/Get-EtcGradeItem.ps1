<#
.SYNOPSIS
    Retrieves grade items for specified courses from the ETC web service.

.DESCRIPTION
    This function retrieves grade items for specified courses from the ETC web service.
    It supports retrieving grade items for a single course, all courses, or multiple courses.
    If the -Force switch is used, it forces the function to reload the data.
    If the -Raw switch is used, it returns the raw response instead of the processed data.

.PARAMETER courseid
    The ID of the single course to retrieve grade items for. Mandatory in 'SingleCourse' parameter set.

.PARAMETER All
    Retrieves grade items for all courses. Mandatory in 'AllCourses' parameter set.

.PARAMETER courseids
    An array of course IDs to retrieve grade items for. Mandatory in 'MultipleCourses' parameter set.

.PARAMETER Force
    If specified, forces the function to reload the grade items even if they have been previously cached.

.PARAMETER Raw
    If specified, returns the raw response from the ETC web service instead of the processed data.

.NOTES
    You must run 'Get-EtcUser' to authenticate and retrieve the user token before running this function.
    The function 'Invoke-ETCRestMethod' is used to make the web service call.

.EXAMPLE
    PS> Get-EtcGradeItem -courseid 123
    Retrieves grade items for the specified course ID 123.

.EXAMPLE
    PS> Get-EtcGradeItem -All
    Retrieves grade items for all courses.

.EXAMPLE
    PS> Get-EtcGradeItem -courseids 123, 456
    Retrieves grade items for the specified course IDs 123 and 456.

.EXAMPLE
    PS> Get-EtcGradeItem -courseid 123 -Force
    Forces the function to reload the grade items for the specified course ID 123.

.EXAMPLE
    PS> Get-EtcGradeItem -courseid 123 -Raw
    Retrieves the raw response for the specified course ID 123.
#>
function Get-EtcGradeItem {
    [CmdletBinding(DefaultParameterSetName = 'SingleCourse')]
    param (
        [Parameter(ParameterSetName = 'SingleCourse', Mandatory = $true)]
        [int]$courseid,

        [Parameter(ParameterSetName = 'AllCourses', Mandatory = $true)]
        [switch]$All,

        [Parameter(ParameterSetName = 'MultipleCourses', Mandatory = $true)]
        [int[]]$courseids,

        [switch]$Force,
        [switch]$Raw,
		
		[Parameter(ParameterSetName = 'SingleCourse')]
		[int]$groupid,
		[Parameter(ParameterSetName = 'SingleCourse')]
		[int]$ClassName,
		[Parameter(ParameterSetName = 'SingleCourse')]
		[switch]$allgroups
    )
	
	Function Process-Response {
		param(
		[Parameter(Mandatory=$true)]
		$response
		)
		Write-Verbose "Processing response for course ID: $id"
		foreach ($usergrade in $response.usergrades) {
			$student = [EtcStudent]::new( $usergrade.userid, $usergrade.userfullname )
			Write-Debug "Created student: $($student.UserFullName) with ID: $($student.UserID)"
			foreach ($gradeItem in $usergrade.gradeitems) {
				if ( $gradeItem.itemmodule -eq "quiz" ) {
					$grade = [EtcGradeItem]::new($gradeItem.id,$gradeItem.itemName, $gradeItem.iteminstance, $gradeItem.gradeRaw, $student.userid )
					$student.addGradeItem( $grade )
					$course.addGradeItem( $grade )
					Write-Debug "Added grade item ID: $($gradeItem.id) for student: $($student.UserFullName)"
				}
			}
			$course.addStudent($student)
			Write-Verbose "Added student: $($student.UserFullName) with ID: $($student.UserID) to course ID: $id"
		}
		if ( $raw ) {
			return $response
		}
	}

    # Retrieve the user and their courses
    $courses = $script:user.courses
    $user = $script:user

    # Set the web service function name
    $wsfunction = "gradereport_user_get_grade_items"

    # Initialize the list of courses to get
    [int[]]$coursesToGet = @()
	[int[]]$groupsToGet = @()

    Write-Verbose "Determining courses to retrieve based on parameter set."

    # Determine the courses to retrieve based on the parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'SingleCourse' {
            Write-Verbose "Parameter set: SingleCourse"
            Write-Host "Retrieving grade items for course ID: $courseid"
            $coursesToGet += $courseid
			if ( $groupid ) {
				$groupsToGet += $groupId
			}
			elseif ( $allGroups -or $className ) {
				$course = $courses | where-object -property id -eq $courseid
				if ( $force ) {
					$course.groups = @()
				}
				if ( $course.groups.length -eq 0 ) {
					Get-EtcGroupData -courseid $course.id
					foreach ( $group in $course.groups ) {
						if ( -not $className ) {
							$groupsToGet += $group.id
						}
						else {
							if ( $group.name -match $classname ) {
								$groupsToGet += $group.id
							}
						}
					}
				}
				
			}
        }
        'AllCourses' {
            Write-Verbose "Parameter set: AllCourses"
            Write-Host "Retrieving grade items for all courses"
            $coursesToGet += $courses.id
        }
        'MultipleCourses' {
            Write-Verbose "Parameter set: MultipleCourses"
            Write-Host "Retrieving grade items for course IDs: $($courseids -join ', ')"
            $coursesToGet += $courseids
        }
        default {
            Write-Error "Invalid parameter set."
            throw "Invalid parameter set."
        }
    }
	
    Write-Verbose "Processing each course ID to retrieve grade items."
	$rv = ""
    # Process each course ID to retrieve grade items
    foreach ($id in $coursesToGet) {
        Write-Debug "Processing course ID: $id"
        if ($id -in $($courses.id)) {
            $course = $courses | Where-Object -Property id -EQ $id
            Write-Verbose "Found course with ID: $id"

            # Force reload if the -Force switch is used
            if ($Force) {
                Write-Verbose "Force reload enabled. Clearing existing students and grade items."
                $course.students = @()
                $course.gradeitems = @()
            }

            # If students are not already loaded, retrieve them
            if ($course.students.Length -eq 0) {
                Write-Verbose "Students not loaded for course ID: $id. Retrieving data from web service."
				$parms = @{ courseid = $course.id }
				if ( $groupsToGet ) {
						foreach ( $groupid in $groupsToGet ) {
							$parms.add("groupid", $groupID )
							$response = Invoke-ETCRestMethod -wsfunction $wsfunction -Parameters $parms
							$rv = Process-Response ( $response )
						}
				}
				else {
					$response = Invoke-ETCRestMethod -wsfunction $wsfunction -Parameters $parms
					$rv = Process-Response ( $response )
				}
            } else {
                Write-Verbose "Students already loaded for course ID: $id"
            }
        } else {
            Write-Warning "Course ID: $id not found in user's courses."
        }
    }
    # Return processed data
    return $coursesToGet | ForEach-Object { $courses | Where-Object -Property id -EQ $_ }
}



<#  Older code prior to ChatGPT's input.



function Get-EtcGradeItem {
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
	
	$wsfunction = "gradereport_user_get_grade_items "
	
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
	$rv = @()
	foreach ( $id in $coursesToGet ) {
		if ( $id -in $($courses.id) ) {
			$course = $courses | Where-object -property id -eq $id
			if ( $force ) {
				$course.students = @()
				$course.gradeitems = @()
			}
			if ( $course.students.length -eq 0 ) {
				$response = Invoke-EtcRestMethod -wsfunction $wsfunction -Parameters @{ courseid = $course.id }
				if ( $raw ) {
					$rv += $response
				}
				foreach ( $item in $response ) {
					$student = [EtcStudent]::new($item.userfullname, $item.userid)
					foreach ( $gradeItem in $item.gradeitems ) {
						$grade = [EtcGradeItem]::new()
						$student.addGradeItem( $gradeItem.id, $gradeItem.iteminstance, $gradeItem.gradeRaw )
					}
					$course.addStudent( $student )
				}
			}
		}
	}
	if ( $raw ) {
		return $rv
	}
	return 

}
#>