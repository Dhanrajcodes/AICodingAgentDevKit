# Tests for .agentkit/doctor.ps1. Mirrors tests/test_doctor.sh. ASCII only.
. (Join-Path $PSScriptRoot 'lib.ps1')
$Install = Join-Path $Root 'install.ps1'

function New-Fresh([string]$Name) {
    $d = New-Target $Name
    $null = Invoke-Script $Install @('-Target', $d)
    return $d
}
function Invoke-Doctor([string]$W) { return Invoke-Script (Join-Path $W '.agentkit\doctor.ps1') @($W) }
function Add-Lines([string]$Path, [int]$N) {
    $sb = New-Object System.Text.StringBuilder
    for ($i = 0; $i -lt $N; $i++) { [void]$sb.Append("line $i`n") }
    Add-Text $Path $sb.ToString()
}
function Set-StatusDate([string]$Path, [string]$Date) {
    Write-Text $Path ([regex]::Replace((Read-Text $Path), '(?m)^Last updated: [^\r\n]*', "Last updated: $Date"))
}

$Labels = 'kit-installed', 'kit-markers', 'stub-claude', 'stub-gemini', 'ring0-size', 'agents-lines',
    'status-lines', 'decisions-lines', 'log-size', 'status-fresh', 'tracker-single-doing', 'no-secrets', 'env-ignored', 'no-hidden-unicode'

$Case = 'clean'
$t = New-Fresh 'clean ws'
$r = Invoke-Doctor $t
Assert-Eq $r.Code 0 'exit'
foreach ($l in $Labels) { Assert-Contains $r.Out "ok   $l" $l }
Assert-Contains $r.Out 'doctor: 0 warning(s)' 'summary'

$Case = 'default-target'
Push-Location $TmpRoot
$r = Invoke-Script (Join-Path $t '.agentkit\doctor.ps1') @()
Pop-Location
Assert-Eq $r.Code 0 'runs against its own workspace from any cwd'

$Case = 'kit-installed'
$t = New-Fresh 'k1'; Remove-Item (Join-Path $t '.agentkit\VERSION'); $r = Invoke-Doctor $t
Assert-Eq $r.Code 1 'exit'; Assert-Contains $r.Out 'warn kit-installed' 'label'

$Case = 'kit-markers'
$t = New-Fresh 'k2'; Write-Text (Join-Path $t 'AGENTS.md') "# mine`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn kit-markers' 'label'

$Case = 'stubs'
$t = New-Fresh 'k3'; Write-Text (Join-Path $t 'CLAUDE.md') "custom`n"; Remove-Item (Join-Path $t 'GEMINI.md'); $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn stub-claude' 'claude'
Assert-Contains $r.Out 'warn stub-gemini' 'gemini'

$Case = 'ring0-size'
$t = New-Fresh 'k4'; Add-Text (Join-Path $t '.agentkit.local\budgets.env') "RING0_MAX_BYTES=100`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn ring0-size' 'label'
Assert-Contains $r.Out 'ok   status-lines' 'others unaffected'

$Case = 'agents-lines'
$t = New-Fresh 'k5'; Add-Lines (Join-Path $t 'AGENTS.md') 200; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn agents-lines' 'label'

$Case = 'status-lines'
$t = New-Fresh 'k6'; Add-Lines (Join-Path $t 'docs\agent\STATUS.md') 50; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn status-lines' 'label'

$Case = 'decisions-lines'
$t = New-Fresh 'k7'; Add-Lines (Join-Path $t 'docs\agent\DECISIONS.md') 90; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn decisions-lines' 'label'

$Case = 'log-size'
$t = New-Fresh 'k8'; Add-Text (Join-Path $t '.agentkit.local\budgets.env') "LOG_MAX_BYTES=10`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn log-size' 'label'

$Case = 'status-fresh'
$t = New-Fresh 'k9'
$s = Join-Path $t 'docs\agent\STATUS.md'
Set-StatusDate $s '2026-01-01'
Add-Text (Join-Path $t 'docs\agent\LOG.md') "`n## 2026-02-01: later work`n- x`n"
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn status-fresh' 'stale'
Set-StatusDate $s '2026-03-01'
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'ok   status-fresh' 'fresh'

$Case = 'crlf-status'
Write-Text $s ((Read-Text $s).Replace("`n", "`r`n"))
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'ok   status-fresh' 'crlf parses'
Set-StatusDate $s '2026-01-01'
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn status-fresh' 'crlf stale'

$Case = 'tracker'
$t = New-Fresh 'k10'
$p = Join-Path $t 'docs\agent\plans\p'
New-Item -ItemType Directory -Path $p -Force | Out-Null
Write-Text (Join-Path $p 'tracker.md') "| ID | Task | Priority | Status | Commit |`n|---|---|---|---|---|`n| T-01 | a | P0 | doing | |`n| T-02 | b | P0 |  doing  | |`n"
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn tracker-single-doing' 'label'
Assert-Contains $r.Out 'plans/p/tracker.md' 'names the file'

$Case = 'secrets'
$t = New-Fresh 'k11'; Add-Text (Join-Path $t 'docs\agent\STATUS.md') "key sk-abcdefghijklmnopqrstuvwx1234`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn no-secrets' 'label'
Assert-Contains $r.Out 'STATUS.md' 'names the file'
if ($r.Out.Contains('sk-abcdefghij')) { Bad 'printed the secret' } else { Ok }

$Case = 'env-ignored'
$t = New-Fresh 'envtest ws'
& git -C $t init -q
Write-Text (Join-Path $t '.env') "SECRET=1`n"
Write-Text (Join-Path $t '.env.example') "X=`n"
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn env-ignored' 'unignored .env'
if ($r.Out.Contains('.env.example')) { Bad 'example files are fine' } else { Ok }
Write-Text (Join-Path $t '.gitignore') ".env`n"
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'ok   env-ignored' 'ignored .env'
New-Item -ItemType Directory -Path (Join-Path $t 'app') | Out-Null
Write-Text (Join-Path $t 'app\.env.local') "K=1`n"
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn env-ignored' 'nested unignored'
Assert-Contains $r.Out 'app/.env.local' 'names nested file'
$t = New-Fresh 'envnogit'
Write-Text (Join-Path $t '.env') "K=1`n"
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'ok   env-ignored' 'not a git repo'

$Case = 'hidden-unicode'
$tag = [char]::ConvertFromUtf32(0xE0041) + [char]::ConvertFromUtf32(0xE0042)
$t = New-Fresh 'hu1'; Add-Text (Join-Path $t 'AGENTS.md') "Normal line`n$tag hidden tag chars`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn no-hidden-unicode' 'tag characters'
Assert-Contains $r.Out 'AGENTS.md' 'names the file'
$t = New-Fresh 'hu2'; Add-Text (Join-Path $t 'docs\agent\STATUS.md') ("abc" + [char]0x202E + "def`n"); $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn no-hidden-unicode' 'bidi override'
$t = New-Fresh 'hu3'; Add-Text (Join-Path $t '.agentkit.local\overrides.md') ("zero" + [char]0x200B + "width`n"); $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn no-hidden-unicode' 'zero-width space'
$t = New-Fresh 'hu4'; Add-Text (Join-Path $t 'docs\agent\STATUS.md') ("Plain UTF-8 is fine: caf" + [char]0xE9 + ", " + [char]0x2192 + "`n"); $r = Invoke-Doctor $t
Assert-Contains $r.Out 'ok   no-hidden-unicode' 'ordinary unicode ok'

$Case = 'budget-comments'
$t = New-Fresh 'b1'; Add-Text (Join-Path $t '.agentkit.local\budgets.env') "AGENTS_MAX_LINES=10      # trailing comment`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn agents-lines' 'budget with trailing comment honoured'

$Case = 'budget-huge'
$t = New-Fresh 'b2'; Add-Text (Join-Path $t '.agentkit.local\budgets.env') "RING0_MAX_BYTES=99999999999999999999`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'ok   ring0-size' 'oversized budget ignored'
Assert-Contains $r.Out 'doctor: 0 warning(s)' 'no crash'

$Case = 'secret-false-positive'
$t = New-Fresh 's1'
Add-Text (Join-Path $t 'docs\agent\LOG.md') "`n## 2026-01-01: plans/2026-11-12-task-tracking-dashboard-redesign/`n"
Set-StatusDate (Join-Path $t 'docs\agent\STATUS.md') '2026-12-31'
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'ok   no-secrets' 'words ending in sk are not keys'

$Case = 'secret-in-agents'
$t = New-Fresh 's2'; Add-Text (Join-Path $t 'AGENTS.md') "token sk-proj-abcdefghijklmnopqrstuvwx1234`n"; $r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn no-secrets' 'AGENTS.md scanned'

$Case = 'duplicate-markers'
$t = New-Fresh 'm1'
$a = Join-Path $t 'AGENTS.md'
$txt = Read-Text $a
$blk = $txt.Substring(0, $txt.IndexOf('<!-- agentkit:end -->') + '<!-- agentkit:end -->'.Length)
Add-Text $a ($blk + "`n")
$r = Invoke-Doctor $t
Assert-Contains $r.Out 'warn kit-markers' 'duplicate block'

if (-not (Show-Summary 'doctor.ps1')) { exit 1 }
