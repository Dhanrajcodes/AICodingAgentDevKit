# Tests for install.ps1. Mirrors tests/test_install.sh. ASCII only.
. (Join-Path $PSScriptRoot 'lib.ps1')
$Install = Join-Path $Root 'install.ps1'
$Tpl = Join-Path $Root 'kit\.agentkit\templates'

$Case = 'fresh'
$t = New-Target 'fresh ws'
$r = Invoke-Script $Install @('-Target', $t)
Assert-Eq $r.Code 0 'exit'
foreach ($f in '.agentkit\VERSION', '.agentkit\INDEX.md', 'AGENTS.md', 'CLAUDE.md', 'GEMINI.md',
    '.agentkit.local\overrides.md', '.agentkit.local\budgets.env',
    'docs\agent\STATUS.md', 'docs\agent\LOG.md', 'docs\agent\DECISIONS.md', 'docs\agent\OPEN-QUESTIONS.md',
    'docs\agent\plans\.gitkeep', 'docs\agent\decisions\.gitkeep', 'docs\agent\research\.gitkeep', 'docs\agent\log\.gitkeep') {
    Assert-File (Join-Path $t $f)
}
Assert-Same (Join-Path $t 'AGENTS.md') (Join-Path $Tpl 'AGENTS.md')
Assert-Same (Join-Path $t 'CLAUDE.md') (Join-Path $Tpl 'stub.md')
Assert-Same (Join-Path $t 'docs\agent\STATUS.md') (Join-Path $Tpl 'status.md')
Assert-Contains $r.Out 'created .agentkit/ (v' 'first install'
Assert-Contains $r.Out 'created AGENTS.md' 'agents'
Assert-Contains $r.Out 'created docs/agent/STATUS.md' 'status'

$Case = 'rerun'
Add-Text (Join-Path $t 'docs\agent\STATUS.md') "MINE`n"
Add-Text (Join-Path $t 'AGENTS.md') "PROJECT-NOTE`n"
Write-Text (Join-Path $t '.agentkit\stale.md') "stale`n"
$r = Invoke-Script $Install @('-Target', $t)
Assert-Eq $r.Code 0 'exit'
Assert-FileHas (Join-Path $t 'docs\agent\STATUS.md') 'MINE'
Assert-FileHas (Join-Path $t 'AGENTS.md') 'PROJECT-NOTE'
Assert-NoFile (Join-Path $t '.agentkit\stale.md')
Assert-Contains $r.Out 'updated .agentkit/ (v' 'update'
Assert-Contains $r.Out 'kept docs/agent/STATUS.md' 'status kept'
Assert-Contains $r.Out 'updated kit block in AGENTS.md' 'block'
Assert-Contains $r.Out 'kept CLAUDE.md' 'stub kept'

$Case = 'block-refresh'
$a = Join-Path $t 'AGENTS.md'
Write-Text $a ((Read-Text $a).Replace('Read this first.', 'OLD TEXT'))
$null = Invoke-Script $Install @('-Target', $t)
Assert-FileHas $a 'Read this first.'
Assert-FileLacks $a 'OLD TEXT'
Assert-FileHas $a 'PROJECT-NOTE'
Assert-Eq ([regex]::Matches((Read-Text $a), 'agentkit:start').Count) 1 'one start marker'

$Case = 'update-recreates-stub'
Remove-Item (Join-Path $t 'GEMINI.md')
$r = Invoke-Script $Install @('-Target', $t)
Assert-Eq $r.Code 0 'exit'
Assert-Contains $r.Out 'created GEMINI.md' 'stub recreated on update'
Assert-Same (Join-Path $t 'GEMINI.md') (Join-Path $Tpl 'stub.md')

$Case = 'crlf'
$t = New-Target 'crlf'
$null = Invoke-Script $Install @('-Target', $t)
$a = Join-Path $t 'AGENTS.md'
Write-Text $a (((Read-Text $a).Replace('Read this first.', 'OLD TEXT')).Replace("`n", "`r`n") + "CRLF-NOTE`r`n")
$r = Invoke-Script $Install @('-Target', $t)
Assert-Contains $r.Out 'updated kit block in AGENTS.md' 'crlf block'
Assert-FileHas $a 'Read this first.'
Assert-FileLacks $a 'OLD TEXT'
Assert-FileHas $a 'CRLF-NOTE'

$Case = 'foreign-agentkit'
$t = New-Target 'foreign'
New-Item -ItemType Directory -Path (Join-Path $t '.agentkit') | Out-Null
Write-Text (Join-Path $t '.agentkit\keep.txt') "x`n"
$r = Invoke-Script $Install @('-Target', $t)
Assert-Eq $r.Code 3 'exit'
Assert-File (Join-Path $t '.agentkit\keep.txt')
Assert-NoFile (Join-Path $t 'AGENTS.md')

$Case = 'adopt'
$t = New-Target 'adopt'
Write-Text (Join-Path $t 'AGENTS.md') "# mine`n"
Write-Text (Join-Path $t 'CLAUDE.md') "custom rules`n"
$r = Invoke-Script $Install @('-Target', $t)
Assert-Eq $r.Code 0 'exit'
Assert-Eq (Read-Text (Join-Path $t 'AGENTS.md')) "# mine`n" 'agents untouched'
Assert-Eq (Read-Text (Join-Path $t 'CLAUDE.md')) "custom rules`n" 'claude untouched'
Assert-Contains $r.Out 'adopt AGENTS.md' 'agents adopt'
Assert-Contains $r.Out 'adopt CLAUDE.md' 'claude adopt'
Assert-File (Join-Path $t 'GEMINI.md')

$Case = 'dry-run'
$t = New-Target 'dry'
$r = Invoke-Script $Install @('-DryRun', '-Target', $t)
Assert-Eq $r.Code 0 'exit'
Assert-Eq (@(Get-ChildItem -LiteralPath $t -Force).Count) 0 'dir still empty'
Assert-Contains $r.Out 'would: created AGENTS.md' 'dry agents'

$Case = 'bad-target'
$r = Invoke-Script $Install @('-Target', (Join-Path $TmpRoot 'does-not-exist'))
Assert-Eq $r.Code 2 'exit'
$r = Invoke-Script $Install @()
Assert-Eq $r.Code 2 'no args'

$Case = 'crlf-preserved'
$t = New-Target 'crlf2'
$null = Invoke-Script $Install @('-Target', $t)
$a = Join-Path $t 'AGENTS.md'
Write-Text $a ((Read-Text $a).Replace("`n", "`r`n"))
$lines = ([regex]::Matches((Read-Text $a), "`n")).Count
$null = Invoke-Script $Install @('-Target', $t)
Assert-Eq ([regex]::Matches((Read-Text $a), "`r`n")).Count $lines 'every line keeps CRLF'

$Case = 'agentkit-is-a-file'
$t = New-Target 'filekit'
Write-Text (Join-Path $t '.agentkit') "data`n"
$r = Invoke-Script $Install @('-Target', $t)
Assert-Eq $r.Code 3 'exit'
Assert-Eq (Read-Text (Join-Path $t '.agentkit')) "data`n" 'file untouched'

$Case = 'target-is-kit-payload'
$c = New-Target 'kitcopy'
Copy-Item -LiteralPath $Install -Destination $c
Copy-Item -LiteralPath (Join-Path $Root 'kit') -Destination (Join-Path $c 'kit') -Recurse
$r = Invoke-Script (Join-Path $c 'install.ps1') @('-Target', (Join-Path $c 'kit'))
Assert-Eq $r.Code 3 'exit'
Assert-File (Join-Path $c 'kit\.agentkit\VERSION')

$Case = 'extra-arg'
$t = New-Target 'extra'
$r = Invoke-Script $Install @('-Target', $t, 'surplus')
Assert-Eq $r.Code 2 'unexpected extra argument'

if (-not (Show-Summary 'install.ps1')) { exit 1 }
