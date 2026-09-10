extends Node3D

# Physical neighbourhood shell. Gameplay remains in the original level/DeliveryZone.
const VEHICLES := "res://assets/environment/kenney_car-kit/Models/"
var asphalt := _material("414a50")
var paving := _paving()
var plaster := _material("d1c5ab")
var stone := _material("8d9388")
var green := _material("50734c")
var trim := _material("287e85")
var paint := _material("edcb68")

func _ready() -> void:
	# Continuous collision surface directly below the original zero-height footpaths.
	_solid("ContinuousGround", Vector3(0, -0.58, 5), Vector3(64, 1, 76), paving)
	for building in get_parent().get_node("Presentation").get_children():
		if building.has_meta("building_bounds"):
			var bounds: AABB = building.get_meta("building_bounds")
			_solid("BuildingCollision", bounds.get_center(), bounds.size)
	_mesh(Vector3(0, -0.065, -17), Vector3(62, 0.015, 9), asphalt)
	_mesh(Vector3(21, -0.06, 5), Vector3(8, 0.015, 42), asphalt)
	for x in range(-29, 31, 4):
		if x < 17 or x > 25:
			_mesh(Vector3(x, -0.05, -17), Vector3(2, 0.01, 0.12), paint)
	for z in range(-12, 27, 4):
		_mesh(Vector3(21, -0.045, z), Vector3(0.12, 0.01, 2), paint)
	# Readable perimeter: visible retaining wall/hedge with matching collision.
	for x in [-31.0, 31.0]:
		_solid("BoundarySide", Vector3(x, 1.25, 5), Vector3(1, 2.6, 76), stone)
		_mesh(Vector3(x, 2.7, 5), Vector3(1.1, 0.5, 76), green)
	for z in [-32.0, 42.0]:
		_solid("BoundaryEnd", Vector3(0, 1.25, z), Vector3(62, 2.6, 1), stone)
		_mesh(Vector3(0, 2.7, z), Vector3(62, 0.5, 1.1), green)
	# Fill below the upper lobby/corridor, away from the established lower alley.
	_solid("VillaLowerStorey", Vector3(6.85, 1.5, 7.2), Vector3(7.5, 3, 3.2), plaster)
	_solid("VillaAlleyStorey", Vector3(2.1, 1.5, 9.1), Vector3(1.8, 3, 6), plaster)
	for x in [4.4, 6.4, 8.4]:
		_mesh(Vector3(x, 1.7, 5.58), Vector3(1.05, 1.1, 0.04), trim)
		_mesh(Vector3(x, 1.7, 5.55), Vector3(0.86, 0.9, 0.04), _material("283e4e"))
	# Shelter over the final hall, well above the player and carried parcel.
	_solid("LobbyRoof", Vector3(8.8, 6.03, 7.2), Vector3(4.2, 0.18, 3.8), trim)
	_solid("CorridorRoof", Vector3(3.8, 6.03, 7.2), Vector3(5.8, 0.18, 3), trim)
	_solid("AlleyRoof", Vector3(2, 6.03, 10.5), Vector3(2.6, 0.18, 3.6), trim)
	for step in get_parent().get_node("Environment").get_children():
		if str(step.name).begins_with("Step") and step is StaticBody3D:
			var height: float = step.position.y - 0.089
			if height > 0.01:
				var first_flight := int(str(step.name).trim_prefix("Step")) <= 9
				_solid("StairFoundation", Vector3(4.4 if first_flight else step.position.x, height / 2.0, step.position.z), Vector3(2.6 if first_flight else 1.8, height, 0.35), stone)
	# Garden strips and kerbs break up the paved site without creating hidden walls.
	for location in [Vector3(-25, 0, 8), Vector3(27, 0, 26), Vector3(0, 0, 32)]:
		_solid("GardenBed", location + Vector3(0, 0.05, 0), Vector3(5, 0.25, 9), stone)
		_mesh(location + Vector3(0, 0.185, 0), Vector3(4.6, 0.03, 8.6), green)
	for x in [-22.0, 22.0]:
		for z in [31.0, 36.0]:
			_tree(Vector3(x, 0, z))
	for x in range(-27, 29, 3):
		_mesh(Vector3(x, -0.045, -12.45), Vector3(2.8, 0.04, 0.16), plaster)
	_parking_bay(Vector3(-17, -0.045, -25), true)
	_parking_bay(Vector3(26, -0.045, -19), false)
	_building_envelope()
	for location in [Vector3(-7, 0, -11), Vector3(-7, 0, 1), Vector3(-7, 0, 17), Vector3(13, 0, 23), Vector3(26, 0, -8), Vector3(26, 0, 12)]:
		_tree(location)
	for location in [Vector3(-5, 0, -14), Vector3(12, 0, -13), Vector3(16, 0, 19)]:
		_lamp(location)
	_delivery_truck()
	_parked_car(Vector3(26, -0.07, -19), 0.0)
	_parked_car(Vector3(-17, -0.07, -25), PI / 2.0)
	var environment: Environment = get_parent().get_node("Environment/WorldEnvironment").environment
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color("5389b4")
	sky_material.sky_horizon_color = Color("cfdfdb")
	sky_material.ground_horizon_color = Color("cfdfdb")
	sky_material.ground_bottom_color = Color("829581")
	var sky := Sky.new()
	sky.sky_material = sky_material
	environment.sky = sky
	environment.background_mode = Environment.BG_SKY

func _delivery_truck() -> void:
	for old in get_parent().get_node("Environment").get_children():
		if str(old.name).begins_with("Truck"):
			old.queue_free()
	var truck: Node3D = load(VEHICLES + "delivery.glb").instantiate()
	truck.name = "DeliveryTruckModel"
	truck.position = Vector3(0, -0.04, -5.3)
	truck.scale = Vector3.ONE * 2.0
	add_child(truck)
	_solid("TruckCargoCollision", Vector3(0, 1.65, -6.0), Vector3(2.5, 2.6, 4.7))
	_solid("TruckCabCollision", Vector3(0, 1.05, -3.25), Vector3(2.5, 1.8, 1.9))
	var label := Label3D.new()
	label.name = "TruckLivery"
	label.text = "HELL DELIVERY\n언덕마을 배송"
	label.font_size = 40
	label.pixel_size = 0.005
	label.position = Vector3(0, 2.15, -8.66)
	label.rotation.y = PI
	label.outline_size = 0
	_mesh(Vector3(0, 2.15, -8.62), Vector3(1.9, 0.64, 0.04), trim)
	add_child(label)
	_mesh(Vector3(0, 0.01, -9.3), Vector3(1.45, 0.018, 1.45), paint)

func _parking_bay(center: Vector3, sideways: bool) -> void:
	# Two parallel sides and a rear stop, with an open vehicle entrance.
	for side in [-1.6, 1.6]:
		var offset := Vector3(0, 0, side) if sideways else Vector3(side, 0, 0)
		var size := Vector3(5.2, 0.02, 0.1) if sideways else Vector3(0.1, 0.02, 5.2)
		_mesh(center + offset, size, plaster)
	_mesh(center + (Vector3(-2.6, 0, 0) if sideways else Vector3(0, 0, -2.6)), Vector3(0.1, 0.02, 3.3) if sideways else Vector3(3.3, 0.02, 0.1), plaster)

func _building_envelope() -> void:
	# An enclosed stair hall; the west ground-floor doorway opens onto the alley.
	# Keep the north turning clearance outside the held parcel's swept path.
	_solid("StairHallEast", Vector3(5.8, 3, 16.2), Vector3(0.2, 6, 8.4), plaster)
	# The north wall with real glazed openings is built by VillaInterior.
	_solid("StairHallWest", Vector3(0.4, 3, 17.9), Vector3(0.2, 6, 5.0), plaster)
	_solid("EntranceLintel", Vector3(0.4, 4.45, 13.7), Vector3(0.2, 3.1, 3.4), plaster)
	_solid("StairHallSouthEast", Vector3(4.5, 4.55, 12), Vector3(2.6, 2.7, 0.2), plaster)
	_solid("StairHallSouthWest", Vector3(0.65, 4.55, 12), Vector3(0.5, 2.7, 0.2), plaster)
	_solid("UpperDoorLintel", Vector3(2.05, 5.8, 12), Vector3(2.3, 0.4, 0.2), plaster)
	_solid("StairHallRoof", Vector3(3.1, 6.12, 16.2), Vector3(5.8, 0.24, 8.8), trim)
	# Close the L-shaped corridor's accidental open south end and wall junction.
	_solid("CorridorSouthClosure", Vector3(1.95, 4.55, 5.6), Vector3(2.3, 2.7, 0.2), plaster)
	_solid("CorridorWestClosure", Vector3(0.8, 4.55, 5.9), Vector3(0.2, 2.7, 0.6), plaster)
	_solid("LobbyNorthJunction", Vector3(8.1, 4.55, 8.6), Vector3(0.2, 2.7, 0.4), plaster)

func _parked_car(location: Vector3, yaw: float) -> void:
	var car: Node3D = load(VEHICLES + "sedan.glb").instantiate()
	car.position = location
	car.rotation.y = yaw
	car.scale = Vector3.ONE * 1.6
	add_child(car)
	var size := Vector3(2.2, 1.6, 3.7) if yaw == 0.0 else Vector3(3.7, 1.6, 2.2)
	_solid("ParkedCarCollision", location + Vector3(0, 0.9, 0), size)

func _tree(location: Vector3) -> void:
	_solid("TreePlanter", location + Vector3(0, 0.18, 0), Vector3(1.7, 0.5, 1.7), stone)
	_solid("TreeTrunk", location + Vector3(0, 1.5, 0), Vector3(0.3, 2.5, 0.3), _material("74604d"))
	var crown := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.35
	sphere.height = 2.5
	sphere.radial_segments = 8
	sphere.rings = 4
	sphere.material = green
	crown.mesh = sphere
	crown.position = location + Vector3(0, 3.3, 0)
	add_child(crown)

func _lamp(location: Vector3) -> void:
	_solid("LampPost", location + Vector3(0, 1.9, 0), Vector3(0.12, 3.8, 0.12), trim)
	_mesh(location + Vector3(0.35, 3.85, 0), Vector3(0.85, 0.12, 0.4), plaster)

func _solid(id: String, location: Vector3, size: Vector3, material: Material = null) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = id
	body.position = location
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	if material != null:
		var surface := _mesh(location, size, material)
		surface.name = id + "Visual"
	return body

func _mesh(location: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	instance.mesh = mesh
	instance.position = location
	add_child(instance)
	return instance

func _material(hex: String) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(hex)
	material.roughness = 0.85
	return material

func _paving() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = preload("res://scenes/level/VillaSurface.gdshader")
	material.set_shader_parameter("base_color", Color("a8aaa2"))
	material.set_shader_parameter("tile_size", 1.25)
	material.set_shader_parameter("seam_strength", 0.06)
	return material
