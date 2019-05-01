$ModuleName = '<%=$PLASTER_PARAM_ModuleName%>'
$here = Split-Path -Parent -Path (Split-Path -Parent -Path $MyInvocation.MyCommand.Path)
$internal = @(Get-ChildItem "$here\internal\*.ps1" -ErrorAction SilentlyContinue)
$functions = @(Get-ChildItem "$here\functions\*.ps1" -ErrorAction SilentlyContinue)

Describe "Module Manifest Tests" {
    It "Passes Test-ModuleManifest" {
        Test-ModuleManifest -Path "$here\$ModuleName.psd1" | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}
Describe "Module: $ModuleName" -Tags Unit {
    Context "Module Configuration" {
        It "Has a root module file ($ModuleName.psm1)" {
            "$here\$ModuleName.psm1" | Should -Exist
        }
        It "Is valid PowerShell (Has no syntax errors)" {
            $contents = Get-Content -Path "$here\$ModuleName.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
        It "Has a manifest file ($ModuleName.psd1)" {
            "$here\$ModuleName.psd1" | Should -Exist
        }
        It "Contains a root module path in the manifest (RootModule = '.\$ModuleName.psm1')" {
            "$here\$ModuleName.psd1" | Should -Exist
            "$here\$ModuleName.psd1" | Should -FileContentMatch "$ModuleName.psm1"
        }
        It "Has the internal, functions and Dependencies folders" {
            "$here\internal" | Should -Exist
            "$here\functions" | Should -Exist
            "$here\lib" | Should -Exist
        }
        It "Has functions in the folders" {
            "$here\functions\*.ps1" | Should -Exist

        }
        foreach ($CurrentFunction in @($functions + $internal))
        {
            Context "Function: $ModuleName::$($CurrentFunction.BaseName)" {
                It "Is valid PowerShell (Has no syntax errors)" {
                    $contents = Get-Content -Path $CurrentFunction -ErrorAction Stop
                    $errors = $null
                    $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
                    $errors.Count | Should Be 0
                }
                It "Has Pester test" {
                    "$here\tests\$($CurrentFunction.BaseName).tests.ps1" | Should -Exist
                }
                It "Is not Empty" {
                    $CurrentFunction | Should -Not -BeNullOrEmpty
                }
                It "Has Get-Help comment block" {
                    $CurrentFunction | Should -FileContentMatch "<#"
                    $CurrentFunction | Should -FileContentMatch "#>"
                }
                It "Has Get-Help .SYNOSIS" {
                    $CurrentFunction | Should -FileContentMatch "\.SYNOPSIS"
                }
                It "Has Get-Help .DESCRIPTION" {
                    $CurrentFunction | Should -FileContentMatch "\.DESCRIPTION"
                }
                <#It "Has Get-Help .NOTES" {
                    $CurrentFunction | Should -FileContentMatch "\.NOTES"
                }#>
                It "Has Get-Help .EXAMPLE" {
                    $CurrentFunction | Should -FileContentMatch "\.EXAMPLE"
                }
            }
        }
    }
}