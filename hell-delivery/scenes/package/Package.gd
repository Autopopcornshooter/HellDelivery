class_name Package
extends RigidBody3D

@export var follow_strength: float = 8.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var max_follow_speed: float = 6.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var follow_acceleration: float = 40.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)
@export var max_hold_distance: float = 3.0 # 프로토타입 기준값(T061 Baseline Freeze, 실제 플레이 검증 완료)

const _RESTORE_SEPARATION_FRAMES: int = 3 # TODO: 프로토타입 값, 튜닝 필요 (경계 재충돌 방지 여유)
const _RESTORE_WARN_FRAMES: int = 300 # TODO: 프로토타입 값, 튜닝 필요 (약 5초, 지연 경고 기준)
const _HOLD_BLOCKED_RELEASE_FRAMES: int = 3 # 연속 몇 프레임 차단되어야 자동 Release할지(한 프레임짜리 접촉/모서리 오차 무시, T065)
const _HOLD_LOS_MASK: int = 21 # World(1) + Package(4) + PhysicsObject(16). Player.gd의 _INTERACT_LOS_MASK와 동일한 값을 별도 상수로 중복 선언(공용 시스템 신설 방지, T065).

var is_held: bool = false
var hold_point: Node3D = null
var holder: CollisionObject3D = null

var _pending_collision_restore: bool = false
var _separation_streak: int = 0
var _restore_wait_frames: int = 0
var _restore_warned: bool = false
var _hold_block_streak: int = 0

@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


func grab(target_hold_point: Node3D, holder_body: CollisionObject3D) -> bool:
	if is_held:
		return false
	if target_hold_point == null or not is_instance_valid(target_hold_point):
		return false
	if holder_body == null or not is_instance_valid(holder_body):
		return false

	if _pending_collision_restore and holder == holder_body:
		# 복구 대기 중이던 같은 holder가 다시 잡음: 기존 exception을 그대로 재사용
		_cancel_pending_restore()
	elif _pending_collision_restore and holder != holder_body:
		# 방어 처리: 싱글플레이 MVP에서는 도달하지 않는 경로. exception 누적을 막기 위해 기존 대기를 즉시 정리한다.
		_finish_pending_restore()
		holder = holder_body
		add_collision_exception_with(holder)
		holder.add_collision_exception_with(self)
	else:
		holder = holder_body
		add_collision_exception_with(holder)
		holder.add_collision_exception_with(self)

	is_held = true
	hold_point = target_hold_point
	sleeping = false
	_hold_block_streak = 0
	return true


func release() -> void:
	is_held = false
	hold_point = null
	_hold_block_streak = 0
	if holder != null and is_instance_valid(holder):
		_pending_collision_restore = true
		_separation_streak = 0
		_restore_wait_frames = 0
		_restore_warned = false


func throw(direction: Vector3, impulse_strength: float) -> bool:
	if not is_held:
		return false
	release()
	sleeping = false
	apply_central_impulse(direction.normalized() * impulse_strength)
	return true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if is_held:
		if hold_point == null or not is_instance_valid(hold_point):
			release()
		else:
			var to_target := hold_point.global_position - state.transform.origin
			if to_target.length() > max_hold_distance:
				release()
			else:
				if _is_hold_path_blocked(state):
					_hold_block_streak += 1
				else:
					_hold_block_streak = 0

				if _hold_block_streak >= _HOLD_BLOCKED_RELEASE_FRAMES:
					release()
				else:
					var desired_velocity := (to_target * follow_strength).limit_length(max_follow_speed)
					state.linear_velocity = state.linear_velocity.move_toward(desired_velocity, follow_acceleration * state.step)

	if _pending_collision_restore:
		_process_pending_restore(state)


func _is_hold_path_blocked(state: PhysicsDirectBodyState3D) -> bool:
	# HoldPoint와 Package 중심 사이에 벽 등이 끼어들면 차단으로 판단(T065, 벽 뒤 Hold 유지 버그 수정).
	# 단발성 접촉/모서리 오차로 즉시 Release되지 않도록 호출 측에서 연속 프레임 카운트로 판단한다.
	if hold_point == null or not is_instance_valid(hold_point):
		return false
	var exclude_rids: Array[RID] = [get_rid()]
	if holder != null and is_instance_valid(holder):
		exclude_rids.append(holder.get_rid())
	var query := PhysicsRayQueryParameters3D.create(hold_point.global_position, state.transform.origin, _HOLD_LOS_MASK, exclude_rids)
	var result := state.get_space_state().intersect_ray(query)
	return not result.is_empty()


func _process_pending_restore(state: PhysicsDirectBodyState3D) -> void:
	if holder == null or not is_instance_valid(holder):
		_cancel_pending_restore()
		holder = null
		return

	sleeping = false # 복구 대기 중에는 겹침 감시가 계속 돌아야 하므로 sleep 상태로 넘어가지 않게 한다

	if _is_overlapping_holder(state):
		_separation_streak = 0
		_restore_wait_frames += 1
		if _restore_wait_frames >= _RESTORE_WARN_FRAMES and not _restore_warned:
			push_warning("Package: holder와 겹친 상태로 collision 복구가 지연되고 있습니다.")
			_restore_warned = true
	else:
		_separation_streak += 1
		if _separation_streak >= _RESTORE_SEPARATION_FRAMES:
			_finish_pending_restore()


func _is_overlapping_holder(state: PhysicsDirectBodyState3D) -> bool:
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
		if result.get("collider") == holder:
			return true
	return false


func _finish_pending_restore() -> void:
	if holder != null and is_instance_valid(holder):
		remove_collision_exception_with(holder)
		holder.remove_collision_exception_with(self)
	_cancel_pending_restore()
	holder = null


func _cancel_pending_restore() -> void:
	_pending_collision_restore = false
	_separation_streak = 0
	_restore_wait_frames = 0
	_restore_warned = false
