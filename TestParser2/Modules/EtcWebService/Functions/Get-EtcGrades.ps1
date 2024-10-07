Function Get-EtcGrade {
	param(
		[int]$courseid,
        [int]$groupid,
        [int]$studentid
	)
	$wsFunction = 'gradereport_user_get_grade_items'
	if ( -not $courseid ) {
		write-host "Must supply a course ID to use Get-Groups"
		return
	}
    if ( -not $goupdid -and -not $studentid ) {
        Write-host "Either a group id or student id must be supplied."
        return
    }

    $param = @{courseid = $courseid}

    if ( $groupid ) {
        $param.Add("groupdid",$groupid)
    }
    if ( $studentid ) {
        $param.add("userid",$studentid)
    }

	
	$response = Invoke-EtcRestMethod -wsfunction $wsFunction -Parameters $param
	
	return $response
}
<#
$wsFuncParams = @{
    wstoken = ConvertTo-String $user.token
    moodlewsrestformat = "json"
}
$wsFuncParams.wsfunction = 'core_group_get_course_groups'
$wsfuncParams.courseid = $test.id

$results = Invoke-WebRequest -uri $service.serverURL -Method Get -Body $wsFuncParams
$jResults = ConvertFrom-Json $results.Content
$test.groups = @()
$jResults | ForEach-Object {  $group = @{ groupid = $_.id; name = $_.name }; $test.groups += $group  }

write-Debug "Getting Grades for Class"
$wsFuncParams = @{
    wstoken = ConvertTo-String $user.token
    moodlewsrestformat = "json"
}
$wsFuncParams.wsfunction = $ws_f_get_gradeItems
$wsfuncParams.courseid = $test.id
$group = $test.groups | Where-Object -Property name -eq $classNumber
$wsfuncParams.groupid = $group.groupid

$results = Invoke-WebRequest -uri $service.serverURL -Method Get -Body $wsFuncParams
$jResults = ConvertFrom-Json $results.Content 

$students = $( $jResults.usergrades |  ForEach-Object { @{ fullname = $_.userfullname; userid = $_.userid; gradeitems = $( $_.gradeitems | foreach { $_ | where-object { $_.id -eq $( $test.gradeitems )  -and $_.graderaw -lt 75.0 } }  )  } } ) | Where-Object {$_.gradeitems.length -ne 0  } 

write-Debug "Getting failed attempts by student"
foreach ( $student in $students ) {
    $wsFuncParams = @{
        wstoken = ConvertTo-String $user.token
        moodlewsrestformat = "json"
    }
    $wsFuncParams.wsfunction = $ws_f_get_Attempts
    $wsfuncParams.userid = $student.userid
    $wsfuncParams.quizid = $student.gradeitems.iteminstance

    $results = Invoke-WebRequest -uri $service.serverURL -Method Get -Body $wsFuncParams
    $jResults = ConvertFrom-Json $results.Content
    $stuend.attemps = $jResults.attempts

}
foreach ( $student in $students ) {
    $wsFuncParams = @{
        wstoken = ConvertTo-String $user.token
        moodlewsrestformat = "json"
    }
    $wsFuncParams.wsfunction = $ws_f_get_Attempt
    $wsfuncParams.userid = $student.userid
    $wsfuncParams.quizid = $student.gradeitems.iteminstance

    $results = Invoke-WebRequest -uri $service.serverURL -Method Get -Body $wsFuncParams
    $jResults = ConvertFrom-Json $results.Content
    $student.attemps = $jResults.attempts
    foreach ( $attempt in $student.attempts ) {
         $wsFuncParams = @{
            wstoken = ConvertTo-String $user.token
            moodlewsrestformat = "json"
        }
        $wsFuncParams.wsfunction = $ws_f_get_Attempt
        $wsfuncParams.attemptid = $attempt.id
        

        $results = Invoke-WebRequest -uri $service.serverURL -Method Get -Body $wsFuncParams
        $jResults = ConvertFrom-Json $results.Content
        $student.review = $jResults[0]
        $student.questions = $jResults.questions
        $student.wrongAnswers = $jResults.questions | foreach { $_.mark } | where { $_ -eq 1 }
    }

}


write-Debug "Parsing Tests by student"




write-Debug "Writting Output files"


#====================================================================================
# Script Clean up
#====================================================================================
Write-Debug "Program ending sucessfull."
$DebugPreference = $oldDebugPreference
$VerbosePreference = $oldDebugPreference
Stop-Transcript

#>