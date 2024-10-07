function Output-ScriptVariables {
	$scriptScopeVars = Get-Variable -Scope Script
	
	    foreach ($var in $scriptScopeVars) {
	        Write-Host "$($var.Name) = $($var.Value)"
	    }
	pause
}