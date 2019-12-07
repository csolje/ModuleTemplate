. "$PSScriptRoot\RequiredModule.class.ps1"

$requiredModules = @(
    [RequiredModule]::New('Pester', '4.4.2'),
    [RequiredModule]::New('Psake', '4.7.4'),
    [RequiredModule]::New('PSScriptAnalyzer', '1.17.1')
)