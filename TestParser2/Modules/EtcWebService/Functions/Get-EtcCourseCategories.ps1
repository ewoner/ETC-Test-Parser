<#
.SYNOPSIS
    Retrieves course categories from the ETC web service.
.DESCRIPTION
    This function fetches course categories from the ETC web service and updates the script's data with the fetched categories.
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

function Get-EtcCourseCategories {
    [CmdletBinding()]
	param()
	
	$user = $script:user
	$token = $user.token
	$wsFunction = 'local_intelliboard_course_get_categories'
	#$etcData = $script:etcData
	
	if( -not $user ) {
		Write-host "You must first run 'Get-EtcUser'."
		return
	}
	if ( -not $token ) {
		Write-Host "User does not have a token.  Please call 'Get-EtcToken'".
		return
	}
	if ( $script:etcData.courseCategories.length -gt 0 ) {
		return $script:etcData.courseCategories
	}
	
	$response = Invoke-ETCRestMethod -wsfunction $wsFunction
	foreach ( $item in $response ) {
		if ( $item.path -match "/3/" -or $item.id -eq 3 ) {
			$category = [EtcCourseCategory]::new($item.id, $item.name, $true)
		}
		else {
			$category = [EtcCourseCategory]::new($item.id, $item.name)
		}
		$script:etcData.courseCategories += $category
	}
	return $script:etcData.courseCategories
}