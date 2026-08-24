# Checks one Azure DevOps repo for new active PRs, notifies, and offers /pr-review.
# Invoked by Task Scheduler with the path to a config file written by /pr-watch-setup.
# Config is simple KEY=VALUE lines (no shell metacharacters expected/executed).
param(
  [Parameter(Mandatory = $true)][string]$ConfigFile
)

if (-not (Test-Path $ConfigFile)) {
  Write-Error "[pr-watch] config file not found: $ConfigFile"
  exit 1
}

$config = @{}
Get-Content $ConfigFile | ForEach-Object {
  if ($_ -match '^\s*([A-Z_]+)=(.*)$') {
    $config[$matches[1]] = $matches[2].Trim('"')
  }
}

foreach ($key in @('ORG', 'PROJECT', 'REPOSITORY', 'STATE_FILE', 'REPO_ROOT')) {
  if (-not $config.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($config[$key])) {
    Write-Error "[pr-watch] $key missing in config"
    exit 1
  }
}

if ($config.ContainsKey('PAT') -and $config['PAT']) {
  $env:AZURE_DEVOPS_EXT_PAT = $config['PAT']
}

New-Item -ItemType Directory -Force -Path (Split-Path $config['STATE_FILE']) | Out-Null
if (-not (Test-Path $config['STATE_FILE'])) { New-Item -ItemType File -Path $config['STATE_FILE'] | Out-Null }

$prJson = az repos pr list `
  --org $config['ORG'] --project $config['PROJECT'] --repository $config['REPOSITORY'] `
  --status active `
  --query "[].{id:pullRequestId,title:title}" `
  -o json 2>$null
if (-not $prJson) { $prJson = "[]" }
$prs = $prJson | ConvertFrom-Json
if ($prs.Count -eq 0) { exit 0 }

$seen = @(Get-Content $config['STATE_FILE'] -ErrorAction SilentlyContinue)
$newPrs = $prs | Where-Object { $seen -notcontains [string]$_.id }
if ($newPrs.Count -eq 0) { exit 0 }

($prs | ForEach-Object { $_.id }) | Set-Content $config['STATE_FILE']

$lines = ""
foreach ($pr in $newPrs) {
  $url = "$($config['ORG'].TrimEnd('/'))/$($config['PROJECT'])/_git/$($config['REPOSITORY'])/pullrequest/$($pr.id)"
  $lines += "PR #$($pr.id): $($pr.title)`n  $url`n"
}

Write-Output "[pr-watch] $($newPrs.Count) new PR(s) on $($config['REPOSITORY'])"

$prompt = "$($newPrs.Count) new PR(s) opened on $($config['REPOSITORY']) (org $($config['ORG']), project $($config['PROJECT'])):`n`n$lines" +
  "Ask me which PR number(s) to review, or all, or skip. For each I approve, run /pr-review <pr_url> <PAT>, reading PAT from the PAT= line in $ConfigFile -- never print the PAT."

$claudeBin = (Get-Command claude -ErrorAction SilentlyContinue).Source
if (-not $claudeBin) { $claudeBin = "claude" }

$escapedPrompt = $prompt -replace '"', '\"'
$launcherCmd = "cd '$($config['REPO_ROOT'])'; & '$claudeBin' `"$escapedPrompt`""
Start-Process powershell -ArgumentList "-NoExit", "-Command", $launcherCmd
