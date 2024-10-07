# Function to retrieve token from Moodle and save it to local app files
function Get-Token {
    [CmdletBinding()]
    param (
    [string]$username = $script:user.UserName
    )
    
    # Initialize variables
    $tokenPath = "$env:LOCALAPPDATA\ETC\tokens.txt"
    
    
    # Return null if username is null
    if (-not $username) {
        Write-Host "Username is null. Cannot retrieve token."
        return $null
    }
    
    try {
        # Prompt for password securely
        $script:user.Password = Read-Host "Enter your Moodle password" -AsSecureString
        
        Write-Verbose  "$($script:user.Password)"
        $response = Invoke-EtcRestMethod -Token
        
        if ($response.token) {
            $script:user.Token = $response.token | ConvertTo-SecureString -AsPlainText -Force
            
            # Save token to local app files
            $tokenLine = "$username $( $script:user.Token | ConvertFrom-SecureString)"
            Add-Content -Path $tokenPath -Value $tokenLine
            
            Write-Host "Token retrieved and saved to local app files."
            return $token
        } else {
            Write-Host "Failed to retrieve token from Moodle."
            return $null
        }
    } catch {
        Write-Host "Failed to retrieve token: $_"
        return $null
    }
}
