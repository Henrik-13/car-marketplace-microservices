param(
    [ValidateSet('user-service', 'listing-service', 'prediction-service', 'cache-service', 'all')]
    [string]$Service = 'all',

    [string]$Tag = 'latest',
    [string]$Registry = 'ghcr.io/henrik-13',
    [string]$Namespace = 'car-marketplace',

    [switch]$SkipBuild,
    [switch]$SkipPush,
    [switch]$SkipDeploy,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot

$serviceConfig = @{
    'user-service' = @{
        Context = Join-Path $repoRoot 'services/user-service'
        Deployment = 'user-service'
        Container = 'user-service'
    }
    'listing-service' = @{
        Context = Join-Path $repoRoot 'services/listing-service'
        Deployment = 'listing-service'
        Container = 'listing-service'
    }
    'prediction-service' = @{
        Context = Join-Path $repoRoot 'services/prediction-service'
        Deployment = 'prediction-service'
        Container = 'prediction-service'
    }
    'cache-service' = @{
        Context = Join-Path $repoRoot 'services/cache-service'
        Deployment = 'cache-service'
        Container = 'cache-service'
    }
}

function Invoke-Step {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [switch]$DryRun
    )

    if ($DryRun) {
        Write-Host "[DRY-RUN] $Command" -ForegroundColor Yellow
        return
    }

    Write-Host "> $Command" -ForegroundColor Cyan
    Invoke-Expression $Command

    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $Command"
    }
}

if ($Service -eq 'all') {
    $targets = @('user-service', 'listing-service', 'prediction-service', 'cache-service')
}
else {
    $targets = @($Service)
}

Write-Host "Starting deployment pipeline" -ForegroundColor Green
Write-Host "Services: $($targets -join ', ')"
Write-Host "Tag: $Tag"
Write-Host "Registry: $Registry"
Write-Host "Namespace: $Namespace"

if ($Tag -eq 'latest') {
    Write-Warning "Using 'latest' can make rollbacks/debugging harder. Prefer unique tags (for example: git SHA or timestamp)."
}

foreach ($svc in $targets) {
    $cfg = $serviceConfig[$svc]

    if (-not (Test-Path $cfg.Context)) {
        throw "Service context not found: $($cfg.Context)"
    }

    $image = "$Registry/$svc`:$Tag"

    Write-Host "`n=== $svc ===" -ForegroundColor Magenta

    if (-not $SkipBuild) {
        Invoke-Step -Command "docker build -t $image `"$($cfg.Context)`"" -DryRun:$DryRun
    }

    if (-not $SkipPush) {
        Invoke-Step -Command "docker push $image" -DryRun:$DryRun
    }

    if (-not $SkipDeploy) {
        Invoke-Step -Command "kubectl set image deployment/$($cfg.Deployment) $($cfg.Container)=$image -n $Namespace" -DryRun:$DryRun
        Invoke-Step -Command "kubectl rollout restart deployment/$($cfg.Deployment) -n $Namespace" -DryRun:$DryRun
        Invoke-Step -Command "kubectl rollout status deployment/$($cfg.Deployment) -n $Namespace --timeout=300s" -DryRun:$DryRun
        Invoke-Step -Command "kubectl get pods -n $Namespace -l app.kubernetes.io/name=$svc" -DryRun:$DryRun
    }
}

Write-Host "`nDone." -ForegroundColor Green
