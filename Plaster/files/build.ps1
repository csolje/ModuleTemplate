$ModuleName = "<%=$PLASTER_PARAM_ModuleName%>"

. "$PSScriptRoot\$ModuleName\lib\RequiredModules.ps1"

#Ensuring module availability
forEach ($module in $requiredModules)
{
    try
    {
        Write-Host "Ensuring module: $($module.Name), minimum version: $($module.MinimumVersion) availability.. " -NoNewline
        If (-not(Get-Module -Name $module.Name -ListAvailable))
        {
            Write-Host "Installing.. " -NoNewline -ForegroundColor Yellow
            $null = Install-Module -Name $module.Name -Scope CurrentUser -Force -Confirm:$false -MinimumVersion $module.MinimumVersion
        }
        else
        {
            $currentModule = Get-Module $module.Name
            if ($currentModule)
            {
                if ($currentModule.Version -lt $module.MinimumVersion)
                {
                    Remove-Module $module.Name
                }
            }
        }
        Import-Module $module.Name -MinimumVersion $module.MinimumVersion -ErrorAction Stop
        Write-Host "Success. Using version: $((Get-Module $module.Name).Version)" -ForegroundColor Green
    }
    catch
    {
        Write-Host 'Failed!' -ForegroundColor Red
        throw $Error[0]
    }
}

Invoke-Psake -BuildFile "$PSScriptRoot\psake.ps1" -Parameters @{'ModuleName' = $ModuleName}
if ($psake.build_success)
{
    "Build Successful."
}
else {
    #This will fail the build in the TFS Build pipeline, if psake detects errors.
    "Build failed."
    exit 1
}