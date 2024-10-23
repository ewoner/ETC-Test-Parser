# Import the necessary modules
Import-Module Pester
Import-Module TestParser2_1 -force -verbose

# Describe block for the unit test
Describe "Import-ModConfiguration" {

    # Mock the Get-Content command to return test data for specific config files
    Mock Get-Content {
        param($filePath)
        switch ($filePath) {
            # Mocked content for mod1.conf (standard objectives)
            "C:\Users\Brion.Lang\Documents\WindowsPowerShell\Modules\TestParser\Config\mod1.conf" {
                return @"
<objectives>
First objective
Second objective
</objectives>
"@
            }
            # Mocked content for mod2.conf (daily objectives)
            "C:\Users\Brion.Lang\Documents\WindowsPowerShell\Modules\TestParser\Config\mod2.conf" {
                return @"
<objectives>
<DAYBREAK>
Day 1 objective
<DAYBREAK>
Day 2 objective
</objectives>
"@
            }
            default {
                throw "Unexpected file path: $filePath"
            }
        }
    }

    # Test for standard objective block
It "should correctly parse standard objective block" {
    $ModNumber = 1  # Corresponds to mod1.conf

    # Execute the function being tested
    $result = Import-ModConfiguration -ModNumber $ModNumber

    # Assertions to verify the expected outcome
    $result | Should -BeOfType 'ModConfiguration'
    $result.objectives.Count | Should -Be 2
    $result.objectives[0].objString | Should -Be "First objective"
    $result.objectives[1].objString | Should -Be "Second objective"
}

# Test for daily objective block
It "should correctly parse daily objective block" {
    $ModNumber = 2  # Corresponds to mod2.conf

    # Execute the function being tested
    $result = Import-ModConfiguration -ModNumber $ModNumber

    # Assertions to verify the expected outcome
    $result | Should -BeOfType 'ModConfiguration'
    $result.objectives.Count | Should -Be 2
    $result.objectives[0].dayNum | Should -Be 1
    $result.objectives[1].dayNum | Should -Be 2
    $result.objectives[0].objString | Should -Be "Day 1 objective"
    $result.objectives[1].objString | Should -Be "Day 2 objective"
}
}

# Run the Pester tests
#Invoke-Pester -Verbose
