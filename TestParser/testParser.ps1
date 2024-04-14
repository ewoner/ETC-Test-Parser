
<#
    Author:  Brion Lang
    Version:  v0.1.0-dev.3

    versioning specification : https://semver.org/

    Discription:  This program will read in a file give in the hardcoded varaibles, and parse the number of questions wrong and print a report to the screen.

    See Github repositoty at : https://github.com/ewoner/ETC-Test-Parser for more complete discription, current updates and future plans.
#>

<#
TODO:  Rename variables to better self document
#>

<#
    To add color: 
    Filter Wrap-Red {
    $esc = "$([char]27)"
    $WrapFormat = "$esc[91m{0}$esc[33m"
    If ($_ -match 'Valid') { $WrapFormat -f $_ }
    ELse {$_} 
}


#>
clear-host

#Creates a log file from this run.
Start-Transcript -path "./lastrun.log"
#For debugging information make sure this lines below is uncommented.
$DebugPreference = "Continue" # "Inquire" # change to "Continue" to not halt on debugging messages
$VerbosePreference = "Continue" # uncomment to see real detailed debugging messages.

Write-Debug "Debugging....."
#=======================================================================================================
#Get Mod number to load conf file 
#=======================================================================================================
write-debug "Set Configuration by mod#..."
$modNumber = 0  #Module number to load configuration for
while ( $True ) {
	$modNumber = [int]( Read-host "Enter your Mod (3 or 10): " )
	if ( $modNumber -eq 3 -or $modNumber -eq 10  ) {
		break
	} else {
		write-host "Invalid response MUST be either '3' or '10'" -foreground "RED" 
	}
}
#=======================================================================================================
#Read Configuration File
#=======================================================================================================
Write-Debug "Loading from configuration file"
# variables that can be loaded are set to default values	
# values loaded from the configuration file will be checked to see if they are spelled 
# correctly using these preset variables
<# Below are the directories and regex patterns that should only be changed in conf
files due to special cases.  #>
$htmlDirStr = ".\Html_Files"
$saveDirStr = ".\Output_Files"  # Should be the directory were remediation files are stored.  Next version???
$objRegexPattern = "Objective[s:\W]+(\d+)\.(\d+)\.?(\d+)?" # Default for Mod 3/ 10 hopefully all mods....
# nameRegexPattern is from the ETC HTML and should be universial.
$nameRegexPattern = 'class=""\s*>((\w+[\. ]*){2,})<\/a><\/td><\/tr><tr><th class="cell" scope="row">Started on' #default from ETC HTML
$endOfQuestionRegexPattern = "<thead>"
# Used the "<thead>" tag to stop a questions parsing.  This tag is used on the 'history' of the saving of the question.
# This tag is only one right after a question in the HTML code and not found else place in the HTML code.


$mod = 0
$numOfObj = 0
$numOfDays = 0
$maxNumOfQuestions = 0
$objectiveStrings = @()

$confFileStr = "./config/mod$modNumber.conf"	
$valueLineRegex = "^\s*([a-zA-Z_]\w+)\s*=\s*((['`"])?.+\3?)$" #used for configuration files

write-debug "Getting configuration file data"
$confFileContent = get-content $confFileStr
if ( $confFileContent.count -gt 0 ) {
	write-debug "File loaded, parsing for $modNumber"
	$readingObj = $false
	$currLineNum = 0
	foreach ( $line in $confFileContent ) {
		$currLineNum += 1
		if ( $line -match "^#" ) {
			write-verbose "$currLineNum - COMMENT - $line"
			continue
		}
		elseif ( $line -match $valueLineRegex -and -not $readingObj ) {
			write-verbose "$currLineNum - VARIABLE - $line"
			$varName = $matches.1
			$varData = $matches.2
			#Use test-path to see if the variable exists and then set the value
			#else just going to ignore the variable loaded in.
			if ( test-path -path "variable:$varName" ) {
				write-verbose "Set $varName to $varData"
				set-variable -name $varName -value $varData
			}
			else {
				write-host -Forground Yellow "$varName variable is not a reconized variable!"
				write-verbose "Error!!!!! with setting $varName to $varData" 
			}
		}
		elseif ( $line -eq "<Objectives>" ) {
			write-verbose "$currLineNum - $line"
			$readingObj = $True
		}
		elseif ( $line -eq "</Objectives>" ) {
			write-verbose "$currLineNum - $line"
			$readingObj = $false
		}
		elseif ( $readingObj ) {
			write-verbose "$currLineNum - $line"
			$objectiveStrings += $line
		}
		else {
			write-output "$currLineNum - $line was not parsed!"
			write-verbose "$currLineNum - Error!!!!! with Parsing $line"
		}
	}
} else {
	write-warning "Error loading configuration file.  Using default values."
}
write-debug "Parsed a total of $currLineNum"	



write-Debug "List of current variables settings:"
if ( $DebugPreference -ne "SilentlyContinue"  ){
	$oldPreference = $DebugPreference
	$debugPreference = "continue"
	write-debug "`n`n`$mod = $mod"
	write-debug "`$htmlDirStr = $htmlDirStr "
	write-debug "`$saveDirStr = $saveDirStr "
	write-debug "`$objRegexPattern = $objRegexPattern "
	write-debug "`$nameRegexPattern = $nameRegexPattern "
	write-debug "`$endOfQuestionRegexPattern = $endOfQuestionRegexPattern "
	write-debug "`$numOfObj = $numOfObj "
	write-debug "`$numOfDays = $numOfDays "
	write-debug "`$maxNumOfQuestions = $maxNumOfQuestions "
	write-debug "`$objectiveStrings = $objectiveStrings "
	$DebugPreference = $oldPreference
	write-debug "Done!`n`n"
} else {
	write-verbose "List of current variables settings:"
	write-verbose "`n`n`$mod = $mod"
	write-verbose "`$htmlDirStr = $htmlDirStr "
	write-verbose "`$saveDirStr = $saveDirStr "
	write-verbose "`$objRegexPattern = $objRegexPattern "
	write-verbose "`$nameRegexPattern = $nameRegexPattern "
	write-verbose "`$endOfQuestionRegexPattern = $endOfQuestionRegexPattern "
	write-verbose "`$numOfObj = $numOfObj "
	write-verbose "`$numOfDays = $numOfDays "
	write-verbose "`$maxNumOfQuestions = $maxNumOfQuestions "
	write-verbose "`$objectiveStrings = $objectiveStrings "
	write-verbose "Done!`n`n"
}
$objOutputStr = "`t`tObjective: "  #output string for Console output
Write-Verbose ('$objRegexPattern' + " is $objRegexPattern")
Write-Verbose ('$nameRegexPattern' + " is $nameRegexPattern")
Write-Verbose ('$endOfQuestionRegexPattern' + " is $endOfQuestionRegexPattern")
Write-Verbose ('$objOutputStr' + " is $objOutputStr")


#Get files to read
write-debug "Getting files...."
$filesToParseObjs = get-childItem -Path "$htmlDirStr" -Filter "*.htm*"
Write-verbose "$filesToParseObjs to process...."

foreach ( $fileParsingObj in $filesToParseObjs ){
    Write-debug "Processing $($fileParsingObj.fullName)"
    $objTallies = @()                        #Array to hold number of missed questions by objective, note SIZE == $numOfObj above
    $missedQuestions = @()                         #Matches to missed questions
    write-verbose "Creating tally array: "
    #Set up array to hold number of questions wrong, index by (objective# -1)
    for ( $index = 0; $index -lt $numOfObj; $index += 1 ) {
        $objTallies += 0;
    }
    Write-verbose "$($objTallies.count) sized arrry set to : $($objTallies)"
    #=======================================================================================================
    #Per File to parse....
    #=======================================================================================================
    #set up variables for a single file parse:
    $questionStr = ""                  #string to hold the current quesion being parsed
    $foundName = $false             #flag to set if the name has been parsed; used to short circuit if below 
    $nameStr = "UNKNOWN"            # string to hold the Students name; Defaults to "UNKNOW" if not parsed
    Write-verbose "Getting file $htmlDirStr/$fileParsingObj :"
    #get the file as an array of strings/lines
    try {
        $htmlFileContent = Get-Content -path $fileParsingObj.FullName
    }
    catch {
        Write-Error "Error opening the file $fileParsingObj for reading.\nProgram exiting."
        return 1
    }
    Write-verbose "Processing a question"
    $questionLineCount = 0    #used for debugging
    $fileLineCount = 0    #used for debugging
	$numOfFoundQuestions = 0 # used for debugging
    #read in each line and parse it into a question....
    foreach ( $line in $htmlFileContent) {
		$line = $line.replace(""+[char]194,"").replace("&nbsp;"," ")
        $fileLineCount += 1
        #Write-Debug "Line: $fileLineCount"
        # Uses the HTML code to find the student's name based on the $nameRegexPattern
        if ($foundName -eq $false -and ($line | select-string -pattern $nameRegexPattern -quiet) ) {
            $questionStr += $line
			$nameMatches = $line | select-string -pattern $nameRegexPattern
            $nameStr = $nameMatches.Matches[0].Groups[1]  #Returns the results of the capture group around the Student's name (group 1)
            $foundName = $true
            Write-verbose "$fileLineCount -->`t`tFound the name:  $nameStr"
        }
        # End of the question currently pasring
        elseif ( $line -match $endOfQuestionRegexPattern ) {
            $numOfFoundQuestions += 1
            
			$IncorrectQuestion = $questionStr | Select-String -pattern '<div class="state">Incorrect</div>' -Quiet
           # Quesiton is incorrect; save the html for now, and update objectives missed etc
           if ( $IncorrectQuestion ) {
                Write-verbose "Question is INCORRECT."
                $missedQuestions += $questionStr
                $objStr = $questionStr | select-string -pattern $objRegexPattern
                $objNum = [int]($objStr.Matches[0].groups[2].value)  #Capture Group 2 -- Objective number
                $objTallies[ $objNum-1 ] += 1;
                # check if this is the wrong mod and move to next file if true
                if ( [int]($objStr.Matches[0].groups[1].value) -ne $modNumber ) {
                    write-debug "$modNumber found!!!!!!!!!!!!!!!!!!"
                    $wrongMod = $true
                    break;
                }
			}
			Write-verbose "$fileLineCount-->`t`tEnd of question:  $($missedQuestions.count) of $numOfFoundQuestions :  Lines = $questionLineCount"
			$questionStr = ""
            $questionLineCount = 0
        }
        # Still parsing the question
        else {
            $questionStr += $line  
            $questionLineCount += 1
		}
		if ( $numOfFoundQuestions -eq $maxNumOfQuestions ) {
			write-verbose "Found all the questions, exiting loop"
			break
		}
    }
    write-verbose "Total Lines parsed: $fileLineCount"
    write-verbose "Total Questions parsed: $numOfFoundQuestions"
    write-verbose "Total Questions wrong: $($missedQuestions.count)"
    
    if ( $wrongMod ) {
        Write-Debug "$fileParsingObj is not current from the current parsing mod and has been skipped."
        $wrongMod = $false
        continue
    }

	# Build the output string
	write-debug "Done with parshing $fileParsingObj now building output strings"
	$excelStr = '"# Missed" ,' + ($missedQuestions.count) + ',"Student Name: ' + $nameStr + '"' + "`n`n"
	$outputStr = "";  #output string to a text file.
    $csvStr = "";  #output string for csv file
    $disclaimerStr = "
    To Ensure correct operations, ensure 'Total Questions Parsed' and 'Total Questions Missed' match ETC.
    If they do not match, there is a parsing issues.  Please report this error, along with the which
    student it incorrectly parsed.  Thank you, Brion.`n`n"
    #PS will auto promote to double and round!
    #Note this outputs the number of questions as parsed.
    $outputHeaderStr = "
Test Parsed for $nameStr 
=======================================================================================================
Incorrect Questions     :  $($missedQuestions.count)
Grade                   :  $(([int](($numOfFoundQuestions - $missedQuestions.count) / $numOfFoundQuestions * 100.0)))
Total Questions Parsed  :  $numOfFoundQuestions ($maxNumOfQuestions expected)
======================================================================================================="
    #Disclaimer output for trail versions.  Comment out for full production.
    $outputStr += $disclaimerStr + "`n"

    $outputStr += $outputHeaderStr + "`n"
    $csvStr += "$nameStr`n"
    $curObjNum = 1;
    $totalnumOfMissedQuestions = 0
    foreach ( $objTally in $objTallies ) {
        $totalnumOfMissedQuestions +=  $objTally;
        # The checkbox for missed objectives!
        if ( $objTally -eq 0 ) {
            $wingDingChar = 168
        }
        else {
            $wingDingChar = 254
        }
        if ( $curObjNum -gt 9 ) {
            $outputStr += "$objOutputStr$modNumber.$curObjNum --> $objTally`n"
            $csvStr += "$objTally`n"
			$excelStr += [string]$objTally + ','+[char]$wingDingChar+',"' + $curObjNum + ".  " + $objectiveStrings[$curObjNum-1] + '",'+"`n"
        }
        else {
            $outputStr += "$objOutputStr$modNumber. $curObjNum --> $objTally`n"
            $csvStr += "$objTally`n"
			$excelStr += [string]$objTally + ','+[char]$wingDingChar+',"' + $curObjNum + ".   " + $objectiveStrings[$curObjNum-1] + '",'+"`n"
        }
        $curObjNum += 1;
    }
	$outputFooterStr = "
 Total Questions Missed  : $($missedQuestions.count)
 ======================================================================================================="
    $outputStr += $outputFooterStr

    # sending to console and file, overrighting old information!
    write-host $outputStr
    try {
        Write-host "Creating file '$saveDirStr/$namestr.txt' and saving ..... " -nonewline
        new-item -Path $saveDirStr -Name "$nameStr.txt" -Force 1> $null
        Set-Content -Path "$saveDirStr/$namestr.txt" -Value $outputStr
        write-verbose "TEXT File saved correctly."
        write-host "Succesful!"
    }
    catch {
        write-Host "Error!"
        Write-Error "Unknown error while trying to save file: $saveDirStr/$namestr.txt"
    }
# Section below removed due to Excel output.
<#    try {
        Write-host "Creating file '$saveDirStr/$namestr.csv' and saving ..... " -nonewline
        new-item -Path $saveDirStr -Name "$nameStr.csv" -Force 1> $null
        Set-Content -Path "$saveDirStr/$namestr.csv" -Value $csvstr
        write-verbose "CSV File saved correctly."
        write-host "Succesful!"
    }
    catch {
        write-Host "Error!"
        Write-Error "Unknown error while trying to save file: $saveDirStr/$namestr.csv"
    }
#>
	try {
        Write-host "Creating file '$saveDirStr/$namestr.xlsx' and saving ..... " -nonewline
        $excel = ( (ConvertFrom-Csv $excelStr) | export-Excel "$saveDirStr/$namestr.xlsx"  -autosize -PassThru )
        $Range = "B2:B$($numOfObj+1)"
        Set-excelRange -range $range  -Worksheet $excel.sheet1 -FontName "wingdings"
        Set-ExcelRange -range "A1:B$($numOfObj+1)" -Worksheet $excel.Sheet1 -HorizontalAlignment Center
        Export-Excel -ExcelPackage $excel
        write-verbose "Excel File saved correctly."
        write-host "Succesful!"
    }
    catch {
        write-Host "Error!"
        Write-Error "Unknown error while trying to save file: $saveDirStr/$namestr.xlsx"
    }

    
    #Checking for Errors Will Robinson!
    Write-verbose "Checking for common count errors due to bad parsing."
    if ( $maxNumOfQuestions -ne $numOfFoundQuestions ) {
        Write-Error "$maxNumOfQuestions of questions expected but parsed $numOfFoundQuestions Questions!"
    }
    if ( $totalnumOfMissedQuestions -ne $missedQuestions.count ) {
        Write-Error "$totalnumOfMissedQuestions missed questions by objectives but parsed $($missedQuestions.count) Questions!"
    }
	write-debug "Done with $fileParsingObj"
}
Write-Debug "Program done!"
read-host "`n`nProgram Finished.  Please hit Enter to Exit"

$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"
Stop-Transcript
Write-Debug "If you see this --- opps"

<#
	variable names = $camCase
	files/dir as strings = $___FileStr $___DirStr
	files/dir as objects = $___FileObj $___DirObj
	
#>
<# Excel Sheet format 
    A         |      B         |       C         |      D         |
"# Missed"    | <total missed> | "Student Name:" | <student name> |
<BLANK>
<obj # wrong>  | <checkbox>     | <Objective tile>                 |


Sheet title = <lastname>

WingDings 168 - box
Winddings 254 - box w/check
#>
