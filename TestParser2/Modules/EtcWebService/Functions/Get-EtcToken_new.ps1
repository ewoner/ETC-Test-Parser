<#
.SYNOPSIS
    Retrieves a token from Moodle and saves it to local application files.
.DESCRIPTION
    This function attempts to load an existing token from local files or, if not found, retrieves a new token from Moodle. It also handles the case where a password needs to be entered.
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

function Get-EtcToken {
    [CmdletBinding()]
    param (
        [string]$username = $script:user.UserName,
        [securestring]$password = $script:user.password,
        [switch]$force
    )
    
    # Initialize variables
    $userDataPath = $script:config.userDataPath
    
    # Return null if username is null
    if (-not $username) {
        Write-Host "Username is null. Cannot retrieve token."
        return
    }

    if ($force) {
        Write-Verbose "Forcing token refresh and clearing existing token and password."
        $script:user.token = $null
        $script:user.password = $null
    }
    
    if ($script:user.token) {
        Write-Host "User already has a token."
        return
    }

    try {
        # Read all lines from the tokens file
        Write-Debug "Reading token file from path: $userDataPath"
        $tokenLines = Get-Content $userDataPath
        
        # Search for the selected username in the token file and retrieve the corresponding token
        $tokenLine = $tokenLines | Where-Object { $_ -match "^$username\s+(.*)" }
        
        if ($tokenLine) {
            Write-Verbose "Token found in local app files."
            $script:user.Token = $matches[1] | ConvertTo-SecureString
            Write-Host "Token found and loaded from local app files."
            return
        } else {
            Write-Host "No token found for user $($script:user.UserName) in local app files."
        }
    } catch {
        Write-Host "Failed to load token from local app files."
    }

    try {
        if (-not $script:user.token) {
            Write-Verbose "No token found. Prompting user for password and retrieving a new token."
            $script:user.password = Read-Host "Enter your ETC Password:" -AsSecureString
            Write-Debug "Invoking web service to retrieve token."
            $response = Invoke-EtcRestMethod -Token
            if ($response.token) {
                $script:user.Token = $response.token | ConvertTo-SecureString -AsPlainText -Force
                $script:user.password = $null
                Add-Content -Path $script:config.UserDataPath -Value "$username $($script:user.token | ConvertFrom-SecureString)"
                Write-Host "Token retrieved and saved to local app files."
                return
            } else {
                Write-Host "Failed to retrieve token from Moodle."
                return
            }
        }
    } catch {
        Write-Host "Failed to retrieve token: $_"
        return 
    }
}
