param(
    [string]$DeviceId = '',
    [switch]$PrepareOnly
)

$ErrorActionPreference = 'Stop'

$adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
if (-not (Test-Path -LiteralPath $adbPath)) {
    throw "Android Debug Bridge was not found at $adbPath."
}

$projectPath = Split-Path -Parent $PSScriptRoot
if (-not $DeviceId.Trim()) {
    $serial = & $adbPath -d get-serialno
    if ($LASTEXITCODE -ne 0 -or -not $serial -or $serial.Trim() -eq 'unknown') {
        throw 'Connect one USB Android phone, or pass -DeviceId with the serial from adb devices.'
    }
    $DeviceId = $serial.Trim()
}
$adbArguments = @('-s', $DeviceId.Trim())
$deviceState = & $adbPath @adbArguments get-state
if ($LASTEXITCODE -ne 0 -or -not $deviceState -or $deviceState.Trim() -ne 'device') {
    throw "Phone $DeviceId is unavailable. Connect USB and authorize USB debugging on the phone."
}

try {
    $categories = Invoke-RestMethod -Uri 'http://127.0.0.1:8080/api/v1/explore/categories' -TimeoutSec 10
    if (-not $categories -or -not $categories[0].id) {
        throw 'The server did not return Explore categories.'
    }
} catch {
    throw "Rootly backend is not responding at http://127.0.0.1:8080. Start Rootly_Backend and retry. $($_.Exception.Message)"
}

& $adbPath @adbArguments reverse tcp:8080 tcp:8080
if ($LASTEXITCODE -ne 0) {
    throw 'Could not forward the phone port 8080 to the Rootly backend.'
}

Write-Host "Phone $DeviceId is connected to Rootly at http://127.0.0.1:8080 through USB."
if ($PrepareOnly) {
    return
}

# Prefer the SDK configured by this project over whichever Flutter is on PATH.
$flutterPath = $null
$localPropertiesPath = Join-Path $projectPath 'android\local.properties'
if (Test-Path -LiteralPath $localPropertiesPath) {
    $sdkProperty = Get-Content -LiteralPath $localPropertiesPath |
        Where-Object { $_ -match '^flutter\.sdk=' } | Select-Object -First 1
    if ($sdkProperty) {
        $sdkPath = $sdkProperty.Substring('flutter.sdk='.Length).Replace('\\', '\').Replace('\:', ':')
        $flutterPath = Join-Path $sdkPath 'bin\flutter.bat'
    }
}
if (-not $flutterPath -or -not (Test-Path -LiteralPath $flutterPath)) {
    $flutterPath = (Get-Command flutter -ErrorAction Stop).Source
}

$flutterArguments = @(
    'run',
    '--debug',
    '-d', $DeviceId.Trim(),
    '--dart-define=API_BASE_URL=http://127.0.0.1:8080'
)

# Flutter's batch scripts expand PATH without quoting it. An ampersand in an
# unrelated entry can become a command separator. Limit this workaround to
# this launcher process, preserving the user's stored PATH.
$originalPath = $env:Path
$runExitCode = 1
Push-Location $projectPath
try {
    $env:Path = ($originalPath -split ';' | Where-Object { $_ -notmatch '&' }) -join ';'
    & $flutterPath @flutterArguments
    $runExitCode = $LASTEXITCODE
} finally {
    $env:Path = $originalPath
    Pop-Location
}
exit $runExitCode
