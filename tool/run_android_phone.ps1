param(
    [string]$DeviceId = ''
)

$ErrorActionPreference = 'Stop'

$adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
if (-not (Test-Path -LiteralPath $adbPath)) {
    throw "Android Debug Bridge was not found at $adbPath."
}

$adbArguments = @()
if ($DeviceId.Trim()) {
    $adbArguments += @('-s', $DeviceId.Trim())
}

& $adbPath @adbArguments reverse tcp:8080 tcp:8080
if ($LASTEXITCODE -ne 0) {
    throw 'Could not forward the phone port 8080 to the Rootly backend.'
}

$flutterArguments = @(
    'run',
    '--dart-define=API_BASE_URL=http://127.0.0.1:8080'
)
if ($DeviceId.Trim()) {
    $flutterArguments += @('-d', $DeviceId.Trim())
}

& flutter @flutterArguments
exit $LASTEXITCODE