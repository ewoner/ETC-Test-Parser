function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$logEntry,

        [switch]$NoNewline
    )

    Write-Verbose "Entering Write-Log function with log entry: $logEntry."

    try {
        # Get the current timestamp
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Verbose "Timestamp for log entry: $timestamp."

        if ($NoNewline) {
            # Read the last line from the log file if it exists
            if (Test-Path $currentLog) {
                $lastLine = Get-Content -Path $currentLog -Tail 1
                # Remove the newline from the last line if it exists
                $lastLine = $lastLine.TrimEnd()
                # Construct the log entry without adding a new line
                $formattedLogEntry = "$lastLine $logEntry"
            } else {
                # If log file does not exist, start a new line with the log entry
                $formattedLogEntry = $logEntry
            }
        } else {
            # Include timestamp with log entry
            $formattedLogEntry = "$timestamp - $logEntry"
        }

        # Append the log entry to the current log file
        $formattedLogEntry | Out-File -FilePath $currentLog -Append -ErrorAction Stop -Encoding UTF8
        Write-Debug "Logged entry to ${currentLog}: $formattedLogEntry."
    }
    catch {
        Write-Error "Failed to write to log file. Error: $_"
    }
}