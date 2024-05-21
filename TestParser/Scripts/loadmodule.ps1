function Load-Module {
    $modulePathName = "S:\Inst\Projects\VM-Builder\Modules\ImportExcel"
    $destinationPathName = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\ImportExcel"
    if ( -not (Test-Path -Path $destinationPathName)  ) {
        Copy-Item -path $modulePathName -Destination $destinationPathName -Recurse -Verbose
    }
    Import-Module ImportExcel
    write-host "Excell Loaded!"

    $modulePathName = "S:\Inst\3-Programming Fundamentals\Instructors\Brion\TestParser\Scripts"
    $destinationPathName = "C:\Users\$env:USERNAME\Documents\WindowsPowerShell\Modules\TestPaser"
    Copy-Item -path $modulePathName -Destination $destinationPathName -Recurse -Verbose -Force
    Write-Host "TestParser Copied!"
    
   
}

Load-Module
exit