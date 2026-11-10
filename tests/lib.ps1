# Shared helpers for the PowerShell test suites. Dot-sourced. ASCII only.
$ErrorActionPreference = 'Stop'
$script:Root = Split-Path -Parent $PSScriptRoot
$script:TmpRoot = Join-Path $script:Root 'tests\.tmp-ps'
$script:PsExe = (Get-Process -Id $PID).Path
$script:Pass = 0
$script:Fail = 0
$script:Case = ''

function New-Target([string]$Name) {
    $d = Join-Path $script:TmpRoot $Name
    if (Test-Path -LiteralPath $d) { Remove-Item -LiteralPath $d -Recurse -Force }
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    return $d
}

function Invoke-Script([string]$Path, [string[]]$ScriptArgs) {
    $all = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $Path) + $ScriptArgs
    $ErrorActionPreference = 'Continue'
    $out = & $script:PsExe @all 2>&1 | ForEach-Object { "$_" } | Out-String
    return @{ Out = $out; Code = $LASTEXITCODE }
}

function Ok { $script:Pass++ }
function Bad([string]$Msg) { $script:Fail++; Write-Host ("  FAIL [{0}] {1}" -f $script:Case, $Msg) }

function Assert-Eq($Actual, $Expected, [string]$What) {
    if ("$Actual" -eq "$Expected") { Ok } else { Bad "expected '$Expected', got '$Actual' ($What)" }
}
function Assert-File([string]$Path) { if (Test-Path -LiteralPath $Path -PathType Leaf) { Ok } else { Bad "missing file $Path" } }
function Assert-NoFile([string]$Path) { if (-not (Test-Path -LiteralPath $Path)) { Ok } else { Bad "should not exist: $Path" } }
function Assert-Contains([string]$Text, [string]$Needle, [string]$What) {
    if ($Text.Contains($Needle)) { Ok } else { Bad "output lacks '$Needle' ($What)" }
}
function Read-Text([string]$Path) { return [IO.File]::ReadAllText($Path) }
function Assert-FileHas([string]$Path, [string]$Needle) { if ((Read-Text $Path).Contains($Needle)) { Ok } else { Bad "$Path lacks '$Needle'" } }
function Assert-FileLacks([string]$Path, [string]$Needle) { if ((Read-Text $Path).Contains($Needle)) { Bad "$Path has '$Needle'" } else { Ok } }
function Assert-Same([string]$A, [string]$B) {
    if (-not (Test-Path -LiteralPath $A) -or -not (Test-Path -LiteralPath $B)) { Bad "missing $A or $B"; return }
    $x = [IO.File]::ReadAllBytes($A); $y = [IO.File]::ReadAllBytes($B)
    if ($x.Length -eq $y.Length -and -not (Compare-Object $x $y -SyncWindow 0)) { Ok } else { Bad "$A differs from $B" }
}
function Write-Text([string]$Path, [string]$Text) { [IO.File]::WriteAllText($Path, $Text) }
function Add-Text([string]$Path, [string]$Text) { [IO.File]::AppendAllText($Path, $Text) }

function Show-Summary([string]$Suite) {
    Write-Host ("{0}: {1} passed, {2} failed" -f $Suite, $script:Pass, $script:Fail)
    return ($script:Fail -eq 0)
}
