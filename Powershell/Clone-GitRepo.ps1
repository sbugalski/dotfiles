<#
.SYNOPSIS
    Clones a Git repository to a specified directory.

.DESCRIPTION
    The Clone-GitRepoToDirectory function clones a Git repository from a specified URL to a specified directory.
    If no directory is provided, it defaults to the user's 'repos' directory in their user profile.

.PARAMETER Url
    The URL of the Git repository to clone.

.PARAMETER DefaultPath
    The default directory path to clone the repository to. If not provided, it defaults to the user's 'repos' directory.

.EXAMPLE
    Clone-GitRepoToDirectory -Url "https://github.com/example/repo.git" -DefaultPath "C:\Projects"

    This example clones the Git repository from the specified URL to the 'C:\Projects' directory.
#>

function Clone-GitRepoToDirectory {

    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,

        [string]$DefaultPath
    )

    try {
        if (-not $DefaultPath) {
            $DefaultPath = Join-Path -Path ([Environment]::GetFolderPath("UserProfile")) -ChildPath "repos"
        }

        Write-Host "Default path is set to: $DefaultPath"

        $uri = New-Object System.Uri($Url)
        $path = $uri.Host + $uri.AbsolutePath

        Write-Host "Parsed path from URL: $path"

        # Remove the '_git' part from the path
        $path = $path -replace '/_git', ''

        $fullPath = Join-Path -Path $DefaultPath -ChildPath $path

        Write-Host "Full path for the repository: $fullPath"

        New-Item -ItemType Directory -Force -Path $fullPath

        Write-Host "Created directory structure at: $fullPath"

        git clone $Url $fullPath

        Write-Host "Cloned repository from $Url to $fullPath"
    }
    catch {
        Write-Host "An error occurred: $_"
    }
}

Set-Alias -Name gitclone -Value Clone-GitRepoToDirectory