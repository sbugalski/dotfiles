# Variables
if ( (!$env:UserFilesLocation) -and ($env:OneDriveCommercial -or $env:OneDriveConsumer)) {
  [System.Environment]::SetEnvironmentVariable('UserFilesLocation', $env:OneDriveCommercial, [System.EnvironmentVariableTarget]::User)
}
else {
  [System.Environment]::SetEnvironmentVariable('UserFilesLocation', $env:USERPROFILE, [System.EnvironmentVariableTarget]::User)
}

# Fix git log output encoding issues on Windows 10 command prompt https://stackoverflow.com/questions/41139067/git-log-output-encoding-issues-on-windows-10-command-prompt/41416262#41416262
# Thanks to @laurentkempe
$env:LC_ALL = 'C.UTF-8'

# Append PSModulePath
$MyModulePath = "$env:OneDriveCommercial\Documents\WindowsPowerShell\Modules"
$env:PSModulePath = $env:PSModulePath + "$([System.IO.Path]::PathSeparator)$MyModulePath"

# Modules

## Chocolatey module
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Import-Module 'posh-git'
Import-Module 'oh-my-posh'

## oh-my-posh settings
Set-Theme Paradox
$DefaultUser = $env:USERNAME

## PSFzf for history find, kubectx and kubens
Remove-PSReadlineKeyHandler 'Ctrl+r'
Remove-PSReadlineKeyHandler 'Ctrl+t'
Import-Module PSFzf

# Autocomplete

## Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

## Autocompletion for arrow keys
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Aliases
New-Alias -Name k -Value kubectl -Force
New-Alias -Name open -Value Invoke-Item -Force

## Easier Navigation: ..; ...; ....; .....; and ~
## Thanks to @laurentkempe
${function:~} = { Set-Location ~ }
${function:Set-ParentLocation} = { Set-Location .. }; Set-Alias ".." Set-ParentLocation
${function:...} = { Set-Location ..\.. }
${function:....} = { Set-Location ..\..\.. }
${function:.....} = { Set-Location ..\..\..\.. }
${function:......} = { Set-Location ..\..\..\..\.. }

## Navigation Shortcuts
# Thanks to @laurentkempe
${function:d} = { Set-Location "$env:documentsPath\Desktop" }
${function:docs} = { Set-Location "$env:documentsPath\Documents" }
${function:dl} = { Set-Location "$env:documentsPath\Downloads" }
${function:g} = { Set-Location "~\git\src" }

function global:Run-KubeAlpine {
  [CmdletBinding()]
  [Alias('kalp')]
  param (
    [Parameter(ValueFromRemainingArguments = $true)]$params
  )
  & kubectl run alpine --rm=true -it --image=alpine sh $params
}

# source https://medium.com/rkttu/handy-kubernetes-context-namespace-switcher-for-powershell-a432ff8ae7cd
function global:Select-KubeContext {
  [CmdletBinding()]
  [Alias('kubectx')]
  param (
    [parameter(Mandatory = $False, Position = 0, ValueFromRemainingArguments = $True)]
    [Object[]] $Arguments
  )
  begin {
    if ($Arguments.Length -gt 0) {
      $ctx = & kubectl config get-contexts -o=name | fzf -q @Arguments
    }
    else {
      $ctx = & kubectl config get-contexts -o=name | fzf
    }
  }
  process {
    if ($ctx -ne '') {
      & kubectl config use-context $ctx
    }
  }
}

function global:Select-KubeNamespace {
  [CmdletBinding()]
  [Alias('kubens')]
  param (
    [parameter(Mandatory = $False, Position = 0, ValueFromRemainingArguments = $True)]
    [Object[]] $Arguments
  )
  begin {
    if ($Arguments.Length -gt 0) {
      $ns = & kubectl get namespace -o=name | fzf -q @Arguments
    }
    else {
      $ns = & kubectl get namespace -o=name | fzf
    }
  }
  process {
    if ($ns -ne '') {
      $ns = $ns -replace '^namespace/'
      & kubectl config set-context --current --namespace=$ns
    }
  }
}

# Profile symlink
#cmd /c mklink "$env:UserFilesLocation\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" "$env:USERPROFILE\git\src\github.com\sbugalski\dotfiles\Powershell\Microsoft.PowerShell_profile.ps1"
#cmd /c mklink "$env:UserFilesLocation\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" "$env:USERPROFILE\git\src\github.com\sbugalski\dotfiles\Powershell\Microsoft.PowerShell_profile.ps1"