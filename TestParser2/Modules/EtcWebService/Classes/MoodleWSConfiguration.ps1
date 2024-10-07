<#
.SYNOPSIS
    MoodleWSConfiguration.ps1
.DESCRIPTION
    Defines the MoodleWSConfiguration class for handling Moodle web service configurations.
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

class MoodleWSConfiguration {
    [string]$etcUrl
    [string]$Format
    [string]$TokenUrl
    [string]$WsUrl
    [string]$UserDataPath
    [string]$Service
    [string]$documentation

    MoodleWSConfiguration () {
        $this.etcUrl = "www.etc-iwtc-cs-cso.com"
        $this.Format = "json"
        $this.TokenUrl = "https://www.etc-iwtc-cs-cso.com/login/token.php"
        $this.WsUrl = "https://www.etc-iwtc-cs-cso.com/webservice/rest/server.php"
        $this.UserDataPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath 'ETC\etcusers.txt'
        $this.Service = 'moodle_mobile_app'
    }

    [void]SetConfig([string]$key, [string]$value) {
        if ($this.PSObject.Properties.Match($key).Count -gt 0) {
            $this.PSObject.Properties[$key].Value = $value
        } else {
            throw "Invalid configuration key: |$key|"
        }
    }

    [string]GetConfig([string]$key) {
        if ($this.PSObject.Properties.Match($key).Count -gt 0) {
            return $this.PSObject.Properties[$key].Value
        } else {
            throw "Invalid configuration key value trying to be added to a MoudleWSConfiguration: |$key|"
        }
    }
}
