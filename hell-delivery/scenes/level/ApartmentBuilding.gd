class_name ApartmentBuilding
extends Node3D

# "엘리베이터 고장 아파트" 레벨의 건물 본체. 사용자 레퍼런스(실제 복도식 아파트 계단/복도 사진)를
# 반영해, 매 층 반 층씩 꺾이는 U자 계단(스위치백)으로 좁은 계단실 하나를 여러 층 그대로 쌓아
# 올리고(실제 건물처럼 층마다 같은 평면 위치), 목표 층에는 편복도(한쪽에 문이 늘어선 복도)와
# 세대 문 8개(예: 6층이면 601~608호)를 배치한다. 건물은 11층 규모지만, 실제로 걸어서 올라갈 수
# 있는 것은 목표 층(TARGET_FLOOR)까지만 만든다 — 그 위층은 외관 매스로만 존재한다(최소 구현).
const STEP_RISE := 0.2
const STEP_RUN := 0.3
const HALF_STEPS := 8
const SHAFT_HALF_WIDTH := 1.6
const FLIGHT_X := 0.8
const FLOOR_HEIGHT := STEP_RISE * HALF_STEPS * 2.0 # 3.2
const Z_NEAR := 8.0 # 계단실 진입 쪽(복도/로비와 만나는 층계참)
const Z_FAR := Z_NEAR + HALF_STEPS * STEP_RUN # 중간 층계참(꺾이는 지점)
const RAIL_HEIGHT := 1.0
const TOTAL_FLOORS := 11
const TARGET_FLOOR := 6
const DOORS_PER_FLOOR := 8
const DOOR_SPACING := 2.2
const TARGET_DOOR_INDEX := 3 # 0-based → 604호

var door_position := Vector3.ZERO # DeliveryZone 배치용으로 레벨 스크립트에 공개.


func _ready() -> void:
	_lobby()
	for floor_index in range(1, TARGET_FLOOR + 1):
		_flight(floor_index)
	_corridor(TARGET_FLOOR)
	_exterior_shell()


func _lobby() -> void:
	_box("LobbyFloor", Vector3(0, -0.1, 4.0), Vector3(8, 0.2, 8), "b9ad91")
	for x in [-4.0, 4.0]:
		_box("LobbyWall", Vector3(x, 1.6, 4.0), Vector3(0.2, 3.2, 8), "8d9388")
	_box("LobbyBack", Vector3(-2.4, 1.6, 8.0), Vector3(3.2, 3.2, 0.2), "8d9388")
	_box("LobbyBack2", Vector3(2.4, 1.6, 8.0), Vector3(3.2, 3.2, 0.2), "8d9388")
	# 고장 표시 엘리베이터: 상호작용 없는 순수 장식.
	_box("ElevatorDoor", Vector3(3.2, 1.3, 7.85), Vector3(1.6, 2.4, 0.15), "555b60")
	_add_sign("고장\n계단 이용", Vector3(3.2, 2.3, 7.6), 0.0, 20)
	_add_sign("행복아파트 · 엘리베이터 점검 중\n비상계단으로 이용해 주세요", Vector3(0, 2.8, 0.5), PI, 26)
	_add_sign("6층 604호 배송", Vector3(0, 2.2, 1.5), PI, 22)


func _flight(floor_index: int) -> void:
	var base_y := float(floor_index - 1) * FLOOR_HEIGHT
	var y := base_y
	var z := Z_NEAR
	# 반 층: 진입 층계참에서 중간 층계참까지 (x = -FLIGHT_X 쪽).
	_landing(Vector3(0, y, z), "Landing%d_Near" % floor_index)
	for step_index in HALF_STEPS:
		y += STEP_RISE
		z += STEP_RUN
		_step(Vector3(-FLIGHT_X, y, z))
	# 중간 층계참(꺾이는 지점).
	_landing(Vector3(0, y, Z_FAR), "Landing%d_Mid" % floor_index)
	# 반 층: 중간 층계참에서 다음 층 진입 층계참까지 (x = +FLIGHT_X 쪽, 반대 방향으로 오른다).
	for step_index in HALF_STEPS:
		y += STEP_RISE
		z -= STEP_RUN
		_step(Vector3(FLIGHT_X, y, z))
	if floor_index == TARGET_FLOOR:
		_landing(Vector3(0, y, Z_NEAR), "Landing%d_Top" % floor_index, 2.4)
	else:
		_landing(Vector3(0, y, Z_NEAR), "Landing%d_Top" % floor_index)


func _corridor(floor_index: int) -> void:
	# 편복도: 한쪽 벽에 세대 문이 늘어서 있고 반대쪽은 계단실 층계참으로 그대로 이어진다
	# (실제로 겹치지 않도록 좌표를 계산해 확인 — 처음에는 복도와 층계참 사이에 걸어갈 수 없는
	# 틈이 생기는 배치 오류가 있었다).
	var y := float(floor_index) * FLOOR_HEIGHT
	var length := DOORS_PER_FLOOR * DOOR_SPACING
	var start_x := -length / 2.0 + DOOR_SPACING / 2.0
	var door_wall_z := Z_NEAR - 3.4
	var open_z := Z_NEAR + 0.2 # 층계참과 겹치도록 살짝 넘겨서 이어붙인다.
	var center_z := (door_wall_z + open_z) / 2.0
	var depth := open_z - door_wall_z
	_box("CorridorFloor", Vector3(0, y - 0.1, center_z), Vector3(length + 1.0, 0.2, depth), "9a8465")
	_box("CorridorDoorWall", Vector3(0, y + 1.4, door_wall_z), Vector3(length + 1.0, 2.8, 0.2), "c9cfce")
	for i in DOORS_PER_FLOOR:
		var door_x := start_x + i * DOOR_SPACING
		var unit_number := floor_index * 100 + i + 1
		_box("Door%d" % unit_number, Vector3(door_x, y + 1.1, door_wall_z + 0.15), Vector3(0.9, 2.2, 0.08), "6b5a4f")
		_add_sign(str(unit_number) + "호", Vector3(door_x, y + 2.4, door_wall_z + 0.2), 0.0, 16)
		if i == TARGET_DOOR_INDEX:
			door_position = Vector3(door_x, y + 0.9, door_wall_z + 0.9)


func _step(at: Vector3) -> void:
	_box("Step", at, Vector3(1.1, STEP_RISE, STEP_RUN), "9a8465")
	for side in [-1, 1]:
		_box("StepRail", at + Vector3(side * 0.55, RAIL_HEIGHT / 2.0, 0), Vector3(0.1, RAIL_HEIGHT, STEP_RUN), "6b6f73")


func _landing(at: Vector3, id: String, depth: float = 1.2) -> void:
	_box(id, at, Vector3(SHAFT_HALF_WIDTH * 2.0, 0.2, depth), "9a8465")
	for side in [-1, 1]:
		_box(id + "Rail", at + Vector3(side * SHAFT_HALF_WIDTH, RAIL_HEIGHT / 2.0 + 0.1, 0), Vector3(0.1, RAIL_HEIGHT, depth), "6b6f73")


func _exterior_shell() -> void:
	# 실제로 올라갈 수 있는 건 목표 층까지지만, 11층 건물이라는 설정을 시각적으로 보여주기
	# 위해 목표 층 지붕 위쪽에만 나머지 층 매스를 띄워 둔다. 로비/계단실/복도 위에 겹쳐서
	# 만들면 실내 공간을 그대로 막아버리는 결함이 있어(직접 확인 후 수정) 반드시 그 위층
	# 천장보다 높은 지점부터만 배치한다 — 실내 충돌과 절대 겹치지 않는다.
	var roof_y := float(TARGET_FLOOR) * FLOOR_HEIGHT + 2.8
	var upper_floors := TOTAL_FLOORS - TARGET_FLOOR
	var upper_height := upper_floors * FLOOR_HEIGHT
	_box("UpperFloorsMass", Vector3(0, roof_y + upper_height / 2.0, 4.0), Vector3(9, upper_height, 9), "c7c2b4")
	_add_sign("행복아파트 · 11층", Vector3(0, roof_y + 1.2, 0.05), PI, 32)
	_building_skin(roof_y)


func _building_skin(roof_y: float) -> void:
	# 1~TARGET_FLOOR층 외벽. 실내(로비/계단실/복도)보다 바깥쪽에 배치해 절대 겹치지 않게 한다.
	# 배경 건물/창문 등 디테일은 다음 작업으로 미루고, 지금은 뼈대만 감싸는 최소 껍데기다.
	var half_x := 9.5
	var z_back := 12.0
	var z_front := -1.0
	var mid_y := roof_y / 2.0
	var depth := z_back - z_front
	var z_center := (z_back + z_front) / 2.0
	_box("SkinWest", Vector3(-half_x, mid_y, z_center), Vector3(0.3, roof_y, depth), "c7c2b4")
	_box("SkinEast", Vector3(half_x, mid_y, z_center), Vector3(0.3, roof_y, depth), "c7c2b4")
	_box("SkinBack", Vector3(0, mid_y, z_back), Vector3(half_x * 2.0, roof_y, 0.3), "c7c2b4")
	var gap := 6.0
	var panel_width := (half_x * 2.0 - gap) / 2.0
	var panel_x := gap / 2.0 + panel_width / 2.0
	_box("SkinFrontLeft", Vector3(-panel_x, mid_y, z_front), Vector3(panel_width, roof_y, 0.3), "c7c2b4")
	_box("SkinFrontRight", Vector3(panel_x, mid_y, z_front), Vector3(panel_width, roof_y, 0.3), "c7c2b4")


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
	# Label3D 자체가 양면에서 보이므로 한 장만 만들면 충분하다(villa-77에서 실제 렌더링으로 확인).
	var label := Label3D.new()
	label.text = value
	label.position = at
	label.rotation.y = yaw
	label.font_size = font_size
	label.pixel_size = 0.005
	label.modulate = Color("fff1c8")
	label.outline_size = 0
	add_child(label)
