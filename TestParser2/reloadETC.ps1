Remove-Item -Path "..\Modules\EtcWebService\" -Force
Remove-Item -Path ".\Student_files\" -force
. .\comparefiles.ps1

Set-Alias -Name np -Value "C:\Program Files\Notepad++\notepad++.exe"
Set-Alias -Name cmfl -Value compare-files

. .\testparser2.ps1
