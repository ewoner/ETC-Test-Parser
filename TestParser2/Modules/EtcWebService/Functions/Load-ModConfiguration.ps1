# Function to load ModConfiguration from a specified config file
function Import-ModConfiguration {
    param (
        [string] $fileName
    )

    # Construct the full path to the config file
    $configFile = Join-Path -Path $PSScriptRoot -ChildPath $fileName

    # Check if config file exists
    if (-not (Test-Path $configFile)) {
        Write-Error "Configuration file not found: $configFile"
        return $null
    }

    # Read content from config file
    $configData = Get-Content $configFile -Raw

    # Parse the content into key-value pairs
    $properties = ConvertFrom-StringData $configData

    # Extract objectives from within <objectives> tag
    $objectivesStart = $configData.IndexOf("<objectives>") + "<objectives>".Length
    $objectivesEnd = $configData.IndexOf("</objectives>")
    $objectivesContent = $configData.Substring($objectivesStart, $objectivesEnd - $objectivesStart).Trim()

    # Split objectives into array
    $objectives = $objectivesContent -split "`r`n|`n|`r"

    # Create ModConfiguration object
    $modConfig = [ModConfiguration]::new(
        [int] $properties.mod,
        [string] $properties.objModNum,
        [string] $properties.numOfObj,
        [string] $properties.numOfDays,
        [string] $properties.maxNumOfQuestions,
        [string[]] $objectives
    )

    return $modConfig
}

