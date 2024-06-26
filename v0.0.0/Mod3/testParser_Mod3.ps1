﻿clear-host
<#
    Author:  Brion Lang
    Version:  v0.0.0 - First Code base

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

#For debugging information make sure this line below is uncommented.
#  $DebugPreference = "Continue"
#=======================================================================================================
#hardcoded configurations
#=======================================================================================================
Write-Debug "Debugging....."
$Mod = 3                   #Currently Used to find objective text  TODO: remove
$maxQuestions = 42         #Hard coded question number to help validation of parser   TODO: move to CONF file/auto detect
$htmldir = "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser\Mod3\Html_Files"           #Directory to find html files; defaults to currect directory   TODO: move to CONF file
$saveDir = "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser\Mod3\Output_Files"
#$file = "$directory/test.html"      #TODO remove -Version 1 will load all html's from a given directory
$ObjectivesNumber = 13     #Total number of Objectives, used to create array  TODO: move to CONF file
                    #"Objectives?:\s+$Mod\.(\d+)"
$ObjectivePattern = "Objectives?:?[Â\W]+\d+\.(\d+)"   #Regex 'string' to find the objective missed
$NamePattern = 'class=""\s*>((\w+[\. ]*){2,})<\/a><\/td><\/tr><tr><th class="cell" scope="row">Started on'  #Regex 'string' to find the student's name.  May not be 'finalized'  Does not work in Notepad++  From Regex101.com
$QuestionEndPattern = "<thead>"  # Regex 'string' that hold the pattern to stop parsing a single question.
    # Used the "<thead>" tag to stop a questions parsing.  This tag is used on the 'history' of the saving of the question.
    # This tag is only one right after a question in the HTML code and not found else place in the HTML code.

$ObjectiveDisplayStr = "`t`tObjective: "  #output string for Console output

#Get files to read
$files = get-childItem -Path $htmldir -Filter "*.htm*"
Write-Debug "$files to process...."

foreach ( $file in $files ){
    Write-Debug "Processing $($file.fullName)"
    $Objectives = @()                        #Array to hold number of missed questions by objective, note SIZE == $ObjectivesNumber above
    $Questions = @()                         #Matches to missed questions
    write-debug "Creating tally array: "
    #Set up array to hold number of questions wrong, index by (objective# -1)
    for ( $index = 0; $index -lt $ObjectivesNumber; $index += 1 ) {
        $Objectives += 0;
    }
    Write-Debug "$($Objectives.count) sized arrry set to : $($Objectives)"
    #=======================================================================================================
    #Per File to parse....
    #=======================================================================================================
    #set up variables for a single file parse:
    $qCount = 0                     #number of all questions parsed
    $question = ""                  #string to hold the current quesion being parsed
    $qDone = $false                 #flag to set when a question is done parsing
    $foundName = $false             #flag to set if the name has been parsed; used to short circuit if below 
    $nameStr = "UNKNOWN"            # string to hold the Students name; Defaults to "UNKNOW" if not parsed
    Write-Debug "Getting file $htmldir/$file :"
    #get the file as an array of strings/lines
    try {
        $htmlCon = Get-Content -path $file.FullName
    }
    catch {
        Write-Error "Error opening the file $file for reading.\nProgram exiting."
        #exit 1
    }
    Write-Debug "Processing a question"
    $qlineCount = 0    #used for debugging
    $linecount = 0    #used for debugging
    #read in each line and parse it into a question....
    foreach ( $line in $htmlCon) {
        $linecount += 1
        #Write-Debug "Line: $lineCount"
        # Uses the HTML code to find the student's name based on the $NamePattern
        if ($FoundName -eq $false -and ($line | select-string -pattern $NamePattern -quiet) ) {
            $nameMatches = $line | select-string -pattern $NamePattern
            $nameStr = $nameMatches.Matches[0].Groups[1]  #Returns the results of the capture group around the Student's name (group 1)
            $foundName = $true
            Write-Debug "`t`tFound the name:  $nameStr"
  
        }
        # End of the question currently pasring
        elseif ( $line -match $QuestionEndPattern ) {
            $qCount += 1
            $Incorrect = $question | Select-String -pattern '<div class="state">Incorrect</div>' -Quiet
           # Quesiton is incorrect; save the html for now, and update objectives missed etc
           if ( $Incorrect ) {
                $Questions += $Question
                #write-Debug "$ObjectivePattern`n`n$question`n`n"

                $objStr = $Question | select-string -pattern $ObjectivePattern
                if ( $objStr -eq $null ) {
                    write-debug "HHHHHHHEEEEEEEERRRRRREEEE" #Objective:Â  3.10
                    
                } 
                $objNum = [int]($objStr.Matches[0].groups[1].value)  #Capture Group 2 -- Objective number
                $Objectives[ $objNum-1 ] += 1;
                <#$newMod = [int]($objStr.Matches[0].groups[1].value)  #Capture Group 1 -- Mod  number
                #error handling if the objects' mod number does not matach.
                if ( $mod -ne $newMod ) {
                    write-error "There an issue reading in the Mod Number from the Ojbective."
                    #exit 2
                }
                elseif ( $mod -eq 0 ) {
                    $mod = $newMod
                }#>
           }
	       $question = ""
            Write-Debug "`t`tEnd of question $($qCount) :  Lines = $qlineCount"
            $qlineCount = 0
        }
        # Still parsing the question
        else {
            $question += $line  
            $qlineCount += 1
       }
       # Found all the questions, why parse more!
       #Commented out for initial release to help detect errors.
       <#
       if ( $qCount -eq $maxQuestions ) {
        break
       }
       #>
    }
    #Display Debugging Info
    write-debug "Total Lines parsce: $lineCount"
    write-debug "Total Questions parsed: $qCount"
    write-debug "Total Questions wrong: $($Questions.Count)"


    # Build the output string

    $outstr = "";  #output string to a text file.
    $csvStr = "";  #output string for csv file
    $Disclaimer = "
    To Ensure correct operations, ensure 'Total Questions Parsed' and 'Total Questions Missed' match ETC.
    If they do not match, there is a parsing issues.  Please report this error, along with the which
    student it incorrectly parsed.  Thank you, Brion.`n`n"
    #PS will auto promote to double and round!
    #Note this outputs the number of questions as parsed.
    $outputHeader = "
Test Parsed for $nameStr 
=======================================================================================================
Incorrect Questions     :  $($Questions.count)
Grade                   :  $(([int](($qCount - $Questions.count) / $qCount * 100.0)))
Total Questions Parsed  :  $qCount ($maxQuestions expected)
======================================================================================================="
    Write-Debug "Building the Output string..."

    #Disclaimer output for trail versions.
    $outstr += $Disclaimer + "`n"

    $outstr += $outputHeader + "`n"
    $csvStr += "$nameStr`n"
    $curObj = 1;
    $total = 0
    foreach ( $objScore in $Objectives ) {
        $total +=  $objScore;
        if ( $curObj -gt 9 ) {
            $outstr += "$ObjectiveDisplayStr$mod.$curObj --> $objScore`n"
            $csvStr += "$objScore`n"
        }
        else {
            $outstr += "$ObjectiveDisplayStr$mod. $curObj --> $objScore`n"
            $csvStr += "$objScore`n"
        }
        $curObj += 1;
    }
	$testFooter = "
 Total Questions Missed  : $total
 ======================================================================================================="
    $outstr += $testFooter

    # sending to console and file, overrighting old information!
    write-host $outstr
    try {
        Write-host "Creating file '$saveDir/$namestr.txt' and saving ..... " -nonewline
        new-item -Path $saveDir -Name "$nameStr.txt" -Force 1> $null
        Set-Content -Path "$saveDir/$namestr.txt" -Value $outstr
        write-debug "File saved correctly."
        write-host "Succesful!"
    }
    catch {
        write-Host "Error!"
        Write-Error "Unknown error while trying to save file: $saveDir/$namestr.txt"
    }
    try {
        Write-host "Creating file '$saveDir/$namestr.csv' and saving ..... " -nonewline
        new-item -Path $saveDir -Name "$nameStr.csv" -Force 1> $null
        Set-Content -Path "$saveDir/$namestr.csv" -Value $csvstr
        write-debug "File saved correctly."
        write-host "Succesful!"
    }
    catch {
        write-Host "Error!"
        Write-Error "Unknown error while trying to save file: $saveDir/$namestr.txt"
    }

    Write-Debug "Checking for common count errors due to bad parsing."

    #Checking for Errors Will Robinson!
    if ( $maxQuestions -ne $qCount ) {
        Write-Error "$maxQuestions of questions expected but parsed $qCount Questions!"
    }
    if ( $total -ne $Questions.count ) {
        Write-Error "$total missed questions by objectives buy parsed $questions.count Questions!"
    }
}
Write-Debug "Program done!"

#read-host "Hit Enter to Exit"
$DebugPreference = "SilentlyContinue"
Write-Debug "If you see this --- opps"

