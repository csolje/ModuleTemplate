#Unblock files.
Get-ChildItem -Path $PSScriptRoot -Recurse | Unblock-File

<%
    if ($PLASTER_PARAM_ModuleFolders -contains 'Classes')
    {
@"
#Add the classes required for the module.
Get-ChildItem -Path $PSScriptRoot\Classes\*.cs | ForEach-Object {
    try
    {
        Add-Type -Path $_.FullName -ErrorAction Stop
    }
    catch
    {
        throw
    }
}
"@
    }
%>

$private  = @( Get-ChildItem -Path $PSScriptRoot\Functions\Private\*.ps1 -ErrorAction SilentlyContinue )
$public  = @( Get-ChildItem -Path $PSScriptRoot\Functions\Public\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($private + $public))
{
    Try
    {
        . $import.FullName
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

Export-ModuleMember -Function $public.BaseName