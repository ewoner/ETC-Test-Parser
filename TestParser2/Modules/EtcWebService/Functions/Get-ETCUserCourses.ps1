<#
.SYNOPSIS
    Retrieves and caches site information from Moodle.
.DESCRIPTION
    This function retrieves site information from Moodle if it's not already cached or if the cached information is outdated. It requires the user to be logged in and have a valid token.
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

function Get-EtcSiteInfo {
    [CmdletBinding()]
    param ()
    
    # Check if user is available
    if (-not $script:user) {
        Write-Host "No user. Please call 'Get-EtcUser' first."
        return
    }
    
    # Check if user token is available
    if (-not $script:user.token) {
        Write-Host "User does not have a token. A call to 'Get-EtcToken' is needed before you can use this cmdlet."
        return
    }
    
    # Return cached site info if username matches
    if ($script:user.username -eq $script:site_info.username) {
        Write-Verbose "Returning cached site information for user: $($script:user.username)"
        return $script:site_info
    } else {
        Write-Verbose "Clearing cached site information for user: $($script:user.username)"
        $script:site_info = $null
    }

    # Retrieve site info if not cached
    if (-not $script:site_info) {
        Write-Verbose "Retrieving site information from Moodle."
        
        # Moodle Web service function to call
        $functionName = 'core_webservice_get_site_info'
        
        # Invoke the Moodle Web service using Invoke-ETCRestMethod
        try {
            $response = Invoke-ETCRestMethod -wsfunction $functionName
            Write-Debug "Received response from Moodle web service."

            # Check if response is successful
            if ($response.userid) {
                $script:user.userId = $response.userid  
                $script:site_info = $response
                Write-Verbose "Site information successfully retrieved and cached."
                return $script:site_info
            } else {
                Write-Host "Failed to retrieve user ID and Site Information from ETC."
                return $null
            }
        } catch {
            Write-Host "Error retrieving site information: $_"
            return $null
        }
    }
}
