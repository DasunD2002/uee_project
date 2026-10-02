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

# 1. Device Resolution: check physical USB phone, then running emulator, or launch Pixel_7
if (-not $DeviceId.Trim()) {
    $rawDevices = & $adbPath devices
    $onlineDevices = $rawDevices | Where-Object { $_ -match '^([^\s]+)\s+device$' } | ForEach-Object { $matches[1] }
    
    if ($onlineDevices) {
        $DeviceId = ($onlineDevices | Select-Object -First 1).Trim()
    } else {
        Write-Host "No active Android device found. Launching Pixel_7 emulator..."
        flutter emulators --launch Pixel_7
        Write-Host "Waiting for Android emulator to boot..."
        & $adbPath wait-for-device
        Start-Sleep -Seconds 5
        $rawDevices = & $adbPath devices
        $onlineDevices = $rawDevices | Where-Object { $_ -match '^([^\s]+)\s+device$' } | ForEach-Object { $matches[1] }
        if ($onlineDevices) {
            $DeviceId = ($onlineDevices | Select-Object -First 1).Trim()
        } else {
            $DeviceId = 'emulator-5554'
        }
    }
}

$adbArguments = @('-s', $DeviceId.Trim())
$deviceState = & $adbPath @adbArguments get-state
if ($LASTEXITCODE -ne 0 -or -not $deviceState -or $deviceState.Trim() -ne 'device') {
    throw "Device $DeviceId is unavailable. Ensure it is authorized and online."
}

# 2. Detect Backend Port (8080 for Rootly, or fallback to 8081)
$backendPort = 8080
$backendResponding = $false
foreach ($port in @(8080, 8081)) {
    try {
        $res = Invoke-WebRequest -Uri "http://127.0.0.1:$port/api/v1/explore/categories" -TimeoutSec 3 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($res -and $res.StatusCode -lt 500) {
            $backendPort = $port
            $backendResponding = $true
            break
        }
    } catch {
        # Try next port
    }
}

if (-not $backendResponding) {
    Write-Host "Notice: Rootly backend did not respond to /explore/categories on 8081 or 8080. Using port $backendPort."
}

# 3. Reverse Port Forwarding
& $adbPath @adbArguments reverse "tcp:$backendPort" "tcp:$backendPort"
if ($backendPort -ne 8080) {
    & $adbPath @adbArguments reverse tcp:8080 "tcp:$backendPort"
}

Write-Host "Device $DeviceId is connected to Rootly at port $backendPort."
if ($PrepareOnly) {
    return
}

# 4. Resolve Flutter SDK
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

$isEmulator = $DeviceId.Trim() -match 'emulator'
$hostIp = if ($isEmulator) { '10.0.2.2' } else { '127.0.0.1' }

$flutterArguments = @(
    'run',
    '--debug',
    '-d', $DeviceId.Trim(),
    "--dart-define=API_BASE_URL=http://${hostIp}:$backendPort"
)

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
