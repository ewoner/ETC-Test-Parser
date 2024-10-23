# Test script for Import-ModConfiguration function

# Define the path to the configuration files
$ConfigDirectory = "H:\Documents\Projects\TestParser2\V_1.1.0-dev1\TestParser2\Unit Tests\Modules\TestParser\Config"

# Function to test loading the module configuration
function Test-ImportModConfiguration {
    param (
        [int]$ModNumber
    )

    # Attempt to import the configuration
    try {
        $modConfig = Import-ModConfiguration -ModNumber $ModNumber -ConfigDirectory $ConfigDirectory -Verbose

        # Output the configuration details
        Write-Host "Module Number: $($modConfig.Mod)"
        Write-Host "Module Title: $($modConfig.Title)"
        Write-Host "Number of Objectives: $($modConfig.Objectives.Count)"
        
        # Display each objective
        Write-Host "Objectives:"
        foreach ($objective in $modConfig.Objectives) {
            Write-Host "  - ModNum: $($objective.modNum), DayNum: $($objective.dayNum), ObjNum: $($objective.objNum), ObjString: $($objective.objString), Tallies: $($objective.tallies)"

        }
    } catch {
        Write-Error "Error importing configuration: $_"
    }
}

# Test for both module configurations
Test-ImportModConfiguration -ModNumber 3
Test-ImportModConfiguration -ModNumber 13

# Pause to allow reading output
Read-Host "Press Enter to exit"
