class_name Player
extends CharacterBody3D

enum InputProfile { KEYBOARD_MOUSE, GAMEPAD } # T074: 로컬 협동에서 Player마다 다른 입력 장치를 쓰기 위한 슬롯 설정.

@export var player_slot: int = 0 # T074: 0=P1, 1=P2... 로컬 협동에서 자기 Mesh를 숨기는 시각 레이어를 슬롯별로 다르게 계산하는 데만 사용(그 외 게임플레이 로직에는 영향 없음).
@export var input_profile: InputProfile = InputProfile.KEYBOARD_MOUSE # T074: 기본값은 기존 싱글플레이와 완전히 동일(키보드+마우스).
@export var gamepad_device: int = 0 # T074: input_profile이 GAMEPAD일 때 사용할 장치 인덱스(Input.get_joy_axis/is_joy_button_pressed에 전달).
@export var gamepad_look_sensitivity: float = 2.5 # T074에서 사용자 승인된 프로토타입 기준값(TECH_DEBT.md TD-014) — 오른쪽 스틱 회전 감도(초당 라디안 기준, 마우스 델타와 달리 delta를 직접 곱해야 함).
@export var move_deadzone: float = 0.2 # T075: 왼쪽 스틱(이동) 전용 deadzone — T074의 gamepad_deadzone을 이동/시점용으로 분리.
@export var look_deadzone: float = 0.2 # T075: 오른쪽 스틱(시점) 전용 deadzone.
@export var invert_gamepad_y: bool = false # T075: 오른쪽 스틱 상하 반전 옵션.
@export var gamepad_grab_trigger_threshold: float = 0.5 # T075: 오른쪽 트리거(아날로그, 0~1)를 "누름"으로 판정하는 임계값.

@export var walk_speed: float = 4.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var acceleration: float = 20.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var deceleration: float = 25.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var jump_velocity: float = 6.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var sprint_speed: float = 7.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var mouse_sensitivity: float = 0.003 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var min_pitch: float = -80.0 # degrees, 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var max_pitch: float = 55.0 # degrees, 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var push_force: float = 220.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료 — Package 정지마찰 저항 ≈103N을 확실히 넘도록 설정)
@export var push_mass: float = 70.0 # TODO: 프로토타입 값, 실측 재검증 필요 — Player가 몸으로 미는 상호작용에서만 쓰는 유효 질량(운동량 보존 계산 전용, CharacterBody3D 자체의 물리 질량이 아니다). _apply_push_resistance() 결함 수정(질량 무시 문제) 참고.

const _DETECT_LOS_MASK: int = 21 # World(1) + Package(4) + PhysicsObject(16). GrabbableBody의 _STATIC_BLOCK_MASK와는 목적이 다르다(감지 차폐 판정 vs Hold 정적 차단 판정) — T071에서 값 그대로 유지.

# 조준점(Crosshair) UI가 참조하는 상태값 — 실제 Grab 판정(_detected_grabbable/held_grabbable)과
# 동일한 데이터에서만 파생시킨다(UI 전용 별도 탐색을 하지 않는다, T073).
const GRAB_AIM_NONE: int = 0
const GRAB_AIM_TARGETING: int = 1
const GRAB_AIM_HOLDING: int = 2

signal grab_aim_state_changed(state: int)
signal grab_connection_lost(reason: int) # T075: 이 Player 자신의 Grab 연결이 해제됐을 때(사유 포함) — UI가 짧은 Release 피드백을 표시하는 데 사용.

@onready var camera_pivot: Node3D = $CameraPivot
@onready var grab_shape_cast: ShapeCast3D = $CameraPivot/GrabShapeCast
@onready var hold_point: Node3D = $CameraPivot/HoldPoint
@onready var grab_collision_barrier: AnimatableBody3D = $GrabCollisionBarrier

var _gravity: float = 0.0
var _detected_grabbable: GrabbableBody = null
var _detected_grab_point: Vector3 = Vector3.ZERO
var held_grabbable: GrabbableBody = null
var _last_grab_aim_state: int = -1
var _active_pushes: Array = [] # 직전 프레임에 실제로 밀고 있던 대상 기록: {push_direction: Vector3, mass: float}. 이번 프레임 _apply_push_resistance()가 Player 자신의 속도를 줄이는 데 사용한다.
var _gamepad_grab_was_pressed: bool = false
var _gamepad_grab_just_pressed: bool = false
var _gamepad_grab_just_released: bool = false

# `interact`(E)는 현재 아무 동작도 하지 않는다 — 향후 버튼/문/레버 등 범용 상호작용(그랩과 무관)을 위해 예약된 입력이다(T071).


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	if input_profile == InputProfile.KEYBOARD_MOUSE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_apply_visual_layer_for_slot()
	_apply_settings()
	GameSettings.settings_changed.connect(_apply_settings)


func _apply_settings() -> void:
	# T079: 마우스/게임패드 감도·Y축 반전만 GameSettings(Autoload)에서 실시간으로 반영한다 —
	# 이동 속도·Grab Force 등 물리값은 여기서 전혀 건드리지 않는다. P1/P2 모두 같은 전역 설정을
	# 그대로 받되, KEYBOARD_MOUSE는 mouse_sensitivity만, GAMEPAD는 나머지 두 값만 실제로
	# 쓰이므로(각자의 입력 분기 코드 참고) 서로의 입력 독립성에는 영향이 없다.
	mouse_sensitivity = GameSettings.mouse_sensitivity
	gamepad_look_sensitivity = GameSettings.gamepad_look_sensitivity
	invert_gamepad_y = GameSettings.invert_gamepad_y


func _apply_visual_layer_for_slot() -> void:
	# 로컬 협동(T074)에서 여러 Player 인스턴스가 같은 시각 레이어를 공유하면 서로의 모델이
	# 안 보이게 되는 문제가 있다(T073 "남은 위험"에서 이미 예견됨). player_slot마다 다른 레이어를
	# 계산해 "자기 카메라에서만 자기 모델을 숨긴다"를 인스턴스별로 성립시킨다.
	# slot 0(기본값, 기존 싱글플레이)의 계산 결과는 T073의 기존 고정값(layers=2, cull_mask=1048573)과
	# 완전히 동일해, 싱글플레이 동작은 그대로 유지된다.
	var mesh: MeshInstance3D = $MeshInstance3D
	var own_layer_bit: int = 1 << (1 + player_slot) # slot 0 -> layer 2(bit1), slot 1 -> layer 3(bit2), ...
	mesh.layers = own_layer_bit
	var camera: Camera3D = camera_pivot.get_node("Camera3D")
	camera.cull_mask = 0xFFFFF & ~own_layer_bit # 0xFFFFF = 20개 시각 레이어 전체(T073 cull_mask=1048573=0xFFFFD와 동일 기준)


func _unhandled_input(event: InputEvent) -> void:
	if input_profile != InputProfile.KEYBOARD_MOUSE:
		return # T074: 게임패드 슬롯은 마우스/키보드 이벤트에 전혀 반응하지 않는다(입력 독립성).
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


func _get_movement_input_2d() -> Vector2:
	if input_profile == InputProfile.GAMEPAD:
		var raw := Vector2(Input.get_joy_axis(gamepad_device, JOY_AXIS_LEFT_X), Input.get_joy_axis(gamepad_device, JOY_AXIS_LEFT_Y))
		if raw.length() < move_deadzone:
			return Vector2.ZERO
		return raw
	return Input.get_vector("move_left", "move_right", "move_forward", "move_backward")


func _apply_gamepad_look(delta: float) -> void:
	if input_profile != InputProfile.GAMEPAD:
		return # T074: 키보드+마우스 슬롯은 _unhandled_input()의 마우스 모션이 회전을 담당(여기서는 아무것도 하지 않음).
	var look := Vector2(Input.get_joy_axis(gamepad_device, JOY_AXIS_RIGHT_X), Input.get_joy_axis(gamepad_device, JOY_AXIS_RIGHT_Y))
	if absf(look.x) < look_deadzone:
		look.x = 0.0
	if absf(look.y) < look_deadzone:
		look.y = 0.0
	var y_sign := -1.0 if invert_gamepad_y else 1.0
	rotation.y -= look.x * gamepad_look_sensitivity * delta
	camera_pivot.rotation.x -= look.y * y_sign * gamepad_look_sensitivity * delta
	camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))


func _update_gamepad_grab_edge() -> void:
	if input_profile != InputProfile.GAMEPAD:
		_gamepad_grab_just_pressed = false
		_gamepad_grab_just_released = false
		return
	# T075: 오른쪽 트리거(기본 입력)와 A 버튼(보조 입력)을 OR로 합쳐 단일 상태로 취급한다 —
	# 두 입력이 동시에 눌리거나, 한쪽을 누른 채 다른 쪽만 놓아도(둘 중 하나라도 눌려 있으면
	# "누른 상태") Connection이 중복 생성되거나 조기에 Release되지 않는다(둘 다 떼야 놓임).
	var trigger_pressed := Input.get_joy_axis(gamepad_device, JOY_AXIS_TRIGGER_RIGHT) > gamepad_grab_trigger_threshold
	var button_pressed := Input.is_joy_button_pressed(gamepad_device, JOY_BUTTON_A)
	var pressed := trigger_pressed or button_pressed
	_gamepad_grab_just_pressed = pressed and not _gamepad_grab_was_pressed
	_gamepad_grab_just_released = not pressed and _gamepad_grab_was_pressed
	_gamepad_grab_was_pressed = pressed


func _physics_process(delta: float) -> void:
	_update_gamepad_grab_edge()
	_apply_gamepad_look(delta)

	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		if velocity.y < 0.0:
			velocity.y = 0.0
		# T074: `jump`/`sprint`는 키보드 전용 액션이라 전역 Input 상태다 — 게이트하지 않으면
		# 다른 Player가 Space/Shift를 누르는 것만으로 이 인스턴스도 점프·질주해버린다(입력 독립성 위반).
		if input_profile == InputProfile.KEYBOARD_MOUSE and Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity

	var input_dir := _get_movement_input_2d()
	var direction := transform.basis * Vector3(input_dir.x, 0.0, input_dir.y) # T073: yaw가 Player 자신에 있으므로 자신의 basis를 사용
	direction.y = 0.0
	direction = direction.normalized()

	var is_sprinting := input_profile == InputProfile.KEYBOARD_MOUSE and Input.is_action_pressed("sprint")
	var current_speed := sprint_speed if is_sprinting else walk_speed
	var target_horizontal_velocity := direction * current_speed
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	var speed_change := acceleration if direction.length() > 0.0 else deceleration
	horizontal_velocity = horizontal_velocity.move_toward(target_horizontal_velocity, speed_change * delta)
	horizontal_velocity = _apply_push_resistance(horizontal_velocity)
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


func _apply_push_resistance(horizontal_velocity: Vector3) -> Vector3:
	# CharacterBody3D(kinematic)는 무엇에 부딪히든 항상 자기 속도 그대로 전진하고, Godot/Jolt의
	# 침투 해소는 RigidBody를 그 속도에 맞춰 매 프레임 다시 밀어붙인다(엔진의 raw 접촉 해석 —
	# DD-006 참고, 헤드리스 실측으로 재확인: 정지마찰 245N이 push_force 220N을 넘는 25kg Crate조차
	# 6m/s 이상으로 밀림). RigidBody의 linear_velocity를 읽어 "직전 속도"로 되먹임하는 방식은 그
	# 값 자체가 이미 이 raw 보정으로 오염돼 있어(질량과 무관하게 거의 Player 속도를 그대로 반영)
	# 보정이 누적되지 않음을 실측으로 확인했다. 따라서 RigidBody의 속도를 전혀 참조하지 않고,
	# Player 자신의 전진 속도 자체를 push_mass와 대상 질량의 비율(reduced mass 비율)로 직접
	# 낮춘다 — 무거운 대상을 밀 때는 Player 자신도 함께 느려지므로, 엔진의 raw 보정이 그 뒤를
	# 따라가는 RigidBody 속도도 자연히 낮아진다(실제로 무거운 물체를 미는 감각과 동일).
	var result := horizontal_velocity
	for push in _active_pushes:
		var push_direction: Vector3 = push.push_direction
		var object_mass: float = push.mass
		var current_component := result.dot(push_direction)
		if current_component <= 0.0:
			continue # 그 방향으로 이동 중이 아니면(예: 이미 반대로 이동) 저항을 적용하지 않는다
		var capped_component: float = current_component * (push_mass / (push_mass + object_mass))
		if capped_component < current_component:
			result += push_direction * (capped_component - current_component)
	return result


func _push_away_rigid_bodies(intended_horizontal_velocity: Vector3) -> void:
	_active_pushes.clear()
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if not (collider is RigidBody3D):
			continue
		if collider is GrabbableBody and collider.has_grabber(self):
			continue # 이 Player가 Grab 중인 Grabbable은 Spring-Damper Grab이 담당하므로 Body Push를 중복 적용하지 않음
		var normal := collision.get_normal()
		if absf(normal.y) > 0.5:
			continue # 위/아래에 가까운 접촉(예: 상자 위에 서 있는 경우)은 밀지 않음
		var push_direction := Vector3(-normal.x, 0.0, -normal.z).normalized()
		if intended_horizontal_velocity.dot(push_direction) <= 0.0:
			continue # Player가 실제로 그 방향으로 이동 중일 때만 민다

		# 현재 잡고 있는 물체가 이 대상과 이미 물리적으로 접촉해 Spring-Damper 힘을 전달하고
		# 있다면, 여기서 또 push_force를 더하지 않는다 — 같은 대상에 두 채널(Body Push +
		# Grab Spring)의 힘이 동시에 중복 적용되는 것을 막기 위함(held object가 대상에 닿기 전까지는
		# 평소와 동일하게 push_force가 적용된다). Player 자신의 감속(_apply_push_resistance)은
		# Player 몸이 실제로 이 대상과 접촉했다는 사실 자체는 그대로 반영해야 하므로 아래
		# _active_pushes 기록은 이 경우에도 그대로 수행한다.
		var already_pushed_via_grab: bool = held_grabbable != null and held_grabbable.is_touching(collider)
		if not already_pushed_via_grab:
			# 모든 대상에 항상 동일한 push_force를 힘으로 가한다(질량과 무관하게 같은 물리량) —
			# a = F/mass가 자연히 성립해 무거운 RigidBody일수록 느리게 가속된다. 실제 무게 차이는
			# 위 _apply_push_resistance()(다음 프레임 Player 감속)가 담당하므로 이 힘은 보조적이다.
			collider.apply_central_force(push_direction * push_force)

		_active_pushes.append({
			"push_direction": push_direction,
			"mass": collider.mass,
		})


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

	# T074: `grab_object`는 마우스 왼쪽 버튼 전용 액션이라 게임패드 슬롯에는 아예 대응되지 않고,
	# 게임패드 슬롯의 버튼 입력도 이 전역 액션에는 반영되지 않는다 — 두 채널이 이미 서로 독립적이다.
	var just_pressed: bool = Input.is_action_just_pressed("grab_object") if input_profile == InputProfile.KEYBOARD_MOUSE else _gamepad_grab_just_pressed
	var just_released: bool = Input.is_action_just_released("grab_object") if input_profile == InputProfile.KEYBOARD_MOUSE else _gamepad_grab_just_released

	if just_pressed:
		if held_grabbable == null and _detected_grabbable != null:
			if _detected_grabbable.add_grabber(self, hold_point, _detected_grab_point):
				held_grabbable = _detected_grabbable
				# T075: Release 피드백(사유 구분)을 위해, 이 물체가 "이 Player"의 연결을 해제할 때
				# 알려주도록 연결한다. 같은 물체를 다시 잡을 때 중복 연결되지 않도록 확인 후 연결.
				if not held_grabbable.grabber_disconnected.is_connected(_on_held_grabbable_disconnected):
					held_grabbable.grabber_disconnected.connect(_on_held_grabbable_disconnected)
	elif just_released:
		if held_grabbable != null:
			held_grabbable.remove_grabber(self)
			held_grabbable = null


func _on_held_grabbable_disconnected(grabber: Node3D, reason: int) -> void:
	# T075: 같은 시그널이 다른 Grabber(예: 협동 중인 다른 Player)의 해제에도 발신되므로,
	# 반드시 "나 자신"의 연결이 해제된 경우만 걸러서 UI에 전달한다(_detected_grabbable/
	# held_grabbable과 마찬가지로 이 Player 인스턴스 스스로만 판단, 다른 Player 상태에 관여하지 않음).
	if grabber != self:
		return
	grab_connection_lost.emit(reason)


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
