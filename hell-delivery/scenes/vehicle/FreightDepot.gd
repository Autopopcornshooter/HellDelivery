class_name FreightDepot
extends Node3D

const START := Vector3(0, 0.12, -66)
const PARK := Vector3(0, 0, -8)

func _ready() -> void:
	# The depot is an extension of the same physical map, with no loading cut.
	box("DepotGround", Vector3(0, -0.55, -59), Vector3(64, 1, 58), "b1aa97")
	box("Road", Vector3(0, -0.035, -43), Vector3(10, 0.025, 54), "424c50", false)
	for z in range(-65, -17, 6):
		box("RoadDash", Vector3(0, -0.016, z), Vector3(0.12, 0.012, 2.7), "ede5cc", false)
	for x in [-5.2, 5.2]:
		box("RoadEdge", Vector3(x, 0.04, -42), Vector3(0.22, 0.16, 50), "a4a7a4")
	for x in [-31, 31]: box("Boundary", Vector3(x, 1.2, -60), Vector3(1, 2.5, 58), "718783")
	box("Boundary", Vector3(0, 1.2, -88), Vector3(62, 2.5, 1), "718783")
	box("WarehouseBack", Vector3(-11, 2.5, -82), Vector3(20, 5, 0.3), "d1c5ab")
	box("WarehouseSide", Vector3(-21, 2.5, -74), Vector3(0.3, 5, 16), "d1c5ab")
	box("WarehouseRoof", Vector3(-11, 5.1, -74), Vector3(20.3, 0.22, 16.3), "287e85")
	for x in [-20.5, -2.5]: box("Column", Vector3(x, 2.5, -66), Vector3(0.25, 5, 0.25), "647674")
	box("PickupMark", Vector3(-6, 0.01, -73), Vector3(5, 0.015, 6), "d6ae45", false)
	add_sign("언덕마을 물류센터", Vector3(-11, 4, -65.75), PI, 40)
	add_sign("1 적재 → 2 운전 → 3 빌라 배송\n택배를 직접 트럭에 실으세요", Vector3(-7, 2.1, -76), 0, 28)
	add_sign("빌라 ↑ 60m", Vector3(5.6, 2.2, -60), PI, 30)
	add_sign("빌라 배송 주차\n정차 후 하차 · 왼쪽 골목", Vector3(3.5, 2.1, -12), PI, 25)
	for x in [-1.9, 1.9]: box("DeliveryBay", Vector3(x, 0.1, -8), Vector3(0.1, 0.012, 8.5), "e9cd6b", false)
	# Reuse the supplied factory kit around the pickup area.
	var factory := "res://assets/environment/kenney_factory-kit_3.0/Models/GLB format/"
	for index in 5:
		var item: Node3D = load(factory + "box-large.glb").instantiate()
		item.position = Vector3(-18 + index * 2.2, 0.08, -80)
		item.scale = Vector3.ONE * 1.8
		add_child(item)
		var stock := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(0.8, 0.56, 0.8)
		collision.shape = shape
		collision.position.y = 0.28
		item.add_child(stock)
		stock.add_child(collision)

func box(id: String, at: Vector3, size: Vector3, color: String, solid := true) -> Node3D:
	var node: Node3D = StaticBody3D.new() if solid else Node3D.new()
	node.name = id
	node.position = at
	add_child(node)
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	mesh.material = material
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	node.add_child(visual)
	if solid:
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		collision.shape = shape
		node.add_child(collision)
	return node

func add_sign(value: String, at: Vector3, yaw: float, font_size: int) -> void:
	var mount := Node3D.new()
	mount.position = at
	mount.rotation.y = yaw
	add_child(mount)
	var lines := value.split("\n")
	var width := 0.0
	for line in lines: width = maxf(width, line.length() * font_size * 0.008 * 0.9)
	var board := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(width + 0.4, lines.size() * font_size * 0.012 + 0.25, 0.12)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("245961")
	mesh.material = material
	board.mesh = mesh
	mount.add_child(board)
	var label := Label3D.new()
	label.text = value
	label.position.z = 0.08
	label.font_size = font_size
	label.pixel_size = 0.008
	label.modulate = Color("fff1c8")
	label.outline_size = 0
	mount.add_child(label)
	var back := label.duplicate() as Label3D
	back.position.z = -0.08
	back.rotation.y = PI
	mount.add_child(back)
	if at.y < 3:
		for side in [-1, 1]:
			var post := MeshInstance3D.new()
			var post_mesh := BoxMesh.new()
			post_mesh.size = Vector3(0.08, at.y, 0.08)
			post_mesh.material = material
			post.mesh = post_mesh
			post.position = Vector3(side * width * 0.4, -at.y / 2, 0)
			mount.add_child(post)
