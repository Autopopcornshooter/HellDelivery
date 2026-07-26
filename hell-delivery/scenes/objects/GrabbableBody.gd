class_name GrabbableBody
extends RigidBody3D

# Force-Based Physics Grab(T072): 플레이어는 위치나 속도를 직접 제어하지 않는다.
# 각 Grabber는 실제로 잡은 표면 지점(local_grab_point)에 제한된 Spring-Damper 힘만 가하고,
# 물체는 항상 정상적인 RigidBody3D로서 gravity/mass/충돌의 영향을 그대로 받는다.

@export var grab_spring_strength: float = 500.0 # TODO: 프로토타입 값, 실측 재검증 필요 — Grab Point를 HandPoint로 끌어당기는 스프링 상수(공유, 오브젝트별 배율 없음). mass가 클수록 평형 처짐(mass*gravity/k)이 커져 무게감이 자연히 발생한다.
@export var grab_damping: float = 60.0 # TODO: 프로토타입 값, 실측 재검증 필요 — 진동 억제 계수(공유). 질량이 클수록 임계감쇠비(2*sqrt(k*mass))가 커지므로, 같은 감쇠값에서 무거운 물체일수록 상대적으로 더 크게 출렁인다.
@export var max_force_per_grabber: float = 300.0 # TODO: 프로토타입 값, 실측 재검증 필요 — Grabber 한 명이 낼 수 있는 최대 힘(N). 여러 Grabber는 각자 이 상한 안에서 독립적으로 힘을 내며, 물체에는 합산된 힘이 적용된다(협동 효과는 이 합산에서만 발생, 별도 배율 없음).
@export var max_spring_distance: float = 2.5 # Spring 힘 계산에 사용하는 displacement 상한(2차 안전장치 — 대부분의 경우 max_force_per_grabber가 먼저 힘을 제한한다).
@export var max_grab_distance: float = 3.0 # 연결을 유지할 수 있는 실제 최대 거리(기존 max_hold_distance 값 승계).
@export var max_target_speed: float = 15.0 # HandPoint 순간 이동/저프레임으로 인한 속도 폭주 방지 상한.

const _HOLD_BLOCKED_RELEASE_FRAMES: int = 3 # 연속 몇 프레임 정적 차단이 유지되어야 해당 연결만 해제할지(한 프레임짜리 접촉/모서리 오차 무시).
const _STATIC_BLOCK_MASK: int = 1 # World만. 다른 Grabbable(동적 RigidBody)은 차단 사유에서 제외 — 동적 오브젝트끼리 접촉만으로 연결이 끊기지 않게 한다(T071에서 도입한 정적/동적 분리를 유지).
const _TARGET_VELOCITY_SMOOTH_FACTOR: float = 0.35 # HandPoint 속도 측정 노이즈 완화(지수평활, 최근 3~5 physics frame 반영).
const _MAX_DELTA: float = 0.1 # 비정상적으로 큰 delta(프레임 드롭 등) 방어.
const _GRAB_BARRIER_MASK_BIT: int = 32 # collision_layer 6(GrabCollisionBarrier). Grab 중에만 이 비트를 추가해 실제 Grabber 몸 대신 그 전용 Barrier와만 충돌하게 한다(T072 결함 수정 — Player가 밀리는 문제).
const _RESTORE_SEPARATION_FRAMES: int = 3 # 연속 몇 프레임 분리가 확인되어야 collision exception/Barrier mask를 복구할지.
const _RESTORE_WARN_FRAMES: int = 300 # 약 5초. 분리가 이보다 오래 걸리면 경고 1회 출력.

const _MARKER_RADIUS: float = 0.04 # T075: Grab Point 표시용 절차적 마커 반지름 — 물리에는 전혀 관여하지 않음(CollisionShape 없음).

enum DisconnectReason { MANUAL, DISTANCE_EXCEEDED, BLOCKED } # T075: Release 피드백 UI가 원인을 구분할 수 있도록 함.

signal grabber_disconnected(grabber: Node3D, reason: int) # T075: 각 Player의 Crosshair가 자기 연결이 해제된 이유를 받아 짧은 피드백을 표시하는 데 사용.


class _GrabConnection:
	var grabber: Node3D
	var target_point: Node3D
	var local_grab_point: Vector3 = Vector3.ZERO
	var max_force: float = 0.0
	var prev_target_position: Vector3 = Vector3.ZERO
	var smoothed_target_velocity: Vector3 = Vector3.ZERO
	var block_streak: int = 0


class _PendingRestore:
	var grabber: CollisionObject3D
	var separation_streak: int = 0
	var wait_frames: int = 0
	var warned: bool = false


var grab_connections: Dictionary = {} # Node3D(grabber) -> _GrabConnection. 단일 holder 대신 다중 연결 구조를 사용해, 여러 Grabber가 같은 물체를 동시에 잡을 수 있게 한다(로컬 싱글플레이에서는 항상 1개, 향후 멀티플레이 협동 운반의 물리적 기반).
var _pending_restores: Dictionary = {} # Node3D(grabber) -> _PendingRestore. Release 직후에도 실제 Grabber 몸과 안전하게 분리될 때까지 collision exception/Barrier mask를 유지한다.
var _barrier_hold_count: int = 0 # 현재 Barrier mask가 필요한 Grabber 수(활성 연결 + 안전 분리 대기 중인 release 포함). 0이 되어야 mask를 원래대로 되돌린다.
var _grab_markers: Dictionary = {} # T075: Node3D(grabber) -> MeshInstance3D. 연결이 살아있는 동안 그 local_grab_point를 표시하는 순수 시각 마커(CollisionShape 없음, 물리에 관여하지 않음).

@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8 # is_touching()이 실제 접촉 목록을 조회할 수 있어야 한다(기본값은 비활성).


func is_touching(body: Node) -> bool:
	# Player.gd의 _push_away_rigid_bodies()가, 이 물체(잡혀서 Spring-Damper 힘을 받는 중)가
	# 이미 물리적으로 접촉해 힘을 전달하고 있는 대상에는 Body Push를 중복 적용하지 않기 위해 사용.
	return body in get_colliding_bodies()


func add_grabber(grabber: Node3D, target_point: Node3D, world_grab_position: Vector3) -> bool:
	if grabber == null or not is_instance_valid(grabber):
		return false
	if target_point == null or not is_instance_valid(target_point):
		return false
	if grab_connections.has(grabber):
		return false # 같은 Grabber의 중복 연결은 만들지 않는다.

	if grabber is CollisionObject3D:
		var grabber_body := grabber as CollisionObject3D
		if _pending_restores.has(grabber):
			# 분리 대기 중이던 같은 Grabber가 다시 잡음: 기존 exception/Barrier mask를 그대로 재사용.
			_pending_restores.erase(grabber)
		else:
			add_collision_exception_with(grabber_body)
			grabber_body.add_collision_exception_with(self)
			_barrier_hold_count += 1
			if _barrier_hold_count == 1:
				collision_mask |= _GRAB_BARRIER_MASK_BIT

	var connection := _GrabConnection.new()
	connection.grabber = grabber
	connection.target_point = target_point
	connection.local_grab_point = to_local(world_grab_position)
	connection.max_force = max_force_per_grabber
	connection.prev_target_position = target_point.global_position
	connection.smoothed_target_velocity = Vector3.ZERO
	connection.block_streak = 0
	grab_connections[grabber] = connection
	_create_grab_marker(grabber, connection.local_grab_point)
	sleeping = false
	return true


func remove_grabber(grabber: Node3D) -> void:
	# 현재 linear_velocity/angular_velocity는 전혀 건드리지 않는다 — 놓는 순간 물체는
	# Spring-Damper 힘이 이미 만들어 둔 운동량을 그대로 유지하며 자연스럽게 날아간다.
	if not grab_connections.has(grabber):
		return
	grab_connections.erase(grabber)
	_remove_grab_marker(grabber)
	_begin_pending_restore(grabber)
	grabber_disconnected.emit(grabber, DisconnectReason.MANUAL)


func _create_grab_marker(grabber: Node3D, local_grab_point: Vector3) -> void:
	# T075: Grab Point를 표시하는 순수 시각 마커 — CollisionShape가 없어 물리·충돌 계산에는
	# 전혀 참여하지 않는다. 이 물체(GrabbableBody)의 자식으로 붙여 local 좌표만 지정하면
	# 물체가 움직이거나 회전해도 표면의 같은 지점을 자동으로 따라간다(별도 프레임 동기화 불필요).
	var marker := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = _MARKER_RADIUS
	mesh.height = _MARKER_RADIUS * 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	marker.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = _get_marker_color(grabber)
	marker.material_override = material
	marker.position = local_grab_point
	add_child(marker)
	_grab_markers[grabber] = marker


func _get_marker_color(grabber: Node3D) -> Color:
	# T075: Player별로 구분되는 색(슬롯 0=시안, 슬롯 1=주황) — Player가 아닌 Grabber는 흰색.
	if grabber is Player:
		return Color(0.2, 0.85, 1.0) if grabber.player_slot == 0 else Color(1.0, 0.6, 0.15)
	return Color(1.0, 1.0, 1.0)


func _remove_grab_marker(grabber: Node3D) -> void:
	if not _grab_markers.has(grabber):
		return
	var marker: Node = _grab_markers[grabber]
	if is_instance_valid(marker):
		marker.queue_free()
	_grab_markers.erase(grabber)


func _begin_pending_restore(grabber: Node3D) -> void:
	# 수동 release와 자동 해제(거리 초과·정적 차단) 모두 이 경로를 거쳐야, 실제 Grabber 몸과
	# 안전하게(연속 프레임 미겹침) 분리될 때까지 collision exception/Barrier mask가 즉시 복구되지
	# 않는다 — 근처에서 놓았을 때 즉시 복구하면 침투 해소 충격으로 튕겨나가는 문제가 있다.
	if grabber is CollisionObject3D and not _pending_restores.has(grabber):
		var pending := _PendingRestore.new()
		pending.grabber = grabber as CollisionObject3D
		_pending_restores[grabber] = pending


func has_grabber(grabber: Node3D) -> bool:
	return grab_connections.has(grabber)


func get_grabber_count() -> int:
	return grab_connections.size()


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not grab_connections.is_empty():
		_apply_grab_forces(state)
	if not _pending_restores.is_empty():
		_process_pending_restores(state)


func _apply_grab_forces(state: PhysicsDirectBodyState3D) -> void:
	var step: float = clampf(state.step, 0.0001, _MAX_DELTA)
	var invalid_grabbers: Array = [] # [{grabber, reason}] — T075: Release 피드백 UI가 원인을 구분할 수 있도록 함께 기록.

	for grabber in grab_connections.keys():
		var connection: _GrabConnection = grab_connections[grabber]

		if not is_instance_valid(grabber) or connection.target_point == null or not is_instance_valid(connection.target_point):
			invalid_grabbers.append({"grabber": grabber, "reason": DisconnectReason.BLOCKED})
			continue

		var world_grab_point: Vector3 = to_global(connection.local_grab_point)
		var target_position: Vector3 = connection.target_point.global_position
		var to_target: Vector3 = target_position - world_grab_point

		if to_target.length() > max_grab_distance:
			invalid_grabbers.append({"grabber": grabber, "reason": DisconnectReason.DISTANCE_EXCEEDED}) # 이 연결만 해제 — 다른 Grabber의 연결은 유지된다.
			continue

		if _is_connection_path_blocked(state, connection, world_grab_point):
			connection.block_streak += 1
		else:
			connection.block_streak = 0

		if connection.block_streak >= _HOLD_BLOCKED_RELEASE_FRAMES:
			invalid_grabbers.append({"grabber": grabber, "reason": DisconnectReason.BLOCKED})
			continue

		var raw_target_velocity: Vector3 = (target_position - connection.prev_target_position) / step
		connection.prev_target_position = target_position
		if is_nan(raw_target_velocity.x) or is_nan(raw_target_velocity.y) or is_nan(raw_target_velocity.z):
			raw_target_velocity = Vector3.ZERO
		raw_target_velocity = raw_target_velocity.limit_length(max_target_speed)
		connection.smoothed_target_velocity = connection.smoothed_target_velocity.lerp(raw_target_velocity, _TARGET_VELOCITY_SMOOTH_FACTOR)

		# apply_force()의 position 인자는 무게중심 기준 글로벌 오프셋이다. 여기서 다루는 모든
		# Grabbable은 원점에 대칭인 단일 Shape(Box/Cylinder)라 무게중심이 항상 물체 원점과
		# 일치하므로 state.transform.origin을 그대로 무게중심으로 사용한다(state.center_of_mass는
		# 로컬 좌표를 반환해 이 용도에는 맞지 않음). Grab Point가 원점에서 벗어나 있으면 이
		# 오프셋 때문에 자연스럽게 torque가 발생한다.
		var offset: Vector3 = world_grab_point - state.transform.origin
		var grab_point_velocity: Vector3 = state.linear_velocity + state.angular_velocity.cross(offset)

		var displacement: Vector3 = to_target.limit_length(max_spring_distance)
		var relative_velocity: Vector3 = connection.smoothed_target_velocity - grab_point_velocity
		var desired_force: Vector3 = displacement * grab_spring_strength + relative_velocity * grab_damping
		if is_nan(desired_force.x) or is_nan(desired_force.y) or is_nan(desired_force.z):
			continue

		var applied_force: Vector3 = desired_force.limit_length(connection.max_force)
		state.apply_force(applied_force, offset)

	for entry in invalid_grabbers:
		var grabber: Node3D = entry.grabber
		grab_connections.erase(grabber)
		_remove_grab_marker(grabber)
		_begin_pending_restore(grabber)
		grabber_disconnected.emit(grabber, entry.reason)


func _is_connection_path_blocked(state: PhysicsDirectBodyState3D, connection: _GrabConnection, world_grab_point: Vector3) -> bool:
	# HandPoint와 실제 Grab Point 사이에 정적 World 장애물(벽 등)이 끼어들면 차단으로 판단한다.
	# 다른 Package/PhysicsObject 같은 동적 RigidBody는 여기서 의도적으로 감지하지 않는다.
	var exclude_rids: Array[RID] = [get_rid()]
	if connection.grabber is CollisionObject3D:
		exclude_rids.append((connection.grabber as CollisionObject3D).get_rid())
	var query := PhysicsRayQueryParameters3D.create(connection.target_point.global_position, world_grab_point, _STATIC_BLOCK_MASK, exclude_rids)
	var result := state.get_space_state().intersect_ray(query)
	return not result.is_empty()


func _process_pending_restores(state: PhysicsDirectBodyState3D) -> void:
	var finished: Array = []
	for grabber in _pending_restores.keys():
		var pending: _PendingRestore = _pending_restores[grabber]
		if not is_instance_valid(grabber):
			finished.append(grabber)
			continue

		sleeping = false # 복구 대기 중에는 겹침 감시가 계속 돌아야 하므로 sleep 상태로 넘어가지 않게 한다

		if _is_overlapping(state, pending.grabber):
			pending.separation_streak = 0
			pending.wait_frames += 1
			if pending.wait_frames >= _RESTORE_WARN_FRAMES and not pending.warned:
				push_warning(name + ": " + str(grabber) + "와 겹친 상태로 collision 복구가 지연되고 있습니다.")
				pending.warned = true
		else:
			pending.separation_streak += 1
			if pending.separation_streak >= _RESTORE_SEPARATION_FRAMES:
				finished.append(grabber)

	for grabber in finished:
		_finish_restore(grabber)
		_pending_restores.erase(grabber)


func _finish_restore(grabber: Node3D) -> void:
	if grabber is CollisionObject3D:
		var grabber_body := grabber as CollisionObject3D
		if is_instance_valid(grabber_body):
			remove_collision_exception_with(grabber_body)
			grabber_body.remove_collision_exception_with(self)
		_barrier_hold_count = maxi(_barrier_hold_count - 1, 0)
		if _barrier_hold_count == 0:
			collision_mask &= ~_GRAB_BARRIER_MASK_BIT


func _is_overlapping(state: PhysicsDirectBodyState3D, grabber_body: CollisionObject3D) -> bool:
	if _collision_shape == null or _collision_shape.shape == null:
		return false
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _collision_shape.shape
	query.transform = _collision_shape.global_transform
	query.exclude = [get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var results := state.get_space_state().intersect_shape(query, 8)
	for result in results:
		if result.get("collider") == grabber_body:
			return true
	return false
