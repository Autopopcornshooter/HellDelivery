extends Node3D

const PORT := 27926
const PROTOCOL := 30
var return_lobby_button: Button
var in_lobby := false
var lobby_joined := false
var readiness: Array = [false, false]
var room_ui: VBoxContainer
var peer: ENetMultiplayerPeer
var hosting := false
var remote_id := 0
var level: Node
var active := false
var finished := false
var menu_open := false
var generation := 0
var local_slot := 0
var local_yaw := PI
var local_pitch := 0.0
var remote_last_input := 0
var _snapshot_time := 0.0
var _connect_started := 0
var _last_snapshot := 0
var _characters: Array = []
var _targets: Array = []
var _body_targets: Array = []
var _last_delivery := 0
var _remote_controls: Array = []
var rtt_ms := -1
var _ping_time := 0.0
var _pending_pings: Dictionary = {}
var cancel_button: Button
var personal_recover_button: Button
var _personal_requests: Dictionary = {}
var _personal_last: Dictionary = {}
var status: Label
var address: LineEdit
var port_input: SpinBox
var lobby: VBoxContainer
var panel: PanelContainer
var resume_button: Button
var recover_button: Button
var restart_button: Button
var host_button: Button
var join_button: Button
var _hud_status: Label
var _panel_title: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_ui()
	multiplayer.connected_to_server.connect(_connected)
	multiplayer.connection_failed.connect(func(): _connection_ended("접속 실패 · IP/포트와 호스트 실행 상태를 확인하세요"))
	multiplayer.server_disconnected.connect(func(): _connection_ended("호스트 연결이 종료되었습니다"))
	multiplayer.peer_disconnected.connect(_peer_left)
	if OS.is_debug_build() and ("network-test-host" in OS.get_cmdline_user_args() or "network-test-client" in OS.get_cmdline_user_args()):
		var test: Node = load("res://tests/OnlinePlaytest.gd").new()
		test.name = "NetworkTest"
		add_child(test)

func _label(text: String, size: int = 20) -> Label:
	var item := Label.new()
	item.text = text
	item.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	item.add_theme_font_size_override("font_size", size)
	return item

func _button(parent: Node, text: String, action: Callable) -> Button:
	var item := Button.new()
	item.text = text
	item.custom_minimum_size = Vector2(500, 42)
	item.pressed.connect(action)
	parent.add_child(item)
	return item

func _build_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	add_child(canvas)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(center)
	panel = PanelContainer.new()
	center.add_child(panel)
	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	panel.add_child(margin)
	lobby = VBoxContainer.new()
	lobby.add_theme_constant_override("separation", 10)
	margin.add_child(lobby)
	_panel_title = _label("온라인 협동 · 2인", 28)
	lobby.add_child(_panel_title)
	status = _label("호스트가 방을 만들고 다른 PC에서 IP로 참가하세요", 17)
	status.custom_minimum_size.x = 560
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lobby.add_child(status)
	address = LineEdit.new()
	address.text = "127.0.0.1"
	address.placeholder_text = "호스트 IP 주소"
	address.max_length = 64
	lobby.add_child(address)
	port_input = SpinBox.new()
	port_input.min_value = 1024
	port_input.max_value = 65535
	port_input.value = PORT
	port_input.prefix = "UDP 포트 "
	lobby.add_child(port_input)
	host_button = _button(lobby, "방 만들기", host_game)
	join_button = _button(lobby, "IP로 참가", join_game)
	room_ui = preload("res://scenes/network/OnlineLobby.gd").new()
	lobby.add_child(room_ui)
	room_ui.character_changed.connect(select_lobby_character)
	room_ui.ready_pressed.connect(toggle_ready)
	room_ui.start_pressed.connect(start_delivery)
	room_ui.hide()
	cancel_button = _button(lobby, "대기·접속 취소", func(): _connection_ended("취소했습니다 · 방을 만들거나 다시 참가할 수 있습니다"))
	cancel_button.hide()
	resume_button = _button(lobby, "계속하기", _resume)
	personal_recover_button = _button(lobby, "내 위치만 복구 · 상대와 배송 진행 유지", request_personal_recovery)
	recover_button = _button(lobby, "두 사람·미배송 택배 복구", recover_world)
	restart_button = _button(lobby, "두 사람 처음부터 재시작", restart_world)
	return_lobby_button = _button(lobby, "함께 대기실로 · 캐릭터 변경 / 다시 준비", return_to_lobby)
	return_lobby_button.hide()
	_button(lobby, "메인 메뉴 · 연결 종료", leave)
	for item in [resume_button, personal_recover_button, recover_button, restart_button]:
		item.hide()
	_hud_status = _label("", 17)
	_hud_status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_hud_status.offset_top = -60
	_hud_status.offset_bottom = -35
	_hud_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_hud_status)

func host_game() -> void:
	_close_peer()
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(int(port_input.value), 1)
	if error != OK:
		status.text = "방 생성 실패 · 포트가 사용 중인지 확인하세요 (%d)" % error
		peer = null
		return
	hosting = true
	local_slot = 0
	multiplayer.multiplayer_peer = peer
	var ips: PackedStringArray = []
	for ip in IP.get_local_addresses():
		if ":" not in ip and not ip.begins_with("127.") and not ip.begins_with("169.254."):
			ips.append(ip)
	status.text = "참가자 대기 · UDP %d\n이 PC: %s\n같은 PC 테스트: 127.0.0.1" % [int(port_input.value), ", ".join(ips)]
	_set_connecting(true)
	in_lobby = true
	lobby_joined = false
	_characters = [GameSettings.selected_character_id, CharacterCatalog.get_default_id()]
	readiness = [false, false]
	_show_room()

func join_game() -> void:
	var ip := address.text.strip_edges()
	if not ip.is_valid_ip_address():
		status.text = "올바른 호스트 IP 주소를 입력하세요"
		return
	_close_peer()
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_client(ip, int(port_input.value))
	if error != OK:
		status.text = "접속을 시작할 수 없습니다 (%d)" % error
		peer = null
		return
	hosting = false
	local_slot = 1
	multiplayer.multiplayer_peer = peer
	_connect_started = Time.get_ticks_msec()
	status.text = "%s:%d 접속 중…" % [ip, int(port_input.value)]
	_set_connecting(true)

func _set_connecting(value: bool) -> void:
	cancel_button.visible = value
	host_button.disabled = value
	join_button.disabled = value
	address.editable = not value
	port_input.editable = not value

func _connected() -> void:
	_connect_started = 0
	status.text = "접속됨 · 빌라를 준비하고 있습니다"
	_hello.rpc_id(1, PROTOCOL, GameSettings.selected_character_id)

@rpc("any_peer", "call_remote", "reliable")
func _hello(version: int, character: String) -> void:
	if not hosting or not in_lobby or remote_id != 0:
		return
	var sender := multiplayer.get_remote_sender_id()
	if version != PROTOCOL:
		peer.disconnect_peer(sender)
		return
	remote_id = sender
	_characters[1] = CharacterCatalog.resolve_id_or_default(character)
	lobby_joined = true
	readiness = [false, false]
	_lobby_state.rpc(_characters, readiness)

func _show_room() -> void:
	_panel_title.text = "배송 대기실 · 빌라 201호 / 202호"
	for item in [address, port_input, host_button, join_button]: item.hide()
	room_ui.show_state(_characters, readiness, lobby_joined, local_slot, hosting)
	if lobby_joined:
		status.text = "캐릭터 선택 → 두 사람 준비 → 호스트 배송 시작\n캐릭터를 바꾸면 내 준비가 해제됩니다"

@rpc("authority", "call_local", "reliable")
func _lobby_state(characters: Array, ready_states: Array) -> void:
	in_lobby = true
	lobby_joined = true
	_characters = characters.duplicate()
	readiness = ready_states.duplicate()
	_show_room()

func select_lobby_character(character: String) -> void:
	if not in_lobby: return
	GameSettings.set_selected_character_id(character)
	if hosting:
		_characters[0] = CharacterCatalog.resolve_id_or_default(character)
		readiness[0] = false
		_publish_lobby()
	else:
		_lobby_choice.rpc_id(1, character, false)

func toggle_ready() -> void:
	if not in_lobby or not lobby_joined: return
	if hosting:
		readiness[0] = not readiness[0]
		_publish_lobby()
	else:
		_lobby_choice.rpc_id(1, _characters[1], not readiness[1])

@rpc("any_peer", "call_remote", "reliable")
func _lobby_choice(character: String, ready_state: bool) -> void:
	if not hosting or not in_lobby or multiplayer.get_remote_sender_id() != remote_id: return
	var resolved := CharacterCatalog.resolve_id_or_default(character)
	readiness[1] = ready_state if resolved == _characters[1] else false
	_characters[1] = resolved
	_publish_lobby()

func _publish_lobby() -> void:
	if lobby_joined: _lobby_state.rpc(_characters, readiness)
	else: _show_room()

func start_delivery() -> void:
	if not hosting or not in_lobby or not lobby_joined or not (readiness[0] and readiness[1]): return
	in_lobby = false
	generation += 1
	_start_world.rpc(_characters, generation)

@rpc("authority", "call_local", "reliable")
func _start_world(characters: Array, epoch: int) -> void:
	return_lobby_button.hide()
	in_lobby = false
	room_ui.hide()
	active = false
	finished = false
	menu_open = false
	generation = epoch
	_targets.clear()
	_body_targets.clear()
	_remote_controls.clear()
	_personal_requests.clear()
	_personal_last.clear()
	_last_delivery = 0
	rtt_ms = -1
	_pending_pings.clear()
	_ping_time = 0
	cancel_button.hide()
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
	level = preload("res://scenes/level/VillaDeliveryRun.tscn").instantiate()
	level.set_script(preload("res://scenes/network/OnlineLevel.gd"))
	level.name = "Level"
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	get_tree().paused = false
	level.set_process_unhandled_input(false)
	for name in ["PauseMenu", "OnboardingOverlay", "CompletionOverlay"]:
		var overlay: Node = level.get_node("UI/" + name)
		overlay.hide()
		overlay.set_process_unhandled_input(false)
	for i in 2:
		var courier: Player = _players()[i]
		courier.input_profile = Player.InputProfile.NETWORK
		courier.set_process_unhandled_input(false)
		courier.set_physics_process(false)
		courier.apply_character(characters[i])
		courier.camera_pivot.get_node("Camera3D").current = i == local_slot
	local_yaw = _players()[local_slot].rotation.y
	local_pitch = 0
	level.set_physics_process(false)
	level._feedback.player_pan = 0
	level._second_feedback.player_pan = 0
	if not hosting:
		level.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		for zone in [level.delivery_zone, level.second_zone]:
			zone.monitoring = false
		for body in _bodies():
			body.freeze = true
			body.collision_layer = 0
			body.collision_mask = 0
		for courier in _players():
			courier.collision_layer = 0
			courier.collision_mask = 0
	level.delivery_hud.visible = true
	level.delivery_hud.get_node("HelpLabel").text = "WASD 이동 · 마우스 시점/잡기 · Space 점프 · Shift 달리기 · Esc 메뉴 | 호스트 F5 복구 / R 재시작"
	panel.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_last_snapshot = Time.get_ticks_msec()
	if not hosting:
		_ready_world.rpc_id(1, generation)

@rpc("any_peer", "call_remote", "reliable")
func _ready_world(epoch: int) -> void:
	if not hosting or multiplayer.get_remote_sender_id() != remote_id or epoch != generation:
		return
	active = true
	remote_last_input = Time.get_ticks_msec()
	level.set_physics_process(true)
	for courier in _players():
		courier.set_physics_process(true)
	_go.rpc(generation)

@rpc("authority", "call_remote", "reliable")
func _go(epoch: int) -> void:
	if epoch == generation:
		active = true

func _players() -> Array:
	return [level.player, level.player2]

func _bodies() -> Array:
	var result: Array = []
	for child in level.get_node("Gameplay").get_children():
		if child is GrabbableBody:
			result.append(child)
	return result

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("ui_cancel"):
		if not finished:
			if menu_open: _resume()
			else: _open_menu()
		get_viewport().set_input_as_handled()
	elif not menu_open and not finished and event is InputEventMouseMotion:
		local_yaw = wrapf(local_yaw - event.relative.x * GameSettings.mouse_sensitivity, -PI, PI)
		local_pitch = clampf(local_pitch - event.relative.y * GameSettings.mouse_sensitivity, deg_to_rad(-80), deg_to_rad(55))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("recover") or event.is_action_pressed("restart"):
		if hosting and not menu_open:
			if event.is_action_pressed("recover"): recover_world()
			else: restart_world()
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if _connect_started > 0 and Time.get_ticks_msec() - _connect_started > 10000:
		_connection_ended("접속 시간 초과 · IP/UDP 포트/방화벽 설정을 확인하세요")
	if not active or not is_instance_valid(level):
		return
	var move := Input.get_vector("move_left", "move_right", "move_forward", "move_backward") if not menu_open and not finished else Vector2.ZERO
	var grab := not menu_open and not finished and Input.is_action_pressed("grab_object")
	var jump := not menu_open and not finished and Input.is_action_pressed("jump")
	var sprint := not menu_open and not finished and Input.is_action_pressed("sprint")
	if hosting:
		for slot in _personal_requests.keys():
			_restore_personal(slot)
		_personal_requests.clear()
		_apply_input(level.player, move, local_yaw, local_pitch, grab, jump, sprint)
		if not _remote_controls.is_empty():
			_apply_input(level.player2, _remote_controls[0], _remote_controls[1], _remote_controls[2], _remote_controls[3], _remote_controls[4], _remote_controls[5])
		if Time.get_ticks_msec() - remote_last_input > 500:
			_apply_input(level.player2, Vector2.ZERO, level.player2.rotation.y, level.player2.camera_pivot.rotation.x, false, false, false)
		if not finished and level._delivered_total() == 2:
			_complete.rpc(generation, "\n".join(level._delivery_details))
		_snapshot_time += delta
		if _snapshot_time >= 0.05:
			_snapshot_time = 0
			_send_snapshot()
	else:
		_controls.rpc_id(1, generation, move, local_yaw, local_pitch, grab, jump, sprint)
		_ping_time += delta
		if _ping_time >= 1.0:
			_ping_time = 0
			var stamp := Time.get_ticks_msec()
			_pending_pings[stamp] = true
			for old in _pending_pings.keys():
				if stamp - old > 5000: _pending_pings.erase(old)
			_ping.rpc_id(1, generation, stamp)
		if _targets.size() == 2 and not finished:
			for i in 2:
				var audio: LevelAudio = level._feedback if i == 0 else level._second_feedback
				audio.update_motion(_players()[i].held_grabbable, _targets[i][5], _targets[i][1], delta)
		if Time.get_ticks_msec() - _last_snapshot > 10000:
			_connection_ended("호스트 응답이 없습니다 · 연결을 종료했습니다")
			return
	_hud_status.text = ("호스트" if hosting else "참가자") + " · 온라인 2인 | " + _connection_quality()

func _connection_quality() -> String:
	if finished: return "배송 완료"
	var age := Time.get_ticks_msec() - (remote_last_input if hosting else _last_snapshot)
	if age > 500:
		return "상대 입력 지연 · 안전 정지 중" if hosting else "상태 수신 지연 · 연결 확인 중"
	if hosting: return "참가자 연결됨"
	if rtt_ms < 0: return "연결됨 · 지연 측정 중"
	return "왕복 %d ms%s" % [rtt_ms, " · 반응 지연 가능" if rtt_ms >= 150 else ""]

@rpc("any_peer", "call_remote", "unreliable", 3)
func _ping(epoch: int, stamp: int) -> void:
	if hosting and active and epoch == generation and multiplayer.get_remote_sender_id() == remote_id:
		_pong.rpc_id(remote_id, generation, stamp)

@rpc("authority", "call_remote", "unreliable", 3)
func _pong(epoch: int, stamp: int) -> void:
	if epoch == generation and _pending_pings.has(stamp):
		rtt_ms = int(Time.get_ticks_msec() - stamp)
		_pending_pings.erase(stamp)

func _apply_input(courier: Player, move: Vector2, yaw: float, pitch: float, grab: bool, jump: bool, sprint: bool) -> void:
	courier.network_move = move.limit_length(1)
	courier.rotation.y = yaw
	courier.camera_pivot.rotation.x = pitch
	courier.network_grab = grab
	courier.network_jump = jump
	courier.network_sprint = sprint

@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func _controls(epoch: int, move: Vector2, yaw: float, pitch: float, grab: bool, jump: bool, sprint: bool) -> void:
	if not hosting or not active or finished or epoch != generation or multiplayer.get_remote_sender_id() != remote_id:
		return
	if not move.is_finite() or not is_finite(yaw) or not is_finite(pitch):
		return
	remote_last_input = Time.get_ticks_msec()
	_remote_controls = [move, wrapf(yaw, -PI, PI), clampf(pitch, deg_to_rad(-80), deg_to_rad(55)), grab, jump, sprint]

func _send_snapshot() -> void:
	if remote_id == 0:
		return
	var players: Array = []
	for courier in _players():
		players.append([courier.transform, courier.velocity, courier.camera_pivot.rotation.x, str(courier.held_grabbable.name) if courier.held_grabbable != null else "", courier.network_sprint, courier.is_on_floor(), courier._last_grab_aim_state])
	var bodies: Array = []
	for body in _bodies():
		bodies.append([body.transform, body.is_delivered(), body.visible])
	_state.rpc_id(remote_id, generation, players, bodies, [level.delivery_zone.delivered_count, level.second_zone.delivered_count], level.delivery_hud.get_node("RouteLabel").text)

@rpc("authority", "call_remote", "unreliable_ordered", 2)
func _state(epoch: int, players: Array, bodies: Array, counts: Array, route: String) -> void:
	if epoch != generation or not is_instance_valid(level):
		return
	_last_snapshot = Time.get_ticks_msec()
	_targets = players
	_body_targets = bodies
	# Completion is reliable; an older snapshot on another channel cannot undo it.
	counts[0] = maxi(counts[0], level.delivery_zone.delivered_count)
	counts[1] = maxi(counts[1], level.second_zone.delivered_count)
	level.delivery_zone.delivered_count = counts[0]
	level.second_zone.delivered_count = counts[1]
	level._update_stops()
	level.delivery_hud.update_progress(counts[0] + counts[1], 2)
	level.delivery_hud.get_node("RouteLabel").text = route
	if counts[0] + counts[1] > _last_delivery:
		level._feedback.play_cue("delivery")
	_last_delivery = counts[0] + counts[1]
	level.delivery_hud.set_crosshair_state(players[local_slot][6])

func _process(delta: float) -> void:
	if hosting or not active or _targets.size() != 2:
		return
	var weight := 1.0 - exp(-25.0 * delta)
	for i in 2:
		var courier: Player = _players()[i]
		var data: Array = _targets[i]
		var target: Transform3D = data[0]
		courier.position = courier.position.lerp(target.origin, weight) if courier.position.distance_to(target.origin) < 3.0 else target.origin
		courier.rotation.y = local_yaw if i == local_slot else lerp_angle(courier.rotation.y, target.basis.get_euler().y, weight)
		courier.camera_pivot.rotation.x = local_pitch if i == local_slot else lerpf(courier.camera_pivot.rotation.x, data[2], weight)
		courier.velocity = data[1]
		courier.held_grabbable = level.get_node_or_null("Gameplay/" + data[3]) if data[3] != "" else null
		var animation := courier.character_visual.animation_controller
		animation.update_locomotion(Vector2(courier.velocity.x, courier.velocity.z).length(), data[4], data[5])
		animation.set_carrying(courier.held_grabbable != null)
		animation.carry_pitch = courier.camera_pivot.rotation.x
	var bodies := _bodies()
	for i in mini(bodies.size(), _body_targets.size()):
		var body: GrabbableBody = bodies[i]
		var target: Transform3D = _body_targets[i][0]
		body.transform = body.transform.interpolate_with(target, weight) if body.position.distance_to(target.origin) < 3 else target
		body.visible = _body_targets[i][2]
		body._delivered = _body_targets[i][1]

@rpc("authority", "call_local", "reliable")
func _complete(epoch: int, details: String) -> void:
	if epoch != generation:
		return
	finished = true
	level.delivery_zone.delivered_count = 1
	level.second_zone.delivered_count = 1
	level.delivery_hud.update_progress(2, 2)
	level._update_stops()
	level.set_physics_process(false)
	for courier in _players():
		courier.set_physics_process(false)
	_open_menu()
	_panel_title.text = "배송 완료! · 두 집 배송 성공"
	status.text = details + "\n" + ("대기실에서 캐릭터를 바꾸거나 바로 다시 시작할 수 있습니다" if hosting else "호스트가 함께 대기실로 이동하거나 다시 시작할 수 있습니다")
	resume_button.hide()
	personal_recover_button.hide()
	recover_button.hide()

func _open_menu() -> void:
	menu_open = true
	panel.show()
	_panel_title.text = "온라인 메뉴"
	status.text = "메뉴를 열어도 상대의 게임은 계속됩니다\nWASD · 마우스 잡기 · Space 점프 · Shift 달리기\n개인 복구는 내 위치만 · 전체 복구/재시작은 호스트만"
	for item in [address, port_input, host_button, join_button]:
		item.hide()
	resume_button.visible = not finished
	personal_recover_button.visible = not finished
	recover_button.visible = hosting and not finished
	restart_button.visible = hosting
	return_lobby_button.visible = hosting and finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	menu_open = false
	panel.hide()
	Input.action_release("grab_object")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func recover_world() -> void:
	if not hosting or not active or finished:
		return
	level.recover_all()
	_reset_look.rpc()
	_resume()

func request_personal_recovery() -> void:
	if not active or finished: return
	if hosting:
		_personal_requests[0] = true
	else:
		_request_personal.rpc_id(1, generation)
	status.text = "내 위치 복구 요청 중…"

@rpc("any_peer", "call_remote", "reliable")
func _request_personal(epoch: int) -> void:
	if hosting and active and not finished and epoch == generation and multiplayer.get_remote_sender_id() == remote_id:
		_personal_requests[1] = true

func _restore_personal(slot: int) -> void:
	if finished: return
	var now := Time.get_ticks_msec()
	if now - int(_personal_last.get(slot, -1000)) < 1000:
		_personal_result.rpc(generation, slot, false)
		return
	_personal_last[slot] = now
	if slot == 0:
		level.recover_player()
	else:
		level._recover_second()
		_remote_controls.clear()
		_apply_input(level.player2, Vector2.ZERO, PI, 0, false, false, false)
	_personal_result.rpc(generation, slot, true)

@rpc("authority", "call_local", "reliable")
func _personal_result(epoch: int, slot: int, accepted: bool) -> void:
	if epoch != generation or slot != local_slot: return
	if not accepted:
		status.text = "잠시 후 다시 요청해 주세요"
		return
	_reset_look()
	_resume()
	level.delivery_hud.show_delivery_toast("내 위치를 복구했습니다 · 상대와 완료한 배송은 유지됩니다")

@rpc("authority", "call_local", "reliable")
func _reset_look() -> void:
	local_yaw = PI
	local_pitch = 0
	Input.action_release("grab_object")

func restart_world() -> void:
	if not hosting or not active:
		return
	generation += 1
	_start_world.rpc(_characters, generation)

func return_to_lobby() -> void:
	if not hosting or not active or not finished: return
	_return_lobby.rpc(generation + 1)

@rpc("authority", "call_local", "reliable")
func _return_lobby(epoch: int) -> void:
	# Invalidate snapshots and pending recovery replies from the completed round.
	generation = epoch
	active = false
	finished = false
	menu_open = false
	_targets.clear()
	_body_targets.clear()
	_remote_controls.clear()
	_personal_requests.clear()
	_personal_last.clear()
	_pending_pings.clear()
	rtt_ms = -1
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
		level = null
	for item in [resume_button, personal_recover_button, recover_button, restart_button, return_lobby_button]: item.hide()
	_hud_status.text = ""
	panel.show()
	cancel_button.show()
	Input.action_release("grab_object")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_lobby_state(_characters, [false, false])

func _peer_left(id: int) -> void:
	if hosting and id == remote_id:
		_connection_ended("참가자가 연결을 종료했습니다 · 새 방을 만들 수 있습니다")

func _connection_ended(message: String) -> void:
	return_lobby_button.hide()
	in_lobby = false
	lobby_joined = false
	readiness = [false, false]
	room_ui.hide()
	active = false
	finished = false
	_close_peer()
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
		level = null
	panel.show()
	_panel_title.text = "온라인 협동 · 2인"
	status.text = message
	_hud_status.text = ""
	for item in [address, port_input, host_button, join_button]:
		item.show()
	for item in [resume_button, personal_recover_button, recover_button, restart_button]:
		item.hide()
	_set_connecting(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_peer() -> void:
	rtt_ms = -1
	_pending_pings.clear()
	_connect_started = 0
	remote_id = 0
	if peer != null:
		peer.close()
		peer = null
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func leave() -> void:
	_close_peer()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func _exit_tree() -> void:
	_close_peer()
