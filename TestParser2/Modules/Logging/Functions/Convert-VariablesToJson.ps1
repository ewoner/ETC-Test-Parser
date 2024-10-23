# Function to convert a hashtable of variables to a dictionary format suitable for JSON serialization.
# Parameters:
#   [hashtable]$variables - The hashtable containing variables to be converted.
# Returns:
#   [hashtable] - A dictionary representation of the input variables, suitable for JSON serialization.
function Convert-VariablesToJson {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$variables
    )

    Write-Verbose "Entering Convert-VariablesToJson function."

    # Initialize an empty hashtable for the converted variables
    $convertedVariables = @{}
    Write-Verbose "Initialized empty hashtable for converted variables."

    foreach ($variable in $variables.Keys) {
        try {
            $value = $variables[$variable]

            Write-Verbose "Processing variable: $variable with value: $value."

            if ($value -is [hashtable]) {
                Write-Verbose "Value for variable '$variable' is a hashtable. Converting to dictionary."
                $convertedVariables[$variable] = Convert-HashtableToDictionary -hashtable $value
            } elseif ($value -is [System.Collections.ListDictionaryInternal]) {
                # Skip unsupported types
                Write-Verbose "Skipping variable '$variable' due to unsupported type: ListDictionaryInternal."
            } elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
                # Convert collections to arrays for serialization
                Write-Verbose "Value for variable '$variable' is a collection. Converting to array."
                $convertedVariables[$variable] = @($value)
            } else {
                Write-Verbose "Value for variable '$variable' is of type $($value.GetType().Name). Adding to converted variables."
                $convertedVariables[$variable] = $value
            }
        } catch {
            Write-Verbose "Failed to convert variable '$variable': $_"
        }
    }

    Write-Debug "Converted variables: $convertedVariables"
    return $convertedVariables
}