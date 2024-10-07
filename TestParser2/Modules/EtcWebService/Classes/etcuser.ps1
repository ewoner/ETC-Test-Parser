<#
.SYNOPSIS
    EtcUser.ps1
.DESCRIPTION
    Defines the EtcUser class with methods for handling user details and secure credentials.
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

class EtcUser {
    [string] $UserName
    [securestring] $Password
    [securestring] $Token
    [string] $UserID
    [PSCustomObject]$siteInfo
    [EtcCourse[]]$courses
    
    EtcUser() {
        $this.UserName = "undefined"
    }
    EtcUser([string] $userName ){
        $this.UserName = $userName
        $this.Password = $null
        $this.Token = $null
        $this.UserID = ""
        $this.siteInfo = $null
        $this.courses = @()
    }
    EtcUser([string] $userName, [securestring] $password) {
        $this.UserName = $userName
        $this.Password = $password
        $this.Token = $null
        $this.UserID = ""
        $this.siteInfo = $null
        $this.courses = @()
    }
    
    EtcUser([string] $userName, [securestring] $password, [securestring] $token, [string] $userID) {
        $this.UserName = $userName
        $this.Password = $password
        $this.Token = $token
        $this.UserID = $userID
        $this.siteInfo = $null
        $this.courses = @()
    }

    [string] GetPasswordPlainText() {
        if ($this.Password) {
            return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.Password))
        } else {
            return ''
        }
    }

    [string] GetTokenPlainText() {
        if ($this.Token) {
            return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($this.Token))
        } else {
            return ''
        }
    }
}
