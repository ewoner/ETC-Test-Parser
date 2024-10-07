<#
.SYNOPSIS
    TestParser2.ps1
.DESCRIPTION
    This script processes ETC test data and generates Excel reports based on students' scores. For each student who failed the test, it creates a separate Excel sheet detailing the missed areas by module objective and a remediation sheet for distribution.
.VERSION
    2.0.0-dev2
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
    File Version: 1.1.0-dev2-2024-09-06
.PARAMETER debugParser
    Specifies the debugging level for the script. Options are "off", "on", or "full". Default is "off".
.PARAMETER devParser
    Specifies the development environment. Options are "off", "home", or "work". Default is "off".
.CHANGELOG
    2024-08-15 - Version 1.0.0-dev1
        - Initial release with basic functionality.
    2024-09-06 - Version 2..0-dev2
		- Added SaveFileName data field.
		- Added the getfileName() method
        - Added the getfilename([string]) method.

#>

class ModConfiguration {
    [int] $Mod
	[int] $objModNum
    [string] $Title
    [string] $HtmlDirStr
    [string] $SaveDirStr
	[String] $saveFileName
    [string] $logDirStr
    [string] $ObjRegexPattern
    [int] $NumOfObj
    [int] $NumOfDays
    [int] $MaxNumOfQuestions
    [string[]] $Objectives

    # Default constructor
    ModConfiguration() {
        $this.Mod = 0
		$this.objModNum = $this.Mod
        $this.Title = "Undefined"
        $this.HtmlDirStr = "Undefined"
        $this.SaveDirStr = "."
        $this.logDirStr = "./logs/"
        $this.ObjRegexPattern = "Undefined"
        $this.NumOfObj = 0
        $this.NumOfDays = 0
        $this.MaxNumOfQuestions = 0
        $this.Objectives = @()
		$this.saveFileName = "save.data"
    }

    # Dynamic constructor using hashtable
    ModConfiguration([Hashtable]$properties) {
        # Set default values for all properties
        $defaultValues = @{
            Mod = 0
			ObjModNum = $this.Mod
            Title = "Undefined"
            HtmlDirStr = "Undefined"
            SaveDirStr = "Undefined"
            ObjRegexPattern = "Undefined"
            NumOfObj = 0
            NumOfDays = 0
            MaxNumOfQuestions = 0
            Objectives = @()
        }

        # Set default values
        foreach ($property in $defaultValues.Keys) {
            $this."$property" = $defaultValues[$property]
        }

        # Iterate over the hashtable and set properties dynamically
        foreach ($key in $properties.Keys) {
            $value = $properties[$key]

            # Check if the property exists on the class
            if ($this.PSObject.Properties.Name -contains $key) {
                $property = $this.PSObject.Properties[$key]

                # Set the property value, and handle type conversion if necessary
                try {
                    if ($property.TypeNames -contains 'System.String') {
                        $this."$key" = [string]$value
                    } elseif ($property.TypeNames -contains 'System.Int32') {
                        $this."$key" = [int]$value
                    } elseif ($property.TypeNames -contains 'System.String[]') {
                        $this."$key" = [string[]]$value
                    } else {
                        $this."$key" = $value
                    }

                    # Validate regex pattern
                    if ($key -eq 'ObjRegexPattern') {
                        [regex]::new($this.ObjRegexPattern) | Out-Null
                    }
                } catch {
                    Write-Error "Error setting property '$key' with value '$value': $_"
                }
            } else {
                Write-Warning "Unknown property: $key"
            }
        }
    }
	[string] getFileName([string] $classNumber ) {
		return "Mod $($this.Mod) Remediation $classNumber.xlsx"
	}

    # Method to set ObjRegexPattern with validation
    [void] SetObjRegexPattern([string] $value) {
        if ([string]::IsNullOrEmpty($value)) {
            Write-Warning "Regex pattern is null or empty. Maintaining old value."
            return
        }
        try {
            [regex]::new($value) | Out-Null  # Test the regex pattern
            $this.ObjRegexPattern = $value    # Set the value if it's valid
        } catch {
            Write-Error "Invalid regex pattern: $value. Maintaining old value."
        }
    }
}
