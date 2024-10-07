<#
.SYNOPSIS
Finds the objective number of a question based on a regular expression pattern.

.DESCRIPTION
This script finds the objective number of a question based on a regular expression pattern. It is part of the TestParser module.

.VERSION
1.0.0

.AUTHOR
Brion Lang

.NOTES
Versioning specification: https://semver.org/
See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.

.PARAMETER question
The question object to process.

.EXAMPLE
Get-QuestionObjectiveNumber -question $questionObject

.INPUTS
System.Management.Automation.PSObject
The question object to process.

.OUTPUTS
System.Int32
The objective number of the question.

.FUNCTIONALITY
TestParser

.LINK
https://github.com/ewoner/ETC-Test-Parser

.COMPONENT
TestParser

.ROLE
TestParser

#>
function Get-QuestionObjectiveNumber {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$question
    )

    # Get the objective module number and regular expression pattern from the module configuration
    $objModNum = $ModConfig.objModnum
    $objRegexStr = $ModConfig.ObjRegexPattern

    # Initialize the objective number variable
    $objNum = 0

    # If the question is correct, return -1
    if ($question.correct) {
        Write-Verbose "Question is correct, returning -1"
        return -1
    }

    # Use regular expression to find the objective line in the question HTML
    $objStr = $question.html | Select-String -Pattern $objRegexStr

    # If no objective line is found, throw an error and prompt the user to enter the correct objective number
    if ($objStr -eq $null -or $objStr.Matches.Count -eq 0) {
        Write-Error "No Objective Line found."
        Write-Host -ForegroundColor Blue -BackgroundColor Yellow ($question.html | Select-String -Pattern "\b(Objective[:\W]+(\w+[,. ]*)+)\b").Matches[0].Groups[1]
        $objNum = [int](Read-Host "Enter correct Objective Number or '0'")
    } else {
        try {
            # Try to parse the objective number from the regular expression match
            $objNum = [int]($objStr.Matches[0].Groups[2].Value)  # Capture Group 2 -- Objective number
            Write-Verbose "Parsed objective number: $objNum"
        } catch {
            # If parsing fails, throw an error and prompt the user to enter the correct objective number
            Write-Error "Did not parse an objective number."
            Write-Host -ForegroundColor Blue -BackgroundColor Yellow ($question.html | Select-String -Pattern "\b(Objective[:\W]+(\w+[, ]*)+)\b").Matches[0].Groups[1]
            $objNum = [int](Read-Host "Enter correct Objective Number or '0'")
        }
    }

    # Check if the objective number matches the expected module number
    if ($objModNum -ne [int]($objStr.Matches[0].Groups[1].Value)) {
        Write-Error "Wrong Objective Number! Found [int]($objStr.Matches[0].Groups[1].Value) but expected $objModNum. Will not parse."
        return
    }

    # Return the objective number
    Write-Verbose "Returning objective number: $objNum"
    return $objNum
}