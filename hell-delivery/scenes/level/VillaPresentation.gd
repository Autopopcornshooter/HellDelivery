extends Node3D

# Presentation only: no collision, input or delivery state is added here.
const CITY := "res://assets/environment/kenney_city-kit-commercial_2.1/Models/GLB format/"
const FACTORY := "res://assets/environment/kenney_factory-kit_3.0/Models/GLB format/"
var _cream := _material(Color("e6d9bc"))
var _teal := _material(Color("287e85"))
var _dark := _material(Color("263746"))
var _yellow := _material(Color("f4bf4f"))


func _ready() -> void:
	_dress_surfaces()
	GameSettings.settings_changed.connect(_apply_graphics_settings)
	_apply_graphics_settings()
	_sign(Vector3(-4.0, 1.7, -6.5), "HELL DELIVERY\n출발 · 택배 1개", _teal)
	_box(Vector3(-4.0, 0.65, -6.5), Vector3(0.09, 1.3, 0.09), _dark)
	_sign(Vector3(-0.7, 2.0, 4.1), "배달 경로 ↑\n골목 끝에서 왼쪽", _teal)
	# Thin surface details sit on the existing walls, outside the established clearances.
	for z in [5.2, 7.4, 9.2]:
		_box(Vector3(-1.38, 1.9, z), Vector3(0.035, 0.9, 1.0), _cream)
		_box(Vector3(-1.35, 1.9, z), Vector3(0.035, 0.7, 0.8), _dark)
	# Background buildings use the supplied pack, never the delivery route's collision bodies.
	_building("building-a.glb", Vector3(-12, -0.08, 7), 8.0)
	_building("building-b.glb", Vector3(16, -0.08, -3), 7.0)
	_building("building-c.glb", Vector3(-12, -0.08, -9), 7.0)
	_building("building-d.glb", Vector3(17, -0.08, 14), 7.5)
	_building("building-e.glb", Vector3(-13, -0.08, 22), 7.0)
	# Supplied architectural details above head height; no route clearance changes.
	for z in [5.2, 7.4, 9.2]:
		_prop(CITY + "detail-awning.glb", Vector3(-1.65, 2.45, z), Vector3(3, 1.5, 2), PI / 2.0)
	# Parking bay paint lies on the existing dock surface.
	for x in [-1.85, 1.85]:
		_box(Vector3(x, 0.008, -5.3), Vector3(0.09, 0.012, 7.2), _yellow)
	_box(Vector3(0, 0.008, -8.9), Vector3(3.8, 0.012, 0.09), _yellow)
	# Use the supplied parcel mesh, fitted to the existing 0.8 x 0.6 x 0.8 collider.
	var package: Node3D = get_parent().get_node("Gameplay/Package")
	dress_package(package)

func dress_package(package: Node3D) -> void:
	package.get_node("MeshInstance3D").hide()
	var parcel: Node3D = load(FACTORY + "box-small.glb").instantiate()
	parcel.name = "FactoryParcelVisual"
	parcel.position.y = -0.3
	parcel.scale = Vector3(0.8 / 0.595, 0.6 / 0.55, 0.8 / 0.5)
	package.add_child(parcel)


func _dress_surfaces() -> void:
	var plaster := _surface(Color("e9dfc9"), 0.6, 0.025)
	var paving := _surface(Color("aaa99e"), 0.6, 0.12)
	var asphalt := _surface(Color("424d55"), 2.0, 0.025)
	var upper_tiles := _surface(Color("c7ae8a"), 0.5, 0.10)
	for body in get_parent().get_node("Environment").get_children():
		var mesh := body.get_node_or_null("MeshInstance3D") as MeshInstance3D
		if mesh == null:
			continue
		var id := str(body.name)
		if id.begins_with("Truck"):
			mesh.material_override = _cream if id == "TruckCab" or id == "TruckCargoRoof" else _teal
		elif id == "DockFloor":
			mesh.material_override = asphalt
		elif id.contains("Floor") or id.begins_with("Step") or id.contains("Landing"):
			mesh.material_override = paving
		elif id.contains("Wall") or id.begins_with("Left_") or id.begins_with("Right_"):
			mesh.material_override = plaster
			# Thin coping follows each existing wall rather than introducing a new obstruction.
			if mesh.mesh is BoxMesh and body.position.y < 3.0 and not id.begins_with("ForkPlazaWall"):
				var dimensions: Vector3 = mesh.mesh.size
				_box(body.position + Vector3(0, dimensions.y / 2.0 + 0.025, 0), Vector3(dimensions.x, 0.05, dimensions.z), _teal)
		else:
			mesh.material_override = upper_tiles
	var light: DirectionalLight3D = get_parent().get_node("Environment/DirectionalLight3D")
	light.rotation_degrees = Vector3(-55, -30, 0)
	light.light_color = Color("fff0d6")
	light.light_energy = 1.15
	light.shadow_enabled = true
	light.directional_shadow_max_distance = 65.0


func _surface(color: Color, tile_size: float, seams: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scenes/level/VillaSurface.gdshader")
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("tile_size", tile_size)
	material.set_shader_parameter("seam_strength", seams)
	return material


func _apply_graphics_settings() -> void:
	var light: DirectionalLight3D = get_parent().get_node("Environment/DirectionalLight3D")
	light.shadow_enabled = GameSettings.shadows_enabled


func _prop(path: String, location: Vector3, size: Vector3, yaw: float = 0.0) -> void:
	var prop: Node3D = load(path).instantiate()
	prop.position = location
	prop.scale = size
	prop.rotation.y = yaw
	add_child(prop)


func _building(file: String, location: Vector3, size: float) -> void:
	var scene: PackedScene = load(CITY + file)
	if scene == null:
		return
	var building: Node3D = scene.instantiate()
	building.position = location
	building.scale = Vector3.ONE * size
	add_child(building)
	var bounds := AABB()
	var first := true
	for mesh in building.find_children("*", "MeshInstance3D", true, false):
		var mesh_bounds: AABB = mesh.global_transform * mesh.get_aabb()
		bounds = mesh_bounds if first else bounds.merge(mesh_bounds)
		first = false
	if not first:
		building.set_meta("building_bounds", bounds)


func _sign(location: Vector3, text: String, material: StandardMaterial3D) -> void:
	_box(location, Vector3(1.8, 0.8, 0.07), material)
	var label := Label3D.new()
	label.text = text
	label.font_size = 36
	label.pixel_size = 0.006
	label.position = location + Vector3(0, 0, -0.05)
	label.rotation.y = PI
	label.modulate = Color.WHITE
	label.no_depth_test = false
	add_child(label)
	# Matching text on the reverse side keeps signs readable from both approaches.
	var reverse: Label3D = label.duplicate()
	reverse.position.z = location.z + 0.05
	reverse.rotation.y = 0
	add_child(reverse)


func _box(location: Vector3, size: Vector3, material: StandardMaterial3D) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	instance.mesh = mesh
	instance.position = location
	add_child(instance)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material
