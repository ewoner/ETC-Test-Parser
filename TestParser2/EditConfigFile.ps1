# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create the main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Edit Configuration"
$form.Size = New-Object System.Drawing.Size(600, 600)
$form.StartPosition = "CenterScreen"

# Global variables for UI controls
$global:labelSaveDir
$global:labelObjectives
$global:textObjectives


# Function to create the main form
function CreateMainForm {
    $defaultFont = New-Object System.Drawing.Font("Calibri", 12)

    $global:menuStrip = New-Object System.Windows.Forms.MenuStrip
    $menuStrip.Location = New-Object System.Drawing.Point(0, 0)
    $menuStrip.Size = New-Object System.Drawing.Size(600, 25)
    $form.Controls.Add($menuStrip)
    CreateFileMenu $menuStrip

    $global:labelMod = CreateLabel "Mod:" 10 40
	$global:comboMod = CreateComboBox (1..17) 120 40
	
	$global:labelSaveDir = CreateLabel "Save Directory:" 10 80
	$global:buttonSaveDirStr = CreateButton "Browse..." 120 75 -Click { BrowseForDirectory }
	$global:labelCurrentDir = CreateLabel "" 250 75

	$global:labelObjRegexPattern = CreateLabel "Object Regex Pattern:" 10 120
	$global:textObjRegexPattern = CreateTextBox 120 120
	$global:textObjRegexPattern.Font = $defaultFont

	$global:labelTitle = CreateLabel "Title:" 10 160
	$global:textTitle = CreateTextBox 120 160
	$global:textTitle.Font = $defaultFont

	$global:labelObjModNum = CreateLabel "Object Mod Number:" 10 200
	$global:comboObjModNum = CreateComboBox (1..20) 120 200

	$global:labelNumOfObj = CreateLabel "Number of Objects:" 10 240
	$global:comboNumOfObj = CreateComboBox (1..20) 120 240

	$global:labelNumOfDays = CreateLabel "Number of Days:" 10 280
	$global:comboNumOfDays = CreateComboBox (1..20) 120 280

	$global:labelMaxNumOfQuestions = CreateLabel "Max Number of Questions:" 10 320
	$global:textMaxNumOfQuestions = CreateTextBox 120 320
	$global:textMaxNumOfQuestions.Font = $defaultFont

    CreateObjectivesSection

    # Show the form
    $form.Add_Shown({$form.Activate()})
    $form.ShowDialog() | Out-Null  # No assignment needed
}


# Function to create a label
function CreateLabel {
    param (
        [string]$text,
        [int]$x,
        [int]$y
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $form.Controls.Add($label)
    return $label
}

# Function to create a combo box
function CreateComboBox {
    param (
        [array]$items,
        [int]$x,
        [int]$y
    )

    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.Location = New-Object System.Drawing.Point($x, $y)
    $comboBox.Items.AddRange($items)
    $form.Controls.Add($comboBox)

    return $comboBox
}

# Function to create a text box
function CreateTextBox {
    param (
        [int]$x,
        [int]$y
    )
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point($x, $y)
    $textBox.Size = New-Object System.Drawing.Size(400, 20)
    $form.Controls.Add($textBox)
    return $textBox
}

# Function to create a button
function CreateButton {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [ScriptBlock]$ClickAction
    )
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $text
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Add_Click($ClickAction)
    $form.Controls.Add($button)
    return $button
}

# Function to create the objectives section
function CreateObjectivesSection {
    $global:labelObjectives = CreateLabel "Objectives:" 10 380

    # Create a panel for Objectives to add scroll bars
    $objectivesPanel = New-Object System.Windows.Forms.Panel
    $objectivesPanel.Location = New-Object System.Drawing.Point(120, 380)
    $objectivesPanel.Size = New-Object System.Drawing.Size(400, 100)
    $objectivesPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

    $global:textObjectives = New-Object System.Windows.Forms.TextBox
    $textObjectives.Location = New-Object System.Drawing.Point(0, 0)
    $textObjectives.Size = New-Object System.Drawing.Size(400, 100)
    $textObjectives.Multiline = $true
    $textObjectives.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $objectivesPanel.Controls.Add($textObjectives)

    $form.Controls.Add($objectivesPanel)
}

# Function to browse for directory
function BrowseForDirectory {
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowserDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:labelCurrentDir.Text = $folderBrowserDialog.SelectedPath
    }
}

# Function to create the file menu
function CreateFileMenu {
    param (
        [System.Windows.Forms.MenuStrip]$menuStrip
    )
    $fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem("File")
    $menuStrip.Items.Add($fileMenu)

    $newMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("New")
    $newMenuItem.Add_Click({ CreateNewConfig })
    $fileMenu.DropDownItems.Add($newMenuItem)

    $openMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Open")
    $openMenuItem.Add_Click({ OpenConfig })
    $fileMenu.DropDownItems.Add($openMenuItem)

    $saveMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Save")
    $saveMenuItem.Add_Click({ SaveConfig })
    $fileMenu.DropDownItems.Add($saveMenuItem)

    $closeMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Close")
    $closeMenuItem.Add_Click({ $form.Close() })
    $fileMenu.DropDownItems.Add($closeMenuItem)
}

function CreateNewConfig {
    # Clear all fields
    $global:comboMod.SelectedIndex = -1
    $global:textObjRegexPattern.Text = ""
    $global:textTitle.Text = ""
    $global:comboObjModNum.SelectedIndex = -1
    $global:comboNumOfObj.SelectedIndex = -1
    $global:comboNumOfDays.SelectedIndex = -1
    $global:textMaxNumOfQuestions.Text = ""
    $global:textObjectives.Text = ""
    $global:labelCurrentDir.Text = ""
}


function OpenConfig {
    # Open a file dialog to select a configuration file
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "Configuration Files (*.conf)|*.conf"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Load the configuration from the file
        $config = Get-Content -Path $openFileDialog.FileName
        # Populate the fields with the configuration data
        $objectives = @()
        $inObjectives = $false
        foreach ($line in $config) {
            if ($line -match "mod\s*=\s*(\d+)") {
                $global:comboMod.SelectedIndex = [int]$matches[1] - 1
            } elseif ($line -match "objModNum\s*=\s*(\d+)") {
                $global:comboObjModNum.SelectedIndex = [int]$matches[1] - 1
            } elseif ($line -match "numOfObj\s*=\s*(\d+)") {
                $global:comboNumOfObj.SelectedIndex = [int]$matches[1] - 1
            } elseif ($line -match "numOfDays\s*=\s*(\d+)") {
                $global:comboNumOfDays.SelectedIndex = [int]$matches[1] - 1
            } elseif ($line -match "maxNumOfQuestions\s*=\s*(\d+)") {
                $global:textMaxNumOfQuestions.Text = $matches[1]
            } elseif ($line -match "^\s*<objectives>\s*$") {
                $inObjectives = $true
            } elseif ($line -match "^\s*</objectives>\s*$") {
                $inObjectives = $false
                $global:textObjectives.Text = $objectives -join [Environment]::NewLine
            } elseif ($inObjectives) {
                $objectives += $line
            } elseif ($line -match "saveDirStr\s*=\s*(.*)") {
                $global:labelCurrentDir.Text = $matches[1]
            }
        }
    }
}

function SaveConfig {
    # Save the current configuration to a file
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "Configuration Files (*.conf)|*.conf"
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # Get the configuration data from the fields
        $mod = $($global:comboMod.SelectedIndex + 1)
        $htmlDirStr = $global:labelCurrentDir.Text
        $saveDirStr = $global:labelCurrentDir.Text
        $objRegexPattern = $global:textObjRegexPattern.Text
        $title = $global:textTitle.Text
        $objModNum = $($global:comboObjModNum.SelectedIndex + 1)
        $numOfObj = $($global:comboNumOfObj.SelectedIndex + 1)
        $numOfDays = $($global:comboNumOfDays.SelectedIndex + 1)
        $maxNumOfQuestions = $global:textMaxNumOfQuestions.Text
        $objectives = $global:textObjectives.Text

        # Save the configuration to the file
		$configHeader = @"
####################################################################################################################################################################
#
# Configuration file for TestParser.ps1
#
# Filename: "mod?.conf" 
#	where:
#		? is the module's order in JCAC. See below.
#	
#File Context:	
# Lines that begin with '#' are ignored (REGEX ^\s*#[^\n]*
# Required lines:
#	one Variable named "mod" assigned an integer to the current order in JCAC.
#   one Objectives Block.  Must have one line per line per "numOfObj"
#
# Note:  EBNF is used for all formating lines below.
#
#
# Case-Sensitivity:
#	Variable names and all tags are case-insensitive.  Object Lines, variables strings
#   and the tags are case-sensitive.
#
# Other than the Objectives Block's basic formating, order of lines in file  
#	does not matter.  If two lines contain the same variable name, only the 
#	last ocurrance will be used, the others will basicalyl by ignored.  This 
#	includes if there are Two different Objectives Blocks.
#	
# Format for basic value assignment lines:
#     <variables_name> '=' <string>
#			(spacing before or after '=' is  ignored)
#      where: 
#			<variable_name> can be only a signle, case-insensitive word of 
#				alpha-numaric characters with the underscore, 
#           	but cannot start with a digit. ( Regex [a-z_]\w+ )
#
#			<string>  can be any set of characters upto the end of line. 
#				The string does not require to be in quotes
#				ANy quotes will be retained as either single or double.
#               Any trailing whitespace WILL be added to <string> 
#               if there are NO quotes.  ( Regex [^\n]+ )
#
# Format for Objective Block:
#	"<Objectives>"
#   	<OBJECTIVE_LINE>	
#	"</Objectives>"
# where:
#		<OBJECTIVE_LINE> --> One Line of text (without Mod# and Objective#) per objective 
#							 (Regex [^\n]*)	
#		Insure that the Objective Text is in the Order from the Guide.
#		Number of Module Objectives is taken from the number of lines here
#       The variable "numOfObj" is for quality control only and not needed.
#
#
# Value asignment names:
#		mod --> the Mod's Number.  Used as a keyID for parsing as titles may change.
#		title --> The mod's string name.
#       objModNum --> The Mod's current Objective Number ( IE Programming/Scripting is '9' as of 22 May 24 )
#		htmlDirStr --> The directory (absolute or reletive to ps1 file's location) where to find the html files to parse.  Setting does NOT created
#		saveDirStr -->  The directory (aboslute or reletive to ps1 file's location) where to save results.  Setting does NOT create.
#		objRegexPattern --> a Regex search string to parse out the questions's HTML string.  MUST have at least TWO groups:
#				1st Capture Group will be the mod number
#				2nd Capture Group will be the mod objective number
#				3rd Capture Group will be the daily objective number
#		nameRegexPattern --> a Regex search string to parse out the student's name from the HTML file.
#       endOfQuestionRegexPattern --> a Regex search string that will signal to stop parsing a question
#		numOfObj --> The Highest mod objective number
#		numOfDays --> The Highest daily objective number
#		maxNumOfQuestions --> The maximum number of questions on the test.
#		saveFileName --> The name of the file to save.
#
# Placeholders:  (not implemented yet)
#		Format:  $<placeholder_name>
#			Placeholders are values whose value may change depending on runtime parem enters.
#			All value assignment names above are valid placeholder names
#			They may be used in any value below Except ones with REGEX in their name.
#	
#
# If either numOfObj or maxNumOfQuestions are zero (0), program will exit without parsing.
#
####################################################################################################################################################################		
"@
        $configLines = @"
mod = $mod
htmlDirStr = $htmlDirStr
saveDirStr = $saveDirStr
objRegexPattern = $objRegexPattern
title = $title
objModNum = $objModNum
numOfObj = $numOfObj
numOfDays = $numOfDays
maxNumOfQuestions = $maxNumOfQuestions
<objectives>
$objectives
</objectives>
"@
        Set-Content -Path $saveFileDialog.FileName -Value "$configHeader`n$configLines"
    }
}

# Main execution
CreateMainForm
