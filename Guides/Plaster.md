# Plaster Template

Sentia uses the PowerShell Module called Plaster for the module creatation from a template.

## Quick start

- Install Plaster module

``` powershell
Install-Module -Name Plaster -Scope CurrentUser
```

- Importing the Plaster module

``` powershell
Import-Module -Name Plaster
```

- Creating the scaffolding structure for the module that opens the guided creation of a module
  where the \<DestinationPath> is there the module should get created

``` powershell
Invoke-Plaster -TemplatePath C:\GitHub\private-repos\ModuleTemplate\Plaster-Templates\NC -DestinationPath '<DestinationPath>'
```

- If anywhere else run "

``` powershell
Invoke-Plaster -TemplatePath C:\GitHub\ModuleTemplate\Plaster-Template\CustomModule\ -DestinationPath "'<DestinationPath>'" - ModuleName "Name of the module" -Description "A quick description" -Editor VSCode
```

> Note: the destinationPath should always be the root folder of where you want your module to be located ex. "C:\GitHub\". Plaster will create all the folders for your module.
