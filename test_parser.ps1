
#hardcoded configurations
$Mod = 3
$maxQuestions = 42
$file = ".\test.html"
$ObjectivesNumber = 13
$ObjectivePattern = "Objectives?:\s+$Mod\.(\d+)"
$NamePattern = 'class=""\s*>((\w+[\. ]*){2,})<\/a><\/td><\/tr><tr><th class="cell" scope="row">Started on'
$ObjectiveDisplayStr = "Objective: $Mod."
#code beginning
$Objectives = @()
$Questions = @()
for ( $index = 0; $index -lt $ObjectivesNumber; $index += 1 ) {
    $Objectives += 0;
}

$count = 0;
$htmlCon = Get-Content -path $file
$qCount = 0
$question = ""
$qDone = $false
$foundName = $false
$nameStr = "UNKNOWN"
write-host "Total lines: " $htmlCon.count
foreach ( $line in $htmlCon) {
    if ($FoundName -eq $false -and ($line | select-string -pattern $NamePattern -quiet) ) {
        $nameMatches = $line | select-string -pattern $NamePattern
        $nameStr = $nameMatches.Matches[0].Groups[1]
        $foundName = $true
    }
    elseif ( $line -match "<thead>" ) {
        $qDone = $True
        $count += 1;
    }
    else {
        $question += $line
        
   }
   if ( $qDone -eq $True ) {
       $qCount += 1
       $bad = $question | Select-String -pattern '<div class="state">Incorrect</div>' -Quiet
       if ( $bad ) {
            $Questions += $Question
       }
	   $question = ""
	   $qDone = $false
   }
   if ( $qCount -eq $maxQuestions ) {
    break
   }
}

foreach ( $question in $Questions ) {
		$objStr = $question | select-string -pattern $ObjectivePattern
		$objNum = [int]($objStr.Matches[0].groups[1].value)
        $Objectives[ $objNum-1 ] += 1;
}


write-host "Test Parsed for $nameStr "
write-host "============="
write-host "Incorrect Questions: " $Questions.count
write-host "Total Questions Parsed: " $qCount

$curObj = 1;
$total = 0
foreach ( $objScore in $Objectives ) {
    $total +=  $objScore;
    if ( $curObj -gt 9 ) {
        write-host "$ObjectiveDisplayStr$curObj --> $objScore"
    }
    else {
        write-host "$ObjectiveDisplayStr $curObj --> $objScore"
    }
    $curObj += 1;
}
Write-host "$total"
