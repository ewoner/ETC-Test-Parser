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

function Find-QuestionObjectiveNumber {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$question
    )

    # Get the module configuration
    $objModNum = $ModConfig.objModnum
    $objRegexStr = $ModConfig.ObjRegexPattern
    $objNum = 0

    Write-Verbose "Processing question: $($question.html)"

    # Check if the question is correct
    if ($question.correct) {
        Write-Debug "Question is correct, returning -1"
        return -1
    }

    # Search for the objective line in the question HTML
    $objStr = $question.html | Select-String -Pattern $objRegexStr
    if ($objStr -eq $null -or $objStr.Matches.Count -eq 0) {
        Write-Error "No Objective Line found."
        Write-Host -ForegroundColor Blue -BackgroundColor Yellow ($question.html | Select-String -Pattern "\b(Objective[:\W]+(\w+[,. ]*)+)\b").Matches[0].Groups[1]
        Write-Verbose "Prompting user to enter correct objective number"
        $objNum = [int](Read-Host "Enter correct Objective Number or '0'")
    } else {
        try {
            # Check if the objective number matches the expected value
            if ($objModNum -ne [int]($objStr.Matches[0].Groups[1].Value)) {
                Write-Error "Wrong Objective Number! Found [int]($objStr.Matches[0].Groups[1].Value) but expected $objModNum. Will not parse."
                Write-Debug "Returning null due to incorrect objective number"
                return
            }
            # Extract the objective number from the match
            $objNum = [int]($objStr.Matches[0].Groups[2].Value)  # Capture Group 2 -- Objective number
            Write-Verbose "Extracted objective number: $objNum"
        } catch {
            Write-Error "Did not parse an objective number."
            Write-Host -ForegroundColor Blue -BackgroundColor Yellow ($question.html | Select-String -Pattern "\b(Objective[:\W]+(\w+[, ]*)+)\b").Matches[0].Groups[1]
            Write-Verbose "Prompting user to enter correct objective number"
            $objNum = [int](Read-Host "Enter correct Objective Number or '0'")
        }
    }

    # Return the objective number
    Write-Verbose "Returning objective number: $objNum"
    return $objNum
}