
<#
    .Synopsis
        Building of a module
    .DESCRIPTION
        Building a module psm1 and manifest file from the existing scripts
    .PARAMETER VersionNumber
        Full version number, e.g. 0.0.0.2
    .PARAMETER ModulesRootDir
        The root directory of the modules
    .PARAMETER ZipOnly
        If used, the module will exist in a zip only
    .EXAMPLE
        Invoke-PSModuleBuild.ps1 -VersionNumber "0.0.0.3" -ModulesRootDir .\TMS\Modules\ -ReleaseNotes "New release" -Guid "a20c0717-1c83-4f78-b55f-185a75ccd49b"
#>

param(
    [Parameter(Mandatory = $true)]
    [version]
    $VersionNumber,

    [Parameter(Mandatory = $true)]
    [System.IO.DirectoryInfo]
    $ModulesRootDir,

    [Parameter()]
    [switch]
    $ZipOnly
)

$ErrorActionPreference = "stop"

function Start-PSModuleBuild {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $moduleRootDir,

        [Parameter(Mandatory = $true)]
        [version]
        $ModuleVersion,

        [Parameter()]
        [string]
        $ReleaseNotes,

        [Parameter()]
        [switch]
        $ZipOnly
    )

    Write-Verbose -Message "$ModuleName - Setting ModuleName"
    $moduleName = ([System.IO.DirectoryInfo]$moduleRootDir).Name

    Write-Verbose -Message "$ModuleName - Setting ModuleFilePath"
    $moduleFilePath = "$moduleRootDir\$($ModuleName).psm1"

    if(Test-Path -Path "$moduleRootDir\functions")
    {
        Write-Verbose -Message "$ModuleName - Getting module functions content"
        $moduleFileContent = Get-ChildItem -Path "$moduleRootDir\functions" -Filter '*.ps1' -Recurse | Get-Content
    }

    if(Test-Path -Path "$moduleRootDir\DSCResources")
    {
        Write-Verbose -Message "$ModuleName - Getting module DSCResources content"
        $moduleFileContent = Get-ChildItem -path "$moduleRootDir\DSCResources\*.ps1" | Get-Content
    }

    Write-Verbose -Message "$ModuleName - Writing content to module file"
    $moduleFileContent | Out-File -FilePath $moduleFilePath -Force

    Write-Verbose -Message "$ModuleName - Setting module manifest path"
    $moduleManifestPath = "$moduleRootDir\$($ModuleName).psd1"

    Write-Verbose -Message "$ModuleName - Create manifest splat"
    $newModuleManifestSplat = @{
        Path = $moduleManifestPath
        ModuleVersion = $ModuleVersion
        CompanyName = "Sentia Danmark A/S"
        RootModule = "$($ModuleName).psm1"
        ReleaseNotes = $ReleaseNotes
        Guid = (New-GuidFromString -String $ModuleName)
    }

    Write-Verbose -Message "$ModuleName - New-ModuleManifest"
    New-ModuleManifest @newModuleManifestSplat

    Write-Verbose -Message "$ModuleName - Testing module"
    if(-not (Test-ModuleManifest -Path $moduleManifestPath))
    {
        throw "Module manifest not valid"
    }

    if($ZipOnly) {

        Write-Verbose -Message "$ModuleName - setting zip file path"
        $destination = "$moduleRootDir\$($ModuleName).zip"

        If(Test-path $destination) {
            Write-Verbose -Message "$ModuleName - Deleting existing zip-file"
            $null = Remove-item $destination
        }

        Write-Verbose -Message "$ModuleName - Setting temp dir variable"
        $tempDir = "$moduleRootDir\temp\$ModuleName"

        if(!(Test-Path -Path $tempDir)){
            Write-Verbose -Message "$ModuleName - Creating temp dir"
            $null = New-Item -ItemType "Directory" -Path $tempDir
        }

        Write-Verbose -Message "$ModuleName - Copying files to temp dir"
        Copy-Item -Path "$($moduleRootDir)\*.ps*" -Destination $tempDir

        Write-Verbose -Message "$ModuleName - Zipping files"
        $null = Add-Type -assembly "system.io.compression.filesystem"
        $null = [io.compression.zipfile]::CreateFromDirectory("$moduleRootDir\temp", $destination)

        Write-Verbose -Message "$ModuleName - Cleaning up"
        $null = Remove-Item $moduleFilePath
        $null = Remove-Item $moduleManifestPath
        $null = Remove-Item "$moduleRootDir\temp" -Force -Recurse
    }
}
function New-GuidFromString
{
    param (
        [string]
        $String
    )

    Write-Verbose -Message "Creating GUID for string: $string"

    $guidHash = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create('MD5').ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String)) | `
        ForEach-Object {
            [Void]$guidHash.Append($_.ToString("x2"))
        }

    $guid = [System.guid]::New($guidHash.ToString())

    return $guid.Guid
}

try
{
    if($env:Build_SourceVersionMessage -and -not $ReleaseNotes)
    {
        'setting note'
        $ReleaseNotes = $env:Build_SourceVersionMessage
    }
    if(-not $ReleaseNotes)
    {
        $ReleaseNotes = ' '
    }

    $modulePaths = Get-ChildItem -Path $ModulesRootDir -Directory | Select-Object -ExpandProperty FullName

    foreach ($modulePath in $modulePaths) {

        $psModuleSplat = @{
            moduleRootDir = $modulePath
            ModuleVersion = $VersionNumber
            ReleaseNotes = $ReleaseNotes
            ZipOnly = $ZipOnly
        }

        Start-PSModuleBuild @psModuleSplat
    }
}
catch {
    $_
    throw $_
}