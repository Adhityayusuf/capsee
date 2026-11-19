[CmdletBinding()]
param(
    [string]$DeviceId,
    [string]$BaseUrl = 'https://70-153-146-139.sslip.io',
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$driveRoot = [System.IO.Path]::GetPathRoot($projectRoot)
$env:PUB_CACHE = Join-Path $driveRoot 'Pub\Cache'

Write-Host "Project : $projectRoot"
Write-Host "PUB_CACHE: $env:PUB_CACHE"
Write-Host "Backend : $BaseUrl"

Push-Location $projectRoot
try {
    if ($Clean) {
        Write-Host 'Membersihkan hasil build lama...'
        & flutter clean
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    }

    Write-Host 'Mengambil dependencies...'
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $runArguments = @('--dart-define=BASE_URL=' + $BaseUrl)
    if ($DeviceId) {
        $runArguments = @('-d', $DeviceId) + $runArguments
    }

    Write-Host 'Menjalankan aplikasi...'
    & flutter run @runArguments
    exit $LASTEXITCODE
}
finally {
    Pop-Location
}
