<#
.SYNOPSIS
    Retrieves the attempt ID for a given quiz and user from the ETC web service.
.DESCRIPTION
    This function calls the web service to get the attempt ID for a specific quiz and user.
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

function Get-EtcAttemptId {
    param(
        [int]$quizid,
        [int]$userid
    )
    
    $wsFunction = "mod_quiz_get_user_attempts"
    $parms = @{ quizid = $quizid; userid = $userid }
    $response = Invoke-EtcRestMethod -wsFunction $wsFunction -Parameters $parms
    return $response.attempts.id
}
