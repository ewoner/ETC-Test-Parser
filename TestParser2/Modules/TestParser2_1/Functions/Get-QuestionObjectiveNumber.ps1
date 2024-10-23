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
<#
Changelog for Get-QuestionObjectiveNumber

Version 1.1.0
Date: 2024-10-21
Changes:
- Return Values:
  - If no objective line is found, the function now returns 0 to indicate "Objective Not found in HTML".
  - When a daily objective is detected, the function returns a hashtable containing both the day (Day) and objective number (Objective).
  - When a module objective is detected, the function returns only the objective number.

- Error Handling:
  - Added a try-catch block to handle parsing errors more gracefully. If parsing fails, it now returns 0 to signify an unrecognized objective.

- Verbose Logging:
  - Enhanced verbose messages to provide clearer insights into the flow of data and the outcomes of various operations within the function.

- Regex Handling:
  - Ensured compatibility with both module objectives and daily objectives based on the existing regex structure.
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

    # If no objective line is found, return 0 for 'Objective Not found in HTML'
    if ($objStr -eq $null -or $objStr.Matches.Count -eq 0) {
        Write-Verbose "No Objective Line found. Trying to manual Parse."
    }

    # Extract values based on the regex capture groups
    try {
        # Capture Group 1 is ignored
        $captureGroup2 = $objStr.Matches[0].Groups[2].Value  # Module Objective or Day Objective
        $captureGroup3 = $objStr.Matches[0].Groups[3].Value  # Daily Objective Number (if applicable)

        # Check if we are dealing with a daily objective
        if ($captureGroup3) {
            # Return an array with Day and Objective Number
            Write-Verbose "Returning daily objective: Day = $captureGroup2, Objective = $captureGroup3"
            return @{ Day = [int]$captureGroup2; Objective = [int]$captureGroup3 }
        } elseif ($captureGroup2) {
            # Return single objective number for module objectives
            $objNum = [int]$captureGroup2
            Write-Verbose "Returning module objective: $objNum"
            return $objNum
        }
    } catch {
        # If parsing fails, return 0 for 'Objective Not found in HTML'
        Write-Verbose "No Objective Line found. Trying to manual Parse."
    }
	
	Write-host -background black -fore ground yellow "${$question.html}" 
	wrtie-host "Enter # for Module Objective or #.# for a daily objective.`nEnter 0 if the objective is still unknown."
	$readObjstr = read-host -prompt "Enter object:"
	$readObjStr | Select-String -Pattern (d+)\.?(\d+)?
	try {
        # Capture Group 1 is ignored
        $captureGroup1 = $objStr.Matches[0].Groups[1].Value  # Module Objective or Day Objective
        $captureGroup2 = $objStr.Matches[0].Groups[2].Value  # Daily Objective Number (if applicable)

        # Check if we are dealing with a daily objective
        if ($captureGroup2) {
            # Return an array with Day and Objective Number
            Write-Verbose "Returning daily objective: Day = $captureGroup2, Objective = $captureGroup3"
            return @{ Day = [int]$captureGroup1; Objective = [int]$captureGroup2 }
        } elseif ($captureGroup1) {
            # Return single objective number for module objectives
            $objNum = [int]$captureGroup1
            Write-Verbose "Returning module objective: $objNum"
            return $objNum
        }
    } catch {
        
    }
	# If parsing fails, return 0 for 'Objective Not found in HTML'
    Write-Verbose "No Objective Found Manual Either. Returning 0."
	return 0;
}
