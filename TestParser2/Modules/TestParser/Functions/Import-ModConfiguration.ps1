<#
.SYNOPSIS
Imports the module configuration from a configuration file.

.DESCRIPTION
This function imports the module configuration from a configuration file and returns a ModConfiguration object.

.VERSION
1.1.0

.AUTHOR
Brion Lang

.NOTES
Versioning specification: https://semver.org/
See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.

.PARAMETER ModNumber
The module number to import configuration for.

.EXAMPLE
Import-ModConfiguration -ModNumber 1

.INPUTS
System.Int32
The module number to import configuration for.

.OUTPUTS
ModConfiguration
The imported module configuration.

.FUNCTIONALITY
TestParser

.LINK
https://github.com/ewoner/ETC-Test-Parser

.COMPONENT
TestParser

.ROLE
TestParser

#>
function Import-ModConfiguration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int] $ModNumber  # Accept module number as an integer parameter
    )

    # Define the default configuration file and the specific mod configuration file
    $defaultFileName = "default.conf"
    $modFileName = "mod${ModNumber}.conf"

    # Construct the paths for the configuration files
    $configDirectory = Join-Path -Path (Split-Path -Parent $PSScriptRoot) -ChildPath 'Config'
    $defaultConfigFile = Join-Path -Path $configDirectory -ChildPath $defaultFileName
    $modConfigFile = Join-Path -Path $configDirectory -ChildPath $modFileName

    # Initialize hashtable for properties
    $properties = @{}

    # Function to process a configuration file and add its properties to the hashtable
    function Process-ConfigFile {
        param (
            [string] $filePath
        )

        if (Test-Path $filePath) {
            Write-Verbose "Loading configuration file: $filePath"
            $configData = Get-Content $filePath -Raw
            $configData = $configData -replace '^\s*#.*$', '' -replace '^\s*$',''

            foreach ($line in $configData -split "`r`n|`n|`r") {
                if ($line -match '^\s*(\w+)\s*=\s*(.+)\s*$') {
                    $properties[$matches[1].ToLower()] = $matches[2].Trim()
                    Write-Verbose "Loaded property: $($matches[1]) = $($matches[2])"
                }
            }

            # Extract objectives from within <objectives> tag if it's the mod-specific config
            if ($filePath -eq $modConfigFile) {
                $objectivesStart = $configData.IndexOf("<objectives>") + "<objectives>".Length
                $objectivesEnd = $configData.IndexOf("</objectives>")

                if ($objectivesStart -ge "<objectives>".Length -and $objectivesEnd -ge 0) {
                    $objectivesContent = $configData.Substring($objectivesStart, $objectivesEnd - $objectivesStart).Trim()

					# Check if the block contains <DAYBREAK>
					$isDailyBlock = $objectivesContent -match "<DAYBREAK>"

					# Split based on line breaks; for daily blocks, this will still split objectives, including <DAYBREAK> markers
					$objectivesArray = $objectivesContent -split "`r`n|`n|`r"






                   # Initialize a list to hold Objective objects
					$objectiveList = @()
					$modNum = $ModNumber  # Assume this is the module number passed in

					# Variables to track day number and objective number
					$dayNum = 0
					$objNum = 0

					if ($isDailyBlock) {
						foreach ($line in $objectivesArray) {
							$trimmedLine = $line.Trim()

							if ($trimmedLine -eq "<DAYBREAK>") {
								# Increment day number when <DAYBREAK> is encountered
								$dayNum++
								$objNum = 0  # Reset objective number for each day
							} elseif ($trimmedLine -ne "") {
								# Increment objective number for each valid objective line
								$objNum++

								# Create an Objective object and add it to the list
								$objective = [Objective]::new($modNum, $dayNum, $objNum, $trimmedLine)
								$objectiveList += $objective
							}
						}
					} else {
						# For standard block, dayNum is always 0
						$dayNum = 0
						foreach ($line in $objectivesArray) {
							$trimmedLine = $line.Trim()
							
							if ($trimmedLine -ne "") {
								$objNum++

								# Create an Objective object and add it to the list
								$objective = [Objective]::new($modNum, $dayNum, $objNum, $trimmedLine)
								$objectiveList += $objective
							}
						}
					}

					# Store the Objective objects in the properties hashtable
					$properties['objectives'] = $objectiveList
					Write-Verbose "Loaded objectives: $($objectiveList.Count) objectives parsed."









                } else {
                    Write-Warning "Objectives block is missing or malformed in the configuration file: $filePath"
                }
            }
        } else {
            Write-Warning "Configuration file not found: $filePath"
        }
    }

    # Load and process default configuration file
    Write-Verbose "Loading default configuration file: $defaultConfigFile"
    Process-ConfigFile -filePath $defaultConfigFile

    # Load and process module-specific configuration file
    Write-Verbose "Loading module-specific configuration file: $modConfigFile"
    Process-ConfigFile -filePath $modConfigFile

    # Create ModConfiguration object with the merged properties hashtable
    Write-Verbose "Creating ModConfiguration object"
    $modConfig = [ModConfiguration]::new($properties)

    # Save the ModConfiguration object to a script-scoped variable
    Write-Verbose "Saving ModConfiguration object to script-scoped variable"
    $script:ModConfig = $modConfig

    # Return the ModConfiguration object
    Write-Verbose "Returning ModConfiguration object"
    return $modConfig
}