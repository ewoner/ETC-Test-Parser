﻿
<#
    Author:  Brion Lang
    Version:  v0.1.0-dev.2

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
#$DebugPreference = "Inquire" # change to "Continue" to not halt on debugging messages
#$VerbosePreference = "Continue" # uncomment to see real detailed debugging messages.

#Used to test if conf file loading/parsing is working.
# $loadingFromConf = $true


Write-Debug "Debugging....."
#=======================================================================================================
#Read Configuration File -- must be moved below the choise of which mod to process.
#=======================================================================================================

if ( $loadingFromConf -eq $true ) {
	Write-Debug "Loading from configuration file"
#variables that can be loaded are set to default values	
#values loaded from the configuration file will be checked to see if they are spelled correctly using these preset variables
	$modNumber = 0
	$htmlDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod_$modNumber\Html_Files"
	$saveDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod_$modNumber\Output_Files"
	$objRegexPattern = "Objectives?:?[Â\W]+(\d+)\.(\d+)\.?(\d+)?"
	$nameRegexPattern = 'class=""\s*>((\w+[\. ]*){2,})<\/a><\/td><\/tr><tr><th class="cell" scope="row">Started on'
	$endOfQuestionRegexPattern = "<thead>"
	$numOfObj = 0
	$numOfDays = 0
	$maxNumOfQuestions = 0
	
	write-debug "Getting configuration file data"
	$confFileContent = get-content "./testParser.conf"
	if ( $confFileContent.count -gt 0 ) {
		write-debug "File loaded, parsing for $modToLoad"
		$currLineNum = -1
		$wrongModBlock = $false
		while ( $currLineNum -le $confFileContent.length ) {
			$currLineNum += 1
			$currLine = $confFileContent[ $currLineNum ]
			if ( $currLine -match "^#.*|^\s*$" ) {
				write-verbose "$currLineNum Comment/blank line`t`t`t$currLine"
				continue
			}
			elseif ( ($currLine -match $modBlockStartLineRegex) -and (([int]($Matches.1)) -eq $modToLoad ) ) { #Mod block start
				write-verbose "Found Block for Mod: $($Matches.1).  This is our block we want to parse."
				write-verbose "============================================================="
				write-verbose "$currLineNum Parsed            `t`t$currLine"
				$currLineNum += 1
				$currLine = $confFileContent[ $currLineNum ] 
				write-verbose "$currLineNum Parsed            `t`t$currLine"
			}
			elseif ( ($currLine -match $modBlockStartLineRegex) ) { #Mod block start
				write-verbose "Found Block for Mod: $($Matches.1). Skipping block"
				write-verbose "============================================================="
				write-verbose "$currLineNum Parsed            `t`t$currLine"
				$currLineNum += 1
				$currLine = $confFileContent[ $currLineNum ] 
				write-verbose "$currLineNum Parsed            `t`t$currLine"
				$wrongModBlock = $true
				write-verbose "Wrong MOD block flag: $wrongModBlock"
			}
			elseif ( $currLine -match $modBlockEndLineRegex ) {
				write-verbose "$currLineNum Parsed            `t`t$currLine"
				$wrongModBlock = $false
				write-verbose "End of Block.  Resetting flag: $wrongModBlock"
				write-verbose "============================================================="
			}
			elseif ( $wrongModBlock ) {
				write-verbose "$currLineNum Wrong MOD block   `t`t`t$currLine"
				currLineNum
			}
			elseif ( $currLine -match $valueLineRegex ) {
				$varName =  [string]$Matches.1
				$varValue = [string]$Matches.2
				write-verbose "$currLineNum Parsed value line:`t`t$currLine ---> $varName $varValue"
				set-variable $varName -value $varValue
				write-verbose "$varName set to $(Get-variable $varName -valueonly)"
			}
			else {
				write-verbose "$currLineNum Could not parse---`t`t$currLine"
				write-warning "Error loading configuration file line $currLine.  Using default values."
			}
		}
	} else {
		write-warning "Error loading configuration file.  Using default values."
	}
	write-debug "Parsed a total of $currLineNum"
	
}

#=======================================================================================================
#Get and Set Configuration
#=======================================================================================================
write-debug "Set Configuration by mod#..."
$modToLoad = 3 # test variable for debuggin only
$modBlockStartLineRegex = "\s*mod\s*=\s*(\d+)(#.*)?" #used for configuration files
$modBlockEndLineRegex = "^\s*</data>\s*$"            #used for configuration files
$valueLineRegex = "^\s*([a-zA-Z_]\w+)\s*=\s*((['`"])?.+\3?)$" #used for configuration files
$modNumber = 0  #Module number to load configuration for
while ( $True ) {
	$modNumber = [int]( Read-host "Enter your Mod (3 or 9): " )
	if ( $modNumber -eq 3 -or $modNumber -eq 9 ) {
		break
	} else {
		write-host "Invalid response MUST be either '3' or '9'" -foreground "RED" 
	}
}
if ($modNumber -eq 3 ) {     
	write-debug "...for Programming Fundalmentals (3)..."
	$maxNumOfQuestions = 42         #Hard coded question number to help validation of parser   TODO: move to CONF file/auto detect
	$numOfObj = 13     #Total number of Objectives, used to create array  TODO: move to CONF file
	$htmlDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod3\Html_Files"           #Directory to find html files; defaults to currect directory   TODO: move to CONF file
	$saveDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod3\Output_Files"
}
elseif ( $modNumber -eq 9 ) {
	write-debug "...for Programming/Scripting (9)..."
	$maxNumOfQuestions = 35         #Hard coded question number to help validation of parser   TODO: move to CONF file/auto detect
	$numOfObj = 11     #Total number of Objectives, used to create array  TODO: move to CONF file
	$htmlDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod9\Html_Files"           #Directory to find html files; defaults to currect directory   TODO: move to CONF file
	$saveDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod9\Output_Files"
}

Write-Verbose ('$modNumber' + " is $modNumber")
Write-Verbose ('$maxNumOfQuestions' + " is $maxNumOfQuestions")
Write-Verbose ('$numOfObj' + " is $numOfObj")
Write-Verbose ('$htmlDirStr' + " is $htmlDirStr")
Write-Verbose ('$saveDirStr' + " is $saveDirStr")

Write-Verbose ('$modBlockStartLineRegex' + " is $modBlockStartLineRegex")
Write-Verbose ('$modBlockEndLineRegex' + " is $modBlockEndLineRegex")
Write-Verbose ('$valueLineRegex' + " is $valueLineRegex")
#=======================================================================================================
#hardcoded configurations
#=======================================================================================================
<# Removed with Configuration file data 
$modNumber = 3                   #Currently Used to find objective text  
$maxNumOfQuestions = 42         #Hard coded question number to help validation of parser   TODO: move to CONF file/auto detect
$numOfObj = 13     #Total number of Objectives, used to create array  TODO: move to CONF file
$htmlDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod3\Html_Files"           #Directory to find html files; defaults to currect directory   TODO: move to CONF file
$saveDirStr = "H:\Documents\Projects\TestParser\ETC-Test-Parser-next\TestParser\Mod3\Output_Files"
#>
write-debug "Setting hardcoded Configurations..."
$objRegexPattern = "Objectives?:?[Â\W]+\d+\.(\d+)"   #Regex 'string' to find the objective missed
$nameRegexPattern = 'class=""\s*>((\w+[\. ]*){2,})<\/a><\/td><\/tr><tr><th class="cell" scope="row">Started on'  #Regex 'string' to find the student's name.  May not be 'finalized'  Does not work in Notepad++  From Regex101.com
$endOfQuestionRegexPattern = "<thead>"  # Regex 'string' that hold the pattern to stop parsing a single question.
    # Used the "<thead>" tag to stop a questions parsing.  This tag is used on the 'history' of the saving of the question.
    # This tag is only one right after a question in the HTML code and not found else place in the HTML code.

$objOutputStr = "`t`tObjective: "  #output string for Console output
Write-Verbose ('$objRegexPattern' + " is $objRegexPattern")
Write-Verbose ('$nameRegexPattern' + " is $nameRegexPattern")
Write-Verbose ('$endOfQuestionRegexPattern' + " is $endOfQuestionRegexPattern")
Write-Verbose ('$objOutputStr' + " is $objOutputStr")


#Get files to read
write-debug "Getting files...."
$filesToParseObjs = get-childItem -Path $htmlDirStr -Filter "*.htm*"
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
                $objNum = [int]($objStr.Matches[0].groups[1].value)  #Capture Group 1 -- Objective number
                $objTallies[ $objNum-1 ] += 1;
				
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
    
	# Build the output string
	write-debug "Done with parshing $fileParsingObj now building output strings"
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
        if ( $curObjNum -gt 9 ) {
            $outputStr += "$objOutputStr$modNumber.$curObjNum --> $objTally`n"
            $csvStr += "$objTally`n"
        }
        else {
            $outputStr += "$objOutputStr$modNumber. $curObjNum --> $objTally`n"
            $csvStr += "$objTally`n"
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
    try {
        Write-host "Creating file '$saveDirStr/$namestr.csv' and saving ..... " -nonewline
        new-item -Path $saveDirStr -Name "$nameStr.csv" -Force 1> $null
        Set-Content -Path "$saveDirStr/$namestr.csv" -Value $csvstr
        write-verbose "CSV File saved correctly."
        write-host "Succesful!"
    }
    catch {
        write-Host "Error!"
        Write-Error "Unknown error while trying to save file: $saveDirStr/$namestr.txt"
    }
    Write-verbose "Checking for common count errors due to bad parsing."

    #Checking for Errors Will Robinson!
    if ( $maxNumOfQuestions -ne $numOfFoundQuestions ) {
        Write-Error "maxNumOfQuestions of questions expected but parsed $numOfFoundQuestions Questions!"
    }
    if ( $totalnumOfMissedQuestions -ne $missedQuestions.count ) {
        Write-Error "$total missed questions by objectives buy parsed $($missedQuestions.count) Questions!"
    }
	write-debug "Done with $fileParsingObj"
}
Write-Debug "Program done!"
if ( $DebugPreference -eq "SilentlyContinue") {
	read-host "`n`nProgram Finished.  Please hit Enter to Exit"
}
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"
Stop-Transcript
Write-Debug "If you see this --- opps"

<#
	variable names = $camCase
	files/dir as strings = $___FileStr $___DirStr
	files/dir as objects = $___FileObj $___DirObj
	
#>