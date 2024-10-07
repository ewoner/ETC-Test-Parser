# Import the module if not already imported
Import-Module -Name ETCWebService -force
$VerbosePreference = "Continue"
# Call Get-User function
$user = Get-User

# Check if user object is valid
if ($user) {
    Write-Host "Username: $($user.Username)"
    Write-Host "Token: $($user.GetTokenPlainText())"  # Assuming GetTokenPlainText method exists
} else {
    Write-Host "Failed to retrieve user information."
}
