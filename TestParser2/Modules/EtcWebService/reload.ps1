set-location -path "C:\Users\ewone\Documents\WindowsPowerShell\Modules\ETCWebService"
Import-Module EtcWebService -force
set-alias -name np -value 'C:\Program Files\Notepad++\notepad++.exe'
set-alias -name ier -value Invoke-EtcRestMethod
$user = Get-EtcUser
Get-EtcCourseData|out-null
$course = $user.courses[0]
Get-EtcQuizData -all
$quiz = $course.quizzes[2]