$ErrorActionPreference = 'Stop'
$workspace = Split-Path $PSScriptRoot -Parent
$project = Join-Path $workspace 'hell-delivery'
# Keep small development scenes/tests available; asset dependencies are gathered by Godot.
$runtime = Get-ChildItem $project -Recurse -File | Where-Object {
    $_.FullName -notmatch '[\\/](assets|\.godot)[\\/]' -and $_.Extension -in @('.gd','.tscn','.tres','.gdshader')
} | ForEach-Object { 'res://' + $_.FullName.Substring($project.Length + 1).Replace('\','/') }
# VillaPresentation loads these with constructed paths, so dependency scanning cannot see them.
$city = 'res://assets/environment/kenney_city-kit-commercial_2.1/Models/GLB format/'
$factory = 'res://assets/environment/kenney_factory-kit_3.0/Models/GLB format/'
$dynamic = @('building-a.glb','building-b.glb','building-c.glb','building-d.glb','building-e.glb','detail-awning.glb','detail-overhang-wide.glb') | ForEach-Object { $city + $_ }
$dynamic += @('box-small.glb','box-large.glb','cone.glb') | ForEach-Object { $factory + $_ }
$dynamic += @('delivery.glb','sedan.glb') | ForEach-Object { 'res://assets/environment/kenney_car-kit/Models/' + $_ }
# MainMenu.gd loads this via a String constant (load(MENU_BGM_PATH)), which Godot's
# export dependency scan does not reliably follow the way it follows preload()/ext_resource.
$dynamic += 'res://assets/audio/courier_dash.mp3'
# project.godot's [gui] theme/custom points here by path string, not preload()/ext_resource,
# so the export scanner cannot discover it either -- same class of bug as courier_dash.mp3 above.
# The two Pretendard .otf files are pulled in automatically as this resource's own dependencies.
$dynamic += 'res://assets/fonts/DefaultTheme.tres'
# Same bug class: project.godot's [audio] buses/default_bus_layout is also a bare path string.
$dynamic += 'res://audio/default_bus_layout.tres'
$paths = @($runtime) + @($dynamic) | Sort-Object -Unique
foreach ($resource in $paths) {
    if (-not (Test-Path -LiteralPath (Join-Path $project $resource.Substring(6)))) { throw "Missing export resource: $resource" }
}
$preset = Join-Path $project 'export_presets.cfg'
$text = [IO.File]::ReadAllText($preset)
$text = $text.Replace('export_filter="all_resources"','export_filter="resources"')
$line = 'export_files=PackedStringArray(' + (($paths | ForEach-Object { '"' + $_ + '"' }) -join ', ') + ')'
$text = [regex]::Replace($text, '(?m)^export_files=.*$', $line)
[IO.File]::WriteAllText($preset, $text, (New-Object System.Text.UTF8Encoding($false)))
Write-Output "Export manifest: $($paths.Count) explicit resources plus dependencies"
