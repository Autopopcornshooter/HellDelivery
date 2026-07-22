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
@export var throw_impulse_strength: float = 200.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료 — 수평 비행거리 약 4m)

const _INTERACT_LOS_MASK: int = 21 # World(1) + Package(4) + PhysicsObject(16). Package.gd의 _HOLD_LOS_MASK와 동일한 값을 별도 상수로 중복 선언(공용 시스템 신설 방지, T065).

@onready var camera_pivot: Node3D = $CameraPivot
@onready var interact_shape_cast: ShapeCast3D = $CameraPivot/InteractShapeCast
@onready var hold_point: Node3D = $CameraPivot/HoldPoint

var _gravity: float = 0.0
var _detected_package: Package = null # DEBUG: 감지 확인용 상태, T042 이전 제거 여부 결정
var held_package: Package = null


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity
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
	var direction := camera_pivot.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
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
	_update_interact_detection()
	_handle_interact_input()
	_handle_throw_input()
	_push_away_rigid_bodies(intended_horizontal_velocity)


func _push_away_rigid_bodies(intended_horizontal_velocity: Vector3) -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if not (collider is RigidBody3D):
			continue
		if collider == held_package:
			continue # 잡고 있는 Package는 물리 추종이 담당하므로 push 보조를 중복 적용하지 않음
		var normal := collision.get_normal()
		if absf(normal.y) > 0.5:
			continue # 위/아래에 가까운 접촉(예: 상자 위에 서 있는 경우)은 밀지 않음
		var push_direction := Vector3(-normal.x, 0.0, -normal.z).normalized()
		if intended_horizontal_velocity.dot(push_direction) <= 0.0:
			continue # Player가 실제로 그 방향으로 이동 중일 때만 민다
		if collider.linear_velocity.dot(push_direction) >= max_push_speed:
			continue # 이미 충분히 밀려나고 있으면 추가하지 않음
		collider.apply_central_impulse(push_direction * push_force * get_physics_process_delta_time())


func _get_detected_package() -> Package:
	if not interact_shape_cast.is_colliding():
		return null
	for i in interact_shape_cast.get_collision_count():
		var collider := interact_shape_cast.get_collider(i)
		if collider is Package and _has_line_of_sight_to(collider):
			return collider
	return null


func _has_line_of_sight_to(target: Node3D) -> bool:
	# ShapeCast는 사거리 안 후보만 찾는다. 벽 등 물리적 차단물이 먼저 막고 있으면
	# 후보에서 제외하기 위한 별도 Ray Query(T065, 벽 너머 Package 잡기 버그 수정).
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(interact_shape_cast.global_position, target.global_position, _INTERACT_LOS_MASK, [get_rid()])
	var result := space_state.intersect_ray(query)
	if result.is_empty():
		return true
	return result.get("collider") == target


func _update_interact_detection() -> void:
	# DEBUG: 감지 확인용 로그. T042 이전 제거하거나 실제 감지 로직에 영향 없는 형태로 유지
	var package := _get_detected_package()
	if package == _detected_package:
		return
	if package != null:
		print("Package detected")
	else:
		print("Package lost")
	_detected_package = package


func _handle_interact_input() -> void:
	if held_package != null and (not is_instance_valid(held_package) or not held_package.is_held):
		held_package = null

	if Input.is_action_just_pressed("interact") and held_package == null:
		if _detected_package != null and _detected_package.grab(hold_point, self):
			held_package = _detected_package
	elif Input.is_action_just_released("interact") and held_package != null:
		held_package.release()
		held_package = null


func _handle_throw_input() -> void:
	if held_package == null:
		return
	if not Input.is_action_just_pressed("throw_package"):
		return
	var direction := -camera_pivot.global_transform.basis.z
	if held_package.throw(direction, throw_impulse_strength):
		held_package = null
