class_name ApartmentDepot
extends Node3D

# 아파트 배송 노선 전용 적재소 — 기존 FreightDepot.gd와 같은 역할(트럭 스폰/적재 구역)이지만
# 이 레벨만의 훨씬 짧은 진입로용으로 별도 좌표를 쓴다. FreightRun.gd가 session.order_id에 따라
# 이 클래스와 FreightDepot 중 하나를 골라 생성한다(기존 빌라 노선은 전혀 건드리지 않는다).
const START := Vector3(0, 0.12, -46)
const PARK := Vector3(0, 0, -6)

# 진입로 경로점 — 직선 하나였던 원래 도로에 코너 두 개를 넣어 완만한 S자로 만든다.
# 안전 지면(RouteGround)이 이 경로 전체 폭을 덮으므로 코너 바깥으로 살짝 벗어나도 떨어지지 않는다.
const ROUTE_PATH: Array[Vector3] = [
	Vector3(0, 0, -46), Vector3(0, 0, -36), Vector3(3, 0, -28),
	Vector3(3, 0, -20), Vector3(0, 0, -12), Vector3(0, 0, -1),
]

func _ready() -> void:
	box("DepotGround", Vector3(0, -0.55, -40), Vector3(20, 1, 20), "b1aa97")
	# villa-78 수정: 원래는 도로(폭 8)만 지면이 있어서 코너 바깥이나 도로 밖으로 나가면
	# 바닥이 뚫려 떨어졌다 — 진입로 전체 폭을 덮는 지면을 추가해 해결한다.
	box("RouteGround", Vector3(0, -0.55, -20), Vector3(20, 1, 42), "8a9a7c")
	for i in ROUTE_PATH.size() - 1:
		var from: Vector3 = ROUTE_PATH[i]
		var to: Vector3 = ROUTE_PATH[i + 1]
		_road_segment("RoadSegment%d" % i, from, to, 8.0, "424c50")
		_curb_segment("Curb%dL" % i, from, to, -4.2)
		_curb_segment("Curb%dR" % i, from, to, 4.2)
		var mid := (from + to) / 2.0
		box("RoadDash%d" % i, Vector3(mid.x, -0.016, mid.z), Vector3(0.12, 0.012, 2.7), "ede5cc", false)
	for x in [-9, 9]: box("Boundary", Vector3(x, 1.2, -25), Vector3(1, 2.5, 48), "718783")
	box("Boundary", Vector3(0, 1.2, -50), Vector3(20, 2.5, 1), "718783")
	box("PickupMark", Vector3(0, 0.01, -42), Vector3(4, 0.015, 5), "d6ae45", false)
	add_sign("행복아파트 물류거점", Vector3(-6, 3, -46), PI, 30)
	add_sign("1 적재 → 2 운전 → 3 아파트 배송\n택배를 직접 트럭에 실으세요", Vector3(6, 2.0, -44), 0, 24)
	add_sign("행복아파트 ↑ 40m · 코너 주의", Vector3(3.6, 2.2, -30), PI, 26)
	add_sign("아파트 배송 주차\n정차 후 하차 · 공동현관", Vector3(2.5, 2.1, -9), PI, 22)
	for x in [-1.6, 1.6]: box("DeliveryBay", Vector3(x, 0.1, -6), Vector3(0.1, 0.012, 6), "e9cd6b", false)


func _road_segment(id: String, from: Vector3, to: Vector3, width: float, color: String) -> void:
	var diff := to - from
	var length := Vector2(diff.x, diff.z).length()
	var yaw := atan2(diff.x, diff.z)
	var node := box(id, Vector3(0, -0.035, 0), Vector3(width, 0.025, length), color)
	node.position = (from + to) / 2.0 + Vector3(0, -0.035, 0)
	node.rotation.y = yaw


func _curb_segment(id: String, from: Vector3, to: Vector3, offset: float) -> void:
	var diff := to - from
	var length := Vector2(diff.x, diff.z).length()
	var yaw := atan2(diff.x, diff.z)
	var perp := Vector3(cos(yaw), 0, -sin(yaw))
	var mid := (from + to) / 2.0 + perp * offset
	var node := box(id, Vector3(mid.x, 0.04, mid.z), Vector3(0.22, 0.16, length), "a4a7a4")
	node.rotation.y = yaw

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
	if at.y < 3:
		for side in [-1, 1]:
			var post := MeshInstance3D.new()
			var post_mesh := BoxMesh.new()
			post_mesh.size = Vector3(0.08, at.y, 0.08)
			post_mesh.material = material
			post.mesh = post_mesh
			post.position = Vector3(side * width * 0.4, -at.y / 2, 0)
			mount.add_child(post)
