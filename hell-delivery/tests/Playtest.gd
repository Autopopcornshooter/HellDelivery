extends Node

var root: Window:
	get: return get_tree().root
var current_scene: Node:
	get: return get_tree().current_scene
var paused: bool:
	get: return get_tree().paused
	set(value): get_tree().paused = value

var failures: int = 0
var checks: int = 0
var settings: Node
var visual: bool = false
var report: FileAccess
var report_path: String = "user://self-test.report.txt"


func _ready() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("report-path="):
			report_path = arg.trim_prefix("report-path=")
	report = FileAccess.open(report_path, FileAccess.WRITE)
	report.store_line("START exported=" + str(OS.has_feature("template")))
	report.flush()
	var licenses := FileAccess.open(report_path.get_base_dir().path_join("GODOT_LICENSES.txt"), FileAccess.WRITE)
	licenses.store_string(Engine.get_license_text() + "\n\nThird-party components:\n")
	licenses.store_string(JSON.stringify(Engine.get_copyright_info(), "  ") + "\n")
	licenses.store_string(JSON.stringify(Engine.get_license_info(), "  "))
	licenses.close()
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Keep the harness alive while exercising real scene changes.
	get_tree().current_scene = null
	get_tree().create_timer(300.0 if "multi-route" in OS.get_cmdline_user_args() or "coop" in OS.get_cmdline_user_args() else 120.0).timeout.connect(func():
		print("FAIL test timeout")
		quit(2))
	_run.call_deferred()


func quit(code: int) -> void:
	report.store_line("EXIT %d checks=%d failures=%d" % [code, checks, failures])
	report.flush()
	get_tree().quit(code)


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
	print("PASS " if condition else "FAIL ", label)
	report.store_line(("PASS " if condition else "FAIL ") + label)
	report.flush()


func frames(count: int) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame


func capture(label: String) -> void:
	if not visual:
		return
	await frames(10)
	await RenderingServer.frame_post_draw
	var output_dir: String = report_path.get_base_dir()
	root.get_texture().get_image().save_png(output_dir.path_join("%s.png" % label))


func enter(path: String) -> Node:
	paused = false
	get_tree().change_scene_to_file(path)
	await frames(6)
	return current_scene


func _run() -> void:
	settings = root.get_node("GameSettings")
	if "settings-write" in OS.get_cmdline_user_args() or "settings-read" in OS.get_cmdline_user_args():
		persistence_test("settings-write" in OS.get_cmdline_user_args())
		quit(1 if failures else 0)
		return
	# Tests change in-memory settings only; never replace the user's settings file.
	settings.onboarding_seen = true
	visual = "visual" in OS.get_cmdline_user_args()
	if "grab-contact" in OS.get_cmdline_user_args():
		await grab_contact_test()
		quit(1 if failures else 0)
		return
	if "coop-performance" in OS.get_cmdline_user_args():
		await coop_performance_test()
		quit(1 if failures else 0)
		return
	if "coop" in OS.get_cmdline_user_args():
		await villa_coop_test()
		if failures == 0:
			await villa_coop_route()
		if failures == 0:
			await coop_repeat_test()
		quit(1 if failures else 0)
		return
	if "repeat" in OS.get_cmdline_user_args():
		await repeat_session_test()
		quit(1 if failures else 0)
		return
	if "multi-test" in OS.get_cmdline_user_args():
		await multi_stop_test()
		quit(1 if failures else 0)
		return
	if "multi-route" in OS.get_cmdline_user_args():
		await multi_stop_route()
		quit(1 if failures else 0)
		return
	if "performance" in OS.get_cmdline_user_args():
		await performance_test()
		quit(1 if failures else 0)
		return
	if "inspect" in OS.get_cmdline_user_args():
		await inspect_visual()
		quit(0)
		return
	if "route" in OS.get_cmdline_user_args():
		await route()
		quit(failures)
		return
	await grab_contact_test()
	var menu: Node = await enter("res://scenes/ui/MainMenu.tscn")
	check(menu.get_node("LeftColumn/CenterContainer/VBoxContainer/FullDeliveryButton").has_focus(), "menu focuses full delivery entry")
	await capture("01-menu")
	menu.get_node("LeftColumn/CenterContainer/VBoxContainer/FullDeliveryButton").pressed.emit()
	await frames(6)
	check(current_scene.full_route and "1~4인" in current_scene._panel_title.text, "main menu opens full delivery connection flow")
	await capture("52-full-delivery-connection")
	current_scene.leave()
	await frames(6)
	menu = current_scene
	menu.get_node("LeftColumn/CenterContainer/VBoxContainer/OnlineButton").pressed.emit()
	await frames(6)
	check(current_scene.scene_file_path.ends_with("OnlineSession.tscn") and current_scene.panel.visible, "menu opens online connection screen")
	await capture("49-online-connection")
	for sample in [[" 127.0.0.1:34567 ", ["127.0.0.1", 34567]], ["[::1]:34567", ["::1", 34567]], ["::1", ["::1", 27926]], ["127.0.0.1:99999", []], ["127.0.0.1:abc", []], ["no-host", []]]:
		check(preload("res://scenes/network/OnlineSession.gd").parse_endpoint(sample[0], 27926) == sample[1], "endpoint parser handles " + sample[0])
	var original_ip: String = GameSettings.last_server_ip
	var original_port: int = GameSettings.network_port
	GameSettings.remember_server("192.0.2.45", 34567)
	var network_settings_path := report_path.get_base_dir().path_join("network-settings.cfg")
	GameSettings.save_settings(network_settings_path)
	var restored_settings: Node = GameSettings.get_script().new()
	restored_settings.load_settings(network_settings_path)
	check(restored_settings.last_server_ip == "192.0.2.45" and restored_settings.network_port == 34567, "saved endpoint reloads from configuration")
	var invalid_network := ConfigFile.new()
	invalid_network.set_value("network", "last_server_ip", "not-an-ip")
	invalid_network.set_value("network", "port", "bad")
	invalid_network.save(network_settings_path)
	restored_settings.load_settings(network_settings_path)
	check(restored_settings.last_server_ip == "127.0.0.1" and restored_settings.network_port == 27926, "invalid saved endpoint falls back safely")
	restored_settings.free()
	GameSettings.remember_server(original_ip, original_port)
	current_scene.host_game()
	check(current_scene.peer != null and current_scene.cancel_button.visible, "online host waiting offers cancellation")
	if visual:
		var previous_clipboard := DisplayServer.clipboard_get()
		current_scene.copy_addresses.select(current_scene.copy_addresses.item_count - 1)
		current_scene.copy_button.pressed.emit()
		check(DisplayServer.clipboard_get() == "127.0.0.1:%d" % int(current_scene.port_input.value), "host copies selected endpoint to clipboard")
		await capture("51-online-copy-address")
		DisplayServer.clipboard_set(previous_clipboard)
	current_scene.cancel_button.pressed.emit()
	check(current_scene.peer == null and not current_scene.host_button.disabled and not current_scene.cancel_button.visible, "cancel releases room and restores connection controls")
	current_scene.host_game()
	current_scene._start_world(current_scene._characters, current_scene.generation + 1)
	check(current_scene.loading and current_scene.panel.visible, "loading panel appears before deferred world creation")
	current_scene.cancel_button.pressed.emit()
	await frames(6)
	check(not current_scene.loading and current_scene.level == null and current_scene.peer == null, "cancel prevents deferred world from reappearing")
	current_scene.host_game()
	current_scene._start_world(current_scene._characters, current_scene.generation + 1)
	await frames(6)
	check(current_scene.loading and current_scene._local_world_ready and not current_scene.active, "host waits for remote readiness with world paused")
	await capture("50-online-loading")
	current_scene._loading_started = Time.get_ticks_msec() - current_scene.LOAD_TIMEOUT_MS - 1
	await frames(3)
	check(current_scene.peer == null and current_scene.level == null and "시간 초과" in current_scene.status.text, "loading timeout frees world and restores connection screen")
	current_scene.leave()
	await frames(6)
	menu = current_scene
	check(menu is MainMenu and not paused, "online lobby back returns to menu without a peer")
	menu.start_button.pressed.emit()
	await frames(30)
	check(current_scene.scene_file_path.ends_with("Stage01HillsideVilla.tscn"), "menu enters villa")
	await capture("02-villa-start")
	if visual:
		var overview := Camera3D.new()
		current_scene.add_child(overview)
		overview.position = Vector3(28, 27, -29)
		overview.look_at(Vector3(0, 0, 5))
		overview.make_current()
		await capture("15-neighbourhood-overview")
		for shot in [
			["17-truck-lettering", Vector3(0, 2.05, -10.5), Vector3(0, 2.15, -8.6)],
			["18-stairhall-entry", Vector3(4.15, 1.8, 13.3), Vector3(3.2, 3, 18.8)],
			["19-stairhall-landing", Vector3(4.2, 3.3, 18.3), Vector3(2.5, 4.4, 13.5)],
			["20-apartment-hall", Vector3(3.7, 4.8, 7.2), Vector3(10.5, 4.6, 7.2)],
			["21-delivery-door", Vector3(8.75, 4.8, 7.25), Vector3(10.55, 4.5, 7.2)],
			["22-entrance-header", Vector3(-0.4, 1.7, 12.8), Vector3(0.4, 3.0, 13.4)],
			["23-wall-side-stairs", Vector3(4.1, 2.0, 14.2), Vector3(5.55, 1.2, 16)],
			["24-upper-floor-junction", Vector3(1.4, 4.8, 13.8), Vector3(0.58, 3.2, 13)],
			["25-upper-ceiling-junction", Vector3(2, 4.9, 13.2), Vector3(2, 5.8, 12)]]:
			overview.position = shot[1]
			overview.look_at(shot[2])
			await capture(shot[0])
		current_scene.player.get_node("CameraPivot/Camera3D").make_current()
		overview.queue_free()
	settings.shadows_enabled = false
	settings.settings_changed.emit()
	check(not current_scene.get_node("Environment/DirectionalLight3D").shadow_enabled, "shadows disabled immediately")
	settings.shadows_enabled = true
	settings.settings_changed.emit()
	check(current_scene.get_node("Environment/DirectionalLight3D").shadow_enabled, "shadows enabled immediately")
	var settings_ui: SettingsPanel = current_scene.get_node("UI/PauseMenu/SettingsPanel")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = Vector2i(1280, 720)
	var pause_ui: PauseMenu = current_scene.get_node("UI/PauseMenu")
	pause_ui._open_pause()
	pause_ui._open_settings()
	await capture("12-graphics-settings")
	check(settings_ui.back_button.get_global_rect().end.y <= root.size.y, "settings back button fits viewport")
	pause_ui._close_settings()
	pause_ui._resume()
	check(current_scene.get_node("Presentation").find_children("*", "CollisionObject3D", true, false).is_empty(), "villa presentation adds no collision bodies")
	check("왼쪽 계단" in current_scene.route_hint and not "오른쪽 계단" in current_scene.route_hint, "villa route guides stairs to the left")
	for point in [Vector3(0, 0.5, -20), Vector3(10, 0.5, -10), Vector3(-6, 0.5, 15), Vector3(20, 0.5, 25)]:
		var query := PhysicsRayQueryParameters3D.create(point, point - Vector3(0, 2, 0), 1)
		var hit: Dictionary = current_scene.get_world_3d().direct_space_state.intersect_ray(query)
		check(not hit.is_empty() and absf(hit.position.y + 0.08) < 0.02, "continuous neighbourhood ground " + str(point))
	check(current_scene.get_node("Neighborhood/DeliveryTruckModel") != null, "delivery truck asset included")
	var truck_text: Label3D = current_scene.get_node("Neighborhood/TruckLivery")
	check(truck_text.text == "HELL DELIVERY\n언덕마을 배송", "truck Korean livery survives source and export encoding")
	var window_hit: Dictionary = current_scene.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(1.8, 3.65, 19.5), Vector3(1.8, 3.65, 21), 1))
	check(not window_hit.is_empty() and str(window_hit.collider.name).begins_with("StairWindow"), "stair opening has glazed collision instead of a solid wall")
	var landing_hit: Dictionary = current_scene.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(3.1, 2, 20), Vector3(3.1, 0, 20), 1))
	check(not landing_hit.is_empty() and absf(landing_hit.position.y - 1.602) < 0.01, "stair landing continues to north wall")
	for z in [12.3, 13.3, 14.3]:
		var floor_hit: Dictionary = current_scene.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(0.6, 3.8, z), Vector3(0.6, 2.8, z), 1))
		check(not floor_hit.is_empty() and absf(floor_hit.position.y - 3.204) < 0.01, "upper landing west seam has solid floor " + str(z))
	var stair_edge_hit: Dictionary = current_scene.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(5.55, 2, 15.25), Vector3(5.55, 0, 15.25), 1))
	check(not stair_edge_hit.is_empty() and str(stair_edge_hit.collider.name).begins_with("Step"), "first flight tread and collision reach the east wall")
	for ray in [[Vector3(3, 4, 18), Vector3(7, 4, 18)], [Vector3(3, 4, 18), Vector3(3, 4, 22)], [Vector3(3, 4, 18), Vector3(3, 8, 18)], [Vector3(2, 4, 7), Vector3(2, 4, 4)]]:
		var enclosure_query := PhysicsRayQueryParameters3D.create(ray[0], ray[1], 1)
		check(not current_scene.get_world_3d().direct_space_state.intersect_ray(enclosure_query).is_empty(), "villa enclosure blocks exterior ray " + str(ray[1]))
	current_scene.player.position = Vector3(10, 3, -10)
	current_scene.player.velocity = Vector3.ZERO
	await frames(70)
	check(current_scene.player.is_on_floor() and current_scene.player.position.y > 0.8, "player lands on expanded neighbourhood ground")
	current_scene.recover_all()
	await frames(12)
	await feedback_test(current_scene)
	var catalog := CharacterCatalog.get_all()
	check(catalog.size() == 18, "all 18 character definitions included")
	for definition in catalog:
		current_scene.player.apply_character(definition.id)
		await frames(2)
		var character: CharacterVisual = current_scene.player.character_visual
		var model_forward: Vector3 = character._current_instance.global_basis.z.normalized()
		check(model_forward.dot(-current_scene.player.global_basis.z.normalized()) > 0.99 and character._current_instance.global_basis.y.normalized().dot(Vector3.UP) > 0.99, "character faces gameplay forward and remains upright " + definition.id)
		check(character.current_character_id == definition.id and character.get_head_node() != null and character.animation_controller._has_carry_pose, "character model and carry animation " + definition.id)
		current_scene.player.set_physics_process(false)
		var controller := character.animation_controller
		check(controller._look_head == character.get_head_node(), "head tracking connected for " + definition.id)
		controller.carry_pitch = 0.0
		controller.set_carrying(true)
		await frames(20)
		var forward: Vector3 = -current_scene.player.global_basis.z.normalized()
		check((-controller._arm_left.global_basis.y.normalized()).dot(forward) > 0.95 and (-controller._arm_right.global_basis.y.normalized()).dot(forward) > 0.95, "both arms reach gameplay forward " + definition.id)
		controller.set_carrying(false)
		current_scene.player.set_physics_process(true)
	current_scene.player.apply_character(settings.selected_character_id)
	settings.onboarding_seen = false
	var intro: Node = await enter("res://scenes/level/Stage01HillsideVilla.tscn")
	check(intro.onboarding_overlay.visible and paused, "first-run onboarding pauses level")
	await capture("06-onboarding")
	settings.onboarding_seen = true
	check(InputMap.action_get_events("recover")[0].physical_keycode == KEY_F5, "recovery bound to F5")
	for path in ["Stage01HillsideVilla", "StageRooftopLoop", "PrototypeLevel"]:
		var level: Node = await enter("res://scenes/level/%s.tscn" % path)
		var zone: DeliveryZone = level.delivery_zone
		var expected := 3 if path == "PrototypeLevel" else 1
		check(zone.target_package_count == expected, path + " target")
		check(level.delivery_hud.progress_label.text.ends_with("0 / %d" % expected), path + " HUD target")
		check(str(expected) in level.onboarding_overlay._title_label.text, path + " onboarding target")
		check(str(expected) in level.get_node("UI/PauseMenu").controls_panel._key_goal_label.text, path + " controls target")
		var packages: Array[GrabbableBody] = []
		for body in level.get_node("Gameplay").get_children():
			if body.is_in_group("package"):
				packages.append(body)
		check(packages.size() >= expected, path + " enough packages")
		var box := packages[0]
		box.recover_to(Transform3D(Basis.IDENTITY, Vector3(0, -30, 0)))
		await frames(12)
		check(box.position.y > -5.0, path + " automatic lost-package recovery")
		level.player.position.y = -30
		await frames(12)
		check(level.player.position.y > -5.0, path + " player fall recovery")
		level.recover_all()
		await frames(12)
		check(zone.delivered_count == 0, path + " manual recovery preserves progress")
		if path == "Stage01HillsideVilla":
			await animation_test(level)
			var pause: PauseMenu = level.get_node("UI/PauseMenu")
			pause._open_pause()
			var before: float = level._play_time_elapsed
			await frames(10)
			check(is_equal_approx(before, level._play_time_elapsed), "pause stops play timer")
			await capture("03-pause")
			pause._resume()
		var wrong := Node3D.new()
		level.add_child(wrong)
		zone._on_body_entered(wrong)
		check(zone.delivered_count == 0, path + " non-package rejected")
		wrong.queue_free()
		for i in expected:
			# Physics integration places fixture in the real Area3D; this is not a manual playthrough.
			packages[i].recover_to(Transform3D(Basis.IDENTITY, zone.global_position))
			await frames(15)
			check(zone.delivered_count == i + 1, path + " physical delivery %d" % (i + 1))
			zone._on_body_entered(packages[i])
			check(zone.delivered_count == i + 1, path + " duplicate delivery rejected")
		check(level.completion_overlay.visible and paused, path + " completion shown")
		check(str(expected) in level.completion_overlay.subtitle_label.text, path + " completion count")
		if path == "Stage01HillsideVilla":
			await capture("04-completion")
		level.completion_overlay.replay_button.pressed.emit()
		await frames(12)
		check(current_scene.delivery_zone.delivered_count == 0 and not paused, path + " replay clears state")
		current_scene.get_node("UI/PauseMenu")._on_main_menu_pressed()
		await frames(6)
		check(current_scene is MainMenu and not paused, path + " return to menu")
	print("RESULT checks=", checks, " failures=", failures)
	quit(1 if failures else 0)


func villa_coop_test() -> void:
	var menu: MainMenu = await enter("res://scenes/ui/MainMenu.tscn")
	menu.get_node("LeftColumn/CenterContainer/VBoxContainer/CoopButton").pressed.emit()
	await frames(20)
	var coop: Node = current_scene
	check(paused and coop._character_select_overlay.visible, "coop selection pauses the shared villa")
	await capture("35-coop-character-selection")
	coop._p1_character_panel._on_confirm_pressed()
	coop._p2_character_panel._on_confirm_pressed()
	await frames(30)
	check(not paused and not coop._character_select_overlay.visible, "two confirmations start coop gameplay")
	check(coop._character_selection_manager.get_confirmed(0) != coop._character_selection_manager.get_confirmed(1), "coop characters are unique")
	var level: Node = coop.get_node("Level")
	check(coop._left_viewport.world_3d == coop._right_viewport.world_3d and coop.player1 != coop.player2, "split views share one world with two players")
	check(level.delivery_hud.visible and not level.delivery_hud.crosshair.visible, "shared delivery HUD uses split crosshairs")
	await capture("36-coop-villa-start")
	var controls_pause: PauseMenu = level.get_node("UI/PauseMenu")
	controls_pause._open_pause()
	controls_pause._open_controls()
	var controls: ControlsPanel = controls_pause.controls_panel
	check("P2 X" in controls.get_node("Panel/VBoxContainer/Grid/KeyJump").text and "P2 L3" in controls.get_node("Panel/VBoxContainer/Grid/KeySprint").text, "coop controls include both jump and sprint inputs")
	check("두 사람" in controls.get_node("Panel/VBoxContainer/Grid/KeyRestart").text and "202" in controls._key_goal_label.text, "coop controls describe shared recovery and actual destination")
	root.size = Vector2i(960, 540)
	await frames(5)
	var fits := true
	var controls_size := controls.get_viewport_rect().size
	for label in controls.get_node("Panel/VBoxContainer/Grid").get_children():
		var rect: Rect2 = label.get_global_rect()
		fits = fits and rect.position.x >= 0 and rect.position.y >= 0 and rect.end.x <= controls_size.x and rect.end.y <= controls_size.y
	check(fits and controls.back_button.get_global_rect().end.y <= controls_size.y, "coop controls fit minimum window")
	await capture("47-coop-controls-minimum")
	root.size = Vector2i(1280, 720)
	await frames(4)
	await capture("48-coop-controls")
	controls.back_button.pressed.emit()
	check(paused and controls_pause.visible and not controls.visible, "controls back returns to paused menu")
	controls_pause._resume()
	check(level._feedback.player_pan < 0 and level._second_feedback.player_pan > 0, "coop player audio uses opposite screen channels")
	var left_step: AudioStreamWAV = level._feedback._player_stream("step")
	var right_step: AudioStreamWAV = level._second_feedback._player_stream("step")
	var left_energy := Vector2.ZERO
	var right_energy := Vector2.ZERO
	for sample in left_step.data.size() / 4:
		left_energy += Vector2(absf(left_step.data.decode_s16(sample * 4)), absf(left_step.data.decode_s16(sample * 4 + 2)))
		right_energy += Vector2(absf(right_step.data.decode_s16(sample * 4)), absf(right_step.data.decode_s16(sample * 4 + 2)))
	check(left_step.stereo and right_step.stereo and left_energy.x > left_energy.y * 2 and right_energy.y > right_energy.x * 2, "rendered PCM separates player steps left and right")
	check(not level._feedback._player_stream("delivery").stereo, "shared delivery cue remains centered")
	var original_device: int = coop.player2.gamepad_device
	coop._on_pad_connection_changed(original_device + 10, false)
	check(not paused, "unrelated pad disconnect does not pause coop")
	coop._on_pad_connection_changed(original_device, false)
	check(paused and coop.get_node("Level/UI/PauseMenu").visible, "P2 pad disconnect pauses shared world")
	var frozen_position: Vector3 = coop.player2.position
	await frames(10)
	check(coop.player2.position.is_equal_approx(frozen_position), "disconnected pause freezes player physics")
	await capture("45-controller-disconnected")
	coop._on_pad_connection_changed(original_device + 1, true)
	check(paused and coop.player2.gamepad_device == original_device + 1 and coop._p2_character_panel.gamepad_device == original_device + 1, "reconnected device reassigned without automatic resume")
	await capture("46-controller-reconnected")
	var start_button := InputEventJoypadButton.new()
	start_button.device = original_device + 1
	start_button.button_index = JOY_BUTTON_START
	start_button.pressed = true
	Input.parse_input_event(start_button)
	await frames(3)
	check(not paused, "P2 Start resumes pause menu")
	start_button.pressed = false
	Input.parse_input_event(start_button)
	await frames(2)
	start_button.pressed = true
	Input.parse_input_event(start_button)
	await frames(3)
	check(paused, "P2 Start opens pause menu")
	start_button.pressed = false
	Input.parse_input_event(start_button)
	coop.get_node("Level/UI/PauseMenu")._resume()
	coop.player2.gamepad_device = original_device
	coop._p2_character_panel.gamepad_device = original_device
	coop.player2.position = Vector3(0, 1, -8.5)
	await frames(8)
	check(coop.player2.character_visual._current_instance.global_basis.z.normalized().dot(-coop.player2.global_basis.z.normalized()) > 0.99, "P2 model faces its camera direction")
	await capture("41-partner-facing-away")
	coop.player2.rotation.y = 0
	await frames(8)
	await capture("42-partner-facing-player")
	var head: Node3D = coop.player2.character_visual.get_head_node()
	var head_controller: CharacterAnimationController = coop.player2.character_visual.animation_controller
	for pitch in [-0.7, 0.7]:
		coop.player2.camera_pivot.rotation.x = pitch
		await frames(30)
		check(absf(head_controller._head_pitch - pitch) < 0.02, "P2 head follows camera pitch " + str(pitch))
		check(head.global_basis.z.normalized().y * pitch > 0, "visible face tilts in the same vertical direction as camera")
		await capture("43-head-look-down" if pitch < 0 else "44-head-look-up")
	level.recover_all()
	await frames(12)
	check(absf(coop.player2.character_visual.animation_controller._head_pitch) < 0.01, "recovery returns head to neutral")
	var p1_yaw: float = coop.player1.rotation.y
	var p2_yaw: float = coop.player2.rotation.y
	var mouse := InputEventMouseMotion.new()
	mouse.relative = Vector2(20, 0)
	Input.parse_input_event(mouse)
	await frames(3)
	check(not is_equal_approx(coop.player1.rotation.y, p1_yaw) and is_equal_approx(coop.player2.rotation.y, p2_yaw), "root mouse motion controls P1 camera only")
	coop.player1.rotation.y = p1_yaw
	var before_p1: Vector3 = coop.player1.position
	var before_p2: Vector3 = coop.player2.position
	var motion := InputEventJoypadMotion.new()
	motion.device = coop.player2.gamepad_device
	motion.axis = JOY_AXIS_LEFT_Y
	motion.axis_value = -1.0
	Input.parse_input_event(motion)
	await frames(45)
	motion.axis_value = 0.0
	Input.parse_input_event(motion)
	check(coop.player2.position.distance_to(before_p2) > 0.3 and coop.player1.position.distance_to(before_p1) < 0.1, "gamepad movement affects P2 only")
	check(level._second_feedback._last_played.has("step"), "P2 movement triggers footsteps")
	coop.player2.position.y = -25
	await frames(12)
	check(coop.player2.position.y > -2, "P2 falling recovers to villa spawn")
	var first: Package = level.get_node("Gameplay/Package")
	var second_parcel: Package = level.get_node("Gameplay/Package202")
	var offset: Vector3 = second_parcel.global_position - coop.player2.camera_pivot.global_position
	coop.player2.rotation.y = atan2(-offset.x, -offset.z)
	coop.player2.camera_pivot.rotation.x = atan2(offset.y, Vector2(offset.x, offset.z).length())
	await frames(5)
	var trigger := InputEventJoypadMotion.new()
	trigger.device = coop.player2.gamepad_device
	trigger.axis = JOY_AXIS_TRIGGER_RIGHT
	trigger.axis_value = 1.0
	Input.parse_input_event(trigger)
	await frames(12)
	check(coop.player2.held_grabbable == second_parcel and coop.player1.held_grabbable == null, "P2 trigger grabs its parcel independently")
	check("P2 202호 운반" in level.delivery_hud.get_node("RouteLabel").text, "shared HUD identifies P2 carried address")
	await capture("39-coop-P2-carry")
	check(level._second_feedback._last_played.has("grab"), "P2 grab triggers audio")
	coop._on_pad_connection_changed(coop.player2.gamepad_device, false)
	var frozen_parcel: Vector3 = second_parcel.position
	await frames(10)
	check(paused and second_parcel.position.is_equal_approx(frozen_parcel) and coop.player2.held_grabbable == second_parcel, "disconnect freezes carried parcel and preserves grab")
	coop._on_pad_connection_changed(coop.player2.gamepad_device, true)
	coop.get_node("Level/UI/PauseMenu")._resume()
	trigger.axis_value = 0.0
	Input.parse_input_event(trigger)
	await frames(8)
	check(coop.player2.held_grabbable == null, "P2 trigger release drops parcel")
	check(level._second_feedback._last_played.has("release"), "P2 release triggers audio")
	level.recover_all()
	await frames(12)
	var jump := InputEventJoypadButton.new()
	jump.device = coop.player2.gamepad_device
	jump.button_index = JOY_BUTTON_X
	jump.pressed = true
	Input.parse_input_event(jump)
	await frames(4)
	check(coop.player2.velocity.y > 0 and coop.player1.velocity.y <= 0.1, "P2 jump button is independent")
	check(level._second_feedback._last_played.has("jump"), "P2 jump triggers audio")
	jump.pressed = false
	Input.parse_input_event(jump)
	for landing_frame in 120:
		await frames(1)
		if coop.player2.is_on_floor():
			break
	await frames(2)
	check(level._second_feedback._last_played.has("land"), "P2 landing triggers audio")
	level.recover_all()
	await frames(8)
	# Shared-carry fixture checks the existing two-grabber physics in the villa world.
	coop.player2.position = Vector3(1.1, 1, -11.5)
	first.recover_to(Transform3D(Basis.IDENTITY, Vector3(0.55, 1.3, -9.8)))
	await frames(2)
	var joined1: bool = first.add_grabber(coop.player1, coop.player1.hold_point, first.global_position)
	var joined2: bool = first.add_grabber(coop.player2, coop.player2.hold_point, first.global_position)
	coop.player1.held_grabbable = first
	coop.player2.held_grabbable = first
	await frames(5)
	check(joined1 and joined2 and first.get_grabber_count() == 2 and first.linear_velocity.is_finite(), "two players share one physical parcel without invalid velocity")
	check(coop._left_coop_status.visible and coop._right_coop_status.visible, "shared carry indicator appears in both views")
	first.remove_grabber(coop.player1)
	await frames(3)
	check(first.has_grabber(coop.player2) and not first.has_grabber(coop.player1), "one player releasing leaves partner connected")
	level.recover_all()
	await frames(12)
	first.recover_to(Transform3D(Basis.IDENTITY, level.delivery_zone.global_position))
	await frames(20)
	check(level._delivered_total() == 1 and not paused, "coop shares first delivery progress")
	var pause_menu: PauseMenu = level.get_node("UI/PauseMenu")
	pause_menu._open_pause()
	await frames(3)
	await capture("37-coop-pause")
	pause_menu.get_node("Control/CenterContainer/VBoxContainer/RecoverButton").pressed.emit()
	await frames(15)
	check(not paused and level._delivered_total() == 1 and coop.player2.position.distance_to(Vector3(2.5, 1, -11.5)) < 0.2, "coop pause recovery preserves progress and restores P2")
	var second: Package = level.get_node("Gameplay/Package202")
	second.recover_to(Transform3D(Basis.IDENTITY, level.second_zone.global_position))
	await frames(20)
	check(paused and level.completion_overlay.visible, "both coop deliveries open shared completion")
	coop._on_pad_connection_changed(coop.player2.gamepad_device, false)
	check(paused and level.completion_overlay.visible and not coop.get_node("Level/UI/PauseMenu").visible, "pad disconnect preserves completion without stacking pause")
	await capture("38-coop-completion")
	level.completion_overlay.replay_button.pressed.emit()
	await frames(20)
	check(current_scene.scene_file_path.ends_with("VillaCoop.tscn") and current_scene._character_select_overlay.visible, "coop replay returns to two-player selection")
	current_scene._back_to_menu()
	await frames(8)
	check(current_scene is MainMenu and not paused, "coop selection can return to menu")


func villa_coop_route() -> void:
	var coop: Node = await enter("res://scenes/level/VillaCoop.tscn")
	coop._p1_character_panel._on_confirm_pressed()
	coop._p2_character_panel._on_confirm_pressed()
	await frames(30)
	var level: Node = coop.get_node("Level")
	var courier: Player = coop.player2
	var parcel: Package = level.get_node("Gameplay/Package202")
	var offset := parcel.global_position - courier.camera_pivot.global_position
	courier.rotation.y = atan2(-offset.x, -offset.z)
	courier.camera_pivot.rotation.x = atan2(offset.y, Vector2(offset.x, offset.z).length())
	await frames(6)
	var trigger := InputEventJoypadMotion.new()
	trigger.device = courier.gamepad_device
	trigger.axis = JOY_AXIS_TRIGGER_RIGHT
	trigger.axis_value = 1.0
	Input.parse_input_event(trigger)
	await frames(15)
	check(courier.held_grabbable == parcel, "P2 route grabs 202 parcel with trigger")
	courier.camera_pivot.rotation.x = 0
	var move := InputEventJoypadMotion.new()
	move.device = courier.gamepad_device
	move.axis = JOY_AXIS_LEFT_Y
	var waypoints: Array[Vector2] = [Vector2(-3, -10), Vector2(-3, 1), Vector2(0, 2), Vector2(0, 8), Vector2(0, 12.9), Vector2(4, 13.4), Vector2(4, 18.3), Vector2(2, 18.3), Vector2(2, 13.2), Vector2(2, 7.8), Vector2(5.3, 7.55)]
	for target in waypoints:
		var reached := false
		for frame in 900:
			var direction := Vector3(target.x - courier.position.x, 0, target.y - courier.position.z)
			if direction.length() < 0.25 or parcel.is_delivered():
				reached = true
				break
			var yaw := atan2(-direction.x, -direction.z)
			courier.rotation.y = rotate_toward(courier.rotation.y, yaw, 0.04)
			move.axis_value = -0.55 if absf(angle_difference(courier.rotation.y, yaw)) < 0.25 else 0.0
			Input.parse_input_event(move.duplicate())
			await frames(1)
		move.axis_value = 0
		Input.parse_input_event(move.duplicate())
		check(reached, "P2 input route reaches " + str(target))
		if not reached:
			await capture("coop-route-blocked")
			break
	trigger.axis_value = 0
	Input.parse_input_event(trigger)
	await frames(15)
	check(parcel.is_delivered() and level._delivered_total() == 1 and not paused, "P2 carries through villa stairs and completes its shared delivery")
	await capture("40-coop-P2-route-delivery")
	coop._back_to_menu()
	await frames(8)


func coop_repeat_test() -> void:
	var signal_count := Input.joy_connection_changed.get_connections().size()
	for cycle in 12:
		var coop: Node = await enter("res://scenes/level/VillaCoop.tscn")
		var old_root: WeakRef = weakref(coop)
		coop._p1_character_panel._on_confirm_pressed()
		coop._p2_character_panel._on_confirm_pressed()
		await frames(15)
		var level: Node = coop.get_node("Level")
		var old_audio: WeakRef = weakref(level._second_feedback)
		var old_player: WeakRef = weakref(coop.player2)
		var first: Package = level.get_node("Gameplay/Package")
		var second: Package = level.get_node("Gameplay/Package202")
		check(not paused and level._delivered_total() == 0 and Input.joy_connection_changed.get_connections().size() == signal_count + 1, "coop cycle %d starts with isolated state and one pad subscription" % cycle)
		coop.player2.position = Vector3(1.1, 1, -11.5)
		first.recover_to(Transform3D(Basis.IDENTITY, Vector3(0.55, 1.3, -9.8)))
		await frames(2)
		var joined := first.add_grabber(coop.player1, coop.player1.hold_point, first.global_position)
		joined = first.add_grabber(coop.player2, coop.player2.hold_point, first.global_position) and joined
		coop.player1.held_grabbable = first
		coop.player2.held_grabbable = first
		await frames(3)
		check(joined and first.get_grabber_count() == 2, "coop cycle %d joins shared carry" % cycle)
		var pause_menu: PauseMenu = level.get_node("UI/PauseMenu")
		pause_menu._open_pause()
		pause_menu._on_recover_pressed()
		await frames(8)
		check(not paused and first.get_grabber_count() == 0 and coop.player1.held_grabbable == null and coop.player2.held_grabbable == null and not coop._left_coop_status.visible and not coop._right_coop_status.visible, "coop cycle %d shared-carry recovery clears both grips and indicators" % cycle)
		var early: Package = first if cycle % 2 == 0 else second
		var late: Package = second if cycle % 2 == 0 else first
		var early_zone: DeliveryZone = level.delivery_zone if early == first else level.second_zone
		var late_zone: DeliveryZone = level.second_zone if late == second else level.delivery_zone
		early.recover_to(Transform3D(Basis.IDENTITY, early_zone.global_position))
		await frames(12)
		pause_menu._open_pause()
		pause_menu._on_recover_pressed()
		await frames(8)
		check(level._delivered_total() == 1 and early.is_delivered() and not paused, "coop cycle %d retains partial delivery during two-player recovery" % cycle)
		late.recover_to(Transform3D(Basis.IDENTITY, late_zone.global_position))
		await frames(12)
		check(paused and level.completion_overlay.visible and level._delivery_details.size() == 2, "coop cycle %d completes alternating delivery order" % cycle)
		level.completion_overlay.replay_button.pressed.emit()
		await frames(15)
		check(old_root.get_ref() == null and old_audio.get_ref() == null and old_player.get_ref() == null, "coop cycle %d replay frees old world player and audio" % cycle)
		check(paused and current_scene._character_select_overlay.visible and current_scene.get_node("Level")._delivered_total() == 0, "coop cycle %d replay resets selection and deliveries" % cycle)
		current_scene._back_to_menu()
		await frames(10)
		check(current_scene is MainMenu and not paused and Input.joy_connection_changed.get_connections().size() == signal_count, "coop cycle %d menu return releases pad subscription" % cycle)


func repeat_session_test() -> void:
	# Exercise scene lifetimes and state reset; fixtures do not replace route input tests.
	for cycle in range(12):
		var level: Node = await enter("res://scenes/level/VillaDeliveryRun.tscn")
		var old_level: WeakRef = weakref(level)
		var first: Package = level.get_node("Gameplay/Package")
		var second: Package = level.get_node("Gameplay/Package202")
		var pause_menu: PauseMenu = level.get_node("UI/PauseMenu")
		for toggle in range(3):
			pause_menu._open_pause()
			await frames(2)
			pause_menu._resume()
			await frames(2)
		check(not paused and level.delivery_hud.visible, "cycle %d repeated pause restores HUD" % cycle)
		var early: Package = first if cycle % 2 == 0 else second
		var late: Package = second if cycle % 2 == 0 else first
		var early_zone: DeliveryZone = level.delivery_zone if early == first else level.second_zone
		var late_zone: DeliveryZone = level.second_zone if late == second else level.delivery_zone
		early.recover_to(Transform3D(Basis.IDENTITY, early_zone.global_position))
		await frames(12)
		pause_menu._open_pause()
		pause_menu.get_node("Control/CenterContainer/VBoxContainer/RecoverButton").pressed.emit()
		await frames(8)
		check(level._delivered_total() == 1 and early.is_delivered() and not paused, "cycle %d partial recovery retains delivery" % cycle)
		late.recover_to(Transform3D(Basis.IDENTITY, late_zone.global_position))
		await frames(12)
		check(paused and level.completion_overlay.visible and not level.delivery_hud.visible and level._delivery_details.size() == 2, "cycle %d finishes with isolated two-stop state" % cycle)
		level.completion_overlay.replay_button.pressed.emit()
		await frames(10)
		check(old_level.get_ref() == null and current_scene._delivered_total() == 0 and current_scene.delivery_hud.visible, "cycle %d replay frees old scene and resets state" % cycle)
		var replayed: WeakRef = weakref(current_scene)
		current_scene.get_node("UI/PauseMenu")._on_main_menu_pressed()
		await frames(10)
		check(replayed.get_ref() == null and current_scene is MainMenu and not paused, "cycle %d menu return frees replayed scene" % cycle)


func multi_stop_test() -> void:
	var menu: MainMenu = await enter("res://scenes/ui/MainMenu.tscn")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = Vector2i(960, 540)
	await frames(3)
	check(menu.quit_button.get_global_rect().end.y <= menu.get_viewport_rect().size.y and menu.start_button.get_global_rect().position.y >= 0, "six menu actions fit minimum resolution")
	await capture("32-menu-minimum")
	root.size = Vector2i(1280, 720)
	menu.get_node("LeftColumn/CenterContainer/VBoxContainer/DeliveryRunButton").pressed.emit()
	await frames(30)
	var level: Node = current_scene
	check(level.scene_file_path.ends_with("VillaDeliveryRun.tscn"), "menu enters multi-stop villa")
	var first: Package = level.get_node("Gameplay/Package")
	var second: Package = level.get_node("Gameplay/Package202")
	check(first.destination_id == DeliveryOrders.VILLA_201 and second.destination_id == DeliveryOrders.VILLA_202, "parcels have different delivery addresses")
	check(first.get_node("ShippingLabels").get_child_count() == 5 and second.get_node("ShippingLabels").get_child_count() == 5, "addresses readable from sides and top")
	check(level.delivery_hud.progress_label.text.ends_with("0 / 2"), "multi-stop HUD counts both parcels")
	check("2" in level.onboarding_overlay._title_label.text and "202" in level.onboarding_overlay._title_label.text, "onboarding describes both stops")
	check("202" in level.get_node("UI/PauseMenu").controls_panel._key_goal_label.text, "pause controls describe both stops")
	await capture("26-multi-stop-start")
	# Controlled physics fixtures test the address rules independently of driving inputs.
	first.recover_to(Transform3D(Basis.IDENTITY, level.second_zone.global_position))
	await frames(20)
	check(level._delivered_total() == 0 and not first.is_delivered(), "201 parcel rejected physically at 202")
	check("201" in level.delivery_hud.delivery_toast_label.text and "202" in level.delivery_hud.delivery_toast_label.text, "wrong address feedback names both addresses")
	await capture("27-wrong-address")
	level.recover_all()
	await frames(20)
	second.recover_to(Transform3D(Basis.IDENTITY, level.second_zone.global_position))
	await frames(20)
	check(level._delivered_total() == 1 and not paused, "202 can be delivered first without completing the run")
	check(level.delivery_hud.progress_label.text.ends_with("1 / 2"), "partial delivery HUD stays at one of two")
	check("트럭으로" in level.delivery_hud.get_node("RouteLabel").text and "201호" in level.delivery_hud.get_node("RouteLabel").text, "partial delivery guides player to remaining parcel at truck")
	check(level.second_zone.get_node("DeliveryReceipt").visible and not level.delivery_zone.get_node("DeliveryReceipt").visible, "floor receipt distinguishes completed and outstanding stops")
	check(level.delivery_zone.get_node("DeliveryReceipt").position.y < 0 and level.second_zone.get_node("DeliveryReceipt").position.y < 0, "deferred architectural finish leaves both receipts at floor height")
	var remaining_marker: MeshInstance3D = level.delivery_zone.get_node("MeshInstance3D")
	var completed_marker: MeshInstance3D = level.second_zone.get_node("MeshInstance3D")
	check(remaining_marker.material_override.albedo_color != completed_marker.material_override.albedo_color, "completed stop tint does not alter remaining marker")
	first.recover_to(Transform3D(Basis.IDENTITY, Vector3(0, 0.5, 5)))
	await frames(4)
	check("다시 잡으세요" in level.delivery_hud.get_node("RouteLabel").text, "displaced remaining parcel does not wrongly send player to truck")
	var delivered_position := second.global_position
	var pause_menu: PauseMenu = level.get_node("UI/PauseMenu")
	pause_menu._open_pause()
	await frames(3)
	var summary: Label = pause_menu.get_node("Control/CenterContainer/VBoxContainer/DeliverySummary")
	check(paused and "1 / 2" in summary.text and "202호 완료" in summary.text, "pause snapshot shows completed and outstanding delivery")
	check(not level.delivery_hud.visible, "pause hides gameplay text behind its summary")
	root.size = Vector2i(960, 540)
	await frames(3)
	check(pause_menu.quit_button.get_global_rect().end.y <= pause_menu.quit_button.get_viewport_rect().size.y, "expanded pause menu fits minimum resolution")
	await capture("34-pause-delivery-recovery")
	pause_menu.get_node("Control/CenterContainer/VBoxContainer/RecoverButton").pressed.emit()
	await frames(20)
	check(not paused and not pause_menu.visible and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "pause recovery resumes gameplay and captures mouse")
	check(level.delivery_hud.visible, "pause recovery restores gameplay HUD")
	check(not Input.is_action_pressed("grab_object") and level.player.held_grabbable == null, "recovery click does not grab a parcel")
	root.size = Vector2i(1280, 720)
	check(second.is_delivered() and second.global_position.distance_to(delivered_position) < 0.02, "recovery leaves delivered parcel at its stop")
	check(first.global_position.distance_to(Vector3(0, 0.3, -9.3)) < 1.0 and level._delivered_total() == 1, "recovery restores only outstanding parcel and retains progress")
	var rejections: Array = []
	level.second_zone.package_rejected.connect(func(package): rejections.append(package))
	first.recover_to(Transform3D(Basis.IDENTITY, level.second_zone.global_position))
	await frames(20)
	check(rejections.size() > 0 and not first.is_delivered() and level._delivered_total() == 1, "completed stop still rejects and explains a wrong-address parcel")
	first.recover_to(Transform3D(Basis.IDENTITY, level.delivery_zone.global_position))
	await frames(20)
	check(paused and level.completion_overlay.visible and level._delivered_total() == 2, "both addresses required for overall completion")
	check(not level.delivery_hud.visible, "completion removes gameplay HUD behind results")
	level.delivery_zone._on_body_entered(first)
	level.second_zone._on_body_entered(second)
	check(level._delivered_total() == 2, "duplicate deliveries never increase total")
	check("2" in level.completion_overlay.subtitle_label.text, "completion screen counts both parcels")
	var details: Label = level.completion_overlay.get_node("Control/CenterContainer/VBoxContainer/DetailsLabel")
	check(details.visible and details.text.begins_with("202호") and "201호" in details.text, "completion lists actual delivery order and both addresses")
	check(details.text.count("배송 완료") == 2, "recovery and duplicate entries never duplicate completion receipt")
	await capture("28-multi-stop-completion")
	level.completion_overlay.replay_button.pressed.emit()
	await frames(20)
	check(current_scene._delivered_total() == 0 and not paused, "replay resets all stops")
	check(current_scene.delivery_hud.visible, "replay restores gameplay HUD")
	check(current_scene._delivery_details.is_empty() and not current_scene.second_zone.get_node("DeliveryReceipt").visible, "replay clears receipt history and completed visual")
	current_scene.get_node("UI/PauseMenu")._on_main_menu_pressed()
	await frames(8)
	check(current_scene is MainMenu, "multi-stop returns to menu")

func multi_stop_route() -> void:
	var level: Node = await enter("res://scenes/level/VillaDeliveryRun.tscn")
	await frames(30)
	var player: Player = level.player
	player.set_process_unhandled_input(false)
	var first: Package = level.get_node("Gameplay/Package")
	var second: Package = level.get_node("Gameplay/Package202")
	player.camera_pivot.rotation.x = -0.5
	Input.action_press("move_forward")
	await frames(9)
	Input.action_release("move_forward")
	await frames(15)
	if not await _route_grab(player, first):
		return
	var ascent: Array[Vector2] = [Vector2(-3, -10), Vector2(-3, 1), Vector2(0, 2), Vector2(0, 8), Vector2(0, 12.9), Vector2(4, 13.4), Vector2(4, 18.3), Vector2(2, 18.3), Vector2(2, 13.2), Vector2(2, 7.8), Vector2(4.5, 7.2)]
	for target in ascent + [Vector2(8.7, 7.2)]:
		if not await _route_walk(level, target):
			return
		if not first.is_delivered() and not await _route_grab(player, first):
			return
	Input.action_release("grab_object")
	await frames(15)
	check(level.delivery_zone.delivered_count == 1 and not paused, "input route delivers 201 first and continues")
	await capture("29-route-first-stop")
	player.camera_pivot.rotation.x = -0.8
	await frames(3)
	await capture("33-completed-floor-receipt")
	player.camera_pivot.rotation.x = 0
	var return_route := ascent.duplicate()
	return_route.reverse()
	# Clear the south alley wall's end before turning back; a reversed diagonal
	# from (4,13.4) to (0,12.9) cuts through that wall with the player's capsule.
	return_route[return_route.find(Vector2(4, 13.4))] = Vector2(4, 13.8)
	return_route[return_route.find(Vector2(0, 12.9))] = Vector2(0, 13.8)
	return_route.append(Vector2(1.65, -11))
	for target in return_route:
		if not await _route_walk(level, target):
			return
	check(player.position.y < 1.2, "input route descends stairs and returns to truck")
	await capture("30-route-return-truck")
	if not await _route_grab(player, second):
		return
	for target in ascent + [Vector2(5.3, 7.55)]:
		if not await _route_walk(level, target):
			return
		if not second.is_delivered() and not await _route_grab(player, second):
			return
	Input.action_release("grab_object")
	await frames(15)
	check(level._delivered_total() == 2 and level.completion_overlay.visible, "input route completes two deliveries with a physical return trip")
	await capture("31-route-two-stops-complete")

func _route_walk(level: Node, target: Vector2) -> bool:
	var player: Player = level.player
	var reached := false
	for frame in 900:
		if level.completion_overlay.visible:
			reached = true
			break
		var offset := Vector3(target.x - player.position.x, 0, target.y - player.position.z)
		if offset.length() < 0.25:
			reached = true
			break
		var desired_yaw := atan2(-offset.x, -offset.z)
		player.rotation.y = rotate_toward(player.rotation.y, desired_yaw, 0.04)
		if absf(angle_difference(player.rotation.y, desired_yaw)) < 0.25:
			Input.action_press("move_forward", 0.55)
		else:
			Input.action_release("move_forward")
		await frames(1)
	Input.action_release("move_forward")
	check(reached, "multi-stop route reaches " + str(target))
	if not reached:
		print("ROUTE BLOCK target=", target, " position=", player.position, " velocity=", player.velocity)
		for index in player.get_slide_collision_count():
			print("ROUTE BLOCK collider=", player.get_slide_collision(index).get_collider())
		await capture("route-blocked")
	return reached

func _route_grab(player: Player, package: Package) -> bool:
	if player.held_grabbable == package:
		return true
	Input.action_release("grab_object")
	var to_box := package.global_position - player.camera_pivot.global_position
	player.rotation.y = atan2(-to_box.x, -to_box.z)
	player.camera_pivot.rotation.x = atan2(to_box.y, Vector2(to_box.x, to_box.z).length())
	await frames(6)
	Input.action_press("grab_object")
	await frames(18)
	var grabbed := player.held_grabbable == package
	check(grabbed, "input route grabs " + package.destination_id)
	player.camera_pivot.rotation.x = 0
	return grabbed

func persistence_test(write: bool) -> void:
	# Dedicated file beside the report; never overwrite the player's settings.cfg.
	var path := report_path.get_base_dir().path_join("settings-fixture.cfg")
	var fixture: Node = preload("res://autoload/GameSettings.gd").new()
	if write:
		fixture.selected_character_id = "character_r"
		fixture.fov = 92.0
		fixture.master_volume = 0.35
		fixture.mouse_sensitivity = 0.006
		fixture.window_resolution = Vector2i(1600, 900)
		fixture.onboarding_seen = true
		fixture.shadows_enabled = false
		fixture.save_settings(path)
		check(FileAccess.file_exists(path), "settings written to isolated fixture")
	else:
		check(FileAccess.file_exists(path), "previous process settings file exists")
		fixture.load_settings(path)
		check(fixture.selected_character_id == "character_r", "character persists across processes")
		check(is_equal_approx(fixture.fov, 92.0), "FOV persists across processes")
		check(is_equal_approx(fixture.master_volume, 0.35), "volume persists across processes")
		check(is_equal_approx(fixture.mouse_sensitivity, 0.006), "sensitivity persists across processes")
		check(fixture.window_resolution == Vector2i(1600, 900), "resolution persists across processes")
		check(fixture.onboarding_seen, "onboarding persists across processes")
		check(not fixture.shadows_enabled, "shadows persist across processes")
	fixture.free()


func performance_test() -> void:
	var level: Node = await enter("res://scenes/level/Stage01HillsideVilla.tscn")
	level.player.set_physics_process(false)
	level.player.set_process_unhandled_input(false)
	# Fixed camera and resolution, sequential runs. This is a local sample, not a minimum-spec claim.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = Vector2i(1280, 720)
	for enabled in [true, false]:
		settings.shadows_enabled = enabled
		settings.settings_changed.emit()
		await frames(120)
		var samples: Array[float] = []
		var previous := Time.get_ticks_usec()
		for i in 600:
			await get_tree().process_frame
			var now := Time.get_ticks_usec()
			samples.append(float(now - previous) / 1000.0)
			previous = now
		samples.sort()
		var total := 0.0
		for sample in samples:
			total += sample
		var result := "FRAME_SAMPLE shadows=%s frames=600 mean_ms=%.3f median_ms=%.3f p95_ms=%.3f" % [enabled, total / 600.0, samples[300], samples[570]]
		print(result)
		report.store_line(result)
		report.flush()
		check(level.get_node("Environment/DirectionalLight3D").shadow_enabled == enabled, "performance sample graphics state " + str(enabled))
		await capture("13-shadows-on" if enabled else "14-shadows-off")
	# Stabilization pass: measure the newly detailed interior as well as the old start view.
	var camera := Camera3D.new()
	level.add_child(camera)
	camera.make_current()
	settings.shadows_enabled = true
	settings.settings_changed.emit()
	for view in [["stairwell", Vector3(4.15, 1.8, 13.3), Vector3(3.2, 3, 18.8)], ["hall", Vector3(3.7, 4.8, 7.2), Vector3(10.5, 4.6, 7.2)]]:
		camera.position = view[1]
		camera.look_at(view[2])
		await frames(120)
		var samples: Array[float] = []
		var previous := Time.get_ticks_usec()
		for i in 600:
			await get_tree().process_frame
			var now := Time.get_ticks_usec()
			samples.append(float(now - previous) / 1000.0)
			previous = now
		samples.sort()
		var total := 0.0
		for sample in samples:
			total += sample
		var result := "INTERIOR_SAMPLE view=%s frames=600 mean_ms=%.3f median_ms=%.3f p95_ms=%.3f" % [view[0], total / 600.0, samples[300], samples[570]]
		print(result)
		report.store_line(result)
		report.flush()
		await capture("performance-" + view[0])
	camera.queue_free()


func animation_test(level: Node) -> void:
	var player: Player = level.player
	player.set_physics_process(false)
	var anim: CharacterAnimationController = player.character_visual.animation_controller
	anim.carry_pitch = 0.0
	anim.set_carrying(true)
	for sprinting in [false, true, false]:
		anim.update_locomotion(4.0, sprinting, true)
		await frames(40)
		# Assert the visible gameplay direction, not the model-space pose convention.
		var expected: Vector3 = player.global_basis * Vector3.FORWARD.rotated(Vector3.RIGHT, deg_to_rad(-16.0))
		check(anim._has_carry_pose and (-anim._arm_left.global_basis.y.normalized()).dot(expected) > 0.999, "carry pose persists across animation transitions")
	await capture("05-carry-pose")
	anim.update_locomotion(7.0, true, true)
	await frames(50)
	var low := INF
	var high := -INF
	for i in 90:
		await frames(1)
		var height := player.to_local(anim._arm_left.global_position).y
		low = minf(low, height)
		high = maxf(high, height)
	print("SPRINT arm vertical range=", high - low)
	check(high - low < 0.005, "sprint carry shoulder stays stable relative to player")
	await capture("10-sprint-carry")
	for pitch in [-0.6, 0.6]:
		anim.carry_pitch = pitch
		player.camera_pivot.rotation.x = pitch
		await frames(20)
		var aim: Vector3 = -player.camera_pivot.global_basis.z.normalized()
		check((-anim._arm_left.global_basis.y.normalized()).dot(aim) > 0.95 and (-anim._arm_right.global_basis.y.normalized()).dot(aim) > 0.95, "carry arms follow camera pitch " + str(pitch))
	anim.carry_pitch = 0.0
	player.camera_pivot.rotation.x = 0.0
	anim.set_carrying(false)
	await frames(30)
	check(is_zero_approx(anim._carry_blend), "carry pose releases")
	check(anim._arm_left.scale.is_equal_approx(anim._arm_left_scale) and anim._arm_right.scale.is_equal_approx(anim._arm_right_scale), "release restores original arm proportions")
	check(anim._arm_left.position.is_equal_approx(anim._left_position) and anim._arm_right.position.is_equal_approx(anim._right_position), "release restores shoulder animation hierarchy")
	for sprinting in [false, true]:
		anim.update_locomotion(7.0 if sprinting else 0.0, sprinting, true)
		for pitch in [-1.3, 1.3]:
			anim.carry_pitch = pitch
			await frames(30)
			check(absf(anim._head_pitch - clampf(pitch, -deg_to_rad(55.0), deg_to_rad(55.0))) < 0.02, "head tracks and clamps without carrying sprint=" + str(sprinting) + " pitch=" + str(pitch))
	anim.reset()
	check(is_zero_approx(anim._head_pitch), "animation reset clears head tilt")
	player.set_physics_process(true)


func feedback_test(level: Node) -> void:
	var audio: LevelAudio = level._feedback
	await frames(20)
	Input.action_press("jump")
	await frames(4)
	Input.action_release("jump")
	check(audio._last_played.has("jump"), "jump input produces feedback")
	await frames(85)
	check(audio._last_played.has("land"), "physical landing produces feedback")
	var box: GrabbableBody = level.get_node("Gameplay/Package")
	audio._last_played.erase("impact")
	box.apply_central_impulse(Vector3(0, 75, 0))
	await frames(100)
	check(audio._last_played.has("impact"), "physical package impact produces feedback")
	var impact_time: int = audio._last_played.get("impact", -1000)
	audio.play_cue("impact")
	impact_time = audio._last_played["impact"]
	audio.play_cue("impact")
	check(audio._last_played["impact"] == impact_time, "contact feedback cooldown")


func inspect_visual() -> void:
	var level: Node = await enter("res://scenes/level/Stage01HillsideVilla.tscn")
	await frames(30)
	var camera: Camera3D = root.get_camera_3d()
	print("CAMERA ", camera.get_path(), " mask=", camera.cull_mask, " transform=", camera.global_transform)
	var character: Node3D = level.player.character_visual
	await capture("inspect-before")
	character.hide()
	await frames(3)
	await capture("inspect-no-character")
	character.show()
	for mesh in character.find_children("*", "MeshInstance3D", true, false):
		mesh.layers = 2
	character.animation_controller._arm_left.layers = 1
	character.animation_controller._arm_right.layers = 1
	await frames(3)
	await capture("inspect-arms-only")
	print("ARM transform ", character.animation_controller._arm_left.global_transform)


func route() -> void:
	var level: Node = await enter("res://scenes/level/Stage01HillsideVilla.tscn")
	await frames(30)
	var player: Player = level.player
	var box: GrabbableBody = level.get_node("Gameplay/Package")
	player.set_process_unhandled_input(false) # OS mouse movement must not steer automated camera input.
	# Camera aim and movement actions only. No player/package teleport in the route test.
	player.camera_pivot.rotation.x = -0.5
	Input.action_press("move_forward")
	await frames(9)
	Input.action_release("move_forward")
	await frames(15)
	Input.action_press("grab_object")
	await frames(15)
	check(player.held_grabbable == box, "route grabs package from spawn with input")
	player.camera_pivot.rotation.x = 0.0
	await capture("07-route-grab")
	var waypoints: Array[Vector2] = [Vector2(-3, -10), Vector2(-3, 1), Vector2(0, 2), Vector2(0, 8), Vector2(0, 12.9), Vector2(4, 13.4), Vector2(4, 18.3), Vector2(2, 18.3), Vector2(2, 13.2), Vector2(2, 7.8), Vector2(4.5, 7.2), Vector2(8.7, 7.2)]
	for target in waypoints:
		if target == Vector2(0, 8):
			Input.action_press("sprint")
		var reached := false
		for frame in 900:
			if level.completion_overlay.visible:
				reached = true
				break
			var offset := Vector3(target.x - player.position.x, 0, target.y - player.position.z)
			if offset.length() < 0.25:
				reached = true
				break
			var desired_yaw := atan2(-offset.x, -offset.z)
			player.rotation.y = rotate_toward(player.rotation.y, desired_yaw, 0.04)
			if absf(angle_difference(player.rotation.y, desired_yaw)) < 0.25:
				Input.action_press("move_forward", 0.55)
			else:
				Input.action_release("move_forward")
			await frames(1)
		Input.action_release("move_forward")
		if target == Vector2(0, 8):
			check(player.held_grabbable == box and player.character_visual.animation_controller._locomotion_state == CharacterAnimationController.LocomotionState.SPRINT, "route sprint input keeps package and sprint animation")
			await capture("11-route-sprint")
		Input.action_release("sprint")
		if reached and player.held_grabbable == null and not level.completion_overlay.visible:
			# A physical collision may legitimately release the parcel. Exercise the same
			# nearby re-grab available to a player, without moving either body by script.
			Input.action_release("grab_object")
			var to_box: Vector3 = box.global_position - player.camera_pivot.global_position
			player.rotation.y = atan2(-to_box.x, -to_box.z)
			player.camera_pivot.rotation.x = atan2(to_box.y, Vector2(to_box.x, to_box.z).length())
			await frames(6)
			Input.action_press("grab_object")
			await frames(18)
			check(player.held_grabbable == box, "route re-grabs parcel after physical contact")
			player.camera_pivot.rotation.x = 0.0
		print("ROUTE target=", target, " player=", player.position, " package=", box.position, " holding=", player.held_grabbable == box)
		check(reached, "route reaches " + str(target))
		if target == Vector2(2, 13.2):
			await capture("08-route-upstairs")
		if target == Vector2(4, 18.3):
			await capture("16-stairwell-interior")
		if not reached:
			break
	Input.action_release("grab_object")
	await frames(20)
	check(level.completion_overlay.visible, "route completes villa without teleport")
	await capture("09-route-complete")
	print("RESULT route checks=", checks, " failures=", failures)

func coop_performance_test() -> void:
	var coop: Node = await enter("res://scenes/level/VillaCoop.tscn")
	coop._p1_character_panel._on_confirm_pressed()
	coop._p2_character_panel._on_confirm_pressed()
	await frames(15)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	root.size = Vector2i(1280, 720)
	coop.player1.set_physics_process(false)
	coop.player2.set_physics_process(false)
	for interior in [false, true]:
		if interior:
			coop.player2.position = Vector3(3.7, 4.0, 7.2)
			coop.player2.rotation.y = -PI / 2.0
		for shadows in [true, false]:
			settings.shadows_enabled = shadows
			settings.settings_changed.emit()
			await frames(60)
			var times: Array[float] = []
			var previous := Time.get_ticks_usec()
			for frame in 300:
				await get_tree().process_frame
				var now := Time.get_ticks_usec()
				times.append(float(now - previous) / 1000.0)
				previous = now
			times.sort()
			var total := 0.0
			for value in times:
				total += value
			var line := "COOP_FRAME_SAMPLE interior=%s shadows=%s frames=300 mean_ms=%.3f median_ms=%.3f p95_ms=%.3f" % [interior, shadows, total / times.size(), times[150], times[285]]
			report.store_line(line)
			report.flush()
			check(coop._left_viewport.world_3d == coop._right_viewport.world_3d and times[285] < 1000.0, "coop render sample completed " + str(interior) + "/" + str(shadows))
			await capture("coop-performance-" + str(interior) + "-" + str(shadows))
	coop._back_to_menu()
	await frames(5)

func grab_contact_test() -> void:
	var fixture := Node3D.new()
	root.add_child(fixture)
	fixture.position = Vector3(100, 20, 100)
	var wall := StaticBody3D.new()
	wall.position = Vector3(0, 1, 1.1)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4, 4, 0.2)
	collision.shape = shape
	wall.add_child(collision)
	fixture.add_child(wall)
	var parcel: Package = preload("res://scenes/package/Package.tscn").instantiate()
	parcel.position = Vector3(0, 1, 0.62)
	parcel.gravity_scale = 0
	parcel.max_force_per_grabber = 0
	parcel.constant_force = Vector3(0, 0, 10)
	fixture.add_child(parcel)
	var holder := Node3D.new()
	fixture.add_child(holder)
	var target := Node3D.new()
	target.position = Vector3(0, 1, 0)
	holder.add_child(target)
	await frames(12)
	var state := PhysicsServer3D.body_get_direct_state(parcel.get_rid())
	check(state != null and state.get_contact_count() > 0, "contact fixture presses real parcel against static wall")
	var connection := GrabbableBody._GrabConnection.new()
	connection.grabber = holder
	connection.target_point = target
	var legacy_query := PhysicsRayQueryParameters3D.create(target.global_position, fixture.to_global(Vector3(0, 1, 1.04)), 1, [parcel.get_rid()])
	check(not state.get_space_state().intersect_ray(legacy_query).is_empty(), "original ray-only rule reports shallow contact as a wall")
	check(not parcel._is_connection_path_blocked(state, connection, fixture.to_global(Vector3(0, 1, 0.8))), "unobstructed grab path stays connected")
	check(not parcel._is_connection_path_blocked(state, connection, fixture.to_global(Vector3(0, 1, 1.04))), "four centimetre contact overlap does not count as occlusion")
	check(parcel._is_connection_path_blocked(state, connection, fixture.to_global(Vector3(0, 1, 1.12))), "deep wall occlusion remains blocked despite body contact")
	var other := StaticBody3D.new()
	other.position = Vector3(2, 1, 0.3)
	var other_shape := collision.duplicate()
	other_shape.shape = BoxShape3D.new()
	other_shape.shape.size = Vector3(0.2, 4, 0.2)
	other.add_child(other_shape)
	fixture.add_child(other)
	await frames(3)
	state = PhysicsServer3D.body_get_direct_state(parcel.get_rid())
	target.position.x = 2
	check(parcel._is_connection_path_blocked(state, connection, fixture.to_global(Vector3(2, 1, 0.24))), "near-end ray hit without parcel contact remains blocked")
	target.position.x = 0
	other.queue_free()
	await frames(3)
	var player_holder: Player = preload("res://scenes/player/Player.tscn").instantiate()
	player_holder.input_profile = Player.InputProfile.NETWORK
	player_holder.position = Vector3(0, 0.3, 0)
	player_holder.rotation.y = PI
	player_holder.collision_layer = 0
	player_holder.collision_mask = 0
	fixture.add_child(player_holder)
	player_holder.set_physics_process(false)
	player_holder.grab_collision_barrier.collision_layer = 0
	var player_connection := GrabbableBody._GrabConnection.new()
	player_connection.grabber = player_holder
	player_connection.target_point = player_holder.hold_point
	var virtual_ray := PhysicsRayQueryParameters3D.create(player_holder.hold_point.global_position, fixture.to_global(Vector3(0, 1, 0.8)), 1, [parcel.get_rid()])
	check(not state.get_space_state().intersect_ray(virtual_ray).is_empty(), "turning spring target beyond wall reproduces virtual occlusion")
	check(not parcel._is_connection_path_blocked(state, player_connection, fixture.to_global(Vector3(0, 1, 0.8))), "player-side parcel stays connected when virtual target crosses wall")
	check(not parcel._is_connection_path_blocked(state, player_connection, fixture.to_global(Vector3(0, 1, 1.103))), "visible parcel stays held when its attachment penetrates a stair contact")
	player_holder.position.z = 2
	check(parcel._is_connection_path_blocked(state, player_connection, fixture.to_global(Vector3(0, 1, 0.8))), "wall between actual player and parcel still blocks grip")
	player_holder.queue_free()
	var blocked_holder := Node3D.new()
	fixture.add_child(blocked_holder)
	var blocked_target := Node3D.new()
	blocked_target.position = Vector3(0, 1, 2)
	blocked_holder.add_child(blocked_target)
	var reasons: Array = []
	parcel.grabber_disconnected.connect(func(_holder, reason): reasons.append(reason))
	check(parcel.add_grabber(holder, target, parcel.global_position) and parcel.add_grabber(blocked_holder, blocked_target, parcel.global_position), "two grab connections established for wall regression")
	await frames(8)
	check(parcel.has_grabber(holder) and not parcel.has_grabber(blocked_holder), "wall releases only obstructed partner connection")
	check(GrabbableBody.DisconnectReason.BLOCKED in reasons, "real wall release retains blocked reason")
	parcel.remove_grabber(holder)
	fixture.queue_free()
	await frames(4)
