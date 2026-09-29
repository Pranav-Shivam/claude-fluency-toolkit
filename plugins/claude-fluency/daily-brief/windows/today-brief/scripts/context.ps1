# Helper for the /today-brief skill (Windows, PowerShell 5.1 or 7+).
#   context.ps1            build the run context and create today's folder
#   context.ps1 check DIR  verify the five files exist and follow the style rules
# Always exits 0 so a hiccup here never aborts the skill.
param(
    [string]$Mode = 'context',
    [string]$Dir = ''
)

$ErrorActionPreference = 'SilentlyContinue'
[Console]::OutputEncoding = New-Object System.Text.UTF8Encoding($false)
$OutputEncoding = [Console]::OutputEncoding

$userHome = if ($env:USERPROFILE) { $env:USERPROFILE } else { $HOME }
$Base = if ($env:TODAY_BRIEF_DIR) { $env:TODAY_BRIEF_DIR } else { Join-Path $userHome 'today-brief' }
$MaxChars = 7000
$Sections = @('01', '02', '03', '04', '05')

function Get-Newest([string]$folder, [string]$n) {
    Get-ChildItem -Path $folder -Filter "$n-*.md" -File | Sort-Object Name | Select-Object -Last 1
}

function Get-Handoff([string]$path, [int]$max) {
    $lines = @(Get-Content -LiteralPath $path -Encoding UTF8)
    $start = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^## Handoff') { $start = $i; break }
    }
    if ($start -ge 0) {
        $end = [Math]::Min($lines.Count - 1, $start + $max - 1)
        $lines[$start..$end]
    }
}

if ($Mode -eq 'check') {
    if (-not $Dir) { $Dir = Join-Path $Base (Get-Date -Format 'yyyy-MM-dd') }
    "Checking: $Dir"
    $problems = $false
    foreach ($n in $Sections) {
        $f = Get-Newest $Dir $n
        if (-not $f) { "MISSING: section $n"; $problems = $true; continue }
        if ($f.Length -lt 500) { "TOO SHORT ($($f.Length) bytes): $($f.Name)"; $problems = $true }
        $first = Get-Content -LiteralPath $f.FullName -TotalCount 1 -Encoding UTF8
        if ($first -ne '---') { "NO FRONTMATTER: $($f.Name)"; $problems = $true }
    }
    $emdash = [string][char]0x2014
    $hits = @(Get-ChildItem -Path $Dir -Filter '*.md' -File | Select-String -SimpleMatch $emdash -Encoding UTF8)
    if ($hits.Count -gt 0) {
        "EM-DASH FOUND (replace with comma, colon or period):"
        $hits | Select-Object -First 20 | ForEach-Object { "$($_.Filename):$($_.LineNumber): $($_.Line)" }
        $problems = $true
    }
    if (-not $problems) { 'OK' }
    exit 0
}

$today = Get-Date -Format 'yyyy-MM-dd'
$stamp = Get-Date -Format 'HHmm'
$outdir = Join-Path $Base $today
New-Item -ItemType Directory -Force -Path $outdir | Out-Null

"- Today: $((Get-Date).DayOfWeek), $today, local time $(Get-Date -Format 'HH:mm') (UTC$(Get-Date -Format 'zzz'))"
"- Timestamp for file names: $stamp"
"- Output folder (already created): $outdir"

# Earlier run today?
$todayFiles = @(Get-ChildItem -Path $outdir -Filter '*.md' -File | Sort-Object Name)
if ($todayFiles.Count -gt 0) {
    "- A run already happened today. Existing files (do not repeat their topics):"
    $todayFiles | ForEach-Object { "    $($_.FullName)" }
    $l5 = Get-Newest $outdir '05'
    if ($l5) {
        ''
        '### Earlier run today: handoff'
        Get-Handoff $l5.FullName 40
    }
}

# Previous runs (folders before today)
$prevDirs = @(Get-ChildItem -Path $Base -Directory |
    Where-Object { $_.Name -match '^\d{4}-\d{2}-\d{2}$' -and [string]::CompareOrdinal($_.Name, $today) -lt 0 } |
    Sort-Object Name | Select-Object -Last 7)

if ($prevDirs.Count -eq 0) {
    '- Previous run: none found. This is the first run.'
    exit 0
}

$prev = $prevDirs[$prevDirs.Count - 1]
$inv = [Globalization.CultureInfo]::InvariantCulture
$gap = '?'
try {
    $d1 = [datetime]::ParseExact($today, 'yyyy-MM-dd', $inv)
    $d0 = [datetime]::ParseExact($prev.Name, 'yyyy-MM-dd', $inv)
    $gap = [int]($d1 - $d0).TotalDays
} catch { }
"- Previous run: $($prev.Name) ($gap day(s) ago)"

''
"## Previous run files ($($prev.Name)), newest set only"
foreach ($n in $Sections) {
    $f = Get-Newest $prev.FullName $n
    if (-not $f) { continue }
    ''
    "### $($f.Name)"
    $t = Get-Content -LiteralPath $f.FullName -Raw -Encoding UTF8
    if ($t.Length -gt $MaxChars) { $t.Substring(0, $MaxChars); '[truncated]' } else { $t.TrimEnd() }
}

$older = @($prevDirs | Where-Object { $_.Name -ne $prev.Name })
if ($older.Count -gt 0) {
    ''
    '## Handoff blocks from earlier days (topics already covered, avoid repeating)'
    foreach ($d in $older) {
        $f = Get-Newest $d.FullName '05'
        if (-not $f) { continue }
        ''
        "### $($d.Name)"
        Get-Handoff $f.FullName 30
    }
}
exit 0
