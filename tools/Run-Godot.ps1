param(
    [ValidateSet('Import','Test','Visual','Inspect','Route','Export','Smoke','BuildTest','BuildRoute','BuildVisual','BuildRouteVisual','Performance','SettingsWrite','SettingsRead')][string]$Mode = 'Test',
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$BuildName = 'HellDelivery-Windows-Test-13'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$engine = Join-Path $workspace 'Godot_v4.7.1-stable_win64.exe/Godot_v4.7.1-stable_win64_console.exe'
$project = Join-Path $workspace 'hell-delivery'
$logs = Join-Path $workspace 'validation/villa-13'
$build = Join-Path (Join-Path $workspace 'builds') $BuildName
New-Item -ItemType Directory -Force $logs | Out-Null
New-Item -ItemType Directory -Force $build | Out-Null
function Confirm-GodotRun([int]$Code) {
    if ($Code -ne 0) { throw "Godot exited with code $Code ($Mode)" }
    $log = Join-Path $logs "$Mode.log"
    if ((Test-Path -LiteralPath $log) -and (Select-String -LiteralPath $log -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet)) {
        throw "Godot logged an error or warning: $log"
    }
    if ($Mode -notin @('Import','Export','Smoke')) {
        $report = Join-Path $logs "$Mode.report.txt"
        if (-not (Test-Path -LiteralPath $report) -or (Get-Content -LiteralPath $report -Tail 1) -notmatch '^EXIT 0 checks=\d+ failures=0$') {
            throw "Missing or incomplete successful test report: $report"
        }
    }
}
if ($Mode -eq 'Export') {
    & (Join-Path $PSScriptRoot 'Validate-SourceText.ps1')
    & (Join-Path $PSScriptRoot 'Update-ExportManifest.ps1')
}
# Never accept a successful report left over from an earlier invocation.
$previousReport = Join-Path $logs "$Mode.report.txt"
if (Test-Path -LiteralPath $previousReport) { Remove-Item -LiteralPath $previousReport }
$arguments = @('--path', $project, '--log-file', (Join-Path $logs "$Mode.log"))
switch ($Mode) {
    'Import' { $arguments += @('--headless','--editor','--import') }
    'Test' { $arguments += @('--headless','res://tests/Playtest.tscn') }
    'Visual' { $arguments += @('res://tests/Playtest.tscn','--','visual') }
    'Inspect' { $arguments += @('res://tests/Playtest.tscn','--','visual','inspect') }
    'Route' { $arguments += @('--headless','res://tests/Playtest.tscn','--','route') }
    'Export' { $arguments += @('--headless','--editor','--export-debug','Windows Desktop',(Join-Path $build 'HellDelivery.exe')) }
    'Smoke' { $engine = Join-Path $build 'HellDelivery.exe'; $arguments = @('--headless','--quit-after','180','--log-file',(Join-Path $logs 'Smoke.log')) }
    { $_ -in @('BuildTest','BuildRoute','BuildVisual','BuildRouteVisual','Performance','SettingsWrite','SettingsRead') } {
        $engine = Join-Path $build 'HellDelivery.exe'
        $arguments = @('--log-file',(Join-Path $logs "$Mode.log"))
        if ($Mode -notin @('BuildVisual','BuildRouteVisual','Performance')) { $arguments += '--headless' }
        $arguments += @('--','self-test')
        if ($Mode -in @('BuildRoute','BuildRouteVisual')) { $arguments += 'route' }
        if ($Mode -in @('BuildVisual','BuildRouteVisual','Performance')) { $arguments += 'visual' }
        if ($Mode -eq 'Performance') { $arguments += 'performance' }
        if ($Mode -eq 'SettingsWrite') { $arguments += 'settings-write' }
        if ($Mode -eq 'SettingsRead') { $arguments += 'settings-read' }
    }
}
if ($Mode -in @('Test','Visual','Inspect','Route','BuildTest','BuildRoute','BuildVisual','BuildRouteVisual','Performance','SettingsWrite','SettingsRead')) {
    if ($arguments -notcontains '--') { $arguments += '--' }
    $arguments += ('report-path=' + (Join-Path $logs "$Mode.report.txt"))
}
if ($Mode -in @('Smoke','BuildTest','BuildRoute','BuildVisual','BuildRouteVisual','Performance','SettingsWrite','SettingsRead')) {
    $quotedArguments = $arguments | ForEach-Object { '"' + $_ + '"' }
    if ($Mode -in @('BuildVisual','BuildRouteVisual','Performance')) {
        $run = Start-Process -FilePath $engine -ArgumentList $quotedArguments -PassThru
    } else {
        $run = Start-Process -FilePath $engine -ArgumentList $quotedArguments -WindowStyle Hidden -PassThru
    }
    if (-not $run.WaitForExit(180000)) {
        Stop-Process -Id $run.Id
        throw "Godot validation timed out: $Mode"
    }
    Confirm-GodotRun $run.ExitCode
    exit 0
}
& $engine @arguments
Confirm-GodotRun $LASTEXITCODE
exit 0
