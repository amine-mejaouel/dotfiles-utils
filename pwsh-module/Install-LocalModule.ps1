<#
.SYNOPSIS
    Installs a local PowerShell module to the user's module directory.

.DESCRIPTION
    Creates a symbolic link from the local module directory to the appropriate PowerShell modules directory
    based on the operating system, ensuring clean installation by removing any
    existing version first.
    - Windows: $env:USERPROFILE\Documents\PowerShell\Modules
    - Linux/macOS: ~/.local/share/powershell/Modules

.PARAMETER ModuleName
    The name of the module to install (matches the folder name).

.PARAMETER SourcePath
    The full path to the source module folder to link.

.EXAMPLE
    Install-LocalModule -ModuleName "dol-testing" -SourcePath "$PSScriptRoot/dol-testing"

.NOTES
    Requires write permissions to the PowerShell modules directory.
    Cross-platform compatible (Windows, Linux, macOS).
#>
function Install-LocalModule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModuleName,

        [Parameter(Mandatory=$true)]
        [string]$SourcePath
    )

    # Determine the modules directory based on OS
    if ($IsLinux -or $IsMacOS) {
        $modulesDir = Join-Path $HOME ".local/share/powershell/Modules"
    } else {
        $modulesDir = Join-Path $env:USERPROFILE "Documents" "PowerShell" "Modules"
    }

    $destinationPath = Join-Path $modulesDir $ModuleName

    if (Test-Path $destinationPath) {
        Write-Verbose "Removing existing module at $destinationPath"
        Remove-Item -Path $destinationPath -Recurse -Force
    }

    Write-Verbose "Creating symbolic link to module at $destinationPath"
    New-Item -ItemType SymbolicLink -Path $destinationPath -Target $SourcePath -Force | Out-Null

    Import-Module $SourcePath -Force

    Write-Host "Module '$ModuleName' linked successfully to $destinationPath" -ForegroundColor Green
}
