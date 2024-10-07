<#
.SYNOPSIS
    Invokes a REST method against the ETC service.
.DESCRIPTION
    This function handles the invocation of REST methods, including token retrieval if needed. It merges parameters, handles token and non-token requests, and returns the deserialized response.
.VERSION
    2.0.0-dev1
.FILE_VERSION
    1.0.0-dev1-240815
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
#>

function Invoke-EtcRestMethod {
    [CmdletBinding()]
    param (
        [string]$wsfunction,
        [string]$url = $script:config.WsUrl,
        [hashtable]$Parameters = @{},
        [string]$Format = $script:config.format,
        [switch]$Token
    )

    try {
        # Check if both Token switch and wsfunction are specified
        if ($Token -and $wsfunction) {
            Write-Error "Cannot specify both 'wsfunction' and 'Token'. Please choose one."
            return
        }

        # Determine URL based on Token switch
        if ($Token) {
            Write-Verbose "Using Token URL to retrieve token."
            $url = $script:config.TokenUrl

            # Retrieve username and password from $script:User object
            $username = $script:User.Username
            $password = $script:User.GetPasswordPlainText()

            # Add username and password to parameters
            $mergedParams = $Parameters + @{
                'username' = $username
                'password' = $password
                'service' = $script:config.service
            }
        } else {
            Write-Verbose "Using REST URL to invoke function."
            # Merge additional parameters with common parameters if wsfunction is specified
            $mergedParams = $Parameters + @{
                'wstoken' = $script:User.getTokenPlainText()
                'moodlewsrestformat' = $Format
                'wsfunction' = $wsfunction
            }
        }

        # Debugging output of parameters being sent
        Write-Debug "Parameters being sent: $($mergedParams | ConvertTo-Json -Compress)"
        
        # Verbose output of the URL and parameters before invoking the REST method
        Write-Verbose "Invoking REST method at URL: $url with parameters: $($mergedParams | ConvertTo-Json -Compress)"
        
        # Invoke REST method
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $mergedParams -ErrorAction Stop
        
        # Return deserialized object
        Write-Debug "Received response from REST method."
        return $response
    } catch {
        Write-Error "Failed to invoke ETC REST method '$wsfunction': $_"
        return $null
    }
}
