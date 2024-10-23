class Objective {
	[int]$modNum
	[int]$dayNum
	[int]$objNum
	[string]$objString
	[int]$tallies

	Objective(){
		$this.modNum = 0
		$this.dayNum = 0
		$this.objNum = 0
		$this.objString = "Not Set"
		$this.tallies = 0
		
	}
	
	Objective( [int]$modNum, [int]$dayNum, [int]$objNum, [string]$objStr ) {
		$this.modNum = $modNum
		$this.dayNum = $dayNum
		$this.objNum = $objNum
		$this.objString= $objStr
		$this.tallies = 0
	}
	
	incrementTally(){
		$this.tallies += 1;
	}
    
}
