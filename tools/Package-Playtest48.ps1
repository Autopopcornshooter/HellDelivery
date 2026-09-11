$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$build = Join-Path $workspace 'builds/HellDelivery-Windows-Test-48'
$validation = Join-Path $workspace 'validation/villa-48'
$zip = Join-Path $workspace 'builds/HellDelivery-2026-09-11-villa-48-full-delivery.zip'
$check = Join-Path $validation 'package-check'
if ((Test-Path -LiteralPath $zip) -or (Test-Path -LiteralPath $check)) { throw 'Package or unpack check already exists; preserve it and use an explicit new version.' }
$suites = @('FreightSoloAcceptance02','FreightManualPairAcceptance02','FreightFourAcceptance','PartyAcceptance')
foreach($suite in $suites) {
    $reports = @(Get-ChildItem -LiteralPath (Join-Path $validation $suite) -Filter '*.report.txt')
    if ($reports.Count -eq 0) { throw "No acceptance reports: $suite" }
    foreach($report in $reports) {
        if ((Get-Content -LiteralPath $report.FullName -Tail 1) -notmatch '^EXIT 0 checks=\d+ failures=0$') { throw "Incomplete acceptance: $($report.Name)" }
    }
}
if ((Get-Content -LiteralPath (Join-Path $validation 'BuildVisual.report.txt') -Tail 1) -notmatch '^EXIT 0 checks=\d+ failures=0$') { throw 'Build visual acceptance failed' }
Copy-Item -LiteralPath (Join-Path $workspace 'builds/HellDelivery-Windows-Test-47/licenses') -Destination (Join-Path $build 'licenses') -Recurse
Copy-Item -LiteralPath (Join-Path $workspace 'docs/PLAYTEST_README.md') -Destination (Join-Path $build 'README.md')
Copy-Item -LiteralPath (Join-Path $workspace 'docs/WINDOWS_PLAYTEST_48.md') -Destination (Join-Path $build 'VALIDATION.md')
$evidence = Join-Path $build 'verification'
New-Item -ItemType Directory -Path $evidence | Out-Null
foreach($suite in $suites) {
    $target = Join-Path $evidence $suite
    New-Item -ItemType Directory -Path $target | Out-Null
    Get-ChildItem -LiteralPath (Join-Path $validation $suite) -File | Where-Object { $_.Extension -in @('.png','.log','.txt') } | Copy-Item -Destination $target
}
foreach($name in @('BuildVisual.report.txt','BuildVisual.log','Export.log','01-menu.png','52-full-delivery-connection.png','INVESTIGATION.md')) {
    Copy-Item -LiteralPath (Join-Path $validation $name) -Destination $evidence
}
$lines = @(Get-ChildItem -LiteralPath $build -File -Recurse | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($build.Length + 1).Replace('\','/')
    '{0} *{1}' -f (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash, $relative
})
[IO.File]::WriteAllLines((Join-Path $build 'SHA256SUMS.txt'), $lines, (New-Object Text.UTF8Encoding($false)))
Add-Type -AssemblyName System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($build, $zip, [IO.Compression.CompressionLevel]::Optimal, $false)
[IO.Compression.ZipFile]::ExtractToDirectory($zip, $check)
$checked = 0
foreach($line in [IO.File]::ReadAllLines((Join-Path $check 'SHA256SUMS.txt'))) {
    $target = [IO.Path]::GetFullPath((Join-Path $check $line.Substring(66)))
    if (-not $target.StartsWith($check + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Manifest path escapes package' }
    if ((Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash -ne $line.Substring(0,64)) { throw "Hash mismatch: $target" }
    $checked += 1
}
$hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
[IO.File]::WriteAllText(($zip + '.sha256'), ($hash + ' *' + [IO.Path]::GetFileName($zip) + "`n"), (New-Object Text.UTF8Encoding($false)))
$log = Join-Path $validation 'UnpackedSmoke.log'
$arguments = @('--headless','--quit-after','180','--log-file',('"' + $log + '"'))
$process = Start-Process -FilePath (Join-Path $check 'HellDelivery.exe') -ArgumentList $arguments -WindowStyle Hidden -PassThru
try {
    if (-not $process.WaitForExit(30000)) { throw 'Unpacked smoke timed out' }
    if ($process.ExitCode -ne 0 -or (Select-String -LiteralPath $log -Pattern '^(SCRIPT ERROR:|ERROR:|WARNING:)' -Quiet)) { throw 'Unpacked smoke failed' }
} finally {
    if (-not $process.HasExited) { Stop-Process -Id $process.Id }
}
$summary = "PASS $checked payload hashes`nPASS unpacked 180-frame smoke exit 0`nZIP $zip`nBYTES $((Get-Item -LiteralPath $zip).Length)`nSHA256 $hash`n"
[IO.File]::WriteAllText((Join-Path $validation 'PackageVerification.txt'), $summary, (New-Object Text.UTF8Encoding($false)))
Write-Output $summary
