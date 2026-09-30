$ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty IPAddress)
if (-not $ip) {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like '192.168.*' -or $_.IPAddress -like '10.*' } | Select-Object -First 1 -ExpandProperty IPAddress)
}
if (-not $ip) { $ip = '127.0.0.1' }

$content = "const String hostIp = '$ip';"
Set-Content -Path 'lib\core\constants\host_ip.dart' -Value $content
Write-Host "Updated host_ip.dart with IP: $ip"
