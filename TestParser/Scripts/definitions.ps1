class Mod {
    [int]$number
    [string]$objRegexPattern
    [string]$nameRegexPattern
    [string]$endOfQuestionRegexPattern
    [int]$numberOfObjects
    [int]$numberOfDays
    [int]$numberOfTestQuestions
    [string]$name
    [string]$shortName
    [string[]]$objectives

    Mod( [int]$ModNumber ) { 
        $this.Init(  @{
                        number = $ModNumber
                        objRegexPattern = ""
                        nameRegexPattern = ""
                        endOfQuestionRegexPattern = ""
                        numberOfObjects = 0
                        numberOfDays = 0
                        numberOfTestQuestions = 0
                        name = "Undefined"
                        shortName = "UND"
                        objectives = @()
                      }
                  ) 
    }
    Mod ( [HashTable]$table ) { 
        $this.Init( $table )
   }

    Init( [hashtable]$Properties ) {
        foreach ( $Property in $Properties.Keys) {
            $this.$Property = $Properties.$Property
        }
        
    }
}

class Test {

}

class ConfFile {
    hidden [int]$modNumber
    [string]$fileName
    static [string]$valueLineRegex = "^\s*([a-zA-Z_]\w+)\s*=\s*((['`"])?.+\3?)$"
    hidden [string[]]$fileContent

    ConfFile([int]$modNumber) {
        $this.ModNumber = $modNumber
        $this.fileName = "./config/mod$($this.ModNumber).conf"
    }

    [Mod]parseFile( [Mod]$mod ) {
        return $mod
    }

}