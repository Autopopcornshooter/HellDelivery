param([ValidateSet(1,2,4)][int]$Members = 2, [int]$Port = 27928, [switch]$Source, [switch]$Manual, [switch]$Visual, [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$RunTag = 'FreightFinal')
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$out = Join-Path $workspace ('validation/villa-48/' + $RunTag)
if (Test-Path -LiteralPath $out) { throw 'Use a fresh RunTag for freight verification' }
New-Item -ItemType Directory -Force $out | Out-Null
$engine = Join-Path $workspace 'builds/HellDelivery-Windows-Test-48/HellDelivery.exe'
if ($Source) { $engine = Join-Path $workspace 'Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe' }
$processes = @()
try {
 foreach($seat in 0..($Members-1)) {
  $arguments = @('--log-file',(Join-Path $out "freight-$seat.log"),'--resolution','960x540')
  if($Source) { $arguments += @('--path',(Join-Path $workspace 'hell-delivery')) }
  if(-not $Visual) { $arguments += '--headless' }
  $role = if($seat -eq 0) { 'host' } else { 'client' }
  $arguments += @('--',"network-test-$role",'freight-test',"freight-seat=$seat","freight-members=$Members","freight-port=$Port",('network-output='+$out))
  if($Visual) { $arguments += 'network-visual' }
  if($Manual) { $arguments += 'freight-manual' }
  $quoted = $arguments | ForEach-Object { '"'+$_+'"' }
  $processes += Start-Process -FilePath $engine -ArgumentList $quoted -WindowStyle Hidden -PassThru
  Start-Sleep -Milliseconds 1200
 }
 $deadline = (Get-Date).AddSeconds(560)
 while(@($processes | Where-Object { -not $_.HasExited }).Count -gt 0) {
  if((Get-Date) -gt $deadline) { throw 'Freight test timed out' }
  foreach($seat in 0..($Members-1)) {
   $log = Join-Path $out "freight-$seat.log"
   if((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet)) { Get-Content $log -Tail 12; throw "Freight log error $seat" }
   $report = Join-Path $out "freight-$seat.report.txt"
   if((Test-Path -LiteralPath $report) -and (Select-String -LiteralPath $report -Pattern '^(FAIL |EXIT [1-9])' -Quiet)) { throw "Freight failure $seat" }
  }
  Start-Sleep -Milliseconds 500
 }
 foreach($seat in 0..($Members-1)) {
  if(Select-String -LiteralPath (Join-Path $out "freight-$seat.log") -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet) { throw "Final freight log error $seat" }
  $last = Get-Content -LiteralPath (Join-Path $out "freight-$seat.report.txt") -Tail 1
  if($last -notmatch '^EXIT 0 checks=\d+ failures=0$' -or $processes[$seat].ExitCode -ne 0) { throw "Freight failed $seat" }
  Write-Output "P$($seat+1) $last"
 }
} finally {
 foreach($proc in $processes) { if(-not $proc.HasExited) { Stop-Process -Id $proc.Id } }
}
