# AI Coding Agent Dev Kit doctor: checks memory sizes, stale status, stubs and secrets.
# Usage: powershell -ExecutionPolicy Bypass -File .agentkit\doctor.ps1 [WORKSPACE]
# Default workspace: the folder that holds .agentkit\. Exit 0 when clean, 1 with warnings.
# Budgets: .agentkit.local\budgets.env. Same checks and labels as doctor.sh.
# Copyright (c) 2026 Dhanraj Singh. See LICENSE. ASCII only.
param([string]$Workspace = '')
$ErrorActionPreference = 'Stop'

if (-not $Workspace) { $Workspace = Split-Path -Parent $PSScriptRoot }
if (-not (Test-Path -LiteralPath $Workspace -PathType Container)) {
    [Console]::Error.WriteLine("error: workspace not found: $Workspace")
    exit 2
}
$W = (Resolve-Path -LiteralPath $Workspace).ProviderPath
$M = Join-Path $W 'docs\agent'

$Budget = [ordered]@{
    RING0_MAX_BYTES = 8192; AGENTS_MAX_LINES = 120; STATUS_MAX_LINES = 40
    DECISIONS_MAX_LINES = 80; LOG_MAX_BYTES = 24576
}
$B = Join-Path $W '.agentkit.local\budgets.env'
if (Test-Path -LiteralPath $B) {
    foreach ($line in [IO.File]::ReadAllLines($B)) {
        $bm = [regex]::Match($line, '^\s*([A-Z0-9_]+)=([0-9]{1,18})\s*(#.*)?$')
        if ($bm.Success -and $Budget.Contains($bm.Groups[1].Value)) { $Budget[$bm.Groups[1].Value] = [int64]$bm.Groups[2].Value }
    }
}

$script:Warn = 0
function Ok([string]$Label) { Write-Output "ok   $Label" }
function Warn([string]$Label, [string]$Detail) { Write-Output "warn ${Label}: $Detail"; $script:Warn++ }
function Get-Bytes([string]$Path) { if (Test-Path -LiteralPath $Path -PathType Leaf) { return (Get-Item -LiteralPath $Path).Length } else { return 0 } }
function Get-Text([string]$Path) { if (Test-Path -LiteralPath $Path -PathType Leaf) { return [IO.File]::ReadAllText($Path) } else { return '' } }
function Get-LineCount([string]$Path) {
    $t = Get-Text $Path
    if ($t.Length -eq 0) { return 0 }
    return ([regex]::Matches($t, "`n")).Count
}
function Get-Rel([string]$Path) { return $Path.Substring($W.Length).TrimStart('\', '/').Replace('\', '/') }

# kit-installed
if (Test-Path -LiteralPath (Join-Path $W '.agentkit\VERSION')) { Ok 'kit-installed' }
else { Warn 'kit-installed' '.agentkit/VERSION missing; reinstall the kit' }

# kit-markers
$A = Join-Path $W 'AGENTS.md'
$at = Get-Text $A
# Same rule as the installer: exactly one start marker before exactly one end marker.
$sMarks = [regex]::Matches($at, '(?m)^<!-- agentkit:start -->\r?$')
$eMarks = [regex]::Matches($at, '(?m)^<!-- agentkit:end -->\r?$')
if ($sMarks.Count -eq 1 -and $eMarks.Count -eq 1 -and $sMarks[0].Index -lt $eMarks[0].Index) { Ok 'kit-markers' }
else { Warn 'kit-markers' "AGENTS.md missing, or its kit markers are missing or duplicated, so updates can't refresh it; see .agentkit/playbooks/adopt.md" }

# stubs
foreach ($pair in @(@('stub-claude', 'CLAUDE.md'), @('stub-gemini', 'GEMINI.md'))) {
    if ((Get-Text (Join-Path $W $pair[1])).Contains('@AGENTS.md')) { Ok $pair[0] }
    else { Warn $pair[0] "$($pair[1]) missing or doesn't import @AGENTS.md" }
}

# ring0-size
$r0 = (Get-Bytes $A) + (Get-Bytes (Join-Path $M 'STATUS.md')) + (Get-Bytes (Join-Path $M 'DECISIONS.md'))
if ($r0 -le $Budget.RING0_MAX_BYTES) { Ok 'ring0-size' }
else { Warn 'ring0-size' "AGENTS.md + STATUS.md + DECISIONS.md = $r0 bytes (budget $($Budget.RING0_MAX_BYTES)); run .agentkit/playbooks/compact.md" }

# line budgets
foreach ($c in @(@('agents-lines', $A, $Budget.AGENTS_MAX_LINES),
                 @('status-lines', (Join-Path $M 'STATUS.md'), $Budget.STATUS_MAX_LINES),
                 @('decisions-lines', (Join-Path $M 'DECISIONS.md'), $Budget.DECISIONS_MAX_LINES))) {
    $n = Get-LineCount $c[1]
    if ($n -le $c[2]) { Ok $c[0] }
    else { Warn $c[0] "$(Get-Rel $c[1]) has $n lines (budget $($c[2])); run .agentkit/playbooks/compact.md" }
}

# log-size
$L = Join-Path $M 'LOG.md'
$lb = Get-Bytes $L
if ($lb -le $Budget.LOG_MAX_BYTES) { Ok 'log-size' }
else { Warn 'log-size' "LOG.md is $lb bytes (budget $($Budget.LOG_MAX_BYTES)); rotate old months with .agentkit/playbooks/compact.md" }

# status-fresh: newest LOG entry date must not be after STATUS "Last updated"
$sm = [regex]::Match((Get-Text (Join-Path $M 'STATUS.md')), '(?m)^Last updated: (\d{4}-\d{2}-\d{2})')
$sd = if ($sm.Success) { $sm.Groups[1].Value } else { '' }
$ld = ''
foreach ($x in [regex]::Matches((Get-Text $L), '(?m)^## (\d{4}-\d{2}-\d{2})')) {
    if ([string]::CompareOrdinal($x.Groups[1].Value, $ld) -gt 0) { $ld = $x.Groups[1].Value }
}
if (-not $ld) { Ok 'status-fresh' }
elseif (-not $sd) { Warn 'status-fresh' "STATUS.md has no 'Last updated: YYYY-MM-DD' line but LOG.md has entries; run .agentkit/playbooks/handoff.md" }
elseif ([string]::CompareOrdinal($ld, $sd) -gt 0) { Warn 'status-fresh' "STATUS.md last updated $sd, but LOG.md has an entry from $ld; run .agentkit/playbooks/handoff.md" }
else { Ok 'status-fresh' }

# tracker-single-doing
$multi = ''
$plans = Join-Path $M 'plans'
if (Test-Path -LiteralPath $plans) {
    foreach ($dir in Get-ChildItem -LiteralPath $plans -Directory) {
        $f = Join-Path $dir.FullName 'tracker.md'
        if (-not (Test-Path -LiteralPath $f)) { continue }
        $n = ([regex]::Matches((Get-Text $f), '(?m)^.*\|\s*doing\s*\|')).Count
        if ($n -gt 1) { $multi += " $(Get-Rel $f)($n)" }
    }
}
if (-not $multi) { Ok 'tracker-single-doing' }
else { Warn 'tracker-single-doing' "more than one 'doing' task in:$multi" }

# no-secrets (file names only, never the match)
# Key prefixes need a left boundary so words like "task-tracking-..." don't match.
$Pat = '(?m)(^|[^A-Za-z0-9_-])(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{30,}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,})|-----BEGIN [A-Z ]*PRIVATE KEY-----'
$hits = ''
foreach ($d in @((Join-Path $W 'AGENTS.md'), (Join-Path $W 'CLAUDE.md'), (Join-Path $W 'GEMINI.md'), $M, (Join-Path $W '.agentkit.local'))) {
    if (-not (Test-Path -LiteralPath $d)) { continue }
    foreach ($f in @(Get-ChildItem -LiteralPath $d -Recurse -File -Force)) {
        if ([regex]::IsMatch((Get-Text $f.FullName), $Pat)) { $hits += " $(Get-Rel $f.FullName)" }
    }
}
if (-not $hits) { Ok 'no-secrets' }
else { Warn 'no-secrets' "possible secret in:$hits (remove it and rotate the key)" }

# env-ignored: .env files inside a git repo must be git-ignored (templates like .env.example are fine)
$unignored = ''
if (Get-Command git -ErrorAction SilentlyContinue) {
    $skipDirs = @('node_modules', '.git', '.venv')
    $templates = @('.env.example', '.env.sample', '.env.template', '.env.dist')
    $queue = New-Object System.Collections.Queue
    $queue.Enqueue(@($W, 0))
    while ($queue.Count -gt 0) {
        $item = $queue.Dequeue(); $dir = $item[0]; $depth = $item[1]
        foreach ($e in Get-ChildItem -LiteralPath $dir -Force -ErrorAction SilentlyContinue) {
            if ($e.PSIsContainer) {
                if ($depth -lt 2 -and $skipDirs -notcontains $e.Name) { $queue.Enqueue(@($e.FullName, ($depth + 1))) }
            } elseif ($e.Name -like '.env*' -and $templates -notcontains $e.Name) {
                $ErrorActionPreference = 'Continue'
                $null = & git -C $e.DirectoryName rev-parse --is-inside-work-tree 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $null = & git -C $e.DirectoryName check-ignore -q $e.FullName 2>$null
                    if ($LASTEXITCODE -ne 0) { $unignored += " $(Get-Rel $e.FullName)" }
                }
                $ErrorActionPreference = 'Stop'
            }
        }
    }
}
if (-not $unignored) { Ok 'env-ignored' }
else { Warn 'env-ignored' "not git-ignored, could be committed:$unignored (add to .gitignore)" }

# no-hidden-unicode: invisible characters that can hide instructions in agent files
# (Unicode tag characters, zero-width characters, bidirectional controls).
$UPat = '\uDB40[\uDC00-\uDC7F]|[\u200B-\u200F\u2060\u202A-\u202E\u2066-\u2069]'
$hitsU = ''
$scan = @()
foreach ($n in 'AGENTS.md', 'CLAUDE.md', 'GEMINI.md') { $p = Join-Path $W $n; if (Test-Path -LiteralPath $p -PathType Leaf) { $scan += $p } }
foreach ($d in @((Join-Path $W '.agentkit.local'), $M)) {
    if (Test-Path -LiteralPath $d) { $scan += @(Get-ChildItem -LiteralPath $d -Recurse -File -Force | ForEach-Object { $_.FullName }) }
}
foreach ($f in $scan) {
    if ([regex]::IsMatch([IO.File]::ReadAllText($f, [Text.Encoding]::UTF8), $UPat)) { $hitsU += " $(Get-Rel $f)" }
}
if (-not $hitsU) { Ok 'no-hidden-unicode' }
else { Warn 'no-hidden-unicode' "invisible or bidi characters in:$hitsU (could hide instructions; inspect and remove)" }

Write-Output "doctor: $($script:Warn) warning(s)"
if ($script:Warn -gt 0) { exit 1 } else { exit 0 }
