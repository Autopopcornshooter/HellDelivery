extends Node

var session: Node
var report: FileAccess
var failures := 0
var checks := 0
var client_events: Dictionary = {}
var output_dir := "user://"

func _ready() -> void:
	session = get_parent()
	process_mode = Node.PROCESS_MODE_ALWAYS
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("network-output="):
			output_dir = arg.trim_prefix("network-output=")
	var role := "host" if "network-test-host" in OS.get_cmdline_user_args() else "client"
	report = FileAccess.open(output_dir.path_join("network-" + role + ".report.txt"), FileAccess.WRITE)
	get_tree().create_timer(240).timeout.connect(func(): check(false, "network test timeout"); finish())
	_run.call_deferred(role)

func check(value: bool, text: String) -> void:
	checks += 1
	if not value: failures += 1
	report.store_line(("PASS " if value else "FAIL ") + text)
	report.flush()

func frames(count: int) -> void:
	for frame in count:
		await get_tree().physics_frame
		await get_tree().process_frame

func until(condition: Callable, seconds: float = 15) -> bool:
	var deadline := Time.get_ticks_msec() + int(seconds * 1000)
	while Time.get_ticks_msec() < deadline:
		if condition.call(): return true
		await frames(1)
	return false

func capture(name: String) -> void:
	if "network-visual" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(output_dir.path_join(name + ".png"))

func finish() -> void:
	report.store_line("EXIT %d checks=%d failures=%d" % [0 if failures == 0 else 1, checks, failures])
	report.flush()
	get_tree().quit(0 if failures == 0 else 1)

func _run(role: String) -> void:
	GameSettings.onboarding_seen = true
	await frames(2)
	if role == "client":
		session.address.text = "not-an-ip"
		session.join_game()
		check(session.peer == null and "올바른" in session.status.text, "invalid IP rejected before connection")
		session.address.text = "127.0.0.1"
		session.join_game()
		check(await until(func(): return session.in_lobby and session.lobby_joined), "client enters shared lobby before world creation")
		check(session.level == null and session.room_ui.visible, "lobby does not start gameplay automatically")
		check(await until(func(): return session.active), "client joins real ENet host")
		if not session.active: finish(); return
		check(not session.level.player2.is_physics_processing() and session.level.get_node("Gameplay/Package").freeze, "client replicas do not simulate authority physics")
		check(await until(func(): return session.rtt_ms >= 0, 5), "client measures RTT through actual ping response")
		return
	session.host_game()
	check(session.peer != null and session.hosting, "host binds UDP room")
	await capture("online-host-lobby")
	await _prepare_lobby()
	check(await until(func(): return session.active), "host waits for client world ready")
	if not session.active: finish(); return
	await frames(20)
	check(session.level.player2.input_profile == Player.InputProfile.NETWORK, "host owns remote input simulation")
	check(session.level.player.character_visual.current_character_id == session._characters[0] and session.level.player2.character_visual.current_character_id == session._characters[1], "lobby character choices carry into both world players")
	for courier in session._players():
		courier.grab_connection_lost.connect(func(reason): report.store_line("GRAB_LOST reason=" + str(reason)); report.flush())
	await capture("online-host-start")
	var before: Vector3 = session.level.player2.position
	_phase.rpc("move", [])
	check(await until(func(): return session.level.player2.position.distance_to(before) > 1, 5), "client movement reaches host through network input")
	await frames(20)
	check(absf(session.level.player2.character_visual.animation_controller._head_pitch + 0.4) < 0.05, "client look drives authoritative head pose")
	_phase.rpc("stop", [])
	await frames(15)
	_phase.rpc("stall-input", [])
	await frames(70)
	check("지연" in session._connection_quality() and session.level.player2.network_move == Vector2.ZERO and not session.level.player2.network_grab, "missing client input shows delay and neutralizes controls")
	await capture("online-input-stalled")
	_phase.rpc("resume-input", [])
	check(await until(func(): return Time.get_ticks_msec() - session.remote_last_input < 200), "input resumes without reconnecting")
	session.recover_world()
	await frames(20)
	var box: Package = session.level.get_node("Gameplay/Package")
	session.level.player2.position = Vector3(1.1, 1, -11.5)
	box.recover_to(Transform3D(Basis.IDENTITY, Vector3(0.55, 1.3, -9.8)))
	await frames(45)
	var aims: Array = []
	for courier in session._players():
		var offset: Vector3 = box.global_position - courier.camera_pivot.global_position
		aims.append(Vector2(atan2(-offset.x, -offset.z), atan2(offset.y, Vector2(offset.x, offset.z).length())))
	_phase.rpc("grab", aims)
	await frames(6)
	report.store_line("SHARED_EARLY count=%d p1=%s p2=%s box=%s aims=%s" % [box.get_grabber_count(), str(session.level.player.held_grabbable), str(session.level.player2.held_grabbable), str(box.position), str(aims)])
	report.flush()
	await frames(60)
	report.store_line("SHARED_LATE count=%d p1=%s p2=%s box=%s" % [box.get_grabber_count(), str(session.level.player.held_grabbable), str(session.level.player2.held_grabbable), str(box.position)])
	report.flush()
	check(box.get_grabber_count() == 2 and box.linear_velocity.is_finite(), "two processes share one host-authoritative parcel")
	await capture("online-host-shared-carry")
	_phase.rpc("host-release", [])
	await frames(20)
	check(box.get_grabber_count() == 1 and box.has_grabber(session.level.player2), "host releases while client keeps carrying")
	_phase.rpc("host-regrab", [])
	await frames(20)
	check(box.get_grabber_count() == 2, "host can rejoin client shared carry")
	var host_position: Vector3 = session.level.player.position
	_phase.rpc("personal-client", [])
	check(await until(func(): return session.level.player2.position.distance_to(Vector3(2.5, 1, -11.5)) < 0.2 and not box.has_grabber(session.level.player2)), "client requests personal recovery through authority")
	check(box.has_grabber(session.level.player) and session.level.player.position.distance_to(host_position) < 0.1, "personal recovery preserves partner grip and position")
	_phase.rpc("stop", [])
	await frames(10)
	session.recover_world()
	await frames(25)
	_phase.rpc("route", [])
	check(await until(func(): return client_events.has("route"), 100), "client route test returns through network")
	check(session.level.second_zone.delivered_count == 1 and session.level._delivered_total() == 1, "client carries 202 through stairs to shared delivery")
	await capture("online-host-partial-delivery")
	var client_position: Vector3 = session.level.player2.position
	session.level.player.position = Vector3(-4, 1, -11)
	session._open_menu()
	session.request_personal_recovery()
	await frames(12)
	check(session.level.player.position.distance_to(Vector3(0, 1, -11.5)) < 0.2 and session.level._delivered_total() == 1 and session.level.player2.position.distance_to(client_position) < 0.15, "host personal recovery preserves client and partial delivery")
	session.recover_world()
	await frames(20)
	check(session.level._delivered_total() == 1, "network recovery preserves delivered parcel")
	box.recover_to(Transform3D(Basis.IDENTITY, session.level.delivery_zone.global_position))
	check(await until(func(): return session.finished), "host confirms shared completion")
	_phase.rpc("completed", [])
	check(await until(func(): return client_events.has("completed")), "client confirms completion UI")
	await capture("online-host-complete")
	var completed_epoch: int = session.generation
	var room_peer: ENetMultiplayerPeer = session.peer
	session.return_lobby_button.pressed.emit()
	await frames(15)
	check(session.in_lobby and not session.active and session.level == null and session.peer == room_peer, "completion returns to lobby without disconnecting")
	check(session.generation > completed_epoch and not session.readiness[0] and not session.readiness[1], "return clears readiness and invalidates previous round packets")
	session._complete(completed_epoch, "stale")
	check(not session.finished and session.level == null, "stale completion cannot affect returned lobby")
	_phase.rpc("returned-lobby", [])
	check(await until(func(): return client_events.has("returned-lobby")), "client confirms shared return without reconnect")
	await capture("online-returned-lobby")
	await _prepare_lobby()
	check(await until(func(): return session.active), "same connection starts another round after readying")
	check(session.level._delivered_total() == 0, "lobby replay starts with fresh parcels")
	var epoch: int = session.generation
	session.restart_world()
	check(await until(func(): return session.active and session.generation == epoch + 1), "host restarts both worlds with new generation")
	await frames(20)
	check(session.level._delivered_total() == 0 and not session.finished, "restart clears shared completion")
	_phase.rpc("restart", [])
	check(await until(func(): return client_events.has("restart")), "client acknowledges clean restart")
	_phase.rpc("disconnect", [])
	check(await until(func(): return not session.active), "host detects real client disconnect")
	check(session.level == null and session.peer == null and session.panel.visible, "disconnect frees world and returns to connection screen")
	await capture("online-host-disconnected")
	session.host_game()
	await _prepare_lobby()
	check(await until(func(): return session.active, 20), "same processes reconnect after a completed session")
	check(await until(func(): return client_events.has("reconnected"), 20), "client confirms reconnected world before host shutdown")
	_phase.rpc("host-disconnect", [])
	await frames(15)
	session._connection_ended("테스트 호스트 종료")
	check(session.level == null and session.peer == null, "host can close the new session cleanly")
	finish()

@rpc("authority", "call_local", "reliable")
func _phase(phase: String, data: Array) -> void:
	if phase == "returned-lobby" and not session.hosting:
		check(session.in_lobby and not session.active and session.level == null and session.peer != null, "client keeps peer and frees completed world in lobby")
		check(not session.readiness[0] and not session.readiness[1] and session.room_ui.visible, "client sees reset readiness and character previews")
		await capture("online-client-returned-lobby")
		_client_event.rpc_id(1, "returned-lobby")
	elif phase == "lobby-ready" and not session.hosting:
		check(session.in_lobby and session.room_ui.visible and not session.room_ui.start_button.visible, "client has character previews and readiness without host start control")
		session.room_ui.cycle_character(1)
		await frames(15)
		session.room_ui.ready_button.pressed.emit()
		check(await until(func(): return session.readiness[1]), "client ready synchronizes from host")
		await capture("online-client-ready")
	elif phase == "move" and not session.hosting:
		session.local_yaw = PI
		session.local_pitch = -0.4
		Input.action_press("move_forward")
	elif phase == "stop":
		Input.action_release("move_forward")
		Input.action_release("grab_object")
	elif phase == "stall-input" and not session.hosting:
		session.set_physics_process(false)
	elif phase == "resume-input" and not session.hosting:
		session.set_physics_process(true)
	elif phase == "grab":
		session.local_yaw = data[session.local_slot].x
		session.local_pitch = data[session.local_slot].y
		Input.action_press("grab_object")
	elif phase == "host-release":
		if session.hosting: Input.action_release("grab_object")
		else:
			check(session.level.player.held_grabbable != null and session.level.player2.held_grabbable != null, "client sees both carry poses from snapshot")
			await capture("online-client-shared-carry")
	elif phase == "host-regrab" and session.hosting:
		Input.action_press("grab_object")
	elif phase == "personal-client" and not session.hosting:
		session._open_menu()
		await capture("online-personal-recovery-menu")
		session.personal_recover_button.pressed.emit()
		check(await until(func(): return not session.menu_open), "client personal recovery acknowledgement resumes play")
	elif phase == "route" and not session.hosting:
		await _route()
		_client_event.rpc_id(1, "route")
	elif phase == "completed" and not session.hosting:
		check(await until(func(): return session.finished and session.panel.visible), "client receives reliable completion")
		check(session.level._delivered_total() == 2, "client HUD has both deliveries")
		await capture("online-client-complete")
		_client_event.rpc_id(1, "completed")
	elif phase == "restart" and not session.hosting:
		check(session.active and not session.finished and session.level._delivered_total() == 0, "client restart resets replicas and HUD")
		_client_event.rpc_id(1, "restart")
	elif phase == "disconnect" and not session.hosting:
		session._connection_ended("테스트 연결 종료")
		check(session.level == null and session.peer == null, "client disconnect cleans local world and peer")
		await frames(120)
		session.join_game()
		check(await until(func(): return session.active, 20), "client reconnects without restarting executable")
		if session.active: _client_event.rpc_id(1, "reconnected")
	elif phase == "host-disconnect" and not session.hosting:
		check(await until(func(): return not session.active, 20), "client detects real host shutdown")
		check(session.panel.visible and session.peer == null and session.level == null, "host shutdown leaves usable connection screen")
		await capture("online-client-host-left")
		finish()

func _prepare_lobby() -> void:
	check(await until(func(): return session.lobby_joined, 20), "host receives lobby participant")
	if not session.lobby_joined: return
	check(not session.active and session.level == null and session.room_ui.start_button.disabled, "joining waits in lobby with start locked")
	session.start_delivery()
	check(session.level == null, "host cannot bypass missing readiness")
	_phase.rpc("lobby-ready", [])
	check(await until(func(): return session.readiness[1]), "remote ready is visible to host")
	session.toggle_ready()
	check(not session.room_ui.start_button.disabled, "both ready enables host start")
	session.toggle_ready()
	check(not session.readiness[0] and session.room_ui.start_button.disabled, "ready cancellation locks start again")
	session.toggle_ready()
	session.room_ui.cycle_character(2)
	check(not session.readiness[0] and session.readiness[1] and session.room_ui.start_button.disabled, "character change cancels only own readiness")
	session.toggle_ready()
	await frames(20)
	await capture("online-both-ready")
	session.room_ui.start_button.pressed.emit()

@rpc("any_peer", "call_remote", "reliable")
func _client_event(event: String) -> void:
	if session.hosting and multiplayer.get_remote_sender_id() == session.remote_id:
		client_events[event] = true

func _route() -> void:
	var courier: Player = session.level.player2
	var parcel: Package = session.level.get_node("Gameplay/Package202")
	var offset := parcel.global_position - courier.camera_pivot.global_position
	session.local_yaw = atan2(-offset.x, -offset.z)
	session.local_pitch = atan2(offset.y, Vector2(offset.x, offset.z).length())
	await frames(12)
	Input.action_press("grab_object")
	await frames(20)
	check(courier.held_grabbable == parcel, "client mouse input grabs 202 through server")
	session.local_pitch = 0
	var waypoints: Array[Vector2] = [Vector2(-3, -10), Vector2(-3, 1), Vector2(0, 2), Vector2(0, 8), Vector2(0, 12.9), Vector2(4, 13.4), Vector2(4, 18.3), Vector2(2.4, 18.3), Vector2(2.4, 13.2), Vector2(2.4, 7.8), Vector2(5.3, 7.55)]
	for target in waypoints:
		var reached := false
		for frame in 900:
			var direction := Vector3(target.x - courier.position.x, 0, target.y - courier.position.z)
			if direction.length() < 0.3 or session.level.second_zone.delivered_count == 1:
				reached = true
				break
			var yaw := atan2(-direction.x, -direction.z)
			session.local_yaw = rotate_toward(session.local_yaw, yaw, 0.04)
			if absf(angle_difference(session.local_yaw, yaw)) < 0.25: Input.action_press("move_forward", 0.8)
			else: Input.action_release("move_forward")
			await frames(1)
		Input.action_release("move_forward")
		await frames(8)
		check(reached, "network route reaches " + str(target))
		report.store_line("ROUTE_CARRY held=%s parcel=%s player=%s" % [str(courier.held_grabbable), str(parcel.position), str(courier.position)])
		report.flush()
		if not reached: break
	Input.action_release("grab_object")
	await frames(20)
	check(session.level.second_zone.delivered_count == 1, "client sees delivered 202 on authoritative snapshot")
	await capture("online-client-route")
