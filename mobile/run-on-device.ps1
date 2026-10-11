param(
    [string]$ApiHost
)

$ErrorActionPreference = 'Stop'

if (-not $ApiHost) {
    $route = Get-NetRoute -DestinationPrefix '0.0.0.0/0' |
        Sort-Object RouteMetric |
        Select-Object -First 1

    if (-not $route) {
        throw 'No active network route found. Connect this computer to Wi-Fi or pass -ApiHost with its LAN IP.'
    }

    $address = Get-NetIPAddress -InterfaceIndex $route.InterfaceIndex -AddressFamily IPv4 |
        Where-Object { $_.IPAddress -notlike '169.254.*' } |
        Select-Object -First 1

    if (-not $address) {
        throw 'Could not find a LAN IPv4 address. Pass -ApiHost with this computer''s IP address.'
    }

    $ApiHost = $address.IPAddress
}

$apiUrl = "http://${ApiHost}:8000/api"
Write-Host "Using Dhahabu API at $apiUrl"
Write-Host 'Keep the phone and computer on the same Wi-Fi network.'

flutter run "--dart-define=API_BASE_URL=$apiUrl" @args
