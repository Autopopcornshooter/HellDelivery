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
	get_tree().create_timer(120.0).timeout.connect(func():
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
	var menu: Node = await enter("res://scenes/ui/MainMenu.tscn")
	check(menu.start_button.has_focus(), "menu keyboard focus")
	await capture("01-menu")
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
		check(character.current_character_id == definition.id and character.get_head_node() != null and character.animation_controller._has_carry_pose, "character model and carry animation " + definition.id)
		current_scene.player.set_physics_process(false)
		var controller := character.animation_controller
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
		var expected: Vector3 = player.global_basis * (anim._carry_pose_left * Vector3.DOWN)
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
