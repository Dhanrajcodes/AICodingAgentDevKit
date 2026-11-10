# Runs every PowerShell test suite. Exit 0 only if all pass. ASCII only.
$exe = (Get-Process -Id $PID).Path
$status = 0
foreach ($suite in 'test_install.ps1', 'test_doctor.ps1') {
    $p = Join-Path $PSScriptRoot $suite
    if (-not (Test-Path -LiteralPath $p)) { continue }
    & $exe -NoProfile -ExecutionPolicy Bypass -File $p
    if ($LASTEXITCODE -ne 0) { $status = 1 }
}
$tmp = Join-Path ([IO.Path]::GetTempPath()) 'agentkit-tests-ps'
if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
exit $status
