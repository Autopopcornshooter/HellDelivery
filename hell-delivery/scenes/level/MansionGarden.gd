class_name MansionGarden
extends Node3D

# "대저택 정원 미로" 레벨의 정원 본체. 대문에서 저택 현관까지 곧장 갈 수 없게, 생울타리
# 미로(구불구불한 통로 + 막다른 골목 하나)를 사이에 두고 배치한다. 실내는 없고 저택은 현관
# 앞이 배송 목표라 정원(미로)만 실제로 걸어서 통과 가능하게 만들면 된다(최소 구현).
const PATH: Array[Vector3] = [
	Vector3(0, 0, -18), Vector3(0, 0, -10), Vector3(4, 0, -6),
	Vector3(4, 0, 2), Vector3(-2, 0, 6), Vector3(-2, 0, 14), Vector3(0, 0, 19),
]
const DEAD_END_FROM := Vector3(4, 0, -6)
const DEAD_END_TO := Vector3(8, 0, -6)
const CORRIDOR_WIDTH := 3.0
const WALL_HEIGHT := 2.4
const WALL_THICKNESS := 0.4
const FACADE_Z := 20.0
const FACADE_GAP := 3.2

var door_position := Vector3.ZERO # DeliveryZone 배치용으로 레벨 스크립트에 공개.


func _ready() -> void:
	_ground()
	_gate()
	for i in PATH.size() - 1:
		_corridor("Corridor%d" % i, PATH[i], PATH[i + 1])
	_corridor("DeadEnd", DEAD_END_FROM, DEAD_END_TO)
	var dead_end_yaw := atan2(DEAD_END_TO.x - DEAD_END_FROM.x, DEAD_END_TO.z - DEAD_END_FROM.z)
	_cap("DeadEndCap", DEAD_END_TO, dead_end_yaw, CORRIDOR_WIDTH + WALL_THICKNESS * 2.0, WALL_HEIGHT, WALL_THICKNESS, "2f5c33")
	_mansion_facade()


func _ground() -> void:
	_box("GardenGround", Vector3(0, -0.55, 1.0), Vector3(20, 1, 40), "5f8a52")


func _gate() -> void:
	var yaw := atan2(PATH[1].x - PATH[0].x, PATH[1].z - PATH[0].z)
	for side in [-1, 1]:
		_cap("GatePost%d" % side, PATH[0] + Vector3(side * (CORRIDOR_WIDTH / 2.0 + 0.3), 0, 0), yaw, 0.6, 3.0, 0.6, "5b524a")
	_add_sign("대저택 정원\n미로를 통과해 현관까지 배송하세요", Vector3(0, 3.2, -18), 0.0, 24)


func _corridor(id: String, from: Vector3, to: Vector3) -> void:
	var diff := to - from
	var length := Vector2(diff.x, diff.z).length()
	var yaw := atan2(diff.x, diff.z)
	var perp := Vector3(cos(yaw), 0, -sin(yaw))
	var half := CORRIDOR_WIDTH / 2.0 + WALL_THICKNESS / 2.0
	for side in [-1, 1]:
		var mid := (from + to) / 2.0 + perp * (float(side) * half)
		var wall := _box(id + ("L" if side < 0 else "R"), Vector3(mid.x, WALL_HEIGHT / 2.0, mid.z), Vector3(WALL_THICKNESS, WALL_HEIGHT, length), "2f5c33")
		wall.rotation.y = yaw


func _cap(id: String, at: Vector3, yaw: float, width: float, height: float, thickness: float, color: String) -> void:
	var wall := _box(id, Vector3(at.x, height / 2.0, at.z), Vector3(width, height, thickness), color)
	wall.rotation.y = yaw


func _mansion_facade() -> void:
	var panel_width := (14.0 - FACADE_GAP) / 2.0
	var panel_x := FACADE_GAP / 2.0 + panel_width / 2.0
	_box("FacadeLeft", Vector3(-panel_x, 2.2, FACADE_Z), Vector3(panel_width, 4.4, 0.4), "c9b89a")
	_box("FacadeRight", Vector3(panel_x, 2.2, FACADE_Z), Vector3(panel_width, 4.4, 0.4), "c9b89a")
	_box("MansionMass", Vector3(0, 3.0, FACADE_Z + 5.0), Vector3(14, 6.0, 10), "d8c7a8")
	_add_sign("대저택 현관", Vector3(0, 3.0, FACADE_Z - 0.6), PI, 24)
	door_position = Vector3(0, 0.9, FACADE_Z - 1.4)


func _box(id: String, at: Vector3, size: Vector3, color: String) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = id
	body.position = at
	add_child(body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(color)
	material.roughness = 0.85
	mesh.material = material
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	body.add_child(visual)
	return body


func _add_sign(value: String, at: Vector3, yaw: float, font_size: int = 26) -> void:
	var label := Label3D.new()
	label.text = value
	label.position = at
	label.rotation.y = yaw
	label.font_size = font_size
	label.pixel_size = 0.005
	label.modulate = Color("fff1c8")
	label.outline_size = 0
	add_child(label)
