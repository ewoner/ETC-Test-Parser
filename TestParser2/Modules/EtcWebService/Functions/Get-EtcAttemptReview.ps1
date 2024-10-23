<#
.SYNOPSIS
    Retrieves the review information for a specific quiz attempt from the ETC web service.
.DESCRIPTION
    This function calls the web service to get detailed review data for a quiz attempt, and optionally returns raw data.
.VERSION
    2.0.0-dev1
.FILE_VERSION
    1.0.0-dev1-240815
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
#>

function Get-EtcAttemptReview {
	[cmdletbinding()]
	param(
        [int]$attemptid,
        [switch]$raw
    )
    
    $wsFunction = "mod_quiz_get_attempt_review"
    $parms = @{ attemptid = $attemptid }
    $response = Invoke-EtcRestMethod -wsFunction $wsFunction -Parameters $parms
    
    if ($raw) {
        return $response
    }
    
    [EtcQuestion[]]$questions = @()
    foreach ($question in $response.questions) {
        $questions += [EtcQuestion]::new($question.html, $question.mark, $question.maxmark, $question.status)
    }
    
    $Test = [EtcTest]::new($response.attempt.id, $response.grade, $questions)
    return $Test
}
