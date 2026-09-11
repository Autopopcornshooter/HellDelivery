extends Node

var session: Node
var output := "user://"
var seat := 0
var members := 2
var report: FileAccess
var checks := 0
var failures := 0
var acks: Dictionary = {}
var driving := false
var port := 27928

func _physics_process(_delta: float) -> void:
	if not driving or not is_instance_valid(session.freight): return
	var van: DeliveryVan = session.freight.truck
	var desired := atan2(-van.position.x, 8.0)
	var correction := clampf(angle_difference(van.rotation.y, desired) * 3, -1, 1)
	Input.action_release("move_left")
	Input.action_release("move_right")
	if correction > 0: Input.action_press("move_right", correction)
	else: Input.action_press("move_left", -correction)

func _ready() -> void:
	session = get_parent()
	get_window().focus_exited.disconnect(session._on_window_focus_exited)
	get_window().focus_entered.disconnect(session._on_window_focus_entered)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("network-output="): output = arg.trim_prefix("network-output=")
		if arg.begins_with("freight-seat="): seat = int(arg.trim_prefix("freight-seat="))
		if arg.begins_with("freight-members="): members = int(arg.trim_prefix("freight-members="))
		if arg.begins_with("freight-port="): port = int(arg.trim_prefix("freight-port="))
	report = FileAccess.open(output.path_join("freight-%d.report.txt" % seat), FileAccess.WRITE)
	get_tree().create_timer(420).timeout.connect(func(): check(false, "freight timeout"); finish())
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	report.store_line(("PASS " if ok else "FAIL ") + message)
	report.flush()

func frames(count: int) -> void:
	for index in count: await get_tree().physics_frame

func until(condition: Callable, seconds := 20.0) -> bool:
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

func all_ack(tag: String) -> bool:
	for id in session.peer_slots:
		if id > 1 and not acks.get(tag, {}).has(id): return false
	return true

func walk_to(target: Vector2) -> bool:
	var courier: Player = session.level.player
	var reached := false
	for frame in 900:
		var direction := Vector3(target.x - courier.position.x, 0, target.y - courier.position.z)
		if direction.length() < 0.3:
			reached = true
			break
		var yaw := atan2(-direction.x, -direction.z)
		session.local_yaw = rotate_toward(session.local_yaw, yaw, 0.04)
		if absf(angle_difference(session.local_yaw, yaw)) < 0.25: Input.action_press("move_forward")
		else: Input.action_release("move_forward")
		await frames(1)
	Input.action_release("move_forward")
	await frames(8)
	check(reached, "manual carry reaches " + str(target))
	report.store_line("CARRY player=%s held=%s" % [courier.position, courier.held_grabbable]); report.flush()
	if not reached: await capture("manual-blocked")
	return reached

func manual_load(parcel: Package) -> bool:
	var courier: Player = session.level.player
	# Only the approach setup moves the courier. Parcel transport uses input.
	session.freight.exit_seat(0, true)
	courier.position = parcel.position + Vector3(0, 0.75, -1.5)
	await frames(10)
	var offset := parcel.position - courier.camera_pivot.global_position
	session.local_yaw = atan2(-offset.x, -offset.z)
	session.local_pitch = atan2(offset.y, Vector2(offset.x, offset.z).length())
	await frames(8)
	Input.action_press("grab_object")
	if not await until(func(): return courier.held_grabbable == parcel): check(false, "manual pickup"); return false
	session.local_pitch = 0
	for target in [Vector2(parcel.position.x, -75), Vector2(0, -75), Vector2(0, -69.1)]:
		if not await walk_to(target): return false
	check(courier.held_grabbable == parcel, "grab connection survives walk onto cargo ramp")
	Input.action_release("grab_object")
	check(await until(func(): return parcel.loaded_once), "manual carrying actually loads parcel")
	await frames(30)
	await capture("loaded-" + parcel.delivery_address)
	return courier.held_grabbable == null and parcel.loaded_once

func manual_unload_and_deliver() -> bool:
	var run: FreightRun = session.freight
	var van := run.truck
	var parcel := run.parcels[1]
	var courier: Player = session.level.player
	if not await walk_to(Vector2(van.position.x + 2, van.position.z - 4)): return false
	check("열림" in run.action(0, "door"), "open cargo gate for physical unloading")
	for target in [Vector2(van.position.x, van.position.z - 6), Vector2(parcel.position.x, parcel.position.z - 1.5)]:
		if not await walk_to(target): return false
	var offset := parcel.position - courier.camera_pivot.global_position
	session.local_yaw = atan2(-offset.x, -offset.z)
	session.local_pitch = atan2(offset.y, Vector2(offset.x, offset.z).length())
	await frames(8)
	Input.action_press("grab_object")
	if not await until(func(): return courier.held_grabbable == parcel): check(false, "unload pickup"); await capture("unload-blocked"); return false
	session.local_pitch = 0
	Input.action_press("move_backward")
	var exited := await until(func(): return courier.position.z < van.position.z - 6, 12)
	Input.action_release("move_backward")
	check(exited and courier.held_grabbable == parcel, "walk cargo backward off ramp without teleport")
	await capture("manual-unloaded")
	if not exited: return false
	var route: Array[Vector2] = [Vector2(-3, -14), Vector2(-3, 1), Vector2(0, 2), Vector2(0, 8), Vector2(0, 12.9), Vector2(4, 13.4), Vector2(4, 18.3), Vector2(2.4, 18.3), Vector2(2.4, 13.2), Vector2(2.4, 7.8), Vector2(5.3, 7.55)]
	for target in route:
		session.local_pitch = 0
		if not await walk_to(target): return false
	Input.action_release("grab_object")
	check(await until(func(): return parcel.is_delivered()), "physically loaded driven unloaded parcel reaches 202 through stairs")
	await capture("manual-202-delivered")
	return parcel.is_delivered()

@rpc("any_peer", "call_remote", "reliable")
func _ack(tag: String) -> void:
	if not session.hosting: return
	if not acks.has(tag): acks[tag] = {}
	acks[tag][multiplayer.get_remote_sender_id()] = true

func start_round(tag: String) -> bool:
	session.toggle_ready()
	_phase.rpc("ready", [tag])
	if not await until(func(): return session._all_ready() and all_ack(tag)): check(false, "ready barrier " + tag); return false
	session.start_delivery()
	if not await until(func(): return session.active, 45):
		report.store_line("START loading=%s ready=%s local=%s peers=%s status=%s" % [session.loading, session.ready_peers, session._local_world_ready, session.peer_slots, session.status.text]); report.flush()
		await capture("start-failed")
		check(false, "start " + tag); return false
	_phase.rpc("world", [tag])
	return await until(func(): return all_ack("world-" + tag), 45)

func _run() -> void:
	GameSettings.onboarding_seen = true
	session.port_input.value = port
	if seat > 0:
		session.address.text = "127.0.0.1"
		session.join_game()
		check(await until(func(): return session.in_lobby, 60), "client joins full delivery room")
		if session.in_lobby: _ack.rpc_id(1, "joined")
		else: finish()
		return
	session.host_game()
	if not await until(func(): return session.occupied_slots().size() == members and all_ack("joined"), 60): check(false, "party joins"); finish(); return
	check(session.full_route and session.room_ui.ready_button.disabled == false, "full route supports one to four players")
	await capture("freight-lobby")
	if not await start_round("initial"): finish(); return
	var run: FreightRun = session.freight
	var van: DeliveryVan = run.truck
	check(run.parcels.size() == 2 and run.stage == "적재" and not run.arrived, "starts with depot loading stage")
	check(not session.level.delivery_zone.accepting_deliveries, "villa cannot accept delivery before vehicle arrival")
	await frames(40)
	check(van.position.y > -0.3 and van.position.y < 0.5, "van settles on physical road")
	check(run.parcels.all(func(p): return p.condition == 100 and not p.loaded_once), "gentle depot spawn causes no damage or automatic loading")
	await capture("depot-start")
	# Actual grab from the depot, before the later transport fixture.
	var parcel: Package = run.parcels[0]
	session.level.player.position = parcel.position + Vector3(0, 0.75, -1.5)
	await frames(10)
	var offset: Vector3 = parcel.position - session.level.player.camera_pivot.global_position
	session.local_yaw = atan2(-offset.x, -offset.z)
	session.local_pitch = atan2(offset.y, Vector2(offset.x, offset.z).length())
	Input.action_press("grab_object")
	check(await until(func(): return session.level.player.held_grabbable == parcel), "depot parcel can be physically grabbed")
	Input.action_release("grab_object")
	await frames(15)
	if "freight-manual" in OS.get_cmdline_user_args():
		for body in run.parcels:
			if not await manual_load(body): finish(); return
		await capture("manual-loading-complete")
	# Transport keeps independent rigid bodies; placing inside isolates vehicle
	# dynamics from walking. This is not claimed as manual loading validation.
	if "freight-manual" not in OS.get_cmdline_user_args():
		for index in run.parcels.size():
			run.parcels[index].recover_to(Transform3D(Basis.IDENTITY, van.to_global(Vector3(-0.5 + index, 1.6, -1.3))))
	check(await until(func(): return run.parcels.all(func(p): return p.loaded_once)), "physical cargo volume records loaded packages")
	check(run.parcels.all(func(p): return p.get_parent() == session.level.get_node("Gameplay") and not p.freeze), "cargo is neither parented nor frozen to van")
	run.exit_seat(0, true)
	session.level.player.position = van.to_global(Vector3(1.8, 1, -4.0))
	await frames(5)
	check("닫힘" in run.action(0, "door") and not van.door_open, "rear door closes through proximity interaction")
	var driver := 1 if members > 1 else 0
	for slot in session.occupied_slots():
		run.exit_seat(slot, true)
		session._players()[slot].position = van.to_global(Vector3(-2.5, 1, 1.5 - slot))
	await frames(5)
	# Let the hinged collider and cargo settle before testing boarding.
	await frames(30)
	check(await until(func(): return van.linear_velocity.length() < 0.3), "loaded van is stopped before boarding")
	_phase.rpc("board-driver", [driver])
	var driver_seated := await until(func(): return van.seats[0] == driver)
	if not driver_seated:
		report.store_line("SEAT van=%s velocity=%s player=%s seats=%s reason=%s" % [van.position, van.linear_velocity, session._players()[driver].position, van.seats, run.action(driver, "seat")]); report.flush()
	check(driver_seated, "assigned player boards driver seat through RPC")
	_phase.rpc("board-rest", [driver])
	check(await until(func(): return van.seats.filter(func(slot): return slot >= 0).size() == members), "all active players can occupy independent seats")
	_phase.rpc("seated", [])
	if not await until(func(): return all_ack("seated")): check(false, "seated replicas"); finish(); return
	await capture("loaded-seated")
	_phase.rpc("drive", [driver])
	check(await until(func(): return van.position.z > -54, 15), "vehicle accelerates from controls")
	check("멈춘" in run.action(driver, "seat") and van.seats[0] == driver, "moving vehicle refuses disembark")
	check("정차" in run.action(driver, "door") and not van.door_open, "moving vehicle refuses cargo door")
	_phase.rpc("menu-stop", [driver])
	check(await until(func(): return van.linear_velocity.length() < 0.5, 10), "driver menu neutralizes accelerator and brakes")
	_phase.rpc("drive", [driver])
	if members > 1:
		await frames(90)
		_phase.rpc("stall-driver", [driver])
		check(await until(func(): return van.linear_velocity.length() < 0.5, 10), "missing remote driver input brakes authoritative van")
		_phase.rpc("resume-driver", [driver])
	check(await until(func(): return van.position.z > -10, 35), "player drives physical van from depot to villa")
	report.store_line("DRIVE position=%s velocity=%s throttle=%s enabled=%s seats=%s" % [van.position, van.linear_velocity, van.throttle, van.enabled, van.seats]); report.flush()
	_phase.rpc("brake", [driver])
	check(await until(func(): return van.linear_velocity.length() < 0.5, 10), "brake stops physical vehicle")
	check(await until(func(): return run.arrived, 8), "parking opens villa delivery stage")
	check(run.parcels.all(func(p): return van.cargo_contains(p)), "closed door retains unparented cargo during actual drive")
	check(van.health > 90 and run.parcels.all(func(p): return p.condition > 80), "normal drive does not destroy vehicle or cargo")
	_phase.rpc("exit", [])
	check(await until(func(): return van.seats.all(func(slot): return slot == -1)), "all players exit only after stopping")
	await capture("villa-arrival")
	_phase.rpc("arrived", [])
	if not await until(func(): return all_ack("arrived")): finish(); return
	if "freight-manual" in OS.get_cmdline_user_args():
		if not await manual_unload_and_deliver(): finish(); return
	for body in run.parcels:
		if body.is_delivered(): continue
		var zone: DeliveryZone = session.level.delivery_zone if body.delivery_address == "201" else session.level.second_zone
		body.recover_to(Transform3D(Basis.IDENTITY, zone.global_position))
		if not await until(func(): return body.is_delivered()):
			report.store_line("DELIVERY body=%s pos=%s state=%s freeze=%s pending=%s zone=%s accepts=%s active=%s" % [body.name, body.position, body.shipment_state(), body.freeze, body._recovery_pending, zone.global_position, zone.accepting_deliveries, session.active]); report.flush()
			check(false, "correct address delivery"); finish(); return
	check(await until(func(): return session.finished and session.shipment_result.success), "loaded transported parcels finish successfully")
	check(session.shipment_result.score > 700 and session.shipment_result.grade in ["S", "A"], "healthy timely shipment receives a high grade")
	_phase.rpc("result", ["success"])
	if not await until(func(): return all_ack("result-success")): finish(); return
	await capture("freight-success")
	session.return_to_lobby()
	await frames(15)
	check(session.room_record.get("score", 0) > 0 and session.room_record.recent[0].has("rating"), "rating persists in room history")
	if not await start_round("damage"): finish(); return
	run = session.freight
	run.parcels[0].recover_to(Transform3D(Basis.IDENTITY, Vector3(10, 10, -70)))
	check(await until(func(): return run.parcels[0].condition < 100, 10), "real falling collision damages parcel")
	check(run.parcels[0].condition > 0, "one ordinary hard impact is not instant destruction")
	run.parcels[0].condition = 100 # Known quality fixture for exact score/recovery assertions.
	run.parcels[0].apply_damage(45)
	run.truck.health = 70
	session.recover_world()
	await frames(20)
	check(run.parcels[0].condition == 55 and run.truck.health == 70 and run.recoveries == 1, "recovery preserves damage and records score penalty")
	run.truck.recover(Transform3D(Basis.IDENTITY, FreightDepot.PARK + Vector3.UP * 0.12))
	if not await until(func(): return run.arrived): check(false, "fixture park"); finish(); return
	run.parcels[0].loaded_once = true
	run.parcels[0].recover_to(Transform3D(Basis.IDENTITY, session.level.delivery_zone.global_position))
	if not await until(func(): return run.parcels[0].is_delivered()): check(false, "damaged delivery accepted"); finish(); return
	run.parcels[1].apply_damage(100)
	check(await until(func(): return session.finished), "one delivered and one destroyed resolves the order")
	check(not session.shipment_result.success and session.shipment_result.grade == "C" and session.shipment_result.delivered == 1, "partial damage failure records actual delivery and grade")
	_phase.rpc("result", ["damage"])
	if not await until(func(): return all_ack("result-damage")): finish(); return
	await capture("damage-result")
	session.restart_world()
	check(await until(func(): return session.active and not session.finished and session.freight.parcels[0].condition == 100), "retry creates fresh health cargo and deadline")
	_phase.rpc("world", ["timeout"])
	if not await until(func(): return all_ack("world-timeout")): finish(); return
	session.level._play_time_elapsed = session.freight.deadline + 1
	check(await until(func(): return session.finished), "deadline produces failure without freezing session flow")
	check(session.shipment_result.grade == "F" and session.shipment_result.delivered == 0 and session.shipment_result.reason == "시간 초과", "zero-delivery timeout has explicit F result")
	_phase.rpc("result", ["timeout"])
	if not await until(func(): return all_ack("result-timeout")): finish(); return
	await capture("timeout-result")
	session.return_to_lobby()
	await frames(15)
	session.select_order("bulk")
	if not await start_round("next-order"): finish(); return
	check(session.freight.parcels.size() == 4 and session.freight.deadline == 720 and not session.freight.arrived, "next order rebuilds depot targets and deadline")
	session.freight.parcels[0].mark_lost()
	check(session.freight.parcels[0].shipment_failed and session.freight.parcels[0].failure_reason == "분실", "lost parcel has explicit failure state")
	run = session.freight
	van = run.truck
	var loose := run.parcels[1]
	loose.recover_to(Transform3D(Basis.IDENTITY, van.to_global(Vector3(0, 1.6, -2.0))))
	check(await until(func(): return loose.loaded_once), "loose cargo setup is physically inside van")
	run.exit_seat(0, true)
	session.level.player.position = van.to_global(Vector3(0.7, 1.95, -0.6))
	await frames(8)
	session.request_personal_recovery()
	await frames(20)
	check(van.health > 95 and loose.condition > 95 and van.linear_velocity.length() < 1, "personal recovery from cargo bay does not launch or damage freight")
	session.level.player.position = van.to_global(Vector3(-2.5, 1, 1.5))
	run.action(0, "seat")
	Input.action_press("move_forward")
	check(await until(func(): return not van.cargo_contains(loose) and loose.position.z < van.position.z - 3.0, 12), "open gate lets free cargo slide out during acceleration")
	Input.action_release("move_forward")
	check(await until(func(): return van.linear_velocity.length() < 0.5), "spill test vehicle stops")
	run.exit_seat(0, true)
	van.recover(Transform3D(Basis.IDENTITY, Vector3(28, 0.1, -60)))
	await frames(80)
	van.linear_velocity = Vector3(14, 0, 0)
	check(await until(func(): return van.health < 100, 8), "real barrier collision damages vehicle")
	van.health = 0 # Exact total-breakdown fixture after proving physical damage.
	check(await until(func(): return session.finished), "total vehicle breakdown resolves failure instead of stranding flow")
	check(session.shipment_result.reason == "차량 파손 · 운행 불가", "vehicle failure has explicit result reason")
	_phase.rpc("result", ["vehicle"])
	if not await until(func(): return all_ack("result-vehicle")): finish(); return
	session.return_to_lobby()
	await frames(15)
	session.select_order("course")
	for index in 3:
		var tag := "course-%d" % index
		if not await start_round(tag): finish(); return
		run = session.freight
		check(run.parcels.size() == [2, 3, 2][index], "full course creates target manifest " + tag)
		run.truck.recover(Transform3D(Basis.IDENTITY, FreightDepot.PARK + Vector3.UP * 0.12))
		if not await until(func(): return run.arrived): check(false, "course parking fixture"); finish(); return
		for body in run.parcels:
			body.loaded_once = true # Evaluation fixture, not a claim of manual heavy loading.
			var zone: DeliveryZone = session.level.delivery_zone if body.delivery_address == "201" else session.level.second_zone
			body.recover_to(Transform3D(Basis.IDENTITY, zone.global_position))
			if not await until(func(): return body.is_delivered()): check(false, "course delivery " + tag); finish(); return
		check(await until(func(): return session.finished and session.shipment_result.success), "full course rates actual addresses " + tag)
		_phase.rpc("result", [tag])
		if not await until(func(): return all_ack("result-" + tag)): finish(); return
		if index < 2:
			session.return_to_lobby()
			await frames(15)
	check(session.course.closed and session.course.completed == 3 and session.course.delivered == 7, "three rated orders finish full delivery course without losing party")
	run.truck.health = 0
	check(not run.evaluate("차량 파손 · 운행 불가").success, "all parcels cannot override vehicle failure")
	run.truck.health = 100
	var previous_elapsed: float = session.level._play_time_elapsed
	session.level._play_time_elapsed = run.deadline
	check(not run.evaluate("시간 초과").success, "deadline boundary cannot become a successful order")
	session.level._play_time_elapsed = previous_elapsed
	await capture("freight-course-complete")
	_phase.rpc("shutdown", [])
	if not await until(func(): return all_ack("shutdown")): finish(); return
	session._connection_ended("freight test complete")
	await frames(90)
	finish()

@rpc("authority", "call_local", "reliable")
func _phase(tag: String, data: Array) -> void:
	if tag == "ready" and not session.hosting:
		if not await until(func(): return session.in_lobby): return
		if not session.readiness[session.local_slot]: session.toggle_ready()
		if await until(func(): return session.readiness[session.local_slot]): _ack.rpc_id(1, data[0])
	elif tag == "world" and not session.hosting:
		check(await until(func(): return session.active and not session.finished and is_instance_valid(session.freight), 45), "client enters shipment " + data[0])
		check(session.freight.truck.freeze and session.freight.parcels.all(func(p): return p.freeze), "client never simulates cargo or vehicle authority")
		_ack.rpc_id(1, "world-" + data[0])
	elif tag == "board-driver" and session.local_slot == data[0]:
		print("BOARD active=", session.active, " menu=", session.menu_open, " finished=", session.finished)
		session.request_vehicle_action("seat")
	elif tag == "board-rest" and session.local_slot != data[0]: session.request_vehicle_action("seat")
	elif tag == "seated" and not session.hosting:
		check(await until(func(): return session.freight.truck.seat_of(session.local_slot) >= 0 and session.freight.truck.camera.current), "passenger gets vehicle camera from authoritative seat")
		await capture("seated-view")
		_ack.rpc_id(1, tag)
	elif tag == "drive" and session.local_slot == data[0]:
		if session.menu_open: session._resume()
		driving = true
		Input.action_press("move_forward")
	elif tag == "menu-stop" and session.local_slot == data[0]:
		driving = false
		session._open_menu()
	elif tag == "stall-driver" and session.local_slot == data[0]: session.set_physics_process(false)
	elif tag == "resume-driver" and session.local_slot == data[0]: session.set_physics_process(true)
	elif tag == "brake" and session.local_slot == data[0]:
		driving = false
		Input.action_release("move_left")
		Input.action_release("move_right")
		Input.action_release("move_forward")
		Input.action_press("jump")
	elif tag == "exit":
		Input.action_release("jump")
		session.request_vehicle_action("seat")
	elif tag == "arrived" and not session.hosting:
		check(await until(func(): return session.freight.arrived and session.freight.truck.seat_of(session.local_slot) < 0), "arrival and disembark replicate")
		check(session._players()[session.local_slot].camera_pivot.get_node("Camera3D").current, "on-foot camera restored on exit")
		await capture("arrival-view")
		_ack.rpc_id(1, tag)
	elif tag == "result" and not session.hosting:
		check(await until(func(): return session.finished and not session.shipment_result.is_empty()), "client receives authoritative rating " + data[0])
		check(session.shipment_result.grade in session._panel_title.text, "rating appears in result screen")
		await capture("result-" + data[0])
		_ack.rpc_id(1, "result-" + data[0])
	elif tag == "shutdown" and not session.hosting:
		_ack.rpc_id(1, tag)
		check(await until(func(): return session.peer == null and session.level == null), "shutdown frees vehicle and shipment")
		finish()
