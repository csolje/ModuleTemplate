<#
.SYNOPSIS
Custom Plaster templates

.DESCRIPTION
This script helps you to create a new module scraffording from a template

.NOTES
    Tags: Plaster
    Author: Christian Solje (csolje@gmail.com)
    Copyright: (c) 2018, licensed under MIT
    License: MIT https://opensource.org/licenses/MIT

.EXAMPLE


#>
Clear-Host

# Lets take a look at our module project.
Get-PlasterTemplate -Path .\Plaster-Templates\ -Recurse

# Invoke-Plaster CustomModule v1 - something.
Invoke-Plaster -TemplatePath '.\Plaster-Templates\CustomModule' -DestinationPath 'C:\GitHub'