param(
    [ValidateSet(4)][int]$Lab = 4,
    [ValidateSet('windows','chrome','edge')][string]$Device = 'windows',
    [string]$ApiBase = 'https://dummyjson.com'
)
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
$projectPath = $PSScriptRoot
$sdkCandidates = @(
    (Join-Path $env:USERPROFILE '.cache\lab2025-tools\flutter\bin\flutter.bat')
)
$flutterCommand = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCommand) { $flutterPath = $flutterCommand.Source }
else { $flutterPath = $sdkCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1 }
if (-not $flutterPath) { throw 'Flutter SDK not found. Install Flutter and add flutter/bin to PATH.' }

# A short ASCII junction avoids known Dart/CMake problems with Cyrillic paths.
$hasher = [System.Security.Cryptography.SHA256]::Create()
$hashBytes = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($projectPath))
$hasher.Dispose()
$projectId = ([BitConverter]::ToString($hashBytes)).Replace('-','').Substring(0,12).ToLowerInvariant()
$cacheRoot = Join-Path $env:USERPROFILE '.cache\lab2025-projects'
$buildPath = Join-Path $cacheRoot $projectId
New-Item -ItemType Directory -Path $cacheRoot -Force | Out-Null
$existingAlias = Join-Path $env:USERPROFILE '.cache\lab2025-project'
if (Test-Path -LiteralPath $existingAlias) {
    $aliasItem = Get-Item -LiteralPath $existingAlias
    if ($aliasItem.LinkType -eq 'Junction' -and $aliasItem.Target -eq $projectPath) {
        $buildPath = $existingAlias
    }
}
if (-not (Test-Path -LiteralPath $buildPath)) {
    New-Item -ItemType Junction -Path $buildPath -Target $projectPath | Out-Null
}
$entryPoint = if ($Lab -eq 5) { 'lib/main.dart' } else { "lib/main_lab$Lab.dart" }
Write-Host "Project build path: $buildPath"
Push-Location -LiteralPath $buildPath
try {
    $cmakeCache = Join-Path $buildPath 'build\windows\x64\CMakeCache.txt'
    if (Test-Path -LiteralPath $cmakeCache) {
        $homeEntry = Get-Content -LiteralPath $cmakeCache | Where-Object { $_ -like 'CMAKE_HOME_DIRECTORY:INTERNAL=*' }
        $expectedHome = (Join-Path $buildPath 'windows').Replace('\','/')
        if ($homeEntry -and $homeEntry.Substring('CMAKE_HOME_DIRECTORY:INTERNAL='.Length) -ne $expectedHome) {
            # CMake caches absolute paths. Clear generated files after changing an alias.
            & $flutterPath clean
            if ($LASTEXITCODE -ne 0) { throw 'flutter clean failed' }
            if (Test-Path -LiteralPath $cmakeCache) {
                throw 'Build files are in use. Close running apps or local servers using the build folder and retry.'
            }
        }
    }
    & $flutterPath pub get
    if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed' }
    & $flutterPath run -d $Device --target $entryPoint "--dart-define=API_BASE_URL=$ApiBase"
    if ($LASTEXITCODE -ne 0) { throw 'flutter run failed' }
} finally { Pop-Location }
