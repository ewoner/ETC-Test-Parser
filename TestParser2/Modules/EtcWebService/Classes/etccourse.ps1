<#
.VERSION
    2.0.0-dev1
.FILE_VERSION
    1.0.0-dev1-240815
.AUTHOR
    Brion Lang
.NOTES
    Versioning specification: https://semver.org/
    See GitHub repository at: https://github.com/ewoner/ETC-Test-Parser for more complete description, current updates, and future plans.
#>

# Class: EtcQuestion
# Description: Represents a question in a test, including its HTML content, mark, and correctness status.
class EtcQuestion {
    [string]$html
    [double]$mark
    [int]$maxmark
    [bool]$correct
    
    # Constructor for EtcQuestion class
    EtcQuestion([string]$html, [double]$mark, [int]$maxmark, [string]$status) {
        Write-Verbose "Initializing EtcQuestion with mark: $mark, maxmark: $maxmark"
        $this.html = $html
        $this.mark = $mark
        $this.maxmark = $maxmark
        $this.correct = $status -eq "Correct"
        Write-Debug "EtcQuestion created with status: $status and correctness: $($this.correct)"
    }
}

# Class: EtcTest
# Description: Represents a test with an attempt ID, grade, and a collection of questions.
class EtcTest {
    [int]$attemptid
    [double]$grade
    [EtcQuestion[]]$questions
    
    # Constructor for EtcTest class
    EtcTest([int]$attemptid, [double]$grade, [EtcQuestion[]]$questions) {
        Write-Verbose "Creating EtcTest with attempt ID: $attemptid and grade: $grade"
        $this.attemptid = $attemptid
        $this.grade = $grade
        $this.questions = @() + $questions
        Write-Debug "EtcTest created with $($this.questions.Count) questions"
    }
}

# Class: EtcGroup
# Description: Represents a group of students with a unique ID and name.
class EtcGroup {
    [int]$id
    [string]$name
    [int[]]$memberids = @()
    
    # Constructor for EtcGroup class
    EtcGroup([int]$id, [string]$name) {
        Write-Verbose "Initializing EtcGroup with ID: $id and name: $name"
        $this.id = $id
        $this.name = $name
        $this.memberids = @()
    }
    
    # Method to add a student to the group
    addToGroup([EtcStudent]$student) {
        Write-Verbose "Adding student with ID: $($student.userid) to group: $($this.name)"
        $this.addToGroup($student.userid)
    }
    
    # Method to add a student ID to the group
    addToGroup([int]$student) {
        Write-Verbose "Adding student ID: $student to group"
        $this.memberids += $student
        Write-Debug "Group now contains $($this.memberids.Count) members"
    }
}

# Class: EtcGradeItem
# Description: Represents a grade item, including its ID, instance, name, and raw grade.
class EtcGradeItem {
    [int]$id
    [int]$iteminstance
    [string]$itemname
    [double]$graderaw
    [int]$studentid
    
    # Constructor for EtcGradeItem class
    EtcGradeItem([int]$id, [string]$itemname, [int]$iteminstance, [double]$graderaw, [int]$studentid) {
        Write-Verbose "Initializing EtcGradeItem with ID: $id, name: $itemname, and raw grade: $graderaw"
        $this.id = $id
        $this.itemname = $itemname
        $this.iteminstance = $iteminstance
        $this.graderaw = $graderaw
        $this.studentid = $studentid
        Write-Debug "EtcGradeItem created for student ID: $studentid"
    }
}

# Class: EtcQuiz
# Description: Represents a quiz, including its ID, course module, course, name, and visibility status.
class EtcQuiz {
    [int]$id
    [int]$coursemodule
    [int]$course
    [string]$name
    [bool]$visible
    
    # Constructor for EtcQuiz class
    EtcQuiz($id, $coursemodule, $course, $name, $visible) {
        Write-Verbose "Creating EtcQuiz with ID: $id, name: $name, and visibility: $visible"
        $this.id = $id
        $this.coursemodule = $coursemodule
        $this.course = $course
        $this.name = $name
        $this.visible = $visible
        Write-Debug "EtcQuiz created for course ID: $course"
    }
}

# Class: EtcStudent
# Description: Represents a student with a unique ID, name, associated grade items, and group memberships.
class EtcStudent {
    [int]$userid
    [string]$fullname
    [int[]]$gradeItems = @()
    [int[]]$groupids = @()
    
    # Constructor for EtcStudent class
    EtcStudent([int]$id, $fullname) {
        Write-Verbose "Initializing EtcStudent with ID: $id and name: $fullname"
        $this.userid = $id
        $this.fullname = $fullname
        $this.gradeItems = @()
        $this.groupids = @()
    }
    
    # Method to add a grade item to the student's record
    addGradeItem([EtcGradeItem]$gradeitem) {
        Write-Verbose "Adding grade item ID: $($gradeitem.id) to student ID: $($this.userid)"
        $this.addGradeItem($gradeitem.id)
    }
    
    # Overloaded method to add a grade item ID to the student's record
    addGradeItem([int]$gradeitemId) {
        Write-Verbose "Adding grade item ID: $gradeitemId to student"
        $this.gradeItems += $gradeitemId
        Write-Debug "Student now has $($this.gradeItems.Count) grade items"
    }
    
    # Method to add a student to a group
    addToGroup([int]$groupid) {
        Write-Verbose "Adding student ID: $($this.userid) to group ID: $groupid"
        $this.groupids += $groupid
    }
    
    # Overloaded method to add a student to a group by group object
    addToGroup([EtcGroup]$group) {
        if (-not $group.id -in $this.groupids) {
            Write-Verbose "Student not yet in group $($group.name), adding now"
            $this.addToGroup($group.id)
        }
    }
}

# Class: EtcCourseCategory
# Description: Represents a course category, including its ID, name, and retirement status.
class EtcCourseCategory {
    [int]$id
    [string]$name
    [boolean]$retired
    
    # Constructor for EtcCourseCategory class
    EtcCourseCategory($id, $name) {
        Write-Verbose "Creating EtcCourseCategory with ID: $id and name: $name"
        $this.id = $id
        $this.name = $name
        $this.retired = $name -match "Retired"
        Write-Debug "EtcCourseCategory created with retirement status: $($this.retired)"
    }
    
    # Overloaded constructor for EtcCourseCategory class
    EtcCourseCategory($id, $name, $retired) {
        Write-Verbose "Creating EtcCourseCategory with ID: $id, name: $name, and retired status: $retired"
        $this.id = $id
        $this.name = $name
        $this.retired = $retired
        Write-Debug "EtcCourseCategory created with retirement status: $retired"
    }
}

# Class: EtcCourse
# Description: Represents a course, including its ID, name, category, retirement status, grade items, groups, students, and quizzes.
class EtcCourse {
    [int]$id
    [string]$fullname
    [int]$category
    [bool]$retired
    [EtcGradeItem[]]$gradeitems
    [EtcGroup[]]$groups
    [EtcStudent[]]$students
    [EtcQuiz[]]$quizzes = @()

    # Constructor for EtcCourse class
    EtcCourse($id, $fullname) {
        Write-Verbose "Creating EtcCourse with ID: $id and name: $fullname"
        $this.id = $id
        $this.fullname = $fullname
        $this.category = 0
        $this.retired = $false
        $this.gradeitems = @()
        $this.groups = @()
        $this.students = @()
        $this.quizzes = @()
    }

    EtcCourse($id, $fullname, $category) {
        Write-Verbose "Creating EtcCourse with ID: $id, name: $fullname, and category: $category"
        $this.id = $id
        $this.fullname = $fullname
        $this.category = $category
        $this.retired = $false
        $this.gradeitems = @()
        $this.groups = @()
        $this.students = @()
        $this.quizzes = @()
    }

    EtcCourse($id, $fullname, $category, $retired) {
        Write-Verbose "Creating EtcCourse with ID: $id, name: $fullname, category: $category, and retired status: $retired"
        $this.id = $id
        $this.fullname = $fullname
        $this.category = $category
        $this.retired = $retired
        $this.gradeitems = @()
        $this.groups = @()
        $this.students = @()
        $this.quizzes = @()
    }

    # Method to add a quiz to the course
    addQuiz([EtcQuiz]$quiz) {
        Write-Verbose "Adding quiz with ID: $($quiz.id) to course: $($this.fullname)"
        $this.quizzes += $quiz
        Write-Debug "Course now contains $($this.quizzes.Count) quizzes"
    }

    # Method to add a grade item to the course
    addGradeItem([EtcGradeItem]$gradeItem) {
        Write-Verbose "Adding grade item with ID: $($gradeItem.id) to course: $($this.fullname)"
        $this.gradeitems += $gradeItem
        Write-Debug "Course now contains $($this.gradeitems.Count) grade items"
    }

    # Method to add a group to the course
    addGroup([EtcGroup]$group) {
        Write-Verbose "Adding group with ID: $($group.id) to course: $($this.fullname)"
        $this.groups += $group
        Write-Debug "Course now contains $($this.groups.Count) groups"
    }

    # Method to add a student to the course
    addStudent([EtcStudent]$student) {
        Write-Verbose "Adding student with ID: $($student.userid) to course: $($this.fullname)"
        $this.students += $student
        Write-Debug "Course now contains $($this.students.Count) students"
    }
}    

# Class: EtcData
# Description: Represents a collection of course categories.
class EtcData {
    [EtcCourseCategory[]]$courseCategories
    
    # Constructor for EtcData class
    EtcData() {
        Write-Verbose "Initializing EtcData"
        $this.courseCategories = @()
    }
}
