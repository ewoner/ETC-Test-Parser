<#
.SYNOPSIS
    Retrieves course data for a user from the ETC web service.
.DESCRIPTION
    This function fetches course data for a specific user from the ETC web service and updates the user’s course list.
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

function Get-EtcCourseData {
    [CmdletBinding()]
    param ()
    $user = $Script:user
	$userid = $script:user.userid
	$token = $script:user.token
	
	if ( -not $user ) {
		write-host "No user.  Please call 'Get-EtcUser'"
		return
	}		
	if ( -not $token ) {
		write-host "User does not have a token.  A call to 'Get-EtcToken' is needed before you can use this cmdlet."
		return
	}	
	if ( -not $userid -or $userid -le 0 ) {
		Write-host "User's 'userid' is not valid or missing.  Please call 'Get-EtcSiteInfo'."
		return
	}
	if ( $script:user.courses.length -gt 0 ) {
		return $script:user.courses
	}
	# Moodle Web service function to call
	$functionName = 'core_enrol_get_users_courses'
	Get-EtcCourseCategories
	# Invoke the Moodle Web service using Invoke-ETCRestMethod
	$response = Invoke-ETCRestMethod -wsfunction $functionName -Parameters @{ userid = $userid; returnusercount = 0 }
	
	if ( $response ) {
		foreach ( $item in $response ) {
			$course = [EtcCourse]::new( $item.id, $item.fullname, $item.category )
			$course.retired = (Get-EtcCourseCategories | where-object -property id -eq $item.category).retired
			$script:user.courses += $course
			
		}
	}
	return $script:user.courses
}
