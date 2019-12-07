class RequiredModule
{
    RequiredModule ([string] $Name, [version] $MinimumVersion )
    {
        $this.Name = $Name
        $this.MinimumVersion = $MinimumVersion
    }
    [string] $Name
    [version] $MinimumVersion
}