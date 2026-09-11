extends Node

var session: Node
var report: FileAccess
var output := "user://"
var seat := 0
var checks := 0
var failures := 0
var acks: Dictionary = {}
var before_move: Array[Vector3] = []

func _ready() -> void:
	session = get_parent()
	get_window().focus_exited.disconnect(session._on_window_focus_exited)
	get_window().focus_entered.disconnect(session._on_window_focus_entered)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("network-output="): output = arg.trim_prefix("network-output=")
		if arg.begins_with("party-seat="): seat = int(arg.trim_prefix("party-seat="))
	report = FileAccess.open(output.path_join("party-%d.report.txt" % seat), FileAccess.WRITE)
	get_tree().create_timer(540).timeout.connect(func(): check(false, "party timeout"); finish())
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	report.store_line(("PASS " if ok else "FAIL ") + message)
	report.flush()

func frames(count: int) -> void:
	for index in count: await get_tree().physics_frame

func until(condition: Callable, seconds: float = 30.0) -> bool:
	var end := Time.get_ticks_msec() + int(seconds * 1000)
	while Time.get_ticks_msec() < end:
		if condition.call(): return true
		await frames(1)
	return false

func capture(label: String) -> void:
	if "network-visual" not in OS.get_cmdline_user_args(): return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(output.path_join("p%d-%s.png" % [seat + 1, label]))

func finish() -> void:
	report.store_line("EXIT %d checks=%d failures=%d" % [0 if failures == 0 else 1, checks, failures])
	report.flush()
	get_tree().quit(0 if failures == 0 else 1)

func _run() -> void:
	GameSettings.onboarding_seen = true
	session.port_input.value = 27927
	if seat > 0:
		session.address.text = "127.0.0.1"
		session.join_game()
		check(await until(func(): return session.in_lobby, 90), "client joins party lobby")
		if not session.in_lobby: finish(); return
		check(session.local_slot > 0 and session.peer_slots[session.local_slot] == multiplayer.get_unique_id(), "server assigns stable local player slot")
		_ack.rpc_id(1, "joined")
		return
	session.host_game()
	check(await until(func(): return session.occupied_slots().size() == 4 and _all_ack("joined"), 90), "four real ENet peers populate roster")
	if session.occupied_slots().size() != 4: finish(); return
	await capture("four-lobby")
	session.select_order("team")
	if not await start_round("four-start"): finish(); return
	check(session._players().filter(func(p): return p.visible).size() == 4, "host simulates four visible couriers")
	for courier in session._players(): before_move.append(courier.position)
	_phase.rpc("move", [])
	await until(func(): return range(1, 4).all(func(slot): return session._players()[slot].position.distance_to(before_move[slot]) > 0.3), 8)
	_phase.rpc("stop", [])
	await frames(15)
	for slot in range(1, 4): check(session._players()[slot].position.distance_to(before_move[slot]) > 0.3, "remote P%d movement is independent" % (slot + 1))
	check(session.level.player.position.distance_to(before_move[0]) < 0.2, "remote input does not move host")
	_phase.rpc("move", [])
	await frames(20)
	_phase.rpc("stall-third", [])
	check(await until(func(): return session.level.couriers[2].network_move == Vector2.ZERO and Time.get_ticks_msec() - int(session.slot_last_input.get(2, 0)) > 500, 5), "missing P3 input is neutralized")
	check(session.level.player2.network_move.length() > 0.1 and session.level.couriers[3].network_move.length() > 0.1, "P3 input stall does not stop other clients")
	check("P3" in session._connection_quality(), "host identifies the stalled player")
	_phase.rpc("resume-third", [])
	_phase.rpc("stop", [])
	session.recover_world()
	await frames(20)
	var parcel: Package = session.level.get_node("Gameplay/Package")
	# Use open roadway: the truck occupies the central loading strip.
	var locations := [Vector3(9.1, 1, -18.2), Vector3(10.9, 1, -18.2), Vector3(9.1, 1, -15.8), Vector3(10.9, 1, -15.8)]
	for slot in 4: session._players()[slot].position = locations[slot]
	parcel.recover_to(Transform3D(Basis.IDENTITY, Vector3(10, 1.35, -17)))
	await frames(35)
	var aims: Array = []
	for courier in session._players():
		var delta: Vector3 = parcel.global_position - courier.camera_pivot.global_position
		aims.append(Vector2(atan2(-delta.x, -delta.z), atan2(delta.y, Vector2(delta.x, delta.z).length())))
	_phase.rpc("grab-third", aims)
	check(await until(func(): return parcel.has_grabber(session.level.couriers[2]), 8), "P3 can grab independently")
	_phase.rpc("help-third", [])
	check(await until(func(): return session.help_packages[2] == str(parcel.name), 5), "P3 carry help is attributed to P3")
	_phase.rpc("help-view", [])
	if not await until(func(): return _all_ack("help-view")): check(false, "help broadcast acknowledgement"); finish(); return
	_phase.rpc("grab", aims)
	check(await until(func(): return parcel.get_grabber_count() == 4, 12), "four players grab the same heavy parcel")
	report.store_line("DIAG parcel=%s count=%d inputs=%s" % [parcel.position, parcel.get_grabber_count(), session.slot_inputs]); report.flush()
	for courier in session._players():
		report.store_line("DIAG courier=%s pos=%s held=%s aim=%s" % [courier.name, courier.position, courier.held_grabbable, courier._last_grab_aim_state]); report.flush()
	await capture("four-shared-grip")
	_phase.rpc("shared-view", [])
	if not await until(func(): return _all_ack("shared-view")): finish(); return
	_phase.rpc("recover-last", [])
	check(await until(func(): return parcel.get_grabber_count() == 3 and session.level.couriers[3].position.z < -12, 12), "P4 personal recovery releases only P4 grip and restores P4 spawn")
	check(session.level.player.held_grabbable == parcel and session.level.player2.held_grabbable == parcel and session.level.couriers[2].held_grabbable == parcel, "other three grips remain after P4 recovery")
	_phase.rpc("stop", [])
	await frames(20)
	session.request_order_finish()
	_phase.rpc("vote-others", [])
	check(await until(func(): return session.finish_votes[1] and session.finish_votes[2]), "P2 and P3 agreement reaches host")
	check(not session.finished and not session.finish_votes[3], "three votes cannot finish a four-player order")
	await capture("four-votes-wait")
	_phase.rpc("vote-last", [])
	check(await until(func(): return session.finished), "fourth vote closes order")
	_phase.rpc("result", [0, "four-result"])
	if not await until(func(): return _all_ack("four-result")): finish(); return
	session.return_to_lobby()
	await frames(15)
	_phase.rpc("leave-last", [])
	check(await until(func(): return session.occupied_slots().size() == 3), "one lobby departure retains three-player room")
	check(session.readiness.all(func(r): return not r) and not session.room_ui.previews[3].visible, "departure clears readiness and vacant preview")
	if not await start_round("three-start"): finish(); return
	check(not session.level.couriers[3].visible and not session.level.couriers[3].is_physics_processing(), "empty slot has no active courier")
	var probe := FileAccess.open(output.path_join("probe-active.signal"), FileAccess.WRITE)
	probe.store_string("probe"); probe.close()
	check(await until(func(): return FileAccess.file_exists(output.path_join("probe-done.signal")), 30), "late join rejection completes")
	check(session.active and session.occupied_slots().size() == 3, "rejected late join preserves active three-player delivery")
	if not await deliver_all(): finish(); return
	_phase.rpc("result", [2, "three-result"])
	if not await until(func(): return _all_ack("three-result")): finish(); return
	session.return_to_lobby()
	await frames(15)
	var signal_file := FileAccess.open(output.path_join("rejoin.signal"), FileAccess.WRITE)
	signal_file.store_string("join"); signal_file.close()
	check(await until(func(): return session.occupied_slots().size() == 4 and acks.get("rejoined", {}).has(session.peer_slots[3]), 60), "departed player rejoins same host room")
	if not await start_round("four-rejoin-start"): finish(); return
	_phase.rpc("drop-middle-active", [])
	check(await until(func(): return session.in_lobby and session.occupied_slots().size() == 3), "active departure returns all remaining players to lobby")
	check(session.peer_slots[1] == 0 and session.peer_slots[2] != 0 and session.peer_slots[3] != 0, "middle slot departure preserves P3 and P4 identities")
	_phase.rpc("remaining-lobby", [])
	if not await until(func(): return _all_ack("remaining-lobby")): finish(); return
	var again := FileAccess.open(output.path_join("rejoin-active.signal"), FileAccess.WRITE)
	again.store_string("join"); again.close()
	check(await until(func(): return session.occupied_slots().size() == 4 and acks.get("active-rejoined", {}).has(session.peer_slots[1]), 60), "active departure can rejoin without recreating room")
	session.select_order("course")
	for stage in 3:
		if not await start_round("course-%d" % stage): finish(); return
		check(session.course.index == stage, "four-player course stage sequence")
		if not await deliver_all(): finish(); return
		_phase.rpc("result", [session.level._total_target(), "course-result-%d" % stage])
		if not await until(func(): return _all_ack("course-result-%d" % stage)): finish(); return
		if stage == 2: check(session.course.delivered == 7 and session.course.completed == 3, "four-player course records seven deliveries")
		session.return_to_lobby()
		await frames(15)
	await capture("party-course-finished")
	_phase.rpc("host-shutdown", [])
	check(await until(func(): return _all_ack("shutdown-ready")), "all clients observe shutdown test barrier")
	session._connection_ended("party test finished")
	check(session.peer == null and session.level == null, "host shutdown cleans party world")
	await frames(90)
	finish()

func start_round(tag: String) -> bool:
	acks.erase(tag)
	session.toggle_ready()
	_phase.rpc("ready", [tag])
	if not await until(func(): return session._all_ready() and _all_ack(tag)): check(false, "all members ready " + tag); return false
	session.start_delivery()
	if not await until(func(): return session.active): check(false, "world starts " + tag); return false
	_phase.rpc("world", [tag])
	return await until(func(): return _all_ack("world-" + tag))

func deliver_all() -> bool:
	for body in session._bodies():
		if not body is Package or body.is_delivered(): continue
		var zone: DeliveryZone = session.level.delivery_zone if body.delivery_address == "201" else session.level.second_zone
		var before := zone.delivered_count
		body.recover_to(Transform3D(Basis.IDENTITY, zone.global_position))
		if not await until(func(): return zone.delivered_count == before + 1): check(false, "party fixture delivery"); return false
	return await until(func(): return session.finished)

func _all_ack(tag: String) -> bool:
	for id in session.peer_slots:
		if id != 0 and id != 1 and not acks.get(tag, {}).has(id): return false
	return true

@rpc("any_peer", "call_remote", "reliable")
func _ack(tag: String) -> void:
	if not session.hosting: return
	if not acks.has(tag): acks[tag] = {}
	acks[tag][multiplayer.get_remote_sender_id()] = true

@rpc("authority", "call_local", "reliable")
func _phase(tag: String, data: Array) -> void:
	if tag == "ready" and not session.hosting:
		if not await until(func(): return session.in_lobby): return
		session.select_lobby_character(CharacterCatalog.get_all()[seat + 2].id)
		if not await until(func(): return session._characters[session.local_slot] == GameSettings.selected_character_id): return
		if not session.readiness[session.local_slot]: session.toggle_ready()
		if await until(func(): return session.readiness[session.local_slot]): _ack.rpc_id(1, data[0])
	elif tag == "world" and not session.hosting:
		check(await until(func(): return session.active), "client starts " + data[0])
		if not session.active: return
		check(session._players().filter(func(p): return p.visible).size() == session.occupied_slots().size(), "replica count matches active roster")
		check(session._players()[session.local_slot].camera_pivot.get_node("Camera3D").current, "correct own camera for assigned slot")
		check(session._bodies().all(func(b): return b.freeze), "client does not own parcel physics")
		await capture(data[0])
		_ack.rpc_id(1, "world-" + data[0])
	elif tag == "move" and not session.hosting:
		report.store_line("DIAG move slot=%d active=%s menu=%s focus=%s" % [session.local_slot, session.active, session.menu_open, session._window_unfocused]); report.flush()
		session.local_yaw = 0
		Input.action_press("move_forward")
	elif tag == "stall-third" and session.local_slot == 2:
		session.set_physics_process(false)
	elif tag == "resume-third" and session.local_slot == 2:
		session.set_physics_process(true)
	elif tag == "stop":
		Input.action_release("move_forward")
		Input.action_release("grab_object")
	elif tag == "grab" or (tag == "grab-third" and session.local_slot == 2):
		session.local_yaw = data[session.local_slot].x
		session.local_pitch = data[session.local_slot].y
		Input.action_press("grab_object")
	elif tag == "help-third" and session.local_slot == 2:
		session.request_carry_help()
	elif tag == "help-view" and not session.hosting:
		check(await until(func(): return not session.help_packages[2].is_empty()), "P3 help reaches every client")
		_ack.rpc_id(1, tag)
	elif tag == "shared-view" and not session.hosting:
		check(await until(func(): return session._players().all(func(p): return p.held_grabbable != null)), "all four carry poses reach client")
		await capture("shared-grip")
		_ack.rpc_id(1, tag)
	elif tag == "recover-last" and session.local_slot == 3:
		session._open_menu(); session.request_personal_recovery()
	elif tag == "vote-others" and not session.hosting and session.local_slot != 3:
		if await until(func(): return session.finish_pending): session.vote_order_finish(true)
	elif tag == "vote-last" and session.local_slot == 3:
		if await until(func(): return session.finish_pending): session.vote_order_finish(true)
	elif tag == "result" and not session.hosting:
		check(await until(func(): return session.finished), "client receives result " + data[1])
		check(session.level._delivered_total() == data[0], "authoritative delivery count on client")
		await capture(data[1])
		_ack.rpc_id(1, data[1])
	elif (tag == "leave-last" and session.local_slot == 3) or (tag == "drop-middle-active" and session.local_slot == 1):
		session._connection_ended("test leave")
		if tag == "leave-last":
			if not await until(func(): return FileAccess.file_exists(output.path_join("probe-active.signal")), 90): return
			session.join_game()
			check(await until(func(): return session.peer == null and "배송 진행 중" in session.status.text, 20), "joining an active room explains rejection without hanging")
			var probe_done := FileAccess.open(output.path_join("probe-done.signal"), FileAccess.WRITE)
			probe_done.store_string("done"); probe_done.close()
		var signal_name := "rejoin.signal" if tag == "leave-last" else "rejoin-active.signal"
		if not await until(func(): return FileAccess.file_exists(output.path_join(signal_name)), 90): return
		session.join_game()
		check(await until(func(): return session.in_lobby), "departed client rejoins")
		_ack.rpc_id(1, "rejoined" if tag == "leave-last" else "active-rejoined")
	elif tag == "remaining-lobby" and not session.hosting:
		check(await until(func(): return session.in_lobby and session.level == null), "remaining client leaves interrupted world")
		check(session.occupied_slots().size() == 3, "remaining client receives reduced roster")
		_ack.rpc_id(1, tag)
	elif tag == "host-shutdown" and not session.hosting:
		_ack.rpc_id(1, "shutdown-ready")
		check(await until(func(): return session.peer == null and session.level == null), "host shutdown cleans client")
		finish()
