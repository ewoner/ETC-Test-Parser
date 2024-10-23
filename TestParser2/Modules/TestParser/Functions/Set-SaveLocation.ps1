# Function to prompt the user to change the save directory and file name.
function Set-SaveLocation {

	$filename = $modConfig.GetFileName($classNumber)
    # Prompt user to change the save directory and file name
    $changeSaveDir = Read-Host -Prompt "Output will be saved as $($filename) in the directory $($modConfig.SaveDirStr)`nDo you wish to change these settings (y/N)"
    Write-Verbose "User prompted to change save settings."
    Write-Debug "User input for changing save settings: $changeSaveDir"
    Write-Log -logEntry "User prompted to change save settings."

    if ($changeSaveDir -eq 'y') {
        try {
            # Load Windows Forms assembly
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        } catch {
            $errorMessage = "Failed to load Windows Forms assembly. Using default directory and file name."
            Write-Host $errorMessage
            Write-Log -logEntry $errorMessage
            Handle-Error -errorMessage "$errorMessage Error details: $_" -donotexit $_.scriptstacktrace
            return
        }

        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Filter = "Excel files (*.xlsx)|*.xlsx|All Files (*.*)|*.*"
        Write-Verbose "File dialog initialized with filter settings."
        Write-Debug "File dialog filter set to: $($dialog.Filter)"
        Write-Log -logEntry "File dialog initialized with filter settings."

        # Set the initial directory based on the environment
        if ($devParser -eq 'off') {
            $dialog.InitialDirectory = $modConfig.SaveDirStr
        }
        else {
            $dialog.InitialDirectory = "C:\Users\$env:USERNAME\Downloads"
        }
        Write-Verbose "Initial directory set to $($dialog.InitialDirectory)."
        Write-Log -logEntry "Initial directory set to $($dialog.InitialDirectory)."

        # Set the default file name and show the dialog
        $dialog.FileName = $modConfig.GetFileName($classNumber)

        try {
            $dialogResult = $dialog.ShowDialog()
        } catch {
            $errorMessage = "Failed to show SaveFileDialog. Using default directory and file name."
            Write-Host $errorMessage
            Write-Log -logEntry $errorMessage
            Handle-Error -errorMessage "$errorMessage Error details: $_" -donotexit $_.scriptstacktrace
            return
        }
        Write-Verbose "SaveFileDialog shown."
        Write-Debug "SaveFileDialog result: $dialogResult"
        Write-Log -logEntry "SaveFileDialog shown. Result: $dialogResult."

        if ($dialogResult -eq [System.Windows.Forms.DialogResult]::OK) {
            # Retrieve the selected path and file name
            $selectedPath = [System.IO.Path]::GetDirectoryName($dialog.FileName)
            $selectedFileName = [System.IO.Path]::GetFileName($dialog.FileName)
            Write-Verbose "User selected file: $($dialog.FileName)."
            Write-Debug "Selected path: $selectedPath, selected file name: $selectedFileName"
            Write-Log -logEntry "User selected file: $($dialog.FileName)."

            try {
                if (-Not (Test-Path -Path $selectedPath)) {
                    # Directory does not exist, use default values
                    $errorMessage = "The selected directory does not exist. Using the default directory: $($modConfig.SaveDirStr) and file name: $($modConfig.GetFileName($classNumber))."
                    Write-Host $errorMessage
                    Write-Verbose "Selected directory does not exist. Reverting to default directory and file name."
                    Write-Log -logEntry $errorMessage
                }
                else {
                    # Update the configuration with the selected path and file name
                    $modConfig.SaveDirStr = $selectedPath
                    $modConfig.SaveFileName = $selectedFileName
                    Write-Verbose "Updated save directory to $selectedPath and file name to $selectedFileName."
                    Write-Log -logEntry "Updated save directory to $selectedPath and file name to $selectedFileName."
                }
            } catch {
                $errorMessage = "Error checking or updating path. Using default directory and file name."
                Write-Host $errorMessage
                Write-Log -logEntry $errorMessage
                Handle-Error -errorMessage "$errorMessage Error details: $_" -donotexit $_.scriptstacktrace
            }
        }
        else {
            # File save operation was canceled
            $errorMessage = "File save operation was canceled. Using default directory: $($modConfig.SaveDirStr) and file name: $($modConfig.GetFileName($classNumber))."
            Write-Host $errorMessage
            Write-Verbose "File save operation was canceled. Using default directory and file name."
            Write-Log -logEntry $errorMessage
        }
    }
	else {
		$modConfig.SaveFileName = $filename
	}
}