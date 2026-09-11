extends Node

var session: Node
var report: FileAccess
var failures := 0
var checks := 0
var client_events: Dictionary = {}
var output_dir := "user://"
var settings_restore: Array = []
var settings_host_position := Vector3.ZERO
var repeat_rounds := 0
var repeat_routes := false
var repeat_refs: Array[WeakRef] = []
var repeat_settings_count := 0
var repeat_lobby_settings_count := -1

func _ready() -> void:
	session = get_parent()
	# Two rendered test processes compete for desktop focus. Drive the same
	# callbacks explicitly below; do not treat synthetic focus as real Alt+Tab.
	get_window().focus_exited.disconnect(session._on_window_focus_exited)
	get_window().focus_entered.disconnect(session._on_window_focus_entered)
	process_mode = Node.PROCESS_MODE_ALWAYS
	repeat_routes = "network-repeat-routes" in OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("network-output="):
			output_dir = arg.trim_prefix("network-output=")
		elif arg.begins_with("network-repeat="):
			repeat_rounds = clampi(arg.trim_prefix("network-repeat=").to_int(), 0, 20)
	var role := "host" if "network-test-host" in OS.get_cmdline_user_args() else "client"
	report = FileAccess.open(output_dir.path_join("network-" + role + ".report.txt"), FileAccess.WRITE)
	get_tree().create_timer(360 + (120 if repeat_routes else 30) * repeat_rounds).timeout.connect(func(): check(false, "network test timeout"); finish())
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
	session.port_input.value = session.PORT
	if role == "client":
		session.address.text = "not-an-ip"
		session.join_game()
		check(session.peer == null and "올바른" in session.status.text, "invalid IP rejected before connection")
		session.address.text = "127.0.0.1:%d" % session.PORT
		session.address.text_submitted.emit(session.address.text)
		check(await until(func(): return session.in_lobby and session.lobby_joined), "client enters shared lobby before world creation")
		check(GameSettings.last_server_ip == "127.0.0.1" and GameSettings.network_port == session.PORT and session.address.text == "127.0.0.1", "successful endpoint join normalizes and remembers address")
		check(session.level == null and session.room_ui.visible, "lobby does not start gameplay automatically")
		check(await until(func(): return session.active, 60), "client joins real ENet host")
		if not session.active: finish(); return
		check(not session.level.player2.is_physics_processing() and session.level.get_node("Gameplay/Package").freeze, "client replicas do not simulate authority physics")
		check(await until(func(): return session.rtt_ms >= 0, 5), "client measures RTT through actual ping response")
		await _manifest_check()
		_client_event.rpc_id(1, "initial-active")
		return
	session.host_game()
	check(session.peer != null and session.hosting, "host binds UDP room")
	await capture("online-host-lobby")
	check(await until(func(): return session.lobby_joined), "participant arrives before lobby leave test")
	var waiting_peer: ENetMultiplayerPeer = session.peer
	var host_character: String = session._characters[0]
	session.toggle_ready()
	_phase.rpc("lobby-leave", [])
	check(await until(func(): return not session.lobby_joined), "host detects participant leaving lobby")
	check(session.peer == waiting_peer and session.in_lobby and session.remote_id == 0, "host retains listening room after lobby departure")
	check(not session.readiness[0] and not session.readiness[1] and session.room_ui.start_button.disabled, "departure resets both ready states and disables start")
	check(session._characters[0] == host_character and not session.room_ui.previews[1].visible, "host selection remains and departed preview disappears")
	session.start_delivery()
	check(session.level == null, "cannot start with departed participant readiness")
	await capture("online-lobby-participant-left")
	check(await until(func(): return client_events.has("lobby-rejoined")), "participant rejoins existing listening room")
	check(session.peer == waiting_peer and not session.readiness[0] and not session.readiness[1], "same room accepts rejoin with clean readiness")
	await _prepare_lobby()
	check(await until(func(): return session.active), "host waits for client world ready")
	if not session.active: finish(); return
	await frames(20)
	check(session.level.player2.input_profile == Player.InputProfile.NETWORK, "host owns remote input simulation")
	check(session.level.player.character_visual.current_character_id == session._characters[0] and session.level.player2.character_visual.current_character_id == session._characters[1], "lobby character choices carry into both world players")
	for courier in session._players():
		courier.grab_connection_lost.connect(func(reason): report.store_line("GRAB_LOST reason=" + str(reason)); report.flush())
	await capture("online-host-start")
	await _manifest_check()
	if "network-orders-only" in OS.get_cmdline_user_args() or "network-course-only" in OS.get_cmdline_user_args():
		report.store_line("SCOPE order flow; standard stair route is not executed in this run")
		report.flush()
		if not await until(func(): return client_events.has("initial-active"), 30):
			check(false, "client initial world handshake timed out")
			finish()
			return
		if "network-course-only" in OS.get_cmdline_user_args():
			check(await _course_sessions(), "course session flow completes")
		else:
			check(await _order_sessions(), "order-only session flow completes")
		_phase.rpc("orders-finish", [])
		check(await until(func(): return client_events.has("orders-finish")), "both processes finish order flow")
		finish()
		return
	session.level.player2.position = Vector3(-4, 1, -4)
	await frames(15)
	check(session.partner_marker.visible and not session.partner_marker.offscreen, "partner ahead has an in-view marker")
	await capture("online-partner-ahead")
	_phase.rpc("partner-marker", [])
	check(await until(func(): return client_events.has("partner-marker")), "client sees host marker from replicated position")
	session.local_yaw = 0
	await frames(12)
	check(session.partner_marker.visible and session.partner_marker.offscreen and "↓" in session.partner_marker.label.text, "partner behind gets a screen-edge direction")
	await capture("online-partner-behind")
	session.level.player2.position = session.level.player.position + Vector3(0.5, 0, 0)
	await frames(5)
	check(not session.partner_marker.visible, "nearby partner marker hides during close carry")
	session.recover_world()
	await frames(15)
	# Isolate network movement from truck-side props; physical delivery is
	# exercised by the complete carry route below.
	session.level.player2.position = Vector3(-4, 1, -10)
	await frames(15)
	var before: Vector3 = session.level.player2.position
	_phase.rpc("move", [])
	check(await until(func(): return session.level.player2.position.distance_to(before) > 1, 5), "client movement reaches host through network input")
	await frames(20)
	check(absf(session.level.player2.character_visual.animation_controller._head_pitch + 0.4) < 0.05, "client look drives authoritative head pose")
	_phase.rpc("stop", [])
	await frames(15)
	var host_fov: float = GameSettings.fov
	_phase.rpc("settings-open", [])
	check(await until(func(): return client_events.has("settings-open")), "client opens settings while connected")
	Input.action_press("move_forward")
	await frames(30)
	Input.action_release("move_forward")
	check(is_equal_approx(GameSettings.fov, host_fov), "client settings do not change host FOV")
	_phase.rpc("settings-close", [])
	check(await until(func(): return client_events.has("settings-close")), "client closes settings and resumes")
	_phase.rpc("controls", [])
	check(await until(func(): return client_events.has("controls")), "client reviews online controls without disconnecting")
	# Isolate focus handling from the truck/parcels at the end of the prior walk.
	session.level.player.position = Vector3(-4, 1, -4)
	session.level.player.velocity = Vector3.ZERO
	session.local_yaw = PI
	await frames(20)
	_phase.rpc("focus-lost", [])
	check(await until(func(): return client_events.has("focus-lost")), "client focus loss opens local menu")
	await frames(15)
	check(session.level.player2.network_move == Vector2.ZERO and not session.level.player2.network_grab and not session.level.player2.network_sprint, "unfocused client sends neutral controls to host")
	Input.action_press("move_forward")
	await frames(30)
	Input.action_release("move_forward")
	_phase.rpc("focus-return", [])
	check(await until(func(): return client_events.has("focus-return")), "client explicitly resumes after focus returns")
	session._on_window_focus_exited()
	var focus_before: Vector3 = session.level.player2.position
	_phase.rpc("move", [])
	check(await until(func(): return session.level.player2.position.distance_to(focus_before) > 0.5, 5), "remote keeps moving while host is unfocused")
	check(session.menu_open and not get_tree().paused and session.level.player.network_move == Vector2.ZERO, "host focus loss neutralizes only local player without pausing")
	await capture("online-host-focus-menu")
	session._on_window_focus_entered()
	check(session.menu_open, "host focus return keeps menu open")
	session._resume()
	_phase.rpc("stop", [])
	session._open_menu()
	session.settings_button.pressed.emit()
	var settings_before: Vector3 = session.level.player2.position
	_phase.rpc("move", [])
	check(await until(func(): return session.level.player2.position.distance_to(settings_before) > 0.5, 5), "remote movement continues while host settings are open")
	check(session.settings_panel.visible and not get_tree().paused, "host settings leave world running")
	session.controls_button.pressed.emit()
	check(session.controls_panel.visible and not session.settings_panel.visible and "호스트" in session.controls_panel.get_node("Panel/VBoxContainer/TitleLabel").text, "host controls replace settings with correct role")
	await capture("online-host-controls")
	session.controls_panel.back_button.pressed.emit()
	check(session.panel.visible and session.menu_open and not session.controls_panel.visible, "controls back returns to online menu")
	session._resume()
	_phase.rpc("stop", [])
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
	_phase.rpc("settings-completion", [])
	check(await until(func(): return client_events.has("settings-completion")), "client settings open before completion")
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
	if not await _repeat_sessions():
		check(false, "repeat session sequence did not complete")
		finish()
		return
	if not await _order_sessions():
		check(false, "order flow sequence did not complete")
		finish()
		return
	var retained_peer: ENetMultiplayerPeer = session.peer
	var disconnected_epoch: int = session.generation
	_phase.rpc("disconnect", [])
	check(await until(func(): return not session.active), "host detects real client disconnect")
	check(session.level == null and session.peer == retained_peer and session.in_lobby and session.panel.visible, "gameplay disconnect frees world but preserves host room")
	check(session.generation > disconnected_epoch and "배송 초기화" in session.status.text and not session.loading, "interrupted delivery invalidates old round and explains fresh start")
	await capture("online-host-disconnected")
	await _prepare_lobby()
	check(await until(func(): return session.active, 20), "same processes reconnect after a completed session")
	check(session.peer == retained_peer and session.level._delivered_total() == 0, "same listening room starts a fresh delivery after rejoin")
	check(await until(func(): return client_events.has("reconnected"), 20), "client confirms reconnected world before host shutdown")
	_phase.rpc("hold-loading", [])
	await frames(5)
	session.restart_world()
	check(await until(func(): return session.loading and session._local_world_ready), "host displays loading while remote polling is delayed")
	check(not session.active and session.panel.visible and session.cancel_button.visible and not session.level.player.is_physics_processing(), "loading keeps controls stopped and cancellation available")
	await capture("online-loading-wait")
	check(await until(func(): return session.active), "delayed participant resumes and releases loading screen")
	check(not session.loading and not session.panel.visible, "both-ready hides loading panel")
	_phase.rpc("leave-during-loading", [])
	await frames(5)
	session.restart_world()
	check(await until(func(): return session.loading and session._local_world_ready), "host reaches loading before remote cancellation")
	check(await until(func(): return session.in_lobby and not session.lobby_joined, 10), "loading disconnect returns host to waiting room")
	check(session.peer == retained_peer and session.level == null and not session.loading, "loading disconnect cancels pending world without losing listener")
	await frames(10)
	check(session.level == null, "cancelled loading does not recreate a world")
	await capture("online-loading-partner-left")
	await _prepare_lobby()
	check(await until(func(): return session.active, 20), "room accepts another round after loading interruption")
	check(await until(func(): return client_events.has("loading-rejoined")), "participant rejoins loading-interrupted room")
	_phase.rpc("host-disconnect", [])
	await frames(15)
	session._connection_ended("테스트 호스트 종료")
	check(session.level == null and session.peer == null, "host can close the new session cleanly")
	finish()

@rpc("authority", "call_local", "reliable")
func _phase(phase: String, data: Array) -> void:
	if phase == "repeat-begin":
		repeat_refs.clear()
		for node in [session.level, session.level.player, session.level.player2, session.level._feedback, session.level._second_feedback]:
			repeat_refs.append(weakref(node))
		repeat_settings_count = GameSettings.settings_changed.get_connections().size()
		session._open_menu()
		session.settings_button.pressed.emit()
		session.controls_button.pressed.emit()
		check(session.controls_panel.visible and not session.settings_panel.visible and not get_tree().paused, "repeat %d menu panels remain exclusive without pausing" % data[0])
		session.controls_panel.back_button.pressed.emit()
		session._resume()
		if not session.hosting: _client_event.rpc_id(1, "repeat-begin-%d" % data[0])
	elif phase == "repeat-complete" and not session.hosting:
		check(await until(func(): return session.finished and session.level._delivered_total() == 2), "repeat %d client receives completed deliveries" % data[0])
		_client_event.rpc_id(1, "repeat-complete-%d" % data[0])
	elif phase == "repeat-lobby" and not session.hosting:
		check(await until(func(): return session.in_lobby and session.level == null), "repeat %d client returns to lobby" % data[0])
		await frames(4)
		_check_repeat_cleanup(data[0])
		_client_event.rpc_id(1, "repeat-lobby-%d" % data[0])
	elif phase == "repeat-start" and not session.hosting:
		check(await until(func(): return session.active), "repeat %d client starts next round" % data[0])
		_check_repeat_start(data[0])
		_client_event.rpc_id(1, "repeat-start-%d" % data[0])
	elif phase == "leave-during-loading" and not session.hosting:
		get_tree().multiplayer_poll = false
		await frames(90)
		session._connection_ended("테스트 로딩 중 종료")
		get_tree().multiplayer_poll = true
		await frames(120)
		session.join_game()
		check(await until(func(): return session.active, 20), "participant rejoins after interrupting loading")
		if session.active: _client_event.rpc_id(1, "loading-rejoined")
	elif phase == "partner-marker" and not session.hosting:
		check(await until(func(): return session.active and session.level.player.position.distance_to(session.level.player2.position) > 5 and session.partner_marker.visible), "client displays partner marker after snapshot position is applied")
		await capture("online-client-partner")
		_client_event.rpc_id(1, "partner-marker")
	elif phase == "finish-request" and not session.hosting:
		session._open_menu()
		session.finish_request_button.pressed.emit()
		check(await until(func(): return session.finish_pending), "participant finish request opens shared vote")
		check(session.finish_accept.disabled and not session.finished, "requester already agrees but still waits for partner")
		await capture("finish-request-client")
	elif phase == "finish-cancelled" and not session.hosting:
		check(await until(func(): return not session.finish_pending), "partner decline dismisses finish vote")
		check(session.menu_open and not session.finished and session.level._delivered_total() == 1, "declined request preserves client delivery progress")
		session._resume()
		_client_event.rpc_id(1, "finish-cancelled")
	elif phase == "finish-accept" and not session.hosting:
		check(await until(func(): return session.finish_pending and session.finish_votes.slice(0, 2) == [true, false]), "client receives host finish request")
		session._submit_finish_vote.rpc_id(1, session.generation, data[0], true)
		await frames(5)
		check(not session.finished and session.finish_pending, "stale request vote cannot finish current order")
		session.finish_accept.pressed.emit()
		check(await until(func(): return session.finished), "both votes show partial result on client")
		check(session.level._delivered_total() == 1 and "1/2" in session.status.text and not session.finish_panel.visible, "client partial result preserves count and closes vote")
		await capture("finish-partial-result-client")
		_client_event.rpc_id(1, "finish-accepted")
	elif phase == "finish-zero" and not session.hosting:
		check(await until(func(): return session.finish_pending), "zero-delivery order can request finish")
		session.finish_accept.pressed.emit()
		check(await until(func(): return session.finished), "zero-delivery agreement produces result")
		check(session.level._delivered_total() == 0 and "배달한 택배 없음" in session.status.text, "zero result explicitly records no delivered parcels")
		await capture("finish-zero-result-client")
		_client_event.rpc_id(1, "finish-zero")
	elif phase == "finish-disconnect" and not session.hosting:
		check(await until(func(): return session.finish_pending), "client sees finish request before disconnect")
		var previous_record: Dictionary = session.room_record.duplicate(true)
		session._connection_ended("테스트: 주문 마무리 중 연결 종료")
		check(session.room_record.orders == 0 and session.room_record.recent.is_empty(), "leaving room clears local history")
		check(not session.finish_pending and not session.finish_panel.visible and session.finish_serial == 0, "disconnect removes local finish vote and old room request serial")
		await frames(120)
		session.join_game()
		check(await until(func(): return session.in_lobby), "participant rejoins after interrupted finish request")
		check(session.room_record == previous_record, "rejoining receives retained host history without counting interrupted order")
		_client_event.rpc_id(1, "finish-rejoined")
	elif phase == "history-check" and not session.hosting:
		check(await until(func(): return session.in_lobby), "history inspection happens in lobby")
		check(session.room_record == data[0], "host and participant share identical room totals and recent orders")
		session.room_ui.history_button.pressed.emit()
		check(session.history_panel.visible and not session.panel.visible and "부분 종료" in session.history_text.text, "participant opens room history including partial orders")
		await capture("room-history-client-" + str(data[0].orders))
		var escape := InputEventAction.new()
		escape.action = "ui_cancel"
		escape.pressed = true
		session._input(escape)
		check(not session.history_panel.visible and session.panel.visible, "Escape returns history to lobby")
		_client_event.rpc_id(1, "history-" + str(data[0].orders))
	elif phase == "orders-finish" and not session.hosting:
		check(session.active and session.order_id == "standard", "client is ready to play next order")
		_client_event.rpc_id(1, "orders-finish")
		await frames(3)
		finish()
	elif phase == "help-grab":
		session.local_yaw = data[session.local_slot].x
		session.local_pitch = data[session.local_slot].y
		if session.hosting: Input.action_press("grab_object")
		else: Input.action_release("grab_object")
	elif phase == "help-observe" and not session.hosting:
		check(await until(func(): return not session.help_packages[0].is_empty()), "participant receives host carry request")
		session._update_carry_help()
		check(session.help_marker.visible and "같은 상자" in session.help_notice.text, "requested parcel gets location marker and carry instruction")
		await capture("carry-help-client")
		session.manifest_held = true
		session._update_carry_help()
		check(not session.help_marker.visible and not session.help_notice.visible, "manifest suppresses overlapping carry request UI")
		session.manifest_held = false
		var before_yaw: float = session.local_yaw
		session.local_yaw += PI
		await frames(4)
		check(session.help_marker.offscreen, "request behind player uses edge direction marker")
		await capture("carry-help-behind-client")
		session.local_yaw = before_yaw
		session._open_menu()
		session._update_carry_help()
		check(not session.help_marker.visible and not session.help_notice.visible, "menu hides request without stopping network")
		session._resume()
		_client_event.rpc_id(1, "help-observed")
	elif phase == "help-client-request" and not session.hosting:
		if not await until(func(): return session.level.player.held_grabbable == null and session.level.player2.held_grabbable != null): return
		session.request_carry_help()
	elif phase == "help-client-cancel" and not session.hosting:
		if not await until(func(): return not session.help_packages[1].is_empty()): return
		session.request_carry_help()
	elif phase == "course-lobby" and not session.hosting:
		check(await until(func(): return session.in_lobby and session.course == data[0]), "participant receives selected course stage and totals")
		check(not session.readiness[0] and not session.readiness[1] and "코스" in session.room_ui.order_brief.text, "next course stage requires fresh readiness and explains order")
		session.select_order("standard")
		check(session.course == data[0], "participant cannot replace host course")
		await capture("course-lobby-" + str(data[0].index))
		_client_event.rpc_id(1, "course-lobby-" + str(data[0].index))
	elif phase == "course-result" and not session.hosting:
		check(await until(func(): return session.finished and session.course == data[0]), "participant course result matches authoritative totals")
		check("코스" in session.status.text and not session.restart_button.visible, "course result shows progress and prevents replaying counted stage")
		await capture("course-result-client-" + str(data[0].index))
		_client_event.rpc_id(1, "course-result-" + str(data[0].index))
	elif phase == "course-rejoin" and not session.hosting:
		session._connection_ended("테스트: 코스 도중 재참가")
		check(session.course.is_empty(), "leaving clears local course state")
		await frames(120)
		session.join_game()
		check(await until(func(): return session.in_lobby and session.course == data[0]), "rejoin restores course progress from retained host")
		_client_event.rpc_id(1, "course-rejoined")
	elif phase == "team-lift":
		session.local_pitch = 0.0
		if not session.hosting:
			await frames(75)
			check(session.level.player.held_grabbable != null and session.level.player2.held_grabbable != null, "client sees both players carry heavy order parcel")
			check("동료 + 나 운반 중" in session._manifest_contents() and "45kg" in session._manifest_contents(), "client manifest identifies both heavy parcel carriers")
			await capture("order-shared-client-" + session.order_id)
			_client_event.rpc_id(1, "team-lift")
	elif phase == "order-preready" and not session.hosting:
		session.toggle_ready()
	elif phase == "order-selected" and not session.hosting:
		check(await until(func(): return session.in_lobby and session.order_id == data[0]), "client sees selected order " + data[0])
		check(session.room_ui.order_choice.disabled and not session.readiness[0] and not session.readiness[1], "order selection belongs to host and resets readiness")
		session.select_order("standard")
		check(session.order_id == data[0], "client cannot change host order")
		session._lobby_choice.rpc_id(1, session._characters[1], true, session.order_revision - 1)
		await capture("order-lobby-" + data[0])
		_client_event.rpc_id(1, "order-selected-" + data[0])
	elif phase == "order-active" and not session.hosting:
		check(await until(func(): return session.active and session.order_id == data[0]), "client starts selected order " + data[0])
		check(session.level._total_target() == data[1] and session._bodies().filter(func(body): return body is Package).size() == data[1], "client order parcels and goal match host")
		check(session._manifest_contents().count("kg\n") == data[1], "client manifest has one row per order parcel")
		check(session.help_packages.all(func(item): return item.is_empty()) and not session.help_marker.visible, "new order starts without previous carry requests")
		if data[0] == "team":
			check(is_equal_approx(session.level.get_node("Gameplay/Package").mass, 45.0), "client receives heavy parcel configuration")
		if data[0] == "mixed":
			check(session.level.delivery_zone.target_package_count == 2 and session.level.second_zone.target_package_count == 1, "client receives asymmetric mixed destination goals")
			check(session._manifest_contents().count("15kg\n") == 2 and session._manifest_contents().count("45kg\n") == 1, "client mixed manifest distinguishes two light and one heavy parcels")
			session.manifest_held = true
			session._update_manifest()
			await capture("mixed-manifest-client")
			session.manifest_held = false
		await capture("order-start-" + data[0])
		_client_event.rpc_id(1, "order-active-" + data[0])
	elif phase == "order-result" and not session.hosting:
		check(await until(func(): return session.finished), "client receives order result " + data[0])
		check(session.level._delivered_total() == data[1] and session.level._total_target() == data[1], "order completion does not hardcode two parcels")
		check(DeliveryOrders.format_time(data[2]) in session.status.text and "배송 시간" in session.status.text, "client result uses host delivery time")
		await capture("order-result-" + data[0])
		_client_event.rpc_id(1, "order-result-" + data[0])
	elif phase == "focus-lost" and not session.hosting:
		settings_host_position = session.level.player.position
		for action in ["move_forward", "grab_object", "jump", "sprint"]: Input.action_press(action)
		session._on_window_focus_exited()
		check(session.menu_open and session.panel.visible and not session.level.delivery_hud.visible and not get_tree().paused, "client focus loss opens menu without HUD overlap or pausing")
		check(not Input.is_action_pressed("move_forward") and not Input.is_action_pressed("grab_object") and not Input.is_action_pressed("jump") and not Input.is_action_pressed("sprint"), "focus loss clears held local actions")
		session._resume()
		check(session.menu_open, "background window cannot resume")
		await capture("online-client-focus-menu")
		_client_event.rpc_id(1, "focus-lost")
	elif phase == "focus-return" and not session.hosting:
		check(session.level.player.position.distance_to(settings_host_position) > 0.5, "host movement reaches unfocused client")
		session._on_window_focus_entered()
		check(session.menu_open and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "focus return does not capture mouse or resume")
		session._resume()
		check(not session.menu_open and session.level.delivery_hud.visible and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "explicit resume restores HUD and captures mouse after focus return")
		_client_event.rpc_id(1, "focus-return")
	elif phase == "controls" and not session.hosting:
		session._open_menu()
		session.controls_button.pressed.emit()
		var grid: GridContainer = session.controls_panel.get_node("Panel/VBoxContainer/Grid")
		check(session.controls_panel.visible and not get_tree().paused and "참가자" in session.controls_panel.get_node("Panel/VBoxContainer/TitleLabel").text, "client opens role-specific controls without pause")
		check("호스트만" in grid.get_node("KeyRestart").text and "내 위치만" in grid.get_node("KeyRestart").text and "상대 플레이" in grid.get_node("KeyPause").text, "client instructions distinguish local recovery and host-only actions")
		check(("택배 %d개" % session.level._total_target()) in grid.get_node("KeyGoal").text and session.level.second_zone.destination_name in grid.get_node("KeyGoal").text, "online guide uses actual level target and destinations")
		await capture("online-client-controls")
		var escape := InputEventAction.new()
		escape.action = "ui_cancel"
		escape.pressed = true
		Input.parse_input_event(escape)
		await frames(2)
		check(not session.controls_panel.visible and session.menu_open and session.panel.visible, "Escape closes controls before resuming")
		session._resume()
		_client_event.rpc_id(1, "controls")
	elif phase == "settings-open" and not session.hosting:
		settings_restore = [GameSettings.fov, GameSettings.mouse_sensitivity, GameSettings.master_volume]
		settings_host_position = session.level.player.position
		session._open_menu()
		session.settings_button.pressed.emit()
		session.settings_panel.fov_slider.value = 83
		session.settings_panel.mouse_sensitivity_slider.value = 0.004
		session.settings_panel.master_volume_slider.value = 35
		check(session.settings_panel.visible and session.menu_open and not get_tree().paused, "client settings are modal locally without pausing tree")
		check(is_equal_approx(session.level.player2.camera_pivot.get_node("Camera3D").fov, 83) and is_equal_approx(GameSettings.mouse_sensitivity, 0.004) and is_equal_approx(GameSettings.master_volume, 0.35), "online sliders apply local FOV sensitivity and volume")
		await capture("online-client-settings")
		check(not session.partner_marker.visible, "settings hide partner marker")
		_client_event.rpc_id(1, "settings-open")
	elif phase == "settings-close" and not session.hosting:
		check(session.level.player.position.distance_to(settings_host_position) > 0.5, "host movement reaches client while settings are open")
		GameSettings.set_fov(settings_restore[0])
		GameSettings.set_mouse_sensitivity(settings_restore[1])
		GameSettings.set_master_volume(settings_restore[2])
		var escape := InputEventAction.new()
		escape.action = "ui_cancel"
		escape.pressed = true
		Input.parse_input_event(escape)
		await frames(2)
		check(not session.settings_panel.visible and session.menu_open and session.panel.visible, "Escape returns settings to online menu without resuming")
		session.resume_button.pressed.emit()
		check(not session.menu_open and not session.panel.visible, "resume returns to online play")
		_client_event.rpc_id(1, "settings-close")
	elif phase == "settings-completion" and not session.hosting:
		session._open_menu()
		session.settings_button.pressed.emit()
		_client_event.rpc_id(1, "settings-completion")
	elif phase == "hold-loading" and not session.hosting:
		get_tree().multiplayer_poll = false
		await frames(120)
		get_tree().multiplayer_poll = true
	elif phase == "lobby-leave" and not session.hosting:
		session.toggle_ready()
		check(await until(func(): return session.readiness[1]), "participant can leave after readying")
		session.cancel_button.pressed.emit()
		check(session.peer == null and not session.in_lobby, "lobby cancellation cleans participant connection")
		await frames(120)
		session.join_game()
		check(await until(func(): return session.in_lobby and session.lobby_joined), "participant rejoins without host recreating room")
		check(not session.readiness[0] and not session.readiness[1], "rejoined participant sees both players unready")
		_client_event.rpc_id(1, "lobby-rejoined")
	elif phase == "returned-lobby" and not session.hosting:
		check(session.in_lobby and not session.active and session.level == null and session.peer != null, "client keeps peer and frees completed world in lobby")
		check(not session.readiness[0] and not session.readiness[1] and session.room_ui.visible, "client sees reset readiness and character previews")
		await capture("online-client-returned-lobby")
		_client_event.rpc_id(1, "returned-lobby")
	elif phase == "lobby-ready" and not session.hosting:
		check(session.in_lobby and session.room_ui.visible and not session.room_ui.start_button.visible, "client has character previews and readiness without host start control")
		session.room_ui.cycle_character(1)
		var requested_character: String = GameSettings.selected_character_id
		if not await until(func(): return session._characters[1] == requested_character):
			check(false, "host acknowledges requested character before client readies")
			return
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
		await frames(2)
		check(not session.partner_marker.visible, "completion hides partner marker")
		check(not session.settings_panel.visible, "completion replaces open settings")
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
		session._open_menu()
		session.controls_button.pressed.emit()
		check(await until(func(): return not session.active, 20), "client detects real host shutdown")
		check(not session.settings_panel.visible, "disconnect dismisses online settings")
		check(not session.controls_panel.visible, "disconnect dismisses online controls")
		await frames(2)
		check(not session.partner_marker.visible, "disconnect hides partner marker")
		check(session.panel.visible and session.peer == null and session.level == null, "host shutdown leaves usable connection screen")
		await capture("online-client-host-left")
		finish()

func _repeat_sessions() -> bool:
	for cycle in range(1, repeat_rounds + 1):
		_phase.rpc("repeat-begin", [cycle])
		if not await until(func(): return client_events.has("repeat-begin-%d" % cycle)):
			check(false, "repeat begin timed out")
			return false
		var parcels: Array = [session.level.get_node("Gameplay/Package"), session.level.get_node("Gameplay/Package202")]
		var zones: Array = [session.level.delivery_zone, session.level.second_zone]
		for index in ([0, 1] if cycle % 2 == 0 else [1, 0]):
			if repeat_routes and index == 1:
				client_events.erase("route")
				_phase.rpc("route", [])
				var route_done := await until(func(): return client_events.has("route"), 100)
				check(route_done and zones[1].delivered_count == 1, "repeat %d horizontal stair carry delivers 202" % cycle)
				if not route_done or zones[1].delivered_count != 1: return false
				continue
			parcels[index].recover_to(Transform3D(Basis.IDENTITY, zones[index].global_position))
			if not await until(func(): return zones[index].delivered_count == 1, 5):
				check(false, "repeat delivery timed out")
				return false
		check(await until(func(): return session.finished), "repeat %d completes alternating delivery order" % cycle)
		_phase.rpc("repeat-complete", [cycle])
		if not await until(func(): return client_events.has("repeat-complete-%d" % cycle)): return false
		session.return_to_lobby()
		await frames(6)
		_check_repeat_cleanup(cycle)
		_phase.rpc("repeat-lobby", [cycle])
		if not await until(func(): return client_events.has("repeat-lobby-%d" % cycle)): return false
		await _prepare_lobby()
		if not await until(func(): return session.active):
			check(false, "repeat next round timed out")
			return false
		_check_repeat_start(cycle)
		_phase.rpc("repeat-start", [cycle])
		if not await until(func(): return client_events.has("repeat-start-%d" % cycle)): return false
		if cycle == repeat_rounds: await capture("online-repeat-final")
	return true

func _check_repeat_cleanup(cycle: int) -> void:
	check(repeat_refs.all(func(reference: WeakRef): return reference.get_ref() == null), "repeat %d releases old world players and audio" % cycle)
	var subscriptions := GameSettings.settings_changed.get_connections().size()
	if repeat_lobby_settings_count < 0: repeat_lobby_settings_count = subscriptions
	check(subscriptions == repeat_lobby_settings_count and session.level == null and not session.active, "repeat %d lobby subscriptions remain stable" % cycle)
	check(not session.settings_panel.visible and not session.controls_panel.visible and not session.partner_marker.visible, "repeat %d clears overlays and partner marker" % cycle)

func _check_repeat_start(cycle: int) -> void:
	check(session.level._delivered_total() == 0 and not session.finished and not session.menu_open, "repeat %d resets deliveries and menu state" % cycle)
	check(GameSettings.settings_changed.get_connections().size() == repeat_settings_count, "repeat %d world subscriptions do not accumulate" % cycle)
	check(session.level.player.character_visual.current_character_id == session._characters[0] and session.level.player2.character_visual.current_character_id == session._characters[1], "repeat %d applies changed lobby characters" % cycle)

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
		# Regress the original horizontal-view route, without raising the parcel.
		session.local_pitch = 0.0
		var reached := false
		for frame in 900:
			var direction := Vector3(target.x - courier.position.x, 0, target.y - courier.position.z)
			if direction.length() < 0.3 or session.level.second_zone.delivered_count == 1:
				reached = true
				break
			var yaw := atan2(-direction.x, -direction.z)
			session.local_yaw = rotate_toward(session.local_yaw, yaw, 0.04)
			if absf(angle_difference(session.local_yaw, yaw)) < 0.25: Input.action_press("move_forward", 1.0)
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

func _finish_order_fixture() -> bool:
	for body in session._bodies():
		if not body is Package or body.is_delivered(): continue
		var zone: DeliveryZone = session.level.delivery_zone if body.delivery_address == "201" else session.level.second_zone
		var before := zone.delivered_count
		body.recover_to(Transform3D(Basis.IDENTITY, zone.global_position))
		if not await until(func(): return zone.delivered_count == before + 1, 5): return false
	return await until(func(): return session.finished)

func _order_sessions() -> bool:
	for id in ["bulk", "team", "mixed"]:
		if not await _finish_order_fixture(): return false
		session.return_to_lobby()
		await frames(10)
		var previous_revision: int = session.order_revision
		session.select_order(id)
		check(session.order_id == id and session.order_revision > previous_revision, "host selects next order " + id)
		session.select_order("invalid")
		check(session.order_id == id, "invalid order cannot replace selection")
		_phase.rpc("order-selected", [id])
		if not await until(func(): return client_events.has("order-selected-" + id)): return false
		check(not session.readiness[1], "stale order readiness is rejected")
		session.toggle_ready()
		_phase.rpc("order-preready", [])
		if not await until(func(): return session.readiness[0] and session.readiness[1]): return false
		session.select_order("standard")
		check(not session.readiness[0] and not session.readiness[1], "changing a fully ready order resets both players")
		session.select_order(id)
		client_events.erase("order-selected-" + id)
		_phase.rpc("order-selected", [id])
		if not await until(func(): return client_events.has("order-selected-" + id)): return false
		await _prepare_lobby()
		if not await until(func(): return session.active): return false
		var total: int = DeliveryOrders.total_count(id)
		check(session.level._total_target() == total and session._bodies().filter(func(body): return body is Package).size() == total, "host order creates matching parcel count and goals")
		_phase.rpc("order-active", [id, total])
		if not await until(func(): return client_events.has("order-active-" + id)): return false
		session.select_order("standard")
		check(session.order_id == id, "order cannot change during delivery")
		if id == "bulk":
			var parcel: Package = session.level.get_node("Gameplay/Package")
			parcel.recover_to(Transform3D(Basis.IDENTITY, session.level.delivery_zone.global_position))
			if not await until(func(): return session.level.delivery_zone.delivered_count == 1): return false
			check(not session.finished and session.level.delivery_zone.target_package_count == 2 and not session.level._stop_visuals[session.level.delivery_zone].visible, "first bulk parcel leaves destination and round pending")
			session.recover_world()
			await frames(15)
			check(session.level._delivered_total() == 1, "bulk recovery preserves partial delivery")
			check(session._manifest_contents().count("배송 완료") == 1 and "201호 #2" in session._manifest_contents() and "202호 #2" in session._manifest_contents(), "bulk manifest preserves completed parcel and distinct remaining rows after recovery")
			session.manifest_held = true
			session._update_manifest()
			await capture("online-manifest-bulk")
			session.manifest_held = false
		else:
			if id == "mixed":
				var light: Package = session.level.get_node("Gameplay/Package")
				session.level.second_zone._on_body_entered(light)
				check(not light.is_delivered() and session.level._delivered_total() == 0, "mixed light parcel cannot be delivered to heavy parcel destination")
				light.recover_to(Transform3D(Basis.IDENTITY, session.level.delivery_zone.global_position))
				if not await until(func(): return session.level.delivery_zone.delivered_count == 1): return false
				check(not session.finished and session.level.delivery_zone.target_package_count == 2 and session.level.second_zone.target_package_count == 1, "mixed first light delivery leaves asymmetric targets pending")
			var parcel: Package = session.level.get_node("Gameplay/Package202" if id == "mixed" else "Gameplay/Package")
			check(is_equal_approx(parcel.mass, 45.0) and parcel.get_node("CollisionShape3D").shape.size.x > 1.0, "team order uses larger heavy parcels with matching collision")
			session.level.player2.position = Vector3(1.1, 1, -11.5)
			parcel.recover_to(Transform3D(Basis.IDENTITY, Vector3(0.55, 1.3, -9.8)))
			await frames(45)
			var aims: Array = []
			for courier in session._players():
				var offset: Vector3 = parcel.global_position - courier.camera_pivot.global_position
				aims.append(Vector2(atan2(-offset.x, -offset.z), atan2(offset.y, Vector2(offset.x, offset.z).length())))
			if id == "team":
				if not await _carry_help_flow(aims, parcel): return false
			_phase.rpc("grab", aims)
			await frames(20)
			client_events.erase("team-lift")
			_phase.rpc("team-lift", [])
			if not await until(func(): return client_events.has("team-lift")): return false
			check(parcel.get_grabber_count() == 2 and parcel.position.y > 0.65, "two players lift the heavy order parcel above the ground")
			check("나 + 동료 운반 중" in session._manifest_contents(), "host manifest identifies shared carry from its own perspective")
			await capture("order-shared-host-" + id)
			_phase.rpc("stop", [])
			await frames(15)
			session.recover_world()
			await frames(15)
			if id == "mixed":
				parcel.recover_to(Transform3D(Basis.IDENTITY, session.level.second_zone.global_position))
				if not await until(func(): return session.level.second_zone.delivered_count == 1): return false
				check(session.level._delivered_total() == 2 and not session.finished and session.level._stop_visuals[session.level.second_zone].visible and not session.level._stop_visuals[session.level.delivery_zone].visible, "mixed heavy delivery completes only 202 while last light parcel remains")
				session.recover_world()
				await frames(15)
				check(session.level._delivered_total() == 2 and session.level.get_node("Gameplay/Extra201").visible, "mixed recovery preserves both deliveries and restores remaining light parcel")
				session.manifest_held = true
				session._update_manifest()
				await capture("mixed-two-of-three-host")
				session.manifest_held = false
		if not await _finish_order_fixture(): return false
		check("배송 시간" in session.status.text and DeliveryOrders.get_order(id).title in session._panel_title.text, "host result includes order and delivery time")
		var elapsed: float = session.level._play_time_elapsed
		await frames(10)
		check(is_equal_approx(elapsed, session.level._play_time_elapsed), "completed order timer freezes")
		_phase.rpc("order-result", [id, total, elapsed])
		if not await until(func(): return client_events.has("order-result-" + id)): return false
	session.return_to_lobby()
	await frames(10)
	session.select_order("standard")
	await _prepare_lobby()
	if not await until(func(): return session.active): return false
	check(session.order_id == "standard" and session.level._delivered_total() == 0 and session.level._play_time_elapsed < 3.0, "next standard order starts with clean progress and timer")
	return await _partial_order_flow()

func _partial_order_flow() -> bool:
	var prior_record: Dictionary = session.room_record.duplicate(true)
	var parcel: Package = session.level.get_node("Gameplay/Package")
	parcel.recover_to(Transform3D(Basis.IDENTITY, session.level.delivery_zone.global_position))
	if not await until(func(): return session.level._delivered_total() == 1): return false
	_phase.rpc("finish-request", [])
	if not await until(func(): return session.finish_pending): return false
	check(session.finish_votes.slice(0, 2) == [false, true] and not session.finished, "participant requests finish but cannot end order alone")
	var cancelled_serial: int = session.finish_serial
	await capture("finish-request-host")
	session.finish_continue.pressed.emit()
	if not await until(func(): return not session.finish_pending): return false
	check(session.level._delivered_total() == 1 and not session.finished, "declining finish preserves active order progress")
	check(session.room_record == prior_record, "cancelled finish request does not record unfinished order")
	_phase.rpc("finish-cancelled", [])
	if not await until(func(): return client_events.has("finish-cancelled")): return false
	session._handle_finish_vote(1, session.generation, cancelled_serial, true)
	check(not session.finished and not session.finish_pending, "late vote cannot revive cancelled request")
	session.finish_request_button.pressed.emit()
	check(session.finish_pending and session.finish_votes.slice(0, 2) == [true, false], "host finish request waits for participant")
	_phase.rpc("finish-accept", [cancelled_serial])
	if not await until(func(): return session.finished): return false
	check(session.level._delivered_total() == 1 and session.level._total_target() == 2 and "1/2" in session.status.text, "partial result records actual deliveries without awarding remainder")
	check(session.room_record.orders == prior_record.orders + 1 and session.room_record.delivered == prior_record.delivered + 1 and session.room_record.complete == prior_record.complete, "partial order increments actual deliveries and order count without full completion")
	var recorded: Dictionary = session.room_record.duplicate(true)
	session._display_result(session.generation, "", 0.0, [0, 0])
	check(session.room_record == recorded, "duplicate result cannot count the same order twice")
	var remaining: Package = session.level.get_node("Gameplay/Package202")
	session.level.second_zone._on_body_entered(remaining)
	check(not remaining.is_delivered() and remaining.freeze and session.level._delivered_total() == 1, "closed order freezes remaining parcel and rejects late delivery")
	var elapsed: float = session.level._play_time_elapsed
	await frames(20)
	check(is_equal_approx(elapsed, session.level._play_time_elapsed) and not session.finish_panel.visible, "partial result freezes timer and dismisses vote")
	await capture("finish-partial-result-host")
	if not await until(func(): return client_events.has("finish-accepted")): return false
	session.return_lobby_button.pressed.emit()
	await frames(10)
	session.request_order_finish()
	check(session.in_lobby and not session.finish_pending and not session.finish_request_button.visible, "partial result returns to same lobby without allowing lobby finish votes")
	if not await _check_room_history(): return false
	await _prepare_lobby()
	if not await until(func(): return session.active): return false
	check(session.level._delivered_total() == 0 and session.level.second_zone.accepting_deliveries, "next order starts fresh and accepts deliveries again")
	var listening_peer: ENetMultiplayerPeer = session.peer
	session.request_order_finish()
	_phase.rpc("finish-disconnect", [])
	if not await until(func(): return session.in_lobby and not session.lobby_joined): return false
	check(session.peer == listening_peer and not session.finish_pending and not session.finish_panel.visible and session.level == null, "disconnect during finish request cleans vote and retains host room")
	if not await until(func(): return client_events.has("finish-rejoined")): return false
	await _prepare_lobby()
	if not await until(func(): return session.active): return false
	session.request_order_finish()
	_phase.rpc("finish-zero", [])
	if not await until(func(): return session.finished and client_events.has("finish-zero")): return false
	check(session.level._delivered_total() == 0 and "0/2" in session.status.text, "host zero result does not award unattempted deliveries")
	check(session.room_record.delivered == recorded.delivered and session.room_record.orders == recorded.orders + 1 and session.room_record.recent[0].delivered == 0, "zero result adds an order without phantom deliveries")
	session.return_to_lobby()
	await frames(10)
	if not await _check_room_history(): return false
	await _prepare_lobby()
	if not await until(func(): return session.active): return false
	if not await _finish_order_fixture(): return false
	check(session.room_record.orders == prior_record.orders + 3 and session.room_record.complete == prior_record.complete + 1 and session.room_record.delivered == prior_record.delivered + 3 and session.room_record.target == prior_record.target + 6, "completed and partial orders retain full session totals")
	check(session.room_record.recent.size() == 5 and session.room_record.recent[0].number == session.room_record.orders and session.room_record.recent[4].number == session.room_record.orders - 4, "recent history caps at five while cumulative totals include older orders")
	session.return_to_lobby()
	await frames(10)
	if not await _check_room_history(): return false
	await _prepare_lobby()
	return await until(func(): return session.active)

func _carry_help_flow(aims: Array, parcel: Package) -> bool:
	_phase.rpc("help-grab", aims)
	if not await until(func(): return session.level.player.held_grabbable == parcel): return false
	session._toggle_carry_help(session.generation - 1, 0)
	session._toggle_carry_help(session.generation, 1)
	check(session.help_packages.all(func(item): return item.is_empty()), "stale round and player without parcel cannot create carry requests")
	var key := InputEventKey.new()
	key.physical_keycode = KEY_G
	key.pressed = true
	session._input(key)
	check(session.help_packages[0] == str(parcel.name), "G requests help for actual held parcel")
	_phase.rpc("help-observe", [])
	if not await until(func(): return client_events.has("help-observed")): return false
	session._input(key)
	check(session.help_packages[0].is_empty(), "G cancels own active carry request")
	session.request_carry_help()
	session.help_deadlines[0] = Time.get_ticks_msec() - 1
	session._advance_carry_help()
	check(session.help_packages[0].is_empty(), "expired carry request is cleared by host clock")
	session.request_carry_help()
	_phase.rpc("grab", aims)
	if not await until(func(): return parcel.get_grabber_count() == 2 and session.help_packages[0].is_empty()): return false
	check(true, "shared grip completes request automatically without extra input")
	Input.action_release("grab_object")
	_phase.rpc("help-client-request", [])
	if not await until(func(): return not session.help_packages[1].is_empty()): return false
	session._update_carry_help()
	check(session.help_packages[1] == str(parcel.name) and session.help_marker.visible, "participant can request held parcel and host sees marker")
	await capture("carry-help-host")
	_phase.rpc("help-client-cancel", [])
	if not await until(func(): return session.help_packages[1].is_empty()): return false
	check(true, "participant cancels request through host authority")
	return true

func _check_room_history() -> bool:
	session.room_ui.history_button.pressed.emit()
	check(session.history_panel.visible and not session.panel.visible, "host opens room record from lobby")
	check(str(session.room_record.orders) + "건" in session.history_text.text and "부분 종료" in session.history_text.text, "history displays total orders and partial status")
	await capture("room-history-host-" + str(session.room_record.orders))
	session._close_history()
	_phase.rpc("history-check", [session.room_record])
	return await until(func(): return client_events.has("history-" + str(session.room_record.orders)))

func _manifest_check() -> void:
	var tab := InputEventKey.new()
	tab.physical_keycode = KEY_TAB
	tab.pressed = true
	session._input(tab)
	check(session.manifest_panel.visible and not session.menu_open, "Tab opens live manifest without pausing input")
	check("201호 #1" in session.manifest_text.text and "202호 #1" in session.manifest_text.text and "15kg" in session.manifest_text.text, "manifest lists actual order parcels and weights")
	check("운반 대기" in session.manifest_text.text and "나와" in session.manifest_text.text, "manifest reports available parcels and local distance")
	await capture("online-manifest-host" if session.hosting else "online-manifest-client")
	tab.pressed = false
	session._input(tab)
	check(not session.manifest_panel.visible, "Tab release closes manifest")
	tab.pressed = true
	session._input(tab)
	session._open_menu()
	session._update_manifest()
	check(not session.manifest_panel.visible and not session.manifest_held, "menu clears held manifest")
	session._resume()
	session._update_manifest()
	check(not session.manifest_panel.visible, "resume does not reopen stale manifest")

func _course_sessions() -> bool:
	if not await _finish_order_fixture(): return false
	session.return_to_lobby()
	await frames(10)
	session.select_order("course")
	check(session.course.index == 0 and session.order_id == "standard", "course selection starts with standard delivery")
	var measured_time := 0.0
	for index in 3:
		check(session.course.index == index and session.order_id == session.COURSE_ORDERS[index], "course selects correct order in sequence")
		_phase.rpc("course-lobby", [session.course])
		if not await until(func(): return client_events.has("course-lobby-" + str(index))): return false
		await _prepare_lobby()
		if not await until(func(): return session.active): return false
		if index == 1:
			var before_disconnect: Dictionary = session.course.duplicate(true)
			_phase.rpc("course-rejoin", [before_disconnect])
			if not await until(func(): return session.in_lobby and not session.lobby_joined): return false
			check(session.course == before_disconnect and session.order_id == "mixed", "interrupted course retains finished stages without skipping current order")
			if not await until(func(): return client_events.has("course-rejoined")): return false
			await _prepare_lobby()
			if not await until(func(): return session.active): return false
		await frames(75)
		if not await _finish_order_fixture(): return false
		measured_time += float(session.level._play_time_elapsed)
		check(is_equal_approx(session.course.elapsed, measured_time) and session.course.elapsed > 0.0, "course time equals sum of completed stage clocks")
		check(session.course.completed == index + 1 and session.course.closed == (index == 2), "course records each completed stage once")
		var epoch: int = session.generation
		session.restart_world()
		check(session.generation == epoch and session.finished, "counted course stage cannot be restarted to duplicate totals")
		_phase.rpc("course-result", [session.course])
		if not await until(func(): return client_events.has("course-result-" + str(index))): return false
		if index == 2:
			check(session.course.delivered == 7 and "코스 완료!" in session.status.text and "7/7" in session.status.text, "three-stage course ends with seven actual deliveries")
			await capture("course-complete-host")
		session.return_to_lobby()
		await frames(10)
		check(not session.readiness[0] and not session.readiness[1], "course transition clears both players readiness")
	check(session.course.is_empty() and session.order_id == "standard", "completed course returns to single-order selection")
	session.select_order("course")
	session.toggle_ready()
	session.select_order("standard")
	check(session.course.is_empty() and not session.readiness[0], "switching to individual order exits course and clears ready")
	session.select_order("course")
	await _prepare_lobby()
	if not await until(func(): return session.active): return false
	var parcel: Package = session.level.get_node("Gameplay/Package")
	parcel.recover_to(Transform3D(Basis.IDENTITY, session.level.delivery_zone.global_position))
	if not await until(func(): return session.level._delivered_total() == 1): return false
	session.request_order_finish()
	_phase.rpc("finish-accept", [session.finish_serial - 1])
	if not await until(func(): return session.finished and client_events.has("finish-accepted")): return false
	check(session.course.closed and session.course.completed == 0 and session.course.delivered == 1 and "코스 마무리" in session.status.text, "partial agreement ends course with actual progress only")
	await capture("course-partial-host")
	session.return_to_lobby()
	await frames(10)
	check(session.course.is_empty(), "partial course does not auto-start remaining stages")
	await _prepare_lobby()
	return await until(func(): return session.active and session.order_id == "standard")
