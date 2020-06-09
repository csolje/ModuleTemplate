#Get public and private function definition files.
$internal  = @( Get-ChildItem -Path $PSScriptRoot\internal\*.ps1 -ErrorAction SilentlyContinue )
$functions = @( Get-ChildItem -Path $PSScriptRoot\functions\*.ps1 -ErrorAction SilentlyContinue )
$lib = @( Get-Item -Path $PSScriptRoot\lib\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach($import in @($internal + $functions + $lib))
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

Export-ModuleMember -Function $functions.BaseName