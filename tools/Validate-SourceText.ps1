$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
$files = Get-ChildItem (Join-Path $workspace 'hell-delivery'),(Join-Path $workspace 'docs'),(Join-Path $workspace 'tools') -Recurse -File | Where-Object {
    $_.FullName -notmatch '[\\/](assets|\.godot)[\\/]' -and $_.Extension -in @('.gd','.tscn','.tres','.gdshader','.md','.ps1')
}
foreach ($file in $files) {
    $content = $strictUtf8.GetString([IO.File]::ReadAllBytes($file.FullName))
    if ($content.Contains([string][char]0xFFFD)) { throw "Unicode replacement character in $($file.FullName)" }
}
Write-Output "Strict UTF-8 check passed: $($files.Count) source/document files. In-game text assertions and screenshots verify wording."
