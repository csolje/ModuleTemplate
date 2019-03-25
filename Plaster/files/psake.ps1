Properties {
    $moduleSource = "$PSScriptRoot\$ModuleName"
    $buildDestination = "$PSScriptRoot\build\$ModuleName"

    $modulePSM = "$buildDestination\$ModuleName.psm1"
    $modulePSD = "$buildDestination\$ModuleName.psd1"

    $testResultsPath = Join-Path -Path (Split-Path -Path "$buildDestination\" -Parent) -ChildPath 'testResults'
}

Task default -Depends Test, Build

Task Build -Depends Build-CompilePSM1, Build-CopyPSD1

Task Build-CompilePSM1 {
    $lib = @( Get-ChildItem -Path $PSScriptRoot\$ModuleName\lib\*.ps1 -ErrorAction SilentlyContinue )
    $functions = @( Get-ChildItem -Path $PSScriptRoot\$ModuleName\functions\*.ps1 -ErrorAction SilentlyContinue )
    $internal = @( Get-ChildItem -Path $PSScriptRoot\$ModuleName\internal\*.ps1 -ErrorAction SilentlyContinue )

    New-Item -Path $modulePSM -ItemType File -Force

    Foreach ($file in @($lib + $internal + $functions))
    {
        Try
        {
            Get-Content -Path $file.FullName | Out-File -FilePath $modulePSM -Append
        }
        Catch
        {
            Write-Error -Message "Failed to import file content from $($file.FullName): $_ to $modulePSM"
        }
    }

    for ($i = 0; $i -lt $functions.Count; $i++)
    {
        if ($i -eq 0)
        {
            Add-Content -Path $modulePSM -Value "Export-ModuleMember -Function $($functions[$i].BaseName)" -NoNewline
        }
        else
        {
            Add-Content -Path $modulePSM -Value ",$($functions[$i].BaseName)" -NoNewline
        }
    }
    Add-Content -Path $modulePSM -Value $([Environment]::NewLine)
}

Task Build-CopyPSD1 -Depends Build-CompilePSM1 {
    Copy-Item -Path "$moduleSource\$ModuleName.psd1" -Destination $modulePSD -Force
}

Task Test -Depends Test-Pester, Test-ScriptAnalyzer

Task Test-Pester {
    if (-not(Test-Path $testResultsPath))
    {
        New-Item -Path $testResultsPath -ItemType Directory
    }
    $InvokePesterParamSplat = @{
        Script = "$PSScriptRoot\$ModuleName\tests\*.tests.ps1"
        OutputFile = "$testResultsPath\$ModuleName.testResults.xml"
        OutputFormat = 'NUnitXml'
        CodeCoverageOutputFile = "$testResultsPath\$ModuleName.coverage.xml"
        CodeCoverageOutputFileFormat = 'JaCoCo'
        CodeCoverage = "$PSScriptRoot\$ModuleName\functions\*"
    }

    $testResults = Invoke-Pester @InvokePesterParamSplat -PassThru
    if ($testResults.FailedCount -gt 0)
    {
        Write-Error "Pester tests failed with $($testResults.FailedCount) Errors."
    }
    else
    {
        "Pester tests found 0 Errors."
    }
}

Task Test-ScriptAnalyzer {
    $AnalyzerResults = Invoke-ScriptAnalyzer -Path "$PSScriptRoot\$ModuleName\" -Recurse -Severity Error -ExcludeRule PSAvoidUsingUserNameAndPassWordParams
    if ($AnalyzerResults)
    {
        $AnalyzerResults
        Throw "PSScriptAnalyzer found $($AnalyzerResults.Count) Errors."
        exit 1
    }
    else
    {
        "PSScriptAnalyzer found 0 Errors."
    }
}