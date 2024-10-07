function Get-QuestionObjectiveNumber {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSObject]$question
    )

    $objModNum = $ModConfig.objModnum
    $objRegexStr = $ModConfig.ObjRegexPattern
    $objNum = 0

    if ($question.correct) {
        return -1
    }

    $objStr = $question.html | Select-String -Pattern $objRegexStr
    if ($objStr -eq $null -or $objStr.Matches.Count -eq 0) {
        Write-Error "No Objective Line found."
        Write-Host -ForegroundColor Blue -BackgroundColor Yellow ($question.html | Select-String -Pattern "\b(Objective[:\W]+(\w+[,. ]*)+)\b").Matches[0].Groups[1]
        $objNum = [int](Read-Host "Enter correct Objective Number or '0'")
    } else {
        try {
            $objNum = [int]($objStr.Matches[0].Groups[2].Value)  # Capture Group 2 -- Objective number
        } catch {
            Write-Error "Did not parse an objective number."
            Write-Host -ForegroundColor Blue -BackgroundColor Yellow ($question.html | Select-String -Pattern "\b(Objective[:\W]+(\w+[, ]*)+)\b").Matches[0].Groups[1]
            $objNum = [int](Read-Host "Enter correct Objective Number or '0'")
        }
    }

    if ($objModNum -ne [int]($objStr.Matches[0].Groups[1].Value)) {
        Write-Error "Wrong Objective Number! Found [int]($objStr.Matches[0].Groups[1].Value) but expected $objModNum. Will not parse."
        return
    }

    # Here you can add additional code to handle $objNum if needed.
    # For example, updating arrays or performing other operations.

    return $objNum
}
