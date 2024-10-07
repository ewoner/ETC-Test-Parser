# Function to prompt user for Moodle username and retrieve token if available
function Get-User {
    [CmdletBinding()]
    param ()
    
    # Script-scoped User object
    $script:user = $null
    
    # Initialize variables
    $tokenPath = "$script:TokenPath"
    $usernameOptions = @()
    $selectedUsername = $null
    
    while (-not $selectedUsername) {
        # Clear screen and display menu of username options
        #Clear-Host
        Write-Host "Select a username:"
        Write-Host "1. $env:USERNAME (current user)"
        
        # Check if a tokens file exists
        if (Test-Path $tokenPath -PathType Leaf) {
            try {
                # Read all lines from the tokens file
                $tokenLines = Get-Content $tokenPath
                
                # Get usernames from tokens file, excluding current user environment variable username
                $tokenLines | ForEach-Object {
                    $lineUsername = ($_ -split '\s+')[0]
                    if ($lineUsername -ne $env:USERNAME -and $lineUsername -notin $usernameOptions) {
                        $usernameOptions += $lineUsername
                        Write-Host "$($usernameOptions.Count + 1). $lineUsername"
                    }
                }
            } catch {
                Write-Host "Failed to read tokens file."
            }
        }
        
        Write-Host "N. Enter a new username"
        Write-Host "E. Exit"
        
        # Prompt user for selection
        $choice = Read-Host "Enter selection"
        
        switch -Regex ($choice) {
            '^[1]$' {
                # Select current user environment variable username
                $selectedUsername = $env:USERNAME
            }
            '^\d+$' {
                # Numeric input corresponds to index in $usernameOptions
                $selectedIndex = [int]$choice - 2
                if ($selectedIndex -ge 0 -and $selectedIndex -lt $usernameOptions.Count) {
                    $selectedUsername = $usernameOptions[$selectedIndex]
                } else {
                    Write-Host "Invalid selection."
                    Start-Sleep -Seconds 2  # Pause for readability
                }
            }
            '^[Nn]$' {
                # Option to enter a new username
                $selectedUsername = Read-Host "Enter new username"
            }
            '^[Ee]$' {
                # Option to exit
                Write-Host "Exiting..."
                return $null
            }
            default {
                Write-Host "Invalid selection."
                Start-Sleep -Seconds 2  # Pause for readability
            }
        }
    }
   $script:user = [User]::new($selectedUsername)
    
    # Check if a stored token exists for the selected username
    $token = $false
    try {
        # Read all lines from the tokens file
        $tokenLines = Get-Content $tokenPath
        
        # Search for the selected username in the token file and retrieve the corresponding token
        $tokenLine = $tokenLines | Where-Object { $_ -match "^$selectedUsername\s+(.*)" }
        
        if ($tokenLine) {
            $script:user.Token = $matches[1] | ConvertTo-SecureString
            Write-Host "Token found and loaded from local app files."
            $token = $true
        } else {
            Write-Host "No token found for user $script:user.username in local app files."
        }
    } catch {
        Write-Host "Failed to load token from local app files."
    }
    
    # If token is not found, call Get-Token to retrieve it
    if (-not $token) {
        $token = Get-Token
    }
    
    # Set script-scoped User object with username and token
    return $script:user
}
