﻿#Append PSModulePath
$MyModulePath = "$env:OneDriveCommercial\Documents\WindowsPowerShell\Modules"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$MyModulePath"

# Import modules

## Chocolatey profie
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module 'posh-git'
Import-Module 'oh-my-posh'

# oh-my-posh settings
Set-Theme Paradox
$DefaultUser = $env:USERNAME

# Aliases
New-Alias -Name k -Value kubectl -Force
New-Alias -Name kalp -Value "kubectl run alpine --rm=true -it --image=alpine sh" -Force
