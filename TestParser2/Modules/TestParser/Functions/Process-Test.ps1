function Process-Test {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$test,

        [Parameter(Mandatory = $true)]
        [PSObject]$student,

        [int]$classnumber = 99999
    )
	write-host -backgroundcolor "yellow" -foregroundcolor "blue" "Process-Test is no longer a valid cmdlet and is slated to be removed.  Please send email to Brion.lang@comtechtel when you see this message or update to latest TestParser2.ps1 code."
    $missedQuestions = 0
    $objTallies = @( 0 ) * ( $modConfig.NumOfObj + 1 )
    $comboOutputFileStr = ""

    $nameStr = $student.fullname
    $objectiveStrings = $modConfig.objectives
    $numOfFoundQuestions = $modConfig.MaxNumOfQuestions
    $modNumber = $modConfig.Mod

       # Process the test
    $curObjNum = 0
    foreach ($question in $test.questions) {
        $result = Process-Question -question $question
        if ($result -ne -1) {
            $objTallies[$result]++
            $missedQuestions++
        }
    }
	$excelStr = '"# Missed" ,' + $missedQuestions + ',"Student Name: ' + $nameStr + '"' + "`n`n"
    $outputStr = ""
    $disclaimerStr = "To Ensure correct operations, ensure 'Total Questions Parsed' and 'Total Questions Missed' match ETC. If they do not match, there is a parsing issue. Please report this error, along with the student it incorrectly parsed. Thank you, Brion.`n`n"
    $outputHeaderStr = "Test Parsed for $nameStr `n=======================================================================================================`nIncorrect Questions     :  $missedQuestions`nGrade                   :  $(([int](($numOfFoundQuestions - $missedQuestions) / $numOfFoundQuestions * 100.0)))`nTotal Questions Parsed  :  $numOfFoundQuestions ($($modConfig.MaxNumOfQuestions) expected)`n======================================================================================================="
    
    $outputStr += $disclaimerStr + "`n"
    $outputStr += $outputHeaderStr + "`n"
    
 
    $totalnumOfMissedQuestions = ($objTallies | Measure-Object -Sum | Select-Object -ExpandProperty Sum)
    foreach ($objTally in $objTallies) {
        if ($objTally -eq 0) {
            $wingDingChar = 168
        } else {
            $wingDingChar = 254
        }

        if ($curObjNum -gt 9) {
            $outputStr += "$modNumber.$curObjNum `t--> $objTally`n"
            $excelStr += [string]$objTally + ','+[char]$wingDingChar+',"' + $curObjNum + ".  " + $objectiveStrings[$curObjNum-1] + '",'+"`n"
        } elseif ($curObjNum -eq 0 -and $objTally -ne 0) {
            $outputStr += "`t`tNo Objective Parsed `t--> $objTally`n"
            $outputStr += "`t`t-----------------------------------`n"
            $excelStr += [string]$objTally + ',' + [char]$wingDingChar + ',"' + $curObjNum + ".  " + "Could not Parse" + '",' + "`n"
        } elseif ($curObjNum -gt 0) {
            $outputStr += "$modNumber. $curObjNum `t--> $objTally`n"
            $excelStr += [string]$objTally + ','+[char]$wingDingChar+',"' + $curObjNum + ".   " + $objectiveStrings[$curObjNum-1] + '",'+"`n"
        }
        $curObjNum += 1
    }

    $outputFooterStr = "Total Questions Missed  : $missedQuestions`n======================================================================================================="
    $outputStr += $outputFooterStr

    if ($objTallies[0] -gt 0) {
        Write-Host $outputStr -Background DarkRed
    } else {
        Write-Host $outputStr
    }

    try {
        $saveDir = Join-Path -Path $modConfig.SaveDirStr -ChildPath 'Student_files'
        Write-Host "Creating file '$saveDir/$nameStr.txt' and saving ..... " -NoNewline
        New-Item -Path $saveDir -Name "$nameStr.txt" -Force 1> $null
        Set-Content -Path "$saveDir/$nameStr.txt" -Value $outputStr
        Write-Host "Successful!"
        $comboOutputFileStr += $outputStr + "`n=======================================================================================================`n=======================================================================================================`n`n"
    } catch {
        Write-Error "Unknown error while trying to save file: $saveDir/$nameStr.txt"
        Pause
    }

    try {
        Write-Host "Creating file '$saveDir/$nameStr.xlsx' and saving ..... " -NoNewline
        $excel = (ConvertFrom-Csv $excelStr | Export-Excel -Path "$saveDir/$nameStr.xlsx" -WorksheetName "$nameStr" -AutoSize -PassThru)
        $Range = "B2:B$($modConfig.NumOfObj+1)"
        Set-ExcelRange -Range $Range -Worksheet $excel.$nameStr -FontName "Wingdings"
        Set-ExcelRange -Range "A1:C$($modConfig.NumOfObj+1)" -Worksheet $excel.$nameStr -HorizontalAlignment Center
        Export-Excel -ExcelPackage $excel
        Write-Host "Successful!"
    } catch {
        Write-Error "Unknown error while trying to save file: $saveDir/$nameStr.xlsx"
        Pause
    }

    try {
        Write-Host "Updating '$saveDir/Mod $modNumber Remediation $classnumber.xlsx' and saving ..... " -NoNewline
        $sourceExcel = Open-ExcelPackage -Path "$saveDir/$nameStr.xlsx"
        Copy-ExcelWorksheet -SourceObject $sourceExcel -SourceWorksheet $nameStr -DestinationWorkbook "$saveDir/Mod $modNumber Remediation $classnumber.xlsx" -DestinationWorksheet $nameStr
        Write-Host "Successful!"
    } catch {
        Write-Error "Unknown error while trying to save to file: $saveDir/Mod $modNumber Remediation $classnumber.xlsx"
        Pause
    }

    if ($numOfFoundQuestions -ne $modConfig.MaxNumOfQuestions) {
        Write-Error "$numOfFoundQuestions of questions expected but parsed $($modConfig.MaxNumOfQuestions) Questions!"
        Pause
    }
    if ($totalnumOfMissedQuestions -ne $missedQuestions) {
        Write-Error "$totalnumOfMissedQuestions missed questions by objectives but parsed $missedQuestions Questions!"
        Pause
    }
}
