<#
.SYNOPSIS
    Prompts the user to select or enter a Moodle username and retrieves the associated token.
.DESCRIPTION
    This function provides a menu for selecting or entering a username. If the selected username is associated with an existing token, it retrieves and uses it. Otherwise, it prompts the user for credentials and retrieves a new token.
.VERSION
    1.0.0-dev1
.FILE_VERSION
    1.0.0-dev1-240815
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
#>

function Get-EtcUser {
    [CmdletBinding()]
    param (
        [switch]$remove,
        [switch]$force
    )   

    if ($remove) {
        Write-Verbose "Removing user information from script scope."
        $script:user = $null
        return $null
    }

    if ($force) {
        Write-Verbose "Forcing user reset."
        $script:user = $null
    }

    if (-not $script:user) {
        # Initialize variables
        $userDataPath = $script:config.UserDataPath
        $usernameOptions = @()
        $selectedUsername = $null
        
        while (-not $selectedUsername) {
            # Display menu of username options
            Write-Host "Select a username:"
            Write-Host "1. $env:USERNAME (current user)"
            
            # Check if a tokens file exists
            if (Test-Path $userDataPath -PathType Leaf) {
                try {
                    # Read all lines from the tokens file
                    Write-Debug "Reading tokens file from path: $userDataPath"
                    $tokenLines = Get-Content $userDataPath
                    
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
            
            Write-Host "N. Enter another username and password"
            Write-Host "E. Exit"
            
            # Prompt user for selection
            $choice = Read-Host "Enter selection"
            
            switch -Regex ($choice) {
                '^[1]$' {
                    # Select current user environment variable username
                    $selectedUsername = $env:USERNAME
                    Write-Verbose "Selected current user: $selectedUsername"
                    break
                }
                '^\d+$' {
                    # Numeric input corresponds to index in $usernameOptions
                    $selectedIndex = [int]$choice - 2
                    if ($selectedIndex -ge 0 -and $selectedIndex -lt $usernameOptions.Count) {
                        $selectedUsername = $usernameOptions[$selectedIndex]
                        Write-Verbose "Selected username from list: $selectedUsername"
                    } else {
                        Write-Host "Invalid selection."
                        Start-Sleep -Seconds 2  # Pause for readability
                    }
                    break
                }
                '^[Nn]$' {
                    # Option to enter a new username
                    $selectedUsername = Read-Host "Enter username"
                    Write-Verbose "Entered new username: $selectedUsername"
                    break
                }
                '^[Ee]$' {
                    # Option to exit
                    Write-Host "Exiting..."
                    return $null  # Return null indicating exit
                }
                default {
                    Write-Host "Invalid selection."
                    Start-Sleep -Seconds 2  # Pause for readability
                    break
                }
            }
        }

        # Create new EtcUser object and retrieve token and site info
        $script:user = [EtcUser]::new($selectedUsername)
        Get-EtcToken
        Get-EtcSiteInfo
    }
    
    # Return the script-scoped User object with username and token
    Write-Verbose "Returning user object with username and token."
    return $script:user
}
