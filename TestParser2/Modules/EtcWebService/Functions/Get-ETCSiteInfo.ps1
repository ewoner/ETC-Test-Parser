<#
.SYNOPSIS
    Retrieves site information from Moodle.
.DESCRIPTION
    This function checks if site information is already available for the user. If not, it fetches site information from Moodle using the appropriate web service function.
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
    
    # Check if user information is available
    if (-not $script:user) {
        Write-Host "No user. Please call 'Get-EtcUser' first."
        return
    }
    
    # Check if the user has a token
    if (-not $script:user.token) {
        Write-Host "User does not have a token. A call to 'Get-EtcToken' is needed before you can use this cmdlet."
        return
    }
    
    # Retrieve site information if it's not already available
    if (-not $script:user.siteInfo) {
        Write-Verbose "Fetching site information from Moodle."
        
        # Moodle Web service function to call
        $functionName = 'core_webservice_get_site_info'
        
        # Invoke the Moodle Web service using Invoke-ETCRestMethod
        Write-Debug "Invoking web service function: $functionName"
        $response = Invoke-ETCRestMethod -wsfunction $functionName
        
        # Check if response is successful and contains user information
        if ($response.userid) {
            Write-Verbose "Site information successfully retrieved."
            $script:user.userId = $response.userid  
            $script:user.siteInfo = $response
        } else {
            Write-Host "Failed to retrieve user ID and site information from ETC."
            return
        }
    } else {
        Write-Verbose "Site information is already available."
    }
}
