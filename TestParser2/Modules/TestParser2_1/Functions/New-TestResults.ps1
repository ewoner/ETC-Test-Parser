<#
.SYNOPSIS
Generates test results for a student and saves them to a text file and an Excel report.

.DESCRIPTION
This function generates test results for a student and saves them to a text file and an Excel report, including the number of missed questions and other relevant details.

.VERSION
1.0.0

.AUTHOR
Brion Lang

.NOTES
Versioning specification: https://semver.org/
See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for a complete description, current updates, and future plans.

.PARAMETER test
The test object to process.

.PARAMETER student
The student object associated with the test.

.EXAMPLE
New-TestResults -test $testObject -student $studentObject

.INPUTS
[System.Management.Automation.PSObject] $test
The test object to process.

[System.Management.Automation.PSObject] $student
The student object associated with the test.

.OUTPUTS
[System.String]
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
<#
Changelog for New-TestResults

Version 1.1.0
Date: 2024-10-21
Changes:
- Objective Tally Handling:
  - Updated to handle the new return value structure from Get-QuestionObjectiveNumber.
  - If Get-QuestionObjectiveNumber returns 0, it indicates "Objective Not found in HTML". 
    - A new objective with number 0 and description "Objective Not found in HTML" is added to the objectives array or its tally is incremented if it already exists.
  
- Incrementing Tallies:
  - Adjusted the logic to correctly increment the objective tallies based on the values returned by Get-QuestionObjectiveNumber, ensuring consistency with the new behavior.

- Logging Enhancements:
  - Updated verbose messages to reflect the new objective handling and tallying behavior, aiding in debugging and tracking of objective processing.

- Output Preparation:
  - Removed or modified sections that rely on direct integer returns for objectives, focusing instead on the revised handling and reporting.
#>

function New-TestResults {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [PSObject]$test,

    [Parameter(Mandatory = $true)]
    [PSObject]$student
  )

  # Initialize variables for processing
  Write-Verbose "Initializing variables..."
  $missedQuestions = 0
  $logDir = Join-Path -Path $modConfig.LogDirStr -ChildPath 'Student_Files'
  $nameStr = $student.fullname
  $objectives = $modConfig.objectives
  $numOfFoundQuestions = $modConfig.MaxNumOfQuestions
  $modNumber = $modConfig.Mod
  


  # Reset the Tally property for each objective in the $modConfig.objectives array
  foreach ($objective in $objectives) {
    $objective.tallies = 0
  }


  # Process the test questions
  Write-Verbose "Processing test questions..."
  foreach ($question in $test.questions) {
    $result = Get-QuestionObjectiveNumber -question $question
    if ($result -is [int] ) {
      if ( $result -eq 0 ) {
        $objectives[0].incrementTally()
      }
      elseif ( $result -gt 0 ) {
        $objectives[ $result ].incrementTally()
      }
    }
    elseif ( $result -is [hashtable] ) {
      # For Daily Objectives, find the correct day and objective
      $day = $result.Day
      $objective = $result.Objective
			
      # Assuming the objectives are organized in a way that allows direct indexing
      $obj = $objectives | Where-Object { $_.dayNum -eq $day -and $_.objNum -eq $objective }
      $obj.incrementTally()
      Write-Verbose "  - ModNum: $($obj.modNum), DayNum: $($obj.dayNum), ObjNum: $($obj.objNum), ObjString: $($obj.objString), Tallies: $($obj.tallies)"
    }
  }
	if ($modConfig.objectives[0].tallies) {
    $objNum = $modConfig.objectives.count
  }
  else {
    $objNum = $modConfig.objectives.count - 1
  }
  # Initialize the output string
  # Calculate the sum of all tallies
  $missedQuestions = ($modConfig.objectives | Measure-Object -Property Tallies -Sum).Sum
  $excelStr = '"# Missed" ,' + $missedQuestions + ",`"$nameStr`"`n"   

  # Prioritize and display Objective 0 if it has a tally
  $firstObj = $objectives | Where-Object { $_.objNum -eq 0 -and $_.tallies -gt 0 }
  if ($firstObj) {
    $wingDingChar = if ($firstObj.tallies -eq 0) { 168 } else { 254 }
    $excelStr += [string]$firstObj.tallies + ',' + [char]$wingDingChar + ',"' + $firstObj.modNum + ".0 - " + $firstObj.objString + '"' + "`n"
  }

  # Loop through remaining objectives and generate the Excel output
  foreach ($obj in $objectives | Where-Object { $_.objNum -ne 0 }) {
    $wingDingChar = if ($obj.tallies -eq 0) { 168 } else { 254 }

    if ($obj.dayNum -eq 0) {
      # For Module Objectives
      $excelStr += [string]$obj.tallies + ',' + [char]$wingDingChar + ',"' + $obj.modNum + "." + $obj.objNum + " - " + $obj.objString + '"' + "`n"
    }
    else {
      # For Daily Objectives
      $excelStr += [string]$obj.tallies + ',' + [char]$wingDingChar + ',"' + $obj.modNum + "." + $obj.dayNum + "." + $obj.objNum + " - " + $obj.objString + '"' + "`n"
    }
  }


  # Save the Excel report
  $excel = (ConvertFrom-Csv $excelStr | Export-Excel -Path "$logDir/$nameStr.xlsx" -WorksheetName "$nameStr" -AutoSize -PassThru)
  $ws = $excel.workbook.worksheets[1]

	
  # Define ranges for the formatting
  $checkBoxRange = "B2:B$($Objnum + 1)"
  $headerRange = "A1:C1"
  $outputRange = "A2:C$($Objnum + 1)"
  $fullRange = "A1:C$($Objnum + 1)"

  # Set worksheet printer settings
  $ws.PrinterSettings.Orientation = "Landscape"
    
  # Set the student name in the Excel report
  $ws.Cells["C1"].Style.Font.Bold = $true
    
  # Set borders for the ranges
  Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderTop Thin
  Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderBottom Thin
  Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderRight Thin
  Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderLeft Thin

  Set-ExcelRange -Range $headerRange -Worksheet $ws -BorderAround Thick
  Set-ExcelRange -Range $fullRange -Worksheet $ws -BorderAround Thick

  # Adjust column formatting
  set-ExcelColumn -Worksheet $ws -Column 3 -Width 100
  set-ExcelColumn -Worksheet $ws -Column 1 -HorizontalAlignment Center
  set-ExcelColumn -Worksheet $ws -Column 2 -HorizontalAlignment Center
        
  # Set font styles for the worksheet
  $excel.Workbook.Worksheets[$nameStr].Cells.Style.Font.Name = "Calibri"
  $excel.Workbook.Worksheets[$nameStr].Cells.Style.Font.size = "12"
        
  # Set Wingdings font for the checkbox column (Column B)
  $excel.Workbook.Worksheets[$nameStr].Cells[$checkBoxRange].Style.Font.Name = "Wingdings"
  $excel.Workbook.Worksheets[$nameStr].Cells[$checkBoxRange].Style.HorizontalAlignment = 'Center'

  # Export the final Excel file
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
