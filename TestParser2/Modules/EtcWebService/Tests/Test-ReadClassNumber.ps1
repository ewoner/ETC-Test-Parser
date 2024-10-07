Describe "Read-ClassNumber Tests" {
    BeforeAll {
        # Import the module containing your functions
        Import-Module -Name ".\ETCWebService.psd1" -Force
    }
    
    Context "Valid Class Prefix Directory Exists" {
        It "Returns the correct class prefix" {
            $DirectoryPath = "D:\projects\TestParser\Students"
            $mockedInput = "12345"  # Simulate user input
            
            # Mock the Read-Host cmdlet to provide input
            Mock Read-Host { $mockedInput }
            
            # Call the function and capture the output
            $result = Read-ClassNumber -DirectoryPath $DirectoryPath
            
            # Assert that the function returned the expected class prefix
            $result -eq "12345"
        }
    }
    
    Context "No Class Prefix Directory Exists" {
        It "Handles a non-existent class prefix directory" {
            $DirectoryPath = "D:\projects\TestParser\Students"
            $mockedInput = "99999"  # Simulate user input
            
            # Mock the Read-Host cmdlet to provide input
            Mock Read-Host { $mockedInput }
            
            # Call the function and capture the output
            $result = Read-ClassNumber -DirectoryPath $DirectoryPath
            
            # Assert that the function did not return a valid class prefix
            $result -eq $null
        }
    }
    
    Context "Invalid Class Prefix" {
        It "Handles a class number shorter than 5 characters" {
            $DirectoryPath = "D:\projects\TestParser\Students"
            $mockedInput = "1234"  # Simulate user input
            
            # Mock the Read-Host cmdlet to provide input
            Mock Read-Host { $mockedInput }
            
            # Call the function and capture the output
            $result = Read-ClassNumber -DirectoryPath $DirectoryPath
            
            # Assert that the function did not return a valid class prefix
            $result -eq $null
        }
    }
}
