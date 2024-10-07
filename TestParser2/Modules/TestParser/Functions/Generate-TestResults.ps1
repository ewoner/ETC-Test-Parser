<#
.SYNOPSIS
Generates test results for a student and finds the objective number of a question based on a regular expression pattern.

.DESCRIPTION
This function processes a test and generates a report for a student. It is part of the TestParser module.

.VERSION
1.0.0

.AUTHOR
Brion Lang

.NOTES
Versioning specification: https://semver.org/
See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.

.PARAMETER test
The test object to process.

.PARAMETER student
The student object associated with the test.

.EXAMPLE
Generate-TestResults -test $testObject -student $studentObject

.INPUTS
System.Management.Automation.PSObject
The test object to process.

System.Management.Automation.PSObject
The student object associated with the test.

.OUTPUTS
System.String
The test results report.

.FUNCTIONALITY
TestParser

.LINK
https://github.com/ewoner/ETC-Test-Parser

.COMPONENT
TestParser

.ROLE
TestParser

#>

function Generate-TestResults {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$test,

        [Parameter(Mandatory = $true)]
        [PSObject]$student
    )

    # Write a warning message to inform users that this cmdlet is deprecated
    Write-Warning "Generate-TestResults is no longer a valid cmdlet and is slated to be removed.  Please send email to Brion.lang@comtechtel when you see this message or update to latest TestParser2.ps1 code."

    # Initialize variables
    $missedQuestions = 0
    $objTallies = @(0) * ($modConfig.NumOfObj + 1)
    $logDir = Join-Path -Path $modConfig.LogDirStr -ChildPath 'Student_Files'
    $nameStr = $student.fullname
    $objectiveStrings = $modConfig.objectives
    $numOfFoundQuestions = $modConfig.MaxNumOfQuestions
    $modNumber = $modConfig.Mod

    # Process the test questions
    $curObjNum = 0
    foreach ($question in $test.questions) {
        Write-Verbose "Processing question: $($question.ToString())"
        $result = Process-Question -question $question
        if ($result -ne -1) {
            $objTallies[$result]++
            $missedQuestions++
        }
    }

    # Prepare strings for output and Excel report
    $excelStr = '"# Missed" ,' + $missedQuestions + ",`"Student Name: `"`n"
    $outputStr = ""
    $disclaimerStr = "To Ensure correct operations, ensure 'Total Questions Parsed' and 'Total Questions Missed' match ETC. If they do not match, there is a parsing issue. Please report this error, along with the student it incorrectly parsed. Thank you, Brion.`n`n"
    $outputHeaderStr = "Test Parsed for $nameStr `n=======================================================================================================`nIncorrect Questions     :  $missedQuestions`nGrade                   :  $(([int](($numOfFoundQuestions - $missedQuestions) / $numOfFoundQuestions * 100.0)))`nTotal Questions Parsed  :  $numOfFoundQuestions ($($modConfig.MaxNumOfQuestions) expected)`n======================================================================================================="

    $outputStr += $disclaimerStr + "`n"
    $outputStr += $outputHeaderStr + "`n"

    $totalnumOfMissedQuestions = ($objTallies | Measure-Object -Sum | Select-Object -ExpandProperty Sum)
    foreach ($objTally in $objTallies) {
        $wingDingChar = if ($objTally -eq 0) { 168 } else { 254 }

        if ($curObjNum -gt 9) {
            $outputStr += "$modNumber.$curObjNum `t--> $objTally`n"
            $excelStr += [string]$objTally + ',' + [char]$wingDingChar + ',"' + $curObjNum + ".  " + $objectiveStrings[$curObjNum - 1] + '"' + "`n"
        } elseif ($curObjNum -eq 0 -and $objTally -ne 0) {
            $outputStr += "`t`tNo Objective Parsed `t--> $objTally`n"
            $outputStr += "`t`t-----------------------------------`n"
            $excelStr += [string]$objTally + ',' + [char]$wingDingChar + ',"' + $curObjNum + ".  " + "Could not Parse" + '"' + "`n"
        } elseif ($curObjNum -gt 0) {
            $outputStr += "$modNumber. $curObjNum `t--> $objTally`n"
            $excelStr += [string]$objTally + ',' + [char]$wingDingChar + ',"' + $curObjNum + ".   " + $objectiveStrings[$curObjNum - 1] + '"' + "`n"
        }
        $curObjNum += 1
    }

    $outputFooterStr = "Total Questions Missed  : $missedQuestions`n======================================================================================================="
    $outputStr += $outputFooterStr

    # Save the text