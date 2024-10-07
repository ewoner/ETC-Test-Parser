<#
.SYNOPSIS
    Retrieves a list of courses associated with the current user.
.DESCRIPTION
    This function calls the Moodle web service to fetch the courses that the current user is enrolled in. It processes the response to return a list of `EtcCourse` objects, which include details such as course ID and full name.
.PARAMETER None
    This function does not take any parameters. It uses the `userid` and `token` obtained from the current user's session.
.NOTES
    Ensure that `Get-EtcUser` has been called to set the `$user` and obtain a valid `token` before using this function.
    If the `userid` is not valid or missing, call `Get-EtcSiteInfo` to retrieve the user ID.
.VERSION
    2.0.0-dev1
.FILE_VERSION
    1.0.0-dev1-240815
.AUTHOR
    Brion Lang
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
#>

function Get-EtcCourses {
    [CmdletBinding()]
    param ()
    $user = $Script:user
    $userid = $script:user.userid
    $token = $script:user.token
    
    if ( -not $user ) {
        Write-Host "No user.  Please call 'Get-EtcUser'"
        return
    }        
    if ( -not $token ) {
        Write-Host "User does not have a token.  A call to 'Get-EtcToken' is needed before you can use this cmdlet."
        return
    }    
    if ( -not $userid -or $userid -le 0 ) {
        Write-Host "User's 'userid' is not valid or missing.  Please call 'Get-EtcSiteInfo'."
        return
    }
    # Moodle Web service function to call
    $functionName = 'core_enrol_get_users_courses'
    
    # Invoke the Moodle Web service using Invoke-ETCRestMethod
    $response = Invoke-ETCRestMethod -wsfunction $functionName -Parameters @{ userid = $userid; returnusercount = 0 }
    
    $script:Courses = @()
    if ( $response ) {
        foreach ( $item in $response ) {
            $course = [EtcCourse]::new( $item.id, $item.fullname )
            $script:Courses += $course
        }
    }
    return $script:Courses
}
