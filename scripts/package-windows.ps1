#Requires -Version 5.1
<#
.SYNOPSIS
    Assembles a self-contained BaboViolent 2 Windows release folder.

.PARAMETER BuildDir
    CMake build directory. Default: build-windows

.PARAMETER Config
    Build configuration. Default: Release

.PARAMETER OutDir
    Output directory. Default: dist

.EXAMPLE
    .\scripts\package-windows.ps1
    .\scripts\package-windows.ps1 -Config Debug
#>
param(
    [string]$BuildDir = "build-windows",
    [string]$Config   = "Release",
    [string]$OutDir   = "dist"
)

$ErrorActionPreference = "Stop"
$Root = Split-Path $PSScriptRoot -Parent
Set-Location $Root

$ClientExe = Join-Path $Root (Join-Path $BuildDir (Join-Path $Config "BaboViolent.exe"))
$ServerExe = Join-Path $Root (Join-Path $BuildDir (Join-Path $Config "BaboViolentDedicated.exe"))

if (-not (Test-Path $ServerExe)) {
    throw "Server exe not found: $ServerExe"
}

$PkgName = "BaboViolent2-windows-x86_64"
$Stage   = Join-Path $Root (Join-Path $OutDir $PkgName)

if (Test-Path $Stage) { Remove-Item $Stage -Recurse -Force }
New-Item -ItemType Directory -Force -Path $Stage | Out-Null

Write-Host "Copying Content/..."
Copy-Item -Path (Join-Path $Root "Content") -Destination (Join-Path $Stage "Content") -Recurse

# Exes and DLLs go inside Content/ so main\bv2.cfg is found immediately —
# no relocation logic needed.
$ContentStage = Join-Path $Stage "Content"

Write-Host "Copying executables..."
Copy-Item -Path $ServerExe -Destination (Join-Path $ContentStage "BaboViolentDedicated.exe")
if (Test-Path $ClientExe) {
    Copy-Item -Path $ClientExe -Destination (Join-Path $ContentStage "BaboViolent.exe")
} else {
    Write-Warning "Client exe not found - server-only package"
}

Write-Host "Copying MSVC runtime DLLs..."
$DllsToCopy = @(
    "msvcp140.dll"
    "vcruntime140.dll"
    "vcruntime140_1.dll"
)
$CrtDir = $null
$CrtCandidates = @(
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Redist\MSVC\14.44.35112\x64\Microsoft.VC143.CRT"
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Redist\MSVC\14.44.35207\x64\Microsoft.VC143.CRT"
    "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\VC\Redist\MSVC\14.44.35112\x64\Microsoft.VC143.CRT"
    "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Redist\MSVC\14.44.35112\x64\Microsoft.VC143.CRT"
    "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Redist\MSVC\14.44.35112\x64\Microsoft.VC143.CRT"
)
foreach ($candidate in $CrtCandidates) {
    if ([System.IO.Directory]::Exists($candidate)) {
        $CrtDir = $candidate
        break
    }
}
if ($CrtDir) {
    Write-Host "  from $CrtDir"
    foreach ($dll in $DllsToCopy) {
        $src = Join-Path $CrtDir $dll
        if (Test-Path $src) {
            Copy-Item -Path $src -Destination (Join-Path $ContentStage $dll)
            Write-Host "  $dll"
        }
    }
} else {
    Write-Warning "MSVC CRT not found - users may need VC++ Redistributable"
}

$readme = @(
    "BaboViolent 2 (Windows x86_64)"
    "-------------------------------"
    "PLAY:   Double-click Content\BaboViolent.exe"
    "HOST:   Double-click Content\BaboViolentDedicated.exe  (starts FFA by default)"
    "        Or from a command prompt:"
    "          Content\BaboViolentDedicated.exe CTF"
    "          Content\BaboViolentDedicated.exe TDM"
)
$readme | Out-File -FilePath (Join-Path $Stage "README.txt") -Encoding utf8

$ZipPath = Join-Path $Root (Join-Path $OutDir ($PkgName + ".zip"))
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
Write-Host "Creating zip..."
Compress-Archive -Path $Stage -DestinationPath $ZipPath

$sizeMB = [math]::Round((Get-Item $ZipPath).Length / 1MB, 1)
Write-Host ""
Write-Host "Done: $ZipPath  ($sizeMB MB)"
Write-Host "Folder: $Stage"
