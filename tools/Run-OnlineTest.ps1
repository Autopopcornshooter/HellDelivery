param([switch]$Source, [switch]$Visual, [string]$RunTag = 'NetworkFinal')
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$out = Join-Path $workspace ('validation/villa-30/' + $RunTag)
New-Item -ItemType Directory -Force -Path $out | Out-Null
$engine = Join-Path $workspace 'builds/HellDelivery-Windows-Test-30/HellDelivery.exe'
if ($Source) { $engine = Join-Path $workspace 'Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' }
$processes = @()
try {
    foreach ($role in @('host','client')) {
        $arguments = @('--log-file', (Join-Path $out ($role + '.log')))
        if ($Source) { $arguments += @('--path',(Join-Path $workspace 'hell-delivery')) }
        if (-not $Visual) { $arguments += '--headless' }
        $arguments += @('--',('network-test-' + $role),('network-output=' + $out))
        if ($Visual) { $arguments += 'network-visual' }
        $quoted = $arguments | ForEach-Object { '"' + $_ + '"' }
        $processes += Start-Process -FilePath $engine -ArgumentList $quoted -WindowStyle Hidden -PassThru
        Start-Sleep -Milliseconds 800
    }
    $deadline = (Get-Date).AddSeconds(250)
    while (@($processes | Where-Object { -not $_.HasExited }).Count -gt 0) {
        if ((Get-Date) -gt $deadline) { throw 'Online test timed out' }
        foreach ($role in @('host','client')) {
			$partial = Join-Path $out ('network-' + $role + '.report.txt')
			if ((Test-Path -LiteralPath $partial) -and (Get-Content -LiteralPath $partial -Tail 1) -match '^EXIT [1-9]') { throw "Online test reported failure: $role" }
            $log = Join-Path $out ($role + '.log')
            if ((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet)) {
                Get-Content -LiteralPath $log -Tail 20
                throw "Online test logged error: $role"
            }
        }
        Start-Sleep -Milliseconds 500
    }
    foreach ($role in @('host','client')) {
		if (Select-String -LiteralPath (Join-Path $out ($role + '.log')) -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet) { throw "Final online log contains errors: $role" }
        $report = Join-Path $out ('network-' + $role + '.report.txt')
        $last = Get-Content -LiteralPath $report -Tail 1
        if ($last -notmatch '^EXIT 0 checks=[0-9]+ failures=0$') { Get-Content -LiteralPath $report; throw "Online test failed: $role" }
        Write-Output "$role $last"
    }
    foreach ($proc in $processes) { if ($proc.ExitCode -ne 0) { throw "Process exited $($proc.ExitCode)" } }
} finally {
    foreach ($proc in $processes) { if (-not $proc.HasExited) { Stop-Process -Id $proc.Id } }
}
