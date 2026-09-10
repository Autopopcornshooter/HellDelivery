extends Node3D

# Villa-specific architectural finish. Existing player stairs and goal stay in the scene.
# Reference interpretation: docs/VILLA_INTERIOR_REFERENCES.md. All meshes are authored here.
var plaster := _paint(4.3)
var stair_plaster := _paint(2.75)
var terrazzo := _stone()
var ivory := _material("eee9dd")
var metal := _material("414b49")
var wood := _material("8b6e4e")
var door_color := _material("546660")
var skirting := _material("74776e")

func _ready() -> void:
	_finish_existing_structure()
	_stair_hall()
	_upper_hall()
	_lighting()
	# PrototypeLevel creates its shared objective label in the parent's _ready.
	_finish_delivery_marker.call_deferred()

func _finish_delivery_marker() -> void:
	var zone := get_parent().get_node("Gameplay/DeliveryZone")
	var visual: MeshInstance3D = zone.get_node("MeshInstance3D")
	visual.scale.y = 0.035
	visual.position.y = -0.4775
	for label in zone.get_children():
		if label is Label3D:
			label.position.y = 1.5
			label.font_size = 32

func _finish_existing_structure() -> void:
	for body in get_parent().get_node("Environment").get_children():
		var surface := body.get_node_or_null("MeshInstance3D") as MeshInstance3D
		if surface == null:
			continue
		var id := str(body.name)
		if id.begins_with("Step") or id == "StairLanding" or (body.position.y > 3 and id.contains("Floor")):
			surface.material_override = terrazzo
		elif body.position.y > 3 and id.contains("Wall"):
			surface.material_override = plaster
		elif id.begins_with("ForkPlazaWall"):
			surface.material_override = stair_plaster
		if id.begins_with("Step"):
			var upper_flight := int(id.trim_prefix("Step")) > 9
			var edge := 0.14 if upper_flight else -0.14
			# Both flights meet the enclosure; duplicate shared resources before resizing.
			var width := 2.4 if upper_flight else 2.6
			var offset := -0.3 if upper_flight else 0.4
			surface.mesh = surface.mesh.duplicate()
			surface.mesh.size.x = width
			surface.position.x = offset
			var collision: CollisionShape3D = body.get_node("CollisionShape3D")
			collision.shape = collision.shape.duplicate()
			collision.shape.size.x = width
			collision.position.x = offset
			_box(body.position + Vector3(offset, 0.093, edge), Vector3(width - 0.06, 0.008, 0.025), metal)
		elif id == "UpperMergeFloor":
			# The old x=0.8 edge left a 30 cm slot against the x=0.5 inner wall.
			surface.mesh = surface.mesh.duplicate()
			surface.mesh.size.x = 2.8
			surface.position.x = -0.2
			var collision: CollisionShape3D = body.get_node("CollisionShape3D")
			collision.shape = collision.shape.duplicate()
			collision.shape.size.x = 2.8
			collision.position.x = -0.2
			_box(Vector3(1.8, 2.879, 13.3), Vector3(2.8, 0.05, 2.4), ivory)
	var neighborhood := get_parent().get_node("Neighborhood")
	for id in ["StairHallEast", "StairHallWest", "EntranceLintel", "StairHallSouthEast", "StairHallSouthWest", "UpperDoorLintel", "CorridorSouthClosure", "CorridorWestClosure", "LobbyNorthJunction"]:
		var surface := neighborhood.get_node(id + "Visual") as MeshInstance3D
		surface.material_override = stair_plaster if id.begins_with("StairHall") or id == "EntranceLintel" else plaster
	# White underside and cornice connect the ceiling planes without a teal indoor roof.
	for id in ["LobbyRoof", "CorridorRoof", "AlleyRoof", "StairHallRoof"]:
		var roof := neighborhood.get_node(id + "Visual") as MeshInstance3D
		var dimensions: Vector3 = roof.mesh.size
		_box(roof.position - Vector3(0, dimensions.y / 2 + 0.025, 0), Vector3(dimensions.x, 0.05, dimensions.z), ivory)
		if id == "AlleyRoof":
			# This roof end projects into the stair hall; finish its exposed vertical face.
			_box(roof.position + Vector3(0, 0, dimensions.z / 2 + 0.015), Vector3(dimensions.x, dimensions.y, 0.03), ivory)

func _stair_hall() -> void:
	# Full-width landing meets the enclosure; no bare ground strip behind the stairs.
	_solid("LandingExtension", Vector3(3.1, 0.801, 18.765), Vector3(5.2, 1.602, 3.07), terrazzo)
	_solid("EntranceFloor", Vector3(3.1, -0.06, 13.3), Vector3(5.2, 0.12, 2.4), terrazzo)
	# Close the ground-floor south face behind the turning route. The west vestibule
	# remains the intentional entrance; the upper wall no longer floats over an open facade.
	_solid("VestibuleFront", Vector3(4.5, 1.5, 11.35), Vector3(2.6, 3, 0.2), stair_plaster)
	_solid("VestibuleReturn", Vector3(5.8, 1.5, 11.675), Vector3(0.2, 3, 0.65), stair_plaster)
	_solid("VestibuleHeader", Vector3(4.5, 3.1, 11.65), Vector3(2.6, 0.2, 0.9), ivory)
	# North wall is segmented around two actual openings, with matching glazed collision.
	_solid("NorthSillWall", Vector3(3.1, 1.425, 20.4), Vector3(5.6, 2.85, 0.2), stair_plaster)
	_solid("NorthHeader", Vector3(3.1, 5.225, 20.4), Vector3(5.6, 1.55, 0.2), ivory)
	for section in [Vector2(0.725, 0.85), Vector2(3.05, 1.2), Vector2(5.425, 0.95)]:
		_solid("WindowPier", Vector3(section.x, 3.65, 20.4), Vector3(section.y, 1.6, 0.2), stair_plaster)
	var glass := _material("b2cfcd")
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.albedo_color.a = 0.22
	glass.roughness = 0.18
	for x in [1.8, 4.3]:
		_solid("StairWindow", Vector3(x, 3.65, 20.4), Vector3(1.3, 1.6, 0.025), glass)
		for offset in [-0.65, 0.0, 0.65]:
			_box(Vector3(x + offset, 3.65, 20.34), Vector3(0.055, 1.66, 0.1), ivory)
		for height in [2.85, 4.45]:
			_box(Vector3(x, height, 20.34), Vector3(1.4, 0.065, 0.1), ivory)
		_box(Vector3(x, 2.81, 20.24), Vector3(1.48, 0.07, 0.28), terrazzo)
	_sign("FloorSign", Vector3(3.05, 3.6, 20.275), PI, "2F\n← 배송 현관", Vector2(0.95, 0.72))
	# Central guard follows the upper flight, stopping before the turning landing.
	_guard(Vector3(2.88, 3.204, 14.45), Vector3(2.88, 1.602, 17.2))
	# Wall-side rails are unnecessary here. Keep only the central open-edge guard.
	# Wall skirting at the stair landing.
	_box(Vector3(3.1, 1.67, 20.27), Vector3(5.4, 0.14, 0.05), skirting)
	_box(Vector3(0.53, 1.67, 18.8), Vector3(0.05, 0.14, 3), skirting)
	_box(Vector3(5.67, 1.67, 18.8), Vector3(0.05, 0.14, 3), skirting)
	# Deliberate vestibule details, attached to walls rather than hovering in the route.
	_sign("EntranceName", Vector3(0.275, 3.3, 13.35), -PI / 2, "언덕 빌라", Vector2(1.2, 0.32))
	_sign("ApproachStairs", Vector3(-0.7, 1.7, 14.975), PI, "계단 ←", Vector2(1.1, 0.38))

func _upper_hall() -> void:
	# Skirting/cornices follow the actual L footprint and stop at its open corner.
	for segment in [Vector4(0.925, 9.05, 0.045, 5.9), Vector4(3.075, 10.15, 0.045, 3.7), Vector4(5.65, 8.275, 4.9, 0.045), Vector4(5.65, 5.725, 9.8, 0.045), Vector4(9.1, 8.675, 3, 0.045), Vector4(10.575, 7.2, 0.045, 3)]:
		_box(Vector3(segment.x, 3.28, segment.y), Vector3(segment.z, 0.16, segment.w), skirting)
		_box(Vector3(segment.x, 5.83, segment.y), Vector3(segment.z + 0.025, 0.1, segment.w + 0.025), ivory)
	# The corner sign is fixed to the now-closed end wall.
	_sign("HallDirection", Vector3(2, 4.82, 5.735), 0, "201  배송 현관 →", Vector2(1.5, 0.38))
	_door(Vector3(10.565, 3.2, 7.2), -PI / 2, "201", true)
	_door(Vector3(5.3, 3.2, 8.265), PI, "202", false)
	# Flush noticeboard on the west corridor wall adds a domestic scale cue.
	var board := Node3D.new()
	board.position = Vector3(0.935, 4.62, 10)
	board.rotation.y = PI / 2
	add_child(board)
	_local_box(board, Vector3.ZERO, Vector3(0.85, 0.82, 0.04), wood)
	_local_box(board, Vector3(0, 0, 0.025), Vector3(0.76, 0.73, 0.015), _material("b9a883"))
	for offset in [-0.2, 0.19]:
		_local_box(board, Vector3(offset, -0.03, 0.038), Vector3(0.27, 0.43, 0.008), ivory)
	_label(board, "입주민 안내", Vector3(0, 0.255, 0.05), 32, 0.003, metal.albedo_color)
	# Entry portal is above carried-object height; no new doorway narrowing.
	_box(Vector3(2.05, 5.59, 12.02), Vector3(2.3, 0.06, 0.24), ivory)
	for x in [0.94, 3.16]:
		_box(Vector3(x, 4.4, 12.02), Vector3(0.055, 2.4, 0.24), ivory)

func _door(location: Vector3, yaw: float, number: String, delivery: bool) -> void:
	var door := Node3D.new()
	door.name = "Apartment" + number
	door.position = location
	door.rotation.y = yaw
	add_child(door)
	_local_box(door, Vector3(0, 1.04, 0.025), Vector3(1.18, 2.08, 0.04), door_color)
	for x in [-0.64, 0.64]:
		_local_box(door, Vector3(x, 1.08, 0.04), Vector3(0.09, 2.16, 0.11), ivory)
	_local_box(door, Vector3(0, 2.16, 0.04), Vector3(1.37, 0.09, 0.11), ivory)
	for y in [0.57, 1.38]:
		_local_box(door, Vector3(0, y, 0.055), Vector3(0.96, 0.65, 0.02), _material("61716a"))
	_local_box(door, Vector3(0.41, 1.05, 0.085), Vector3(0.11, 0.27, 0.045), metal)
	_local_box(door, Vector3(0.32, 0.99, 0.125), Vector3(0.24, 0.045, 0.045), ivory)
	_local_box(door, Vector3(0, 1.81, 0.08), Vector3(0.4, 0.2, 0.018), ivory)
	_label(door, number, Vector3(0, 1.81, 0.095), 42, 0.003, metal.albedo_color)
	_local_box(door, Vector3(0.83, 1.45, 0.04), Vector3(0.14, 0.23, 0.04), metal)
	_local_box(door, Vector3(0.83, 1.48, 0.068), Vector3(0.075, 0.06, 0.01), ivory)
	_local_box(door, Vector3(0, 0.013, 0.48), Vector3(1.2, 0.026, 0.7), _material("716952"))
	if delivery:
		_local_box(door, Vector3(-0.94, 1.6, 0.03), Vector3(0.43, 0.56, 0.035), ivory)
		_label(door, "택배는\n현관 앞", Vector3(-0.94, 1.6, 0.058), 30, 0.0027, metal.albedo_color)

func _lighting() -> void:
	var luminous := _material("fff4da")
	luminous.emission_enabled = true
	luminous.emission = Color("fff1ce")
	luminous.emission_energy_multiplier = 0.65
	for location in [Vector3(3.1, 5.86, 18.3), Vector3(2, 5.8, 10.4), Vector3(6.4, 5.8, 7.2), Vector3(9.4, 5.8, 7.2)]:
		_box(location, Vector3(0.62, 0.065, 0.3), metal)
		_box(location - Vector3(0, 0.04, 0), Vector3(0.55, 0.025, 0.24), luminous)
		var light := OmniLight3D.new()
		light.position = location - Vector3(0, 0.2, 0)
		light.light_color = Color("fff0d7")
		light.light_energy = 0.75
		light.omni_range = 5.5
		light.shadow_enabled = false
		add_child(light)

func _guard(start: Vector3, end: Vector3) -> void:
	# Physical rails match their visible slender rods; no invisible full-width blocker.
	_rod(start + Vector3.UP, end + Vector3.UP, 0.035, wood, true)
	_rod(start + Vector3.UP * 0.15, end + Vector3.UP * 0.15, 0.018, metal, true)
	var count := ceili(start.distance_to(end) / 0.28)
	for index in range(count + 1):
		var base := start.lerp(end, float(index) / count)
		_rod(base, base + Vector3.UP, 0.015, metal, true)

func _rod(start: Vector3, end: Vector3, radius: float, material: Material, physical: bool) -> void:
	var root := Node3D.new()
	root.position = (start + end) / 2
	root.quaternion = Quaternion(Vector3.UP, (end - start).normalized())
	add_child(root)
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = start.distance_to(end)
	mesh.radial_segments = 8
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	root.add_child(instance)
	if physical:
		var body := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = radius
		shape.height = mesh.height
		collision.shape = shape
		body.add_child(collision)
		root.add_child(body)

func _sign(id: String, location: Vector3, yaw: float, text: String, size: Vector2) -> void:
	var sign := Node3D.new()
	sign.name = id
	sign.position = location
	sign.rotation.y = yaw
	add_child(sign)
	_local_box(sign, Vector3.ZERO, Vector3(size.x, size.y, 0.03), door_color)
	_label(sign, text, Vector3(0, 0, 0.02), 40, 0.0035, Color("fff8e6"))

func _label(parent: Node3D, text: String, location: Vector3, font_size: int, pixel_size: float, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.font_size = font_size
	label.pixel_size = pixel_size
	label.position = location
	label.modulate = color
	label.outline_size = 0
	parent.add_child(label)

func _solid(id: String, location: Vector3, size: Vector3, material: Material) -> void:
	var body := StaticBody3D.new()
	body.name = id
	body.position = location
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	_local_box(body, Vector3.ZERO, size, material)

func _box(location: Vector3, size: Vector3, material: Material) -> void:
	_local_box(self, location, size, material)

func _local_box(parent: Node3D, location: Vector3, size: Vector3, material: Material) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = location
	parent.add_child(instance)

func _material(hex: String) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(hex)
	material.roughness = 0.8
	return material

func _stone() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scenes/level/VillaInteriorSurface.gdshader")
	return material

func _paint(band_top: float) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scenes/level/VillaInteriorSurface.gdshader")
	material.set_shader_parameter("painted_wall", true)
	material.set_shader_parameter("base_color", Color("e8e4d9"))
	material.set_shader_parameter("lower_color", Color("a0aaa0"))
	material.set_shader_parameter("band_top", band_top)
	return material
