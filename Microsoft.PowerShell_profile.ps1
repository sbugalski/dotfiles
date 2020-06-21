#Append PSModulePath
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

function global:Run-KubeAlpine {
  [CmdletBinding()]
  [Alias('kalp')]
  [Parameter(ValueFromRemainingArguments = $true)]$params
  & kubectl run alpine --rm=true -it --image=alpine sh $params
}

# source https://medium.com/rkttu/handy-kubernetes-context-namespace-switcher-for-powershell-a432ff8ae7cd
function global:Select-KubeContext {
  [CmdletBinding()]
  [Alias('kubectx')]
  param (
    [parameter(Mandatory=$False,Position=0,ValueFromRemainingArguments=$True)]
    [Object[]] $Arguments
  )
  begin {
    if ($Arguments.Length -gt 0) {
      $ctx = & kubectl config get-contexts -o=name | fzf -q @Arguments
    } else {
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
    [parameter(Mandatory=$False,Position=0,ValueFromRemainingArguments=$True)]
    [Object[]] $Arguments
  )
  begin {
    if ($Arguments.Length -gt 0) {
      $ns = & kubectl get namespace -o=name | fzf -q @Arguments
    } else {
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