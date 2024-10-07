function Analyze-Test {
    param (
        [int] $attemptid,
        [int] $quizid,
        [int] $studentid
    )

    # Variables that may need initialization
    $filesToParseStr = "C:\path\to\files\" # Example initialization, update as needed
    $nameRegexStr = "some-regex" # Example initialization, update as needed
    $endOfQuestionRegexStr = "some-end-regex" # Example initialization, update as needed
    $IncorrectQuestionRegexStr = "some-incorrect-regex" # Example initialization, update as needed
    $objRegexStr = "some-obj-regex" # Example initialization, update as needed
    $numOfObj = 10 # Example initialization, update as needed

    $fileParsingObj = get-childItem -path $filesToParseStr
    $objTallies = @()
    $objTotals = @()
    $missedQuestions = @()

    for ( $index = 0; $index -le $numOfObj; $index += 1 ) {
        $objTallies += 0
        $objTotals += 0
    }

    $questionStr = ""
    $foundName = $false
    $nameStr = "UNKNOWN"
    
    try {
        $htmlFileContent = Get-Content -path $fileParsingObj.FullName
    }
    catch {
        Write-Error "Error opening the file $fileParsingObj for reading.\nProgram exiting."
        pause
        Stop-Transcript
        return 2
    }

    $questionLineCount = 0
    $fileLineCount = 0
    $numOfFoundQuestions = 0
    
    foreach ( $line in $htmlFileContent) {
        $objNum = 0
        $line = $line.replace(""+[char]194,"").replace("&nbsp;"," ")
        $fileLineCount += 1

        if ( $foundName -eq $false -and ( $line | select-string -pattern $nameRegexStr -quiet ) ) {
            $questionStr += $line
            $nameMatches = $line | select-string -pattern $nameRegexStr
            $nameStr = $nameMatches.Matches[0].Groups[1]
            $foundName = $true
        }
        elseif ( $line -match $endOfQuestionRegexStr ) {
            $numOfFoundQuestions += 1
            $IncorrectQuestion = $questionStr | Select-String -pattern $IncorrectQuestionRegexStr -Quiet
            $objStr = $questionStr | select-string -pattern $objRegexStr
            
            try {
                $objNum = [int]($objStr.Matches[0].groups[2].value)
            }
            catch {
                if ( $IncorrectQuestion ) {
                    write-Error "Did not parse an objective number."
                    write-host "`nIf the Objective number can not be made out, please enter 0.`nThis will be flagged in the output files and not effect the tallies of any other questions.`n`n"
                    write-host -foreground blue -background yellow ($questionStr | Select-string -pattern "\b(Objective[:\W]+(\w+[, ]*)+)\b").matches[0].groups[1]
                    write-host "`n"
                    $objNum = [int](Read-host "Enter correct Objective Number or '0'")
                }
                else {
                    $objNum = 0
                }
            }

            if ($objNum -gt 0 -and $objNum -le $numOfObj ) {
                $objTallies[$objNum - 1]++
                $objTotals[$objNum - 1]++
            }
            elseif ( $objNum -eq 0 -and $IncorrectQuestion ) {
                $missedQuestions += $questionStr
            }
            $questionStr = ""
        }
        elseif ( $line -match $questionStartRegexStr ) {
            $questionStr = $line
            $questionLineCount += 1
        }
        elseif ( $questionStr -ne "" ) {
            $questionStr += $line
        }
    }

    return @{
        Name = $nameStr
        NumQuestions = $numOfFoundQuestions
        ObjTallies = $objTallies
        ObjTotals = $objTotals
        MissedQuestions = $missedQuestions
    }
}
