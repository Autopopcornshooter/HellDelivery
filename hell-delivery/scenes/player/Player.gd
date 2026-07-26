class_name Player
extends CharacterBody3D

@export var walk_speed: float = 4.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var acceleration: float = 20.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var deceleration: float = 25.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var jump_velocity: float = 6.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var sprint_speed: float = 7.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var mouse_sensitivity: float = 0.003 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var min_pitch: float = -80.0 # degrees, 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var max_pitch: float = 55.0 # degrees, 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var push_force: float = 220.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료 — Package 정지마찰 저항 ≈103N을 확실히 넘도록 설정)
@export var max_push_speed: float = 2.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)

const _DETECT_LOS_MASK: int = 21 # World(1) + Package(4) + PhysicsObject(16). GrabbableBody의 _STATIC_BLOCK_MASK와는 목적이 다르다(감지 차폐 판정 vs Hold 정적 차단 판정) — T071에서 값 그대로 유지.

# 조준점(Crosshair) UI가 참조하는 상태값 — 실제 Grab 판정(_detected_grabbable/held_grabbable)과
# 동일한 데이터에서만 파생시킨다(UI 전용 별도 탐색을 하지 않는다, T073).
const GRAB_AIM_NONE: int = 0
const GRAB_AIM_TARGETING: int = 1
const GRAB_AIM_HOLDING: int = 2

signal grab_aim_state_changed(state: int)

@onready var camera_pivot: Node3D = $CameraPivot
@onready var grab_shape_cast: ShapeCast3D = $CameraPivot/GrabShapeCast
@onready var hold_point: Node3D = $CameraPivot/HoldPoint
@onready var grab_collision_barrier: AnimatableBody3D = $GrabCollisionBarrier

var _gravity: float = 0.0
var _detected_grabbable: GrabbableBody = null
var _detected_grab_point: Vector3 = Vector3.ZERO
var held_grabbable: GrabbableBody = null
var _last_grab_aim_state: int = -1

# `interact`(E)는 현재 아무 동작도 하지 않는다 — 향후 버튼/문/레버 등 범용 상호작용(그랩과 무관)을 위해 예약된 입력이다(T071).


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# 1인칭 전환(T073): 좌우 회전은 Player 본체의 yaw, 상하 회전만 CameraPivot의 pitch로 분리한다
		# (기존에는 CameraPivot이 좌우/상하를 모두 가져 이동 방향 계산에도 CameraPivot.basis를
		# 썼으나, 이제 Player.basis 자체가 바라보는 방향이 된다 — _physics_process() 참고).
		rotation.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	elif event.is_action_pressed("release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y) # T073: yaw가 Player 자신에 있으므로 자신의 basis를 사용
	direction.y = 0.0
	direction = direction.normalized()

	var current_speed := sprint_speed if Input.is_action_pressed("sprint") else walk_speed
	var target_horizontal_velocity := direction * current_speed
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var speed_change := acceleration if direction.length() > 0.0 else deceleration
	horizontal_velocity = horizontal_velocity.move_toward(target_horizontal_velocity, speed_change * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	var intended_horizontal_velocity := horizontal_velocity
	move_and_slide()
	# AnimatableBody3D(GrabCollisionBarrier)는 sync_to_physics 특성상 일반 자식 노드처럼 부모
	# Transform을 자동으로 따라가지 않는다 — 매 물리 프레임 명시적으로 Player를 따라가도록
	# 직접 옮겨줘야 실제로 Player 위치에서 충돌 반응을 낸다(T072 결함 수정에서 발견). Barrier는
	# 원기둥이라 yaw 회전이 섞여도 형태에 영향이 없다.
	grab_collision_barrier.global_transform = global_transform
	_update_grab_detection()
	_handle_grab_input()
	_report_grab_aim_state()
	_push_away_rigid_bodies(intended_horizontal_velocity)


func _push_away_rigid_bodies(intended_horizontal_velocity: Vector3) -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if not (collider is RigidBody3D):
			continue
		if collider == held_grabbable:
			continue # 잡고 있는 Grabbable은 물리 추종이 담당하므로 push 보조를 중복 적용하지 않음
		var normal := collision.get_normal()
		if absf(normal.y) > 0.5:
			continue # 위/아래에 가까운 접촉(예: 상자 위에 서 있는 경우)은 밀지 않음
		var push_direction := Vector3(-normal.x, 0.0, -normal.z).normalized()
		if intended_horizontal_velocity.dot(push_direction) <= 0.0:
			continue # Player가 실제로 그 방향으로 이동 중일 때만 민다
		if collider.linear_velocity.dot(push_direction) >= max_push_speed:
			continue # 이미 충분히 밀려나고 있으면 추가하지 않음
		collider.apply_central_impulse(push_direction * push_force * get_physics_process_delta_time())


func _has_line_of_sight_to(target: Node3D) -> bool:
	# ShapeCast는 사거리 안 후보만 찾는다. 벽이나 다른 Grabbable이 먼저 막고 있으면
	# 후보에서 제외하기 위한 별도 Ray Query(T065에서 도입, T071에서 Grabbable 전체로 확장).
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(grab_shape_cast.global_position, target.global_position, _DETECT_LOS_MASK, [get_rid()])
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.get("collider") == target


func _update_grab_detection() -> void:
	_detected_grabbable = null
	_detected_grab_point = Vector3.ZERO
	if not grab_shape_cast.is_colliding():
		return

	var best: GrabbableBody = null
	var best_point: Vector3 = Vector3.ZERO
	var best_distance: float = INF
	for i in grab_shape_cast.get_collision_count():
		var collider := grab_shape_cast.get_collider(i)
		if collider is GrabbableBody and _has_line_of_sight_to(collider):
			var distance := grab_shape_cast.global_position.distance_to(collider.global_position)
			if distance < best_distance:
				best_distance = distance
				best = collider
				best_point = grab_shape_cast.get_collision_point(i) # 실제 충돌 표면 지점 — Grab Point로 사용(물체 중심이 아님)
	_detected_grabbable = best
	_detected_grab_point = best_point


func _handle_grab_input() -> void:
	if held_grabbable != null and (not is_instance_valid(held_grabbable) or not held_grabbable.has_grabber(self)):
		held_grabbable = null # 다른 사유(정적 차단/거리 초과)로 연결이 이미 해제된 경우 — 새 just_pressed 없이는 재잡기하지 않는다.

	if Input.is_action_just_pressed("grab_object"):
		if held_grabbable == null and _detected_grabbable != null:
			if _detected_grabbable.add_grabber(self, hold_point, _detected_grab_point):
				held_grabbable = _detected_grabbable
	elif Input.is_action_just_released("grab_object"):
		if held_grabbable != null:
			held_grabbable.remove_grabber(self)
			held_grabbable = null


func _report_grab_aim_state() -> void:
	# 조준점 UI(DeliveryHUD/Crosshair)에 전달할 상태 — 위 _update_grab_detection()/_handle_grab_input()이
	# 이미 계산해 둔 _detected_grabbable/held_grabbable을 그대로 재사용한다(T073, 중복 탐색 없음).
	var state: int = GRAB_AIM_NONE
	if held_grabbable != null:
		state = GRAB_AIM_HOLDING
	elif _detected_grabbable != null:
		state = GRAB_AIM_TARGETING
	if state == _last_grab_aim_state:
		return
	_last_grab_aim_state = state
	grab_aim_state_changed.emit(state)
