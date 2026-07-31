class_name CharacterAnimationController
extends Node

## T085D: 이동 상태(Idle/Walk/Sprint/Air)에 맞춰 캐릭터의 AnimationPlayer를 재생하고, 운반 중일
## 때는 팔(arm-left/arm-right)만 별도로 "잡기" Pose로 덮어쓴다(설계 문서 방식 B — 다리·몸통은
## Walk/Sprint Clip을 그대로 쓰고, 팔만 매 프레임 애니메이션 결과 위에 덮어쓴다. 절대 세우지 않고
## 항상 "현재 팔 회전 → 목표 Pose"로 다시 계산해 회전이 누적되지 않게 한다).
## Kenney 팩에는 전용 Carry Clip이 없어 "holding-both"에서 팔 회전만 추출해 목표 Pose로 쓴다.

const BLEND_TIME := 0.15
const CARRY_BLEND_TIME := 0.2
const MOVE_EPSILON := 0.15 # m/s 미만이면 정지로 간주(물리적 미세 떨림으로 Idle/Walk가 반복 전환되지 않도록)
const WALK_ANIM_SPEED_REF := 4.0 # Player.gd walk_speed 기준값과 맞춤(TECH_DEBT 기준값 참고, 애니메이션 재생 속도 스케일 전용)
const SPRINT_ANIM_SPEED_REF := 7.0 # Player.gd sprint_speed 기준값과 맞춤
const _MIN_SPEED_SCALE := 0.5
const _MAX_SPEED_SCALE := 1.5

const _GRAB_START_ANIM := "pick-up"
const _CARRY_POSE_SOURCE_ANIM := "holding-both"
const _AIR_ANIM := "static" # 이 팩에는 전용 공중(Jump/Fall) Clip이 없어 중립 자세로 대체

enum LocomotionState { IDLE, WALK, SPRINT, AIR }

const _LOCOMOTION_ANIM_NAMES := {
	LocomotionState.IDLE: "idle",
	LocomotionState.WALK: "walk",
	LocomotionState.SPRINT: "sprint",
	LocomotionState.AIR: _AIR_ANIM,
}

var _anim_player: AnimationPlayer = null
var _arm_left: Node3D = null
var _arm_right: Node3D = null

var _locomotion_state: LocomotionState = LocomotionState.IDLE
var _is_carrying: bool = false
var _carry_blend: float = 0.0 # 0=팔 덮어쓰기 없음, 1=완전히 Carry Pose
var _carry_pose_left: Quaternion = Quaternion.IDENTITY
var _carry_pose_right: Quaternion = Quaternion.IDENTITY
var _has_carry_pose: bool = false
var _playing_grab_start: bool = false


func _ready() -> void:
	# AnimationPlayer(기본 process_priority=0)가 먼저 이번 프레임의 팔 회전을 계산해 둔 뒤,
	# 이 스크립트가 그 결과 위에 Carry Pose를 덮어써야 한다 — 반드시 나중에 실행되어야 함.
	process_priority = 100


## 캐릭터 교체 시 CharacterVisual이 호출한다. 이전 캐릭터의 연결은 자동으로 해제된다(teardown 불필요
## — set_character()가 매번 새 CharacterAnimationController 상태로 완전히 다시 설정하기 때문).
func setup(anim_player: AnimationPlayer, arm_left: Node3D, arm_right: Node3D) -> void:
	if _anim_player != null and _anim_player.animation_finished.is_connected(_on_animation_finished):
		_anim_player.animation_finished.disconnect(_on_animation_finished)

	_anim_player = anim_player
	_arm_left = arm_left
	_arm_right = arm_right
	_locomotion_state = LocomotionState.IDLE
	_is_carrying = false
	_carry_blend = 0.0
	_has_carry_pose = false
	_playing_grab_start = false

	if _anim_player == null:
		return
	_anim_player.animation_finished.connect(_on_animation_finished)
	_extract_carry_pose()
	_play_locomotion_animation(true)


## 실제 물리 velocity 기반 수평 속력을 받는다(입력값이 아니라) — 미끄러질 때도 자연스럽게 반영된다.
func update_locomotion(horizontal_speed: float, is_sprinting: bool, is_on_floor: bool) -> void:
	if _anim_player == null:
		return
	var new_state: LocomotionState
	if not is_on_floor:
		new_state = LocomotionState.AIR
	elif horizontal_speed < MOVE_EPSILON:
		new_state = LocomotionState.IDLE
	elif is_sprinting:
		new_state = LocomotionState.SPRINT
	else:
		new_state = LocomotionState.WALK

	if new_state != _locomotion_state:
		_locomotion_state = new_state
		_play_locomotion_animation(false)
	_update_playback_speed(horizontal_speed)


## Player.gd의 실제 Grab 보유 여부를 그대로 반영한다 — Grab 물리 자체는 건드리지 않는다.
func set_carrying(carrying: bool) -> void:
	if carrying == _is_carrying:
		return
	_is_carrying = carrying
	if carrying and _has_carry_pose and _anim_player != null and _anim_player.has_animation(_GRAB_START_ANIM):
		_playing_grab_start = true
		_anim_player.play(_GRAB_START_ANIM, BLEND_TIME)


func reset() -> void:
	# Restart 등으로 Player 상태가 초기화될 때 함께 호출한다 — Carry Pose 잔류, 재생 중이던
	# pick-up 원샷 상태 등이 새 Scene에 이어지지 않게 한다.
	_is_carrying = false
	_carry_blend = 0.0
	_playing_grab_start = false
	_locomotion_state = LocomotionState.IDLE
	if _anim_player != null:
		_play_locomotion_animation(true)


func _process(delta: float) -> void:
	if _anim_player == null or not _has_carry_pose:
		return
	var target := 1.0 if _is_carrying else 0.0
	if is_equal_approx(_carry_blend, target):
		return
	_carry_blend = move_toward(_carry_blend, target, delta / CARRY_BLEND_TIME)
	if _carry_blend <= 0.0:
		return
	if _arm_left != null:
		_arm_left.quaternion = _arm_left.quaternion.slerp(_carry_pose_left, _carry_blend)
	if _arm_right != null:
		_arm_right.quaternion = _arm_right.quaternion.slerp(_carry_pose_right, _carry_blend)


func _on_animation_finished(anim_name: String) -> void:
	if anim_name == _GRAB_START_ANIM:
		_playing_grab_start = false
		_play_locomotion_animation(true)
		return
	# idle/walk/sprint/static은 지속 상태로 써야 하지만 원본 Clip은 loop_mode=NONE으로 저장돼
	# 있다 — 공유 리소스(anim.loop_mode)를 직접 바꾸면 같은 GLB를 쓰는 다른 인스턴스(Preview 등)에도
	# 영향을 줄 수 있어, 여기서 "같은 Clip이 끝나면 다시 재생"만 스크립트로 수동 반복한다.
	if anim_name == _LOCOMOTION_ANIM_NAMES.get(_locomotion_state, ""):
		_anim_player.play(anim_name, 0.0)


func _play_locomotion_animation(force: bool) -> void:
	if _playing_grab_start and not force:
		return # pick-up 원샷이 끝날 때까지는 이동 Clip으로 덮어쓰지 않는다(팔 Carry Pose는 별도 프로세스로 계속 블렌드됨)
	var anim_name: String = _LOCOMOTION_ANIM_NAMES.get(_locomotion_state, "idle")
	if not _anim_player.has_animation(anim_name):
		return
	_anim_player.play(anim_name, BLEND_TIME)


func _update_playback_speed(horizontal_speed: float) -> void:
	if _anim_player == null:
		return
	match _locomotion_state:
		LocomotionState.WALK:
			_anim_player.speed_scale = clampf(horizontal_speed / WALK_ANIM_SPEED_REF, _MIN_SPEED_SCALE, _MAX_SPEED_SCALE)
		LocomotionState.SPRINT:
			_anim_player.speed_scale = clampf(horizontal_speed / SPRINT_ANIM_SPEED_REF, _MIN_SPEED_SCALE, _MAX_SPEED_SCALE)
		_:
			_anim_player.speed_scale = 1.0


func _extract_carry_pose() -> void:
	if _anim_player == null or not _anim_player.has_animation(_CARRY_POSE_SOURCE_ANIM):
		return
	var anim: Animation = _anim_player.get_animation(_CARRY_POSE_SOURCE_ANIM)
	var left_track := _find_rotation_track(anim, "arm-left")
	var right_track := _find_rotation_track(anim, "arm-right")
	if left_track < 0 or right_track < 0:
		return
	var sample_time: float = anim.length
	_carry_pose_left = anim.rotation_track_interpolate(left_track, sample_time)
	_carry_pose_right = anim.rotation_track_interpolate(right_track, sample_time)
	_has_carry_pose = true


func _find_rotation_track(anim: Animation, node_name_suffix: String) -> int:
	for i in anim.get_track_count():
		if anim.track_get_type(i) != Animation.TYPE_ROTATION_3D:
			continue
		var path_str := str(anim.track_get_path(i))
		if path_str.ends_with(node_name_suffix):
			return i
	return -1
