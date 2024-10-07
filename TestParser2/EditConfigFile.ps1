# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Edit Configuration File"
$form.Size = New-Object System.Drawing.Size(600, 400)
$form.StartPosition = "CenterScreen"

# Create a TextBox for editing the file content
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ScrollBars = "Vertical"
$textBox.Dock = "Fill"
$form.Controls.Add($textBox)

# Create a menu strip for file operations
$menuStrip = New-Object System.Windows.Forms.MenuStrip
$form.Controls.Add($menuStrip)

# Create "File" menu
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem("File")
$menuStrip.Items.Add($fileMenu)

# Create "Open" menu item
$openMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Open")
$fileMenu.DropDownItems.Add($openMenuItem)

# Create "Save" menu item
$saveMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("Save")
$fileMenu.DropDownItems.Add($saveMenuItem)

# Create "New" menu item
$newMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem("New")
$fileMenu.DropDownItems.Add($newMenuItem)

# Open file dialog
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Filter = "Text files (*.txt;*.conf)|*.txt;*.conf|All files (*.*)|*.*"

# Save file dialog
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveFileDialog.Filter = "Text files (*.txt;*.conf)|*.txt;*.conf|All files (*.*)|*.*"

# Load the content of the file when "Open" is clicked
$openMenuItem.Add_Click({
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textBox.Text = Get-Content -Path $openFileDialog.FileName -Raw
    }
})

# Save the content of the TextBox to a file when "Save" is clicked
$saveMenuItem.Add_Click({
    if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        Set-Content -Path $saveFileDialog.FileName -Value $textBox.Text
    }
})

# Clear the TextBox when "New" is clicked
$newMenuItem.Add_Click({
    $textBox.Clear()
})

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
