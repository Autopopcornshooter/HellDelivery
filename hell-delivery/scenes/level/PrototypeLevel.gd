extends Node3D

@export var smooth_stair_walking: bool = false
@export var route_hint: String = "택배를 초록색 배송 구역으로 옮기세요"

@onready var delivery_zone: DeliveryZone = $Gameplay/DeliveryZone
@onready var delivery_hud: DeliveryHUD = $UI/DeliveryHUD
@onready var completion_overlay: CompletionOverlay = $UI/CompletionOverlay
@onready var player: Player = $Gameplay/Player
@onready var onboarding_overlay: OnboardingOverlay = $UI/OnboardingOverlay

var _play_time_elapsed: float = 0.0
var _spawn_transforms: Dictionary = {}
var _player_spawn: Transform3D
var _feedback: LevelAudio
var _object_speeds: Dictionary = {}
const FALL_LIMIT := -12.0


func _ready() -> void:
	delivery_zone.package_delivered.connect(_on_package_delivered)
	delivery_zone.all_packages_delivered.connect(_on_all_packages_delivered)
	player.grab_aim_state_changed.connect(delivery_hud.set_crosshair_state)
	delivery_hud.get_node("RouteLabel").text = route_hint
	_configure_goal()
	_player_spawn = player.global_transform
	if smooth_stair_walking:
		# Villa의 두 보행 경사면은 Player만 담당한다. 택배·시선 검사는 원래 계단을 유지한다.
		for step in $Environment.get_children():
			if step is StaticBody3D and str(step.name).begins_with("Step"):
				player.add_collision_exception_with(step)
	for child in $Gameplay.get_children():
		if child is GrabbableBody:
			_spawn_transforms[child] = child.global_transform
			child.body_entered.connect(_on_object_contact.bind(child))
	_feedback = LevelAudio.new()
	_feedback.name = "LevelAudio"
	add_child(_feedback)
	var destination_label := Label3D.new()
	destination_label.text = "%s\n택배 %d개" % [delivery_zone.destination_name, delivery_zone.target_package_count]
	destination_label.position = Vector3(0, 2.0, 0)
	destination_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	destination_label.font_size = 48
	destination_label.modulate = Color(0.45, 1.0, 0.6)
	delivery_zone.add_child(destination_label)
	# T080: 첫 실행 안내가 떠 있는 동안에는 그것을 닫은 직후에 목표 문구를 보여주고, 이미 본 적
	# 있으면(재진입·Restart) 안내 없이 곧바로 보여준다 — "항상 큰 튜토리얼" 대신 짧게만 표시.
	if onboarding_overlay.visible:
		onboarding_overlay.closed.connect(delivery_hud.show_goal, CONNECT_ONE_SHOT)
	else:
		delivery_hud.show_goal()


func _configure_goal() -> void:
	delivery_hud.configure_goal(delivery_zone)
	onboarding_overlay.configure_goal(delivery_zone)
	$UI/PauseMenu.controls_panel.configure_goal(delivery_zone)

func _physics_process(delta: float) -> void:
	# T081: 온보딩/Pause/완료 화면 전부 get_tree().paused를 사용하고, 이 노드는 기본
	# process_mode(Pausable)라 paused 동안에는 이 함수 자체가 호출되지 않는다 — 별도 조건 없이
	# 실제 플레이 시간만 자연히 누적된다(T079 Pause 자동 정지와 동일한 원리).
	_play_time_elapsed += delta
	if player.global_position.y < FALL_LIMIT:
		recover_player()
	for body: GrabbableBody in _spawn_transforms:
		_object_speeds[body] = body.linear_velocity.length()
		if not body.is_delivered() and body.global_position.y < FALL_LIMIT:
			body.recover_to(_spawn_transforms[body])
	_feedback.update_player(player, delta)


func _on_object_contact(_other: Node, body: GrabbableBody) -> void:
	var speed: float = _object_speeds.get(body, 0.0)
	if _feedback != null and speed > 2.0 and not body.is_delivered():
		_feedback.play_cue("impact", speed / 7.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("recover"):
		recover_all()
		get_viewport().set_input_as_handled()


func recover_player() -> void:
	if player.held_grabbable != null:
		player.held_grabbable.remove_grabber(player)
	player.global_transform = _player_spawn
	player.velocity = Vector3.ZERO
	player.camera_pivot.rotation = Vector3.ZERO
	player.grab_collision_barrier.global_transform = _player_spawn
	player.reset_physics_interpolation()
	player.character_visual.animation_controller.reset()


func recover_all() -> void:
	# 배송 진행도는 보존하며 미배송 물건과 플레이어만 출발 지점으로 되돌린다.
	recover_player()
	for body: GrabbableBody in _spawn_transforms:
		if not body.is_delivered():
			body.recover_to(_spawn_transforms[body])
	delivery_hud.show_goal()
	_feedback.play_cue("recover")


func _on_package_delivered(_package: RigidBody3D, delivered_count: int, target_count: int) -> void:
	delivery_hud.update_progress(delivered_count, target_count)
	delivery_hud.show_delivery_toast()
	_feedback.play_cue("delivery")


func _on_all_packages_delivered() -> void:
	# Area3D 신호 안에서 트리 pause/물리 상태를 변경하지 않도록 완료 UI는 지연한다.
	completion_overlay.show_completion.call_deferred(delivery_zone.target_package_count, _play_time_elapsed)
