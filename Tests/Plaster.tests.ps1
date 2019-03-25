$PlasterHomePath = Join-Path -Path (Split-Path -Path (Split-Path -Path $MyInvocation.MyCommand.Path -Parent) -Parent) -ChildPath 'Plaster'

$testData = @{
    TemplatePath    = $PlasterHomePath
    DestinationPath = 'TestDrive:\'
    ModuleName      = "MyTestModule"
    Description     = "MyTestDescription123"
    Editor          = 'VSCode'
}

Describe 'Plaster Template Test Dependencies' {
    $module = Get-Module -Name Plaster -ListAvailable

    It 'Plaster module is available' {
        ($plasterModule | Select-Object -First 1 -Property Name).Name | Should -Be "Plaster"
    }
}

Describe 'Plaster Template' {
    [xml]$data = get-content ..\Plaster\PlasterManifest.xml
    Context 'Plaster Defined Files' {
        foreach ($file in @($data.plasterManifest.content.file + $data.plasterManifest.content.templatefile))
        {
            $sPath = "$($testData.TemplatePath)\$($file.source)"

            It "Confirm File In PlasterTemplate::$sPath" {
                Test-Path -Path $sPath | Should -Be $true
            }
        }
    }
    Context 'Module Creation Test' {
        Invoke-Plaster @testData 6>$null
        foreach ($file in @($data.plasterManifest.content.file + $data.plasterManifest.content.templatefile))
        {
            $file.destination = $file.destination.Replace('${PLASTER_PARAM_ModuleName}', $testData.ModuleName)
        }
        $psd1Destination = $data.plasterManifest.content.newModuleManifest.destination.Replace('${PLASTER_PARAM_ModuleName}', $testData.ModuleName)
        $psd1Path = "$($testData.DestinationPath)$psd1Destination"

        It 'Module has been created' {
            Test-Path -Path "$($testData.DestinationPath)\$($testData.ModuleName)" | Should -Be $true
        }

        Context 'Testing files defined in PlasterManifest.xml' {
            It "File Copied to Destination::$psd1Path" {
                Test-Path -Path $psd1Path | Should -Be $true
            }
            foreach ($file in $data.plasterManifest.content.file)
            {
                $dPath = "$($testData.DestinationPath)\$($file.destination)"
                It "File Copied to Destination::$dPath" {
                    Test-Path -Path $dPath | Should -Be $true
                }
            }
            foreach ($file in $data.plasterManifest.content.templatefile)
            {
                $dPath = "$($testData.DestinationPath)\$($file.destination)"
                It "TemplateFile Copied to Destination::$dPath" {
                    Test-Path -Path $dPath | Should -Be $true
                }
            }
        }
    }
}
