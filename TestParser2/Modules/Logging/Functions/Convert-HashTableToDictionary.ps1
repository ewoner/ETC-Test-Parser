# Function to convert a hashtable to a dictionary, handling nested hashtables and collections.
# Parameters:
#   [hashtable]$hashtable - The hashtable to be converted to a dictionary.
# Returns:
#   [hashtable] - A dictionary representation of the input hashtable.
function Convert-HashtableToDictionary {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$hashtable
    )

    Write-Verbose "Entering Convert-HashtableToDictionary function."

    # Initialize an empty dictionary
    $dictionary = @{}
    Write-Verbose "Initialized empty dictionary."

    foreach ($key in $hashtable.Keys) {
        $value = $hashtable[$key]

        Write-Verbose "Processing key: $key with value: $value."

        if ($value -is [hashtable]) {
            Write-Verbose "Value for key '$key' is a hashtable. Recursively converting."
            $dictionary[$key] = Convert-HashtableToDictionary -hashtable $value
        } elseif ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            # If value is a collection (not a string), convert it to an array for serialization
            Write-Verbose "Value for key '$key' is a collection. Converting to array."
            $dictionary[$key] = @($value)
        } else {
            Write-Verbose "Value for key '$key' is of type $($value.GetType().Name). Adding to dictionary."
            $dictionary[$key] = $value
        }
    }

    Write-Debug "Converted dictionary: $dictionary"
    return $dictionary
}