# Build and deploy this checkout to the existing Docker Desktop Compose project.
# Existing .env credentials and the weknora data volumes are retained.
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
$variableNames = @('LOCAL_IMAGE_TAG', 'LOCAL_VERSION', 'LOCAL_COMMIT', 'LOCAL_BUILD_TIME')
$previousValues = @{}
foreach ($name in $variableNames) {
    $previousValues[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}
try {
    if (-not (Test-Path -LiteralPath '.env')) {
        throw 'Create .env from .env.example and configure your credentials first.'
    }
    $commit = git rev-parse --short HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Could not read the current Git commit.' }
    $env:LOCAL_COMMIT = $commit.Trim()
    $env:LOCAL_IMAGE_TAG = $env:LOCAL_COMMIT
    $env:LOCAL_VERSION = (Get-Content -LiteralPath VERSION -Raw).Trim()
    $env:LOCAL_BUILD_TIME = [DateTime]::UtcNow.ToString('yyyy-MM-ddTHH:mm:ssZ')
    $composeArgs = @('compose', '-p', 'weknora', '-f', 'docker-compose.yml', '-f', 'docker-compose.local.yml')
    docker @composeArgs config --quiet
    if ($LASTEXITCODE -ne 0) { throw 'Compose configuration is invalid.' }
    # Build one service at a time to limit Docker Desktop memory/CPU contention.
    # Completed images remain cached if a later service fails to build.
    foreach ($service in @('frontend', 'docreader', 'app')) {
        docker @composeArgs build $service
        if ($LASTEXITCODE -ne 0) { throw "Image build failed for ${service}; running containers have not been replaced." }
    }
    docker @composeArgs up -d --no-build --wait --wait-timeout 180 app frontend docreader postgres redis
    if ($LASTEXITCODE -ne 0) { throw 'Deployment failed; inspect docker compose logs.' }
    docker @composeArgs ps
    if ($LASTEXITCODE -ne 0) { throw 'Could not read deployment status.' }
}
finally {
    foreach ($name in $variableNames) {
        [Environment]::SetEnvironmentVariable($name, $previousValues[$name], 'Process')
    }
    Pop-Location
}
