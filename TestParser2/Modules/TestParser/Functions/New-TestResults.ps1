function New-TestResults {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$test,

        [Parameter(Mandatory = $true)]
        [PSObject]$student
    )

    # Initialize variables
    $missedQuestions = 0
    $objTallies = @( 0 ) * ( $modConfig.NumOfObj + 1 )
    $logDir = Join-Path -Path $modConfig.LogDirStr -ChildPath 'Student_Files'
    $nameStr = $student.fullname
    $objectiveStrings = $modConfig.objectives
    $numOfFoundQuestions = $modConfig.MaxNumOfQuestions
    $modNumber = $modConfig.Mod

    # Process the test questions
    $curObjNum = 0
    foreach ($question in $test.questions) {
        $result = Get-QuestionObjectiveNumber -question $question
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
            $excelStr += [string]$objTally + ','+[char]$wingDingChar+',"' + $curObjNum + ".  " + $objectiveStrings[$curObjNum-1] + '"'+"`n"
        } elseif ($curObjNum -eq 0 -and $objTally -ne 0) {
            $outputStr += "`t`tNo Objective Parsed `t--> $objTally`n"
            $outputStr += "`t`t-----------------------------------`n"
            $excelStr += [string]$objTally + ',' + [char]$wingDingChar + ',"' + $curObjNum + ".  " + "Could not Parse" + '"' + "`n"
        } elseif ($curObjNum -gt 0) {
            $outputStr += "$modNumber. $curObjNum `t--> $objTally`n"
            $excelStr += [string]$objTally + ','+[char]$wingDingChar+',"' + $curObjNum + ".   " + $objectiveStrings[$curObjNum-1] + '"'+"`n"
        }
        $curObjNum += 1
    }

    $outputFooterStr = "Total Questions Missed  : $missedQuestions`n======================================================================================================="
    $outputStr += $outputFooterStr

    # Save the text output
    Write-Verbose "Creating file '$logDir/$nameStr.txt' and saving ..."
    New-Item -Path $logDir -Name "$nameStr.txt" -Force 1> $null
    Set-Content -Path "$logDir/$nameStr.txt" -Value $outputStr
    Write-Verbose "File saved successfully."
    Write-Output "Text file '$nameStr.txt' has been saved successfully."

    # Save the Excel report
	# Save the Excel report
	Write-Verbose "Creating file '$logDir/$nameStr.xlsx' and saving ..."
	$excel = (ConvertFrom-Csv $excelStr | Export-Excel -Path "$logDir/$nameStr.xlsx" -WorksheetName "$nameStr" -AutoSize -PassThru)
	$ws = $excel.workbook.worksheets[1]
	
	# Define ranges for the formatting
	$checkBoxRange = "B2:B$($modConfig.NumOfObj+1)"
	$headerRange = "A1:C1"
	$outputRange = "A2:C$($modConfig.NumOfObj+1)"
	$fullRange = "A1:C$($modConfig.NumOfObj+1)"
	
	$ws.PrinterSettings.Orientation = "Landscape"
	 
	$ws.Cells["C1"].RichText.Add("$nameStr").bold = $true
	 
	 
	Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderTop Thin
	Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderBottom Thin
	Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderRight Thin
	Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderLeft Thin

	
	Set-ExcelRange -Range $headerRange -Worksheet $ws -BorderAround Thick
	Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderAround Thick

	set-ExcelColumn -Worksheet $ws -Column 3 -Width 100
	set-ExcelColumn -Worksheet $ws -Column 1 -HorizontalAlignment Center
	set-ExcelColumn -Worksheet $ws -Column 2 -HorizontalAlignment Center
	
	$excel.Workbook.Worksheets[$nameStr].Cells.Style.Font.Name = "Calibri"
	$excel.Workbook.Worksheets[$nameStr].Cells.Style.Font.size = "12"
	
	# Set Wingdings font for the checkbox column (Column B)
	$excel.Workbook.Worksheets[$nameStr].Cells[$checkBoxRange].Style.Font.Name = "Wingdings"
	$excel.Workbook.Worksheets[$nameStr].Cells[$checkBoxRange].Style.HorizontalAlignment = 'Center'

	# Export the final Excel file
	#Export-Excel -ExcelPackage $excel
	Close-ExcelPackage $excel
	Write-Verbose "Excel file saved successfully."
	Write-Output "Excel file '$nameStr.xlsx' has been saved successfully."



    # Update the existing workbook
    Write-Verbose "Updating '$logDir/$($script:ModConfig.saveFileName)' and saving ..."
    $sourceExcel = Open-ExcelPackage -Path "$logDir/$nameStr.xlsx"
    Copy-ExcelWorksheet -SourceObject $sourceExcel -SourceWorksheet $nameStr -DestinationWorkbook "$logDir/$($script:ModConfig.saveFileName)" -DestinationWorksheet $nameStr
    Write-Verbose "Update successful."
    Write-Output "Workbook '$($script:ModConfig.saveFileName)' has been updated successfully."

    # Copy the updated file to the save directory
    Write-Verbose "Copying the updated file to $script:ModConfig.saveDirStr ..."
    $destinationPath = Join-Path -Path $script:ModConfig.saveDirStr -ChildPath $script:ModConfig.saveFileName
    Copy-Item -Path "$logDir/$($script:ModConfig.saveFileName)" -Destination $destinationPath -Force
    Write-Verbose "File copied to $destinationPath successfully."
    Write-Output "File '$($script:ModConfig.saveFileName)' has been copied to $destinationPath successfully."
}
