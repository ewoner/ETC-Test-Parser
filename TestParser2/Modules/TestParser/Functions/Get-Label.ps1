# Function to convert an integer index to a corresponding label using letters A-Z.
# Parameters:
#   [int]$index - The index to be converted to a label. The index is zero-based.
function Get-Label {
    param (
        [Parameter(Mandatory = $true)]
        [int]$index
    )

    Write-Verbose "Entering Get-Label function with index: $index."

    # Define letters to use in labels
    $letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $label = ""

    do {
        # Get the current character for the given index
        $currentChar = $letters[$index % 26]
        Write-Debug "Current character for index $index is $currentChar."
        $label = $currentChar + $label

        # Update index for the next character
        $index = [math]::Floor($index / 26) - 1
        Write-Debug "Updated index to $index."

    } while ($index -ge 0)

    Write-Verbose "Generated label: $label."
    return $label
}