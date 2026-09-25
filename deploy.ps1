#requires -Version 7.0
<#
.SYNOPSIS
    Быстрый деплой сайта WizardCV на GitHub Pages.

.DESCRIPTION
    Локально собирает проект (заодно срабатывает pre-build валидация content/*.json),
    коммитит изменения, пушит в origin/master и дожидается завершения GitHub Actions,
    после чего печатает статус и ссылку.

.PARAMETER Message
    Сообщение коммита. По умолчанию — "Deploy <дата-время>".

.PARAMETER Watch
    Режим наблюдения: следит за файлами кода и JSON и деплоит при изменениях (Ctrl+C — выход).

.PARAMETER NoWait
    Не дожидаться завершения GitHub Actions.

.PARAMETER SkipBuild
    Пропустить локальную сборку (только commit + push).

.EXAMPLE
    ./deploy.ps1
    ./deploy.ps1 -Message "content: update experience"
    ./deploy.ps1 -Watch
#>
param(
    [string]$Message = "",
    [switch]$Watch,
    [switch]$NoWait,
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

function Write-Step($text) { Write-Host "==> $text" -ForegroundColor Cyan }
function Write-Ok($text)   { Write-Host "    $text" -ForegroundColor Green }
function Write-Warn($text) { Write-Host "    $text" -ForegroundColor Yellow }

function Get-RepoSlug {
    $url = (git remote get-url origin 2>$null)
    if ($url -match 'github\.com[:/](?<slug>[^/]+/[^/]+?)(\.git)?$') { return $Matches['slug'] }
    return $null
}

function Wait-GitHubActions($slug) {
    if ([string]::IsNullOrWhiteSpace($slug)) { return }
    $sha = (git rev-parse HEAD).Trim()
    Write-Step "Ожидаю GitHub Actions для $($sha.Substring(0,7))..."
    for ($i = 0; $i -lt 40; $i++) {
        Start-Sleep -Seconds 15
        try {
            $runs = Invoke-RestMethod -Uri "https://api.github.com/repos/$slug/actions/runs?per_page=5" `
                -Headers @{ 'User-Agent' = 'wizardcv-deploy' } -TimeoutSec 30
            $run = $runs.workflow_runs | Where-Object { $_.head_sha -eq $sha } | Select-Object -First 1
            if ($null -eq $run) { Write-Warn "запуск ещё не появился..."; continue }
            if ($run.status -eq 'completed') {
                if ($run.conclusion -eq 'success') { Write-Ok "GitHub Actions: success" }
                else { Write-Warn "GitHub Actions: $($run.conclusion)" }
                Write-Host "    $($run.html_url)"
                return
            }
            Write-Warn "статус: $($run.status)..."
        }
        catch { Write-Warn "не удалось опросить API, повтор..." }
    }
    Write-Warn "Не дождался завершения. Смотри вручную: https://github.com/$slug/actions"
}

function Invoke-Deploy {
    param([string]$CommitMessage)

    Write-Step "Сборка (Release) + валидация content/*.json"
    if (-not $SkipBuild) {
        dotnet publish WizardCV.csproj -c Release -o publish --nologo | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "Сборка не удалась. Деплой отменён." }
        Write-Ok "Сборка успешна"
    }
    else { Write-Warn "Сборка пропущена (-SkipBuild)" }

    Write-Step "Проверка изменений"
    git add -A
    git diff --cached --quiet
    $hasChanges = ($LASTEXITCODE -ne 0)

    if ($hasChanges) {
        if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
            $CommitMessage = "Deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        }
        git commit -m $CommitMessage | Out-Host
        if ($LASTEXITCODE -ne 0) { throw "git commit не удался." }
        Write-Ok "Коммит: $CommitMessage"
    }
    else {
        Write-Warn "Нет новых изменений — пушу уже существующие коммиты (если есть)"
    }

    Write-Step "Push в origin/master"
    git push origin master
    if ($LASTEXITCODE -ne 0) { throw "git push не удался." }
    Write-Ok "Запушено"

    if (-not $NoWait) { Wait-GitHubActions (Get-RepoSlug) }

    Write-Host ""
    Write-Host "Сайт: https://pharaunwizard.github.io/" -ForegroundColor Cyan
}

if ($Watch) {
    Write-Step "Режим наблюдения. Сохраняешь файл → авто-деплой. Ctrl+C — выход."
    $root = $PSScriptRoot
    $extensions = @('*.json', '*.razor', '*.cs', '*.css', '*.js', '*.html', '*.csproj')
    $watchers = @()
    foreach ($ext in $extensions) {
        foreach ($dir in @($root, (Join-Path $root 'wwwroot'), (Join-Path $root 'wwwroot\content'),
                           (Join-Path $root 'Components'), (Join-Path $root 'Models'),
                           (Join-Path $root 'Services'), (Join-Path $root 'Pages'))) {
            if (Test-Path $dir) {
                $w = New-Object System.IO.FileSystemWatcher $dir, $ext
                $w.IncludeSubdirectories = $false
                $w.NotifyFilter = [System.IO.NotifyFilters]::LastWrite
                $w.EnableRaisingEvents = $true
                $watchers += $w
            }
        }
    }

    $pending = $false
    $lastChange = Get-Date
    foreach ($w in $watchers) {
        Register-ObjectEvent $w Changed -Action { $global:__wizardDirty = $true } | Out-Null
    }
    $global:__wizardDirty = $false

    try {
        while ($true) {
            Start-Sleep -Seconds 2
            if ($global:__wizardDirty) {
                $global:__wizardDirty = $false
                Start-Sleep -Seconds 3   # debounce: дождаться, пока сохранятся все файлы
                Write-Host ""
                Write-Host "----- Изменения обнаружены: $(Get-Date -Format 'HH:mm:ss') -----" -ForegroundColor Magenta
                try { Invoke-Deploy -CommitMessage "" } catch { Write-Warn "$($_.Exception.Message)" }
            }
        }
    }
    finally {
        foreach ($w in $watchers) { $w.Dispose() }
    }
}
else {
    Invoke-Deploy -CommitMessage $Message
}
