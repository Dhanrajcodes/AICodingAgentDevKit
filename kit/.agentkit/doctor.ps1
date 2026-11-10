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
        $bm = [regex]::Match($line, '^\s*([A-Z0-9_]+)=([0-9]+)\s*$')
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
if ($at -match '(?m)^<!-- agentkit:start -->\r?$' -and $at -match '(?m)^<!-- agentkit:end -->\r?$') { Ok 'kit-markers' }
else { Warn 'kit-markers' 'AGENTS.md missing or has no kit block; see .agentkit/playbooks/adopt.md' }

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
$Pat = 'sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|ghp_[A-Za-z0-9]{36}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-[A-Za-z0-9-]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY-----'
$hits = ''
foreach ($d in @($M, (Join-Path $W '.agentkit.local'))) {
    if (-not (Test-Path -LiteralPath $d)) { continue }
    foreach ($f in Get-ChildItem -LiteralPath $d -Recurse -File -Force) {
        if ([regex]::IsMatch((Get-Text $f.FullName), $Pat)) { $hits += " $(Get-Rel $f.FullName)" }
    }
}
if (-not $hits) { Ok 'no-secrets' }
else { Warn 'no-secrets' "possible secret in:$hits (remove it and rotate the key)" }

Write-Output "doctor: $($script:Warn) warning(s)"
if ($script:Warn -gt 0) { exit 1 } else { exit 0 }
