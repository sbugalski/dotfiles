# Profile symlink
#cmd /c mklink "$PROFILE" "$env:USERPROFILE\git\src\github.com\sbugalski\dotfiles\Powershell\Microsoft.PowerShell_profile.ps1"
#cmd /c mklink "$PROFILE" "$env:USERPROFILE\git\src\github.com\sbugalski\dotfiles\Powershell\Microsoft.PowerShell_profile.ps1"
#cmd /c mklink "$env:UserFilesLocation\Documents\WindowsPowerShell\kubectl_aliases.ps1" "$env:USERPROFILE\git\src\github.com\sbugalski\dotfiles\Powershell\kubectl_aliases.ps1"


# Git

## Fix git log output encoding issues on Windows 10 command prompt https://stackoverflow.com/questions/41139067/git-log-output-encoding-issues-on-windows-10-command-prompt/41416262#41416262
### Thanks to @laurentkempe
$env:LC_ALL = 'C.UTF-8'

## Set max GPG4Win passphrase password prompt
Set-Content -Path "$env:AppData\gnupg\gpg-agent.conf" -Value "default-cache-ttl 34560000$([System.Environment]::NewLine)max-cache-ttl 34560000"

# History size
$MaximumHistoryCount = 4096

# Produce UTF-8 by default
$PSDefaultParameterValues["Out-FIle:Encoding"] = "utf8"

# Disable sounds
Set-PSReadLineOption -BellStyle None

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

# Variables
[System.Environment]::SetEnvironmentVariable('UserFilesLocation', $env:OneDriveCommercial, [System.EnvironmentVariableTarget]::User)
# Requires ChocolateyProfile
Update-SessionEnvironment

# Autocomplete

## Shows navigable menu of all options when hitting Tab
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete

## Autocompletion for arrow keys
#Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
#Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

# Remove previous command history "UpArrow" at F8 key
Remove-PSReadLineKeyHandler -Chord F8

Set-PSReadlineKeyHandler -Key UpArrow -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchBackward()
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
}

Set-PSReadlineKeyHandler -Key DownArrow -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::HistorySearchForward()
    [Microsoft.PowerShell.PSConsoleReadLine]::EndOfLine()
}

# Aliases
## Connect-Office365
. $env:USERPROFILE\git\src\github.com\sbugalski\dotfiles\Powershell\Connect-Office365.ps1

## azctx
## TODO
<#function global:azctx {
    Select-AzContext (Get-AzContext -ListAvailable | Invoke-Fzf)
}#>

## kubectl
. $env:USERPROFILE\git\src\github.com\sbugalski\dotfiles\Powershell\kubectl_aliases.ps1
### using k as alias, so it supports unambiguous parameters, like "-o"
New-Alias -Name k -Value kubectl -Description "kubectl k alias" -Option AllScope -Force

New-Alias -Name open -Value Invoke-Item -Description "Open folder or item with default program alias" -Option AllScope -Force
New-Alias -Name encode64 -Value ConvertTo-Base64 -Description "ConvertTo-Base64 alias" -Option AllScope -Force
New-Alias -Name decode64 -Value ConvertFrom-Base64 -Description "ConvertFrom-Base64 alias" -Option AllScope -Force

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
${function:d} = { Set-Location "$env:UserFilesLocation\Desktop" }
${function:docs} = { Set-Location "$env:UserFilesLocation\Documents" }
${function:dl} = { Set-Location "$env:USERPROFILE\Downloads" }
${function:src} = { Set-Location "~\git\src" }

function global:Run-KubeAlpine {
    [CmdletBinding()]
    [Alias('ksh')]
    param (
        [Parameter(ValueFromRemainingArguments = $true)]$params
    )
    & kubectl run alpine --rm=true -it --image=curlimages/curl sh $params
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

function global:ConvertTo-Base64 {
    [Alias('ct64')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string] $string
    )
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($string);
    $encoded = [System.Convert]::ToBase64String($bytes);

    return $encoded;
}

function global:ConvertFrom-Base64 {
    [Alias('base64')]
    param (
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true)]
        [string] $string
    )
    $bytes = [System.Convert]::FromBase64String($string);
    $decoded = [System.Text.Encoding]::UTF8.GetString($bytes);

    return $decoded;
}
