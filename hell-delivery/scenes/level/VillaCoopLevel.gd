extends "res://scenes/level/VillaDeliveryRun.gd"

var player2: Player
var _second_spawn: Transform3D
var _second_feedback: LevelAudio

func _ready() -> void:
	player2 = preload("res://scenes/player/Player.tscn").instantiate()
	player2.name = "Player2"
	player2.player_slot = 1
	player2.collision_mask = player.collision_mask
	player2.floor_snap_length = player.floor_snap_length
	player2.input_profile = Player.InputProfile.GAMEPAD
	player2.position = Vector3(2.5, 1, -11.5)
	player2.rotation.y = PI
	$Gameplay.add_child(player2)
	super._ready()
	$UI/PauseMenu.controls_panel.configure_coop()
	_feedback.player_pan = -0.55
	_second_feedback = LevelAudio.new()
	_second_feedback.name = "Player2Audio"
	_second_feedback.player_pan = 0.55
	add_child(_second_feedback)
	_second_spawn = player2.global_transform
	for step in $Environment.get_children():
		if step is StaticBody3D and str(step.name).begins_with("Step"):
			player2.add_collision_exception_with(step)
	delivery_hud.get_node("HelpLabel").text = "P1 WASD·마우스 | P2 스틱·RT/A 운반·X 점프·L3 달리기 | Esc/Start 메뉴 · F5 복구"

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_second_feedback.update_player(player2, delta)
	if player2.global_position.y < FALL_LIMIT:
		_recover_second()
	var status := " · ".join(destinations.map(func(zone): return "%s %s" % [zone.display_name, "완료" if zone.delivered_count > 0 else "대기"]))
	delivery_hud.get_node("RouteLabel").text = "P1 %s | P2 %s | %s" % [_carrying(player), _carrying(player2), status]

func _carrying(courier: Player) -> String:
	var parcel := courier.held_grabbable as Package
	return "%s 운반" % parcel.display_name if parcel != null and not parcel.is_delivered() else "빈손"

func recover_all() -> void:
	super.recover_all()
	_recover_second()

func _recover_second() -> void:
	if player2.held_grabbable != null:
		player2.held_grabbable.remove_grabber(player2)
	player2.global_transform = _second_spawn
	player2.velocity = Vector3.ZERO
	player2.camera_pivot.rotation = Vector3.ZERO
	player2.grab_collision_barrier.global_transform = _second_spawn
	player2.reset_physics_interpolation()
	player2.character_visual.animation_controller.reset()
