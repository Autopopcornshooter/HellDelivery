param([switch]$Source, [switch]$Visual, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$RunTag = 'PartyFinal')
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$out = Join-Path $workspace ('validation/villa-48/' + $RunTag)
if (Test-Path -LiteralPath $out) { throw 'Use a fresh RunTag for party verification' }
New-Item -ItemType Directory -Force $out | Out-Null
$engine = Join-Path $workspace 'builds/HellDelivery-Windows-Test-48/HellDelivery.exe'
if ($Source) { $engine = Join-Path $workspace 'Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' }
$processes = @()
try {
 foreach($seat in 0..3) {
  $arguments = @('--log-file',(Join-Path $out "party-$seat.log"),'--resolution','960x540')
  if($Source) { $arguments += @('--path',(Join-Path $workspace 'hell-delivery')) }
  if(-not $Visual) { $arguments += '--headless' }
  $role = if($seat -eq 0) { 'host' } else { 'client' }
  $arguments += @('--',"network-test-$role",'party-test',"party-seat=$seat",('network-output='+$out))
  if($Visual) { $arguments += 'network-visual' }
  $quoted = $arguments | ForEach-Object { '"'+$_+'"' }
  $processes += Start-Process -FilePath $engine -ArgumentList $quoted -WindowStyle Hidden -PassThru
  Start-Sleep -Milliseconds 1200
 }
 $deadline = (Get-Date).AddSeconds(560)
 while(@($processes | Where-Object { -not $_.HasExited }).Count -gt 0) {
  if((Get-Date) -gt $deadline) { throw 'Party test timed out' }
  foreach($seat in 0..3) {
   $log = Join-Path $out "party-$seat.log"
   if((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet)) { Get-Content $log -Tail 12; throw "Party log error $seat" }
   $report = Join-Path $out "party-$seat.report.txt"
   if((Test-Path -LiteralPath $report) -and (Get-Content -LiteralPath $report -Tail 1) -match '^EXIT [1-9]') { throw "Party failure $seat" }
  }
  Start-Sleep -Milliseconds 500
 }
 foreach($seat in 0..3) {
  if(Select-String -LiteralPath (Join-Path $out "party-$seat.log") -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet) { throw "Final party log error $seat" }
  $last = Get-Content -LiteralPath (Join-Path $out "party-$seat.report.txt") -Tail 1
  if($last -notmatch '^EXIT 0 checks=\d+ failures=0$' -or $processes[$seat].ExitCode -ne 0) { throw "Party failed $seat" }
  Write-Output "P$($seat+1) $last"
 }
} finally {
 foreach($proc in $processes) { if(-not $proc.HasExited) { Stop-Process -Id $proc.Id } }
}
