$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty IPAddress)
if (-not $ip) {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '192.168.*' -or $_.IPAddress -like '10.*' } | Select-Object -First 1 -ExpandProperty IPAddress)
}
if (-not $ip) { $ip = '127.0.0.1' }

$target = Join-Path $PSScriptRoot '..\lib\core\constants\host_ip.dart'
$content = "const String hostIp = '$ip';"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText((Resolve-Path $target).Path, "$content`n", $utf8NoBom)
Write-Host "Updated host_ip.dart with IP: $ip"

$adbPath = Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe'
if (Test-Path -LiteralPath $adbPath) {
    try {
        & $adbPath reverse tcp:8080 tcp:8080 2>$null
        Write-Host "Configured adb reverse tcp:8080 tcp:8080 for connected Android device."
    } catch {}
}
