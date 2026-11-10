# AI Coding Agent Dev Kit installer (Windows PowerShell 5.1+ and PowerShell 7).
# Usage: powershell -ExecutionPolicy Bypass -File install.ps1 [-DryRun] -Target <path>
# Installing again is the update: it replaces .agentkit\ and the marked block
# in AGENTS.md, and never touches your own files.
# Copyright (c) 2026 Dhanraj Singh. See LICENSE. ASCII only.
param(
    [string]$Target = '',
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

function Show-Usage {
    [Console]::Error.WriteLine('usage: install.ps1 [-DryRun] -Target <path>')
    [Console]::Error.WriteLine('  -Target  workspace folder to install into (must exist)')
    exit 2
}

if (-not $Target) { Show-Usage }
if (-not (Test-Path -LiteralPath $Target -PathType Container)) {
    [Console]::Error.WriteLine("error: target folder not found: $Target")
    exit 2
}
$Target = (Resolve-Path -LiteralPath $Target).ProviderPath

$Src = Join-Path $PSScriptRoot 'kit'
$Kit = Join-Path $Src '.agentkit'
$Tpl = Join-Path $Kit 'templates'
$Version = ([IO.File]::ReadAllText((Join-Path $Kit 'VERSION'))).Trim()
$StartMark = '<!-- agentkit:start -->'
$EndMark = '<!-- agentkit:end -->'
$Utf8 = New-Object System.Text.UTF8Encoding($false)

function Say([string]$Msg) {
    if ($DryRun) { Write-Output "would: $Msg" } else { Write-Output $Msg }
}

# Splits text into lines without line endings. Returns @{ Lines; Crlf }.
function Split-Lines([string]$Text) {
    $crlf = $Text.Contains("`r`n")
    $norm = $Text.Replace("`r`n", "`n")
    if ($norm.EndsWith("`n")) { $norm = $norm.Substring(0, $norm.Length - 1) }
    return @{ Lines = $norm.Split("`n"); Crlf = $crlf }
}

# Returns @(startIndex, endIndex) when there is exactly one start marker before one end marker, else $null.
function Find-Markers([string[]]$Lines) {
    $s = @(); $e = @()
    for ($i = 0; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i] -ceq $StartMark) { $s += $i }
        if ($Lines[$i] -ceq $EndMark) { $e += $i }
    }
    if ($s.Count -eq 1 -and $e.Count -eq 1 -and $s[0] -lt $e[0]) { return @($s[0], $e[0]) }
    return $null
}

# 1. Guard: never delete a .agentkit folder that isn't ours.
$TKit = Join-Path $Target '.agentkit'
if ((Test-Path -LiteralPath $TKit) -and -not (Test-Path -LiteralPath (Join-Path $TKit 'VERSION'))) {
    [Console]::Error.WriteLine("error: $TKit exists but is not a kit install (no VERSION file).")
    [Console]::Error.WriteLine('Move or rename it, then run the installer again. Nothing was changed.')
    exit 3
}

# 2. Kit core: replace whole.
$action = if (Test-Path -LiteralPath $TKit) { 'updated' } else { 'created' }
if (-not $DryRun) {
    if (Test-Path -LiteralPath $TKit) { Remove-Item -LiteralPath $TKit -Recurse -Force }
    Copy-Item -LiteralPath $Kit -Destination $TKit -Recurse
}
Say "$action .agentkit/ (v$Version)"

# 3. AGENTS.md
$A = Join-Path $Target 'AGENTS.md'
$TplAgents = Join-Path $Tpl 'AGENTS.md'
if (-not (Test-Path -LiteralPath $A)) {
    if (-not $DryRun) { Copy-Item -LiteralPath $TplAgents -Destination $A }
    Say 'created AGENTS.md'
} else {
    $cur = Split-Lines ([IO.File]::ReadAllText($A))
    $m = Find-Markers $cur.Lines
    if ($m) {
        if (-not $DryRun) {
            $tpl = Split-Lines ([IO.File]::ReadAllText($TplAgents))
            $tm = Find-Markers $tpl.Lines
            $block = $tpl.Lines[$tm[0]..$tm[1]]
            $before = if ($m[0] -gt 0) { $cur.Lines[0..($m[0] - 1)] } else { @() }
            $after = if ($m[1] -lt $cur.Lines.Count - 1) { $cur.Lines[($m[1] + 1)..($cur.Lines.Count - 1)] } else { @() }
            $nl = if ($cur.Crlf) { "`r`n" } else { "`n" }
            $out = (@($before) + @($block) + @($after)) -join $nl
            [IO.File]::WriteAllText($A, $out + $nl, $Utf8)
        }
        Say 'updated kit block in AGENTS.md'
    } else {
        Say 'adopt AGENTS.md: no kit markers; see .agentkit/playbooks/adopt.md'
    }
}

# 4. Tool stubs
foreach ($stub in 'CLAUDE.md', 'GEMINI.md') {
    $f = Join-Path $Target $stub
    if (-not (Test-Path -LiteralPath $f)) {
        if (-not $DryRun) { Copy-Item -LiteralPath (Join-Path $Tpl 'stub.md') -Destination $f }
        Say "created $stub"
    } elseif (([IO.File]::ReadAllText($f)).Contains('@AGENTS.md')) {
        Say "kept $stub"
    } else {
        Say "adopt ${stub}: has its own content; see .agentkit/playbooks/adopt.md"
    }
}

# Copies $From to $Rel under the target only if it is missing. Empty $From creates an empty file.
function Seed([string]$From, [string]$Rel) {
    $dest = Join-Path $Target ($Rel.Replace('/', '\'))
    if (Test-Path -LiteralPath $dest) { Say "kept $Rel"; return }
    if (-not $DryRun) {
        $dir = Split-Path -Parent $dest
        if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        if ($From) { Copy-Item -LiteralPath $From -Destination $dest } else { [IO.File]::WriteAllText($dest, '') }
    }
    Say "created $Rel"
}

# 5. User-owned seeds (created once, never overwritten)
foreach ($f in 'README.md', 'overrides.md', 'budgets.env') {
    Seed (Join-Path $Src ".agentkit.local\$f") ".agentkit.local/$f"
}
Seed (Join-Path $Tpl 'status.md') 'docs/agent/STATUS.md'
Seed (Join-Path $Tpl 'log.md') 'docs/agent/LOG.md'
Seed (Join-Path $Tpl 'decisions-index.md') 'docs/agent/DECISIONS.md'
Seed (Join-Path $Tpl 'open-questions.md') 'docs/agent/OPEN-QUESTIONS.md'
foreach ($d in 'decisions', 'plans', 'research', 'log') {
    Seed '' "docs/agent/$d/.gitkeep"
}

Write-Output ''
if ($DryRun) {
    Write-Output 'Dry run: nothing was changed.'
} else {
    Write-Output "Kit v$Version installed in $Target."
    Write-Output 'Next: open the workspace in your AI tool and say "start a session".'
    Write-Output 'Check health any time: powershell -ExecutionPolicy Bypass -File .agentkit\doctor.ps1'
}
exit 0
