extends Node3D

const PORT := 27926
const PROTOCOL := 48
@export var full_route := false
var freight: FreightRun
var shipment_result: Dictionary = {}
const MAX_PLAYERS := 4
var peer_slots: Array = [1, 0, 0, 0]
var slot_inputs: Dictionary = {}
var slot_last_input: Dictionary = {}
var ready_peers: Dictionary = {}
var partner_markers: Array = []
const COURSE_ORDERS: Array[String] = ["standard", "mixed", "team"]
var course: Dictionary = {}
var help_packages: Array[String] = ["", "", "", ""]
var help_deadlines: Array[int] = [0, 0, 0, 0]
var help_marker: PanelContainer
var help_notice: Label
var room_record: Dictionary = {"orders": 0, "complete": 0, "delivered": 0, "target": 0, "elapsed": 0.0, "recent": []}
var history_panel: PanelContainer
var history_text: Label
var manifest_panel: PanelContainer
var manifest_text: Label
var manifest_held := false
var finish_request_button: Button
var finish_panel: PanelContainer
var finish_status: Label
var finish_accept: Button
var finish_continue: Button
var finish_pending := false
var finish_serial := 0
var finish_votes: Array = [false, false, false, false]
var order_id := "standard"
var order_revision := 0
var copy_row: HBoxContainer
var copy_addresses: OptionButton
var copy_button: Button
var partner_marker: PanelContainer
var controls_button: Button
var controls_panel: ControlsPanel
var settings_button: Button
var settings_panel: SettingsPanel
const LOAD_TIMEOUT_MS := 30000
var loading := false
var _loading_started := 0
var _local_world_ready := false
var _remote_world_ready := false
var return_lobby_button: Button
var in_lobby := false
var lobby_joined := false
var readiness: Array = [false, false, false, false]
var room_ui: VBoxContainer
var peer: ENetMultiplayerPeer
var hosting := false
var remote_id := 0
var level: Node
var active := false
var finished := false
var menu_open := false
var _window_unfocused := false
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
	if "freight-test" in OS.get_cmdline_user_args(): full_route = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_build_ui()
	get_window().focus_exited.connect(_on_window_focus_exited)
	get_window().focus_entered.connect(_on_window_focus_entered)
	multiplayer.connected_to_server.connect(_connected)
	multiplayer.connection_failed.connect(func(): _connection_ended("접속 실패 · IP/포트와 호스트 실행 상태를 확인하세요"))
	multiplayer.server_disconnected.connect(func(): _connection_ended("호스트 연결이 종료되었습니다"))
	multiplayer.peer_disconnected.connect(_peer_left)
	if OS.is_debug_build() and ("network-test-host" in OS.get_cmdline_user_args() or "network-test-client" in OS.get_cmdline_user_args()):
		var test: Node = load("res://tests/FreightPlaytest.gd" if "freight-test" in OS.get_cmdline_user_args() else ("res://tests/PartyPlaytest.gd" if "party-test" in OS.get_cmdline_user_args() else "res://tests/OnlinePlaytest.gd")).new()
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
	_panel_title = _label("전체 배송 · 1~4인" if full_route else "온라인 협동 · 2~4인", 28)
	lobby.add_child(_panel_title)
	status = _label("방 만들기 → 준비 → 배송 시작 · 혼자 또는 동료와 함께\n물류센터 적재 → 운전 → 빌라 배송 → 결과 평가" if full_route else "호스트가 방을 만들고 다른 PC에서 IP로 참가하세요", 17)
	status.custom_minimum_size.x = 560
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lobby.add_child(status)
	address = LineEdit.new()
	address.text = GameSettings.last_server_ip
	address.placeholder_text = "호스트 IP 또는 IP:포트 · Enter로 참가"
	address.text_submitted.connect(func(_text: String): join_game())
	address.max_length = 64
	lobby.add_child(address)
	port_input = SpinBox.new()
	port_input.min_value = 1024
	port_input.max_value = 65535
	port_input.value = GameSettings.network_port
	port_input.prefix = "UDP 포트 "
	lobby.add_child(port_input)
	host_button = _button(lobby, "방 만들기", host_game)
	join_button = _button(lobby, "IP로 참가", join_game)
	room_ui = preload("res://scenes/network/OnlineLobby.gd").new()
	lobby.add_child(room_ui)
	room_ui.character_changed.connect(select_lobby_character)
	room_ui.ready_pressed.connect(toggle_ready)
	room_ui.start_pressed.connect(start_delivery)
	room_ui.order_changed.connect(select_order)
	room_ui.history_pressed.connect(_open_history)
	room_ui.hide()
	var connection_actions := HBoxContainer.new()
	lobby.add_child(connection_actions)
	cancel_button = _button(connection_actions, "대기·접속 취소", func(): _connection_ended("취소했습니다 · 방을 만들거나 다시 참가할 수 있습니다"))
	cancel_button.custom_minimum_size.x = 180
	cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cancel_button.hide()
	copy_row = HBoxContainer.new()
	connection_actions.add_child(copy_row)
	copy_addresses = OptionButton.new()
	copy_addresses.custom_minimum_size.x = 230
	copy_row.add_child(copy_addresses)
	copy_button = _button(copy_row, "주소 복사", _copy_address)
	copy_button.custom_minimum_size.x = 100
	copy_row.hide()
	resume_button = _button(lobby, "계속하기", _resume)
	personal_recover_button = _button(lobby, "내 위치만 복구 · 상대와 배송 진행 유지", request_personal_recovery)
	recover_button = _button(lobby, "전원·미배송 택배 복구", recover_world)
	restart_button = _button(lobby, "전원 처음부터 재시작", restart_world)
	return_lobby_button = _button(lobby, "다음 주문 준비 · 함께 대기실로", return_to_lobby)
	return_lobby_button.hide()
	finish_request_button = _button(lobby, "현재 기록으로 주문 마무리 · 참가자 전원 동의", request_order_finish)
	finish_request_button.hide()
	settings_button = _button(lobby, "설정 · 내 화면 / 감도 / 음량", _open_settings)
	settings_button.hide()
	controls_button = _button(lobby, "조작법 · 배송 목표 / 복구 안내", _open_controls)
	controls_button.hide()
	_button(lobby, "메인 메뉴 · 연결 종료", leave)
	for item in [resume_button, personal_recover_button, recover_button, restart_button]:
		item.hide()
	_hud_status = _label("", 17)
	_hud_status.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_hud_status.offset_top = -60
	_hud_status.offset_bottom = -35
	_hud_status.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(_hud_status)
	partner_marker = preload("res://scenes/network/OnlinePartnerMarker.gd").new()
	canvas.add_child(partner_marker)
	partner_markers.append(partner_marker)
	for index in 2:
		var marker: PanelContainer = preload("res://scenes/network/OnlinePartnerMarker.gd").new()
		canvas.add_child(marker)
		partner_markers.append(marker)
	help_marker = preload("res://scenes/network/OnlinePartnerMarker.gd").new()
	canvas.add_child(help_marker)
	help_marker.modulate = Color(1.0, 0.85, 0.5)
	help_notice = _label("", 18)
	help_notice.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	help_notice.offset_top = -92
	help_notice.offset_bottom = -65
	help_notice.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(help_notice)
	settings_panel = preload("res://scenes/ui/SettingsPanel.tscn").instantiate()
	canvas.add_child(settings_panel)
	settings_panel.hide()
	settings_panel.closed.connect(_close_settings)
	settings_panel.get_node("Panel/VBoxContainer/TitleLabel").text = "내 설정 · 상대 플레이는 계속됩니다"
	# Online input is keyboard/mouse; avoid offering inactive gamepad options here.
	for path in ["GamepadSensitivityLabel", "GamepadSensitivitySlider", "InvertYCheck"]:
		settings_panel.get_node("Panel/VBoxContainer/" + path).hide()
	controls_panel = preload("res://scenes/ui/ControlsPanel.tscn").instantiate()
	canvas.add_child(controls_panel)
	controls_panel.hide()
	controls_panel.closed.connect(_close_controls)
	finish_panel = PanelContainer.new()
	center.add_child(finish_panel)
	var finish_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		finish_margin.add_theme_constant_override("margin_" + side, 20)
	finish_panel.add_child(finish_margin)
	var finish_content := VBoxContainer.new()
	finish_content.add_theme_constant_override("separation", 12)
	finish_margin.add_child(finish_content)
	finish_content.add_child(_label("이번 주문을 마무리할까요?", 26))
	finish_status = _label("", 18)
	finish_content.add_child(finish_status)
	finish_accept = _button(finish_content, "현재 기록으로 마무리 동의", func(): vote_order_finish(true))
	finish_continue = _button(finish_content, "배송 계속하기 · 요청 취소", func(): vote_order_finish(false))
	finish_panel.hide()

	manifest_panel = PanelContainer.new()
	var manifest_style := StyleBoxFlat.new()
	manifest_style.bg_color = Color(0.035, 0.055, 0.07, 0.94)
	manifest_style.set_corner_radius_all(6)
	manifest_panel.add_theme_stylebox_override("panel", manifest_style)
	manifest_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	manifest_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
	manifest_panel.offset_left = -470
	manifest_panel.offset_right = -20
	manifest_panel.offset_top = -150
	canvas.add_child(manifest_panel)
	var manifest_margin := MarginContainer.new()
	manifest_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["left", "right", "top", "bottom"]:
		manifest_margin.add_theme_constant_override("margin_" + side, 16)
	manifest_panel.add_child(manifest_margin)
	manifest_text = _label("", 18)
	manifest_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	manifest_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	manifest_margin.add_child(manifest_text)
	manifest_panel.hide()
	history_panel = PanelContainer.new()
	center.add_child(history_panel)
	var history_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		history_margin.add_theme_constant_override("margin_" + side, 20)
	history_panel.add_child(history_margin)
	var history_content := VBoxContainer.new()
	history_content.add_theme_constant_override("separation", 12)
	history_margin.add_child(history_content)
	history_content.add_child(_label("이 방의 배송 기록", 26))
	history_text = _label("", 18)
	history_content.add_child(history_text)
	_button(history_content, "대기실로 돌아가기", _close_history)
	history_panel.hide()

func request_carry_help() -> void:
	if not active or finished or menu_open or loading: return
	if hosting: _toggle_carry_help(generation, 0)
	else: _request_carry_help.rpc_id(1, generation)

@rpc("any_peer", "call_remote", "reliable")
func _request_carry_help(epoch: int) -> void:
	var slot := _sender_slot()
	if hosting and slot > 0: _toggle_carry_help(epoch, slot)

func _toggle_carry_help(epoch: int, slot: int) -> void:
	if not hosting or epoch != generation or not active or finished or loading: return
	if not help_packages[slot].is_empty():
		_carry_help_state.rpc(generation, slot, "")
		return
	var parcel: GrabbableBody = _players()[slot].held_grabbable
	if not parcel is Package or parcel.is_delivered() or parcel.get_grabber_count() >= 2: return
	help_deadlines[slot] = Time.get_ticks_msec() + 20000
	_carry_help_state.rpc(generation, slot, str(parcel.name))

@rpc("authority", "call_local", "reliable")
func _carry_help_state(epoch: int, slot: int, parcel_name: String) -> void:
	if epoch != generation or not active or finished: return
	help_packages[slot] = parcel_name

func _advance_carry_help() -> void:
	for slot in occupied_slots():
		if help_packages[slot].is_empty(): continue
		var parcel: Package = level.get_node_or_null("Gameplay/" + help_packages[slot])
		if parcel == null or parcel.is_delivered() or parcel.get_grabber_count() >= 2 or Time.get_ticks_msec() >= help_deadlines[slot]:
			_carry_help_state.rpc(generation, slot, "")

func _clear_carry_help() -> void:
	help_packages = ["", "", "", ""]
	help_deadlines = [0, 0, 0, 0]
	if is_instance_valid(help_marker): help_marker.hide()
	if is_instance_valid(help_notice): help_notice.hide()

func _update_carry_help() -> void:
	help_marker.hide()
	help_notice.hide()
	if not active or finished or menu_open or manifest_held or not is_instance_valid(level): return
	var own: Player = _players()[local_slot]
	var requested: Package = null
	var request_slot := -1
	for slot in occupied_slots():
		if slot == local_slot or help_packages[slot].is_empty(): continue
		requested = level.get_node_or_null("Gameplay/" + help_packages[slot])
		request_slot = slot
		if requested != null: break
	if requested != null and not requested.is_delivered():
		if not manifest_held:
			help_marker.update_partner(own.camera_pivot.get_node("Camera3D"), own.global_position, requested.global_position, "함께 운반 · %s호" % requested.delivery_address, 0.0, 0.65)
			for marker in partner_markers: marker.hide()
		help_notice.text = "P%d 동료가 %s호 택배 운반을 요청했습니다 · 같은 상자를 잡아주세요" % [request_slot + 1, requested.delivery_address]
	elif not help_packages[local_slot].is_empty():
		help_notice.text = "운반 도움 요청 보냄 · 20초 표시 · G 취소"
	elif own.held_grabbable is Package:
		help_notice.text = "G · 이 택배 함께 운반 요청"
	else: return
	help_notice.show()

func _record_order(elapsed: float, counts: Array) -> void:
	var delivered: int = int(counts[0]) + int(counts[1])
	var target: int = level._total_target()
	var successful: bool = delivered == target and (not full_route or shipment_result.get("success", false))
	if not course.is_empty():
		course.delivered += delivered
		course.elapsed += elapsed
		course.completed += 1 if successful else 0
		course.closed = not successful or course.index == COURSE_ORDERS.size() - 1
	room_record.orders += 1
	room_record.complete += 1 if successful else 0
	room_record.delivered += delivered
	room_record.target += target
	room_record.elapsed += elapsed
	room_record.recent.push_front({"number": room_record.orders, "order": order_id, "delivered": delivered, "target": target, "elapsed": elapsed})
	if full_route and not shipment_result.is_empty():
		room_record["score"] = int(room_record.get("score", 0)) + int(shipment_result.score)
		room_record.recent[0]["rating"] = shipment_result.duplicate(true)
	if room_record.recent.size() > 5: room_record.recent.pop_back()

func _history_contents() -> String:
	var lines: Array[String] = ["종료한 주문 %d건 · 전량 완료 %d건" % [room_record.orders, room_record.complete], "배송 %d/%d개 · 합계 시간 %s" % [room_record.delivered, room_record.target, DeliveryOrders.format_time(room_record.elapsed)], ""]
	if room_record.recent.is_empty(): lines.append("아직 마무리한 주문이 없습니다")
	else:
		lines.append("최근 주문 · 최신순 (최대 5건)")
		for entry in room_record.recent:
			lines.append("#%d %s · %d/%d개 · %s · %s" % [entry.number, DeliveryOrders.get_order(entry.order).title, entry.delivered, entry.target, DeliveryOrders.format_time(entry.elapsed), "완료" if (entry.rating.success if entry.has("rating") else entry.delivered == entry.target) else "부분 종료"])
			if entry.has("rating"): lines.append("  %s등급 · %d점 · %s" % [entry.rating.grade, entry.rating.score, entry.rating.reason])
	lines.append("\n호스트가 방을 닫으면 초기화됩니다\n연결 끊김·재시작으로 중단한 주문은 기록하지 않습니다")
	return "\n".join(lines)

func _open_history() -> void:
	if not in_lobby: return
	history_text.text = _history_contents()
	panel.hide()
	history_panel.show()
	history_panel.find_children("*", "Button", true, false)[0].grab_focus()

func _close_history() -> void:
	history_panel.hide()
	if in_lobby:
		panel.show()
		room_ui.history_button.grab_focus()

func _manifest_contents() -> String:
	if not is_instance_valid(level): return ""
	var lines: Array[String] = ["배송 목록 · Tab을 놓으면 닫기", "%s · %d/%d개 완료" % [DeliveryOrders.get_order(order_id).title, level._delivered_total(), level._total_target()], ""]
	var own: Player = _players()[local_slot]
	var numbers: Dictionary = {}
	for parcel in _bodies():
		if not parcel is Package: continue
		var address_id: String = parcel.delivery_address
		numbers[address_id] = int(numbers.get(address_id, 0)) + 1
		var state := "배송 완료"
		if not parcel.is_delivered():
			var carriers: Array[String] = []
			for slot in occupied_slots():
				if _players()[slot].held_grabbable == parcel:
					carriers.append("나" if slot == local_slot else ("동료" if occupied_slots().size() == 2 else "P%d" % (slot + 1)))
			state = " + ".join(carriers) + " 운반 중" if not carriers.is_empty() else "운반 대기"
			state += " · 나와 %.0fm" % own.global_position.distance_to(parcel.global_position)
		if full_route:
			state = (parcel.failure_reason + " · 배송 불가") if parcel.shipment_failed else (state + " · 상태 %d%%" % parcel.condition)
			if not parcel.loaded_once and not parcel.shipment_failed: state += " · 적재 필요"
		lines.append("%s호 #%d · %.0fkg\n  %s" % [address_id, numbers[address_id], parcel.mass, state])
	lines.append("\n거리: 택배까지 직선 거리\n45kg 택배는 두 사람이 함께 운반")
	return "\n".join(lines)

func _update_manifest() -> void:
	var available: bool = active and not finished and not menu_open and not loading and is_instance_valid(level)
	if not available: manifest_held = false
	manifest_panel.visible = available and manifest_held
	if manifest_panel.visible: manifest_text.text = _manifest_contents()

func request_order_finish() -> void:
	if not active or finished or loading or finish_pending: return
	if hosting: _begin_finish_vote(0)
	else: _request_order_finish.rpc_id(1, generation)

@rpc("any_peer", "call_remote", "reliable")
func _request_order_finish(epoch: int) -> void:
	var slot := _sender_slot()
	if hosting and epoch == generation and slot > 0: _begin_finish_vote(slot)

func _begin_finish_vote(slot: int) -> void:
	if not active or finished or loading or finish_pending: return
	finish_serial += 1
	var votes: Array = [false, false, false, false]
	votes[slot] = occupied_slots().size() > 1
	_finish_vote_state.rpc(generation, finish_serial, votes)

@rpc("authority", "call_local", "reliable")
func _finish_vote_state(epoch: int, serial: int, votes: Array) -> void:
	if epoch != generation or not active or finished or serial < finish_serial: return
	finish_serial = serial
	finish_pending = true
	finish_votes = votes.duplicate()
	_open_menu()
	panel.hide()
	finish_panel.show()
	_clear_local_actions()
	finish_status.text = "%s · 현재 배송 %d/%d개\n배달한 택배만 기록하고 남은 배송은 종료합니다\n방은 유지되며 결과에서 다음 주문을 준비할 수 있습니다\n\n호스트 %s · 참가자 %s" % [DeliveryOrders.get_order(order_id).title, level._delivered_total(), level._total_target(), "동의" if votes[0] else "확인 대기", "동의" if votes[1] else "확인 대기"]
	finish_accept.disabled = votes[local_slot]
	var vote_labels: Array[String] = []
	for slot in occupied_slots(): vote_labels.append("P%d %s" % [slot + 1, "동의" if votes[slot] else "대기"])
	finish_status.text = "%s · 배송 %d/%d개\n참가자 전원이 동의하면 실제 기록으로 종료합니다\n%s" % [DeliveryOrders.get_order(order_id).title, level._delivered_total(), level._total_target(), " · ".join(vote_labels)]
	finish_accept.text = "동의 완료 · 상대 확인 대기" if votes[local_slot] else "현재 기록으로 마무리 동의"
	finish_continue.grab_focus()

func vote_order_finish(agree: bool) -> void:
	if not finish_pending or finished: return
	if hosting: _handle_finish_vote(0, generation, finish_serial, agree)
	else: _submit_finish_vote.rpc_id(1, generation, finish_serial, agree)

@rpc("any_peer", "call_remote", "reliable")
func _submit_finish_vote(epoch: int, serial: int, agree: bool) -> void:
	var slot := _sender_slot()
	if hosting and slot > 0: _handle_finish_vote(slot, epoch, serial, agree)

func _handle_finish_vote(slot: int, epoch: int, serial: int, agree: bool) -> void:
	if not finish_pending or not active or finished or epoch != generation or serial != finish_serial: return
	if not agree:
		_cancel_finish_vote.rpc(epoch, serial)
		return
	finish_votes[slot] = true
	if occupied_slots().all(func(index): return finish_votes[index]):
		if full_route: finish_freight("합의 종료")
		else: _partial_result.rpc(generation, "\n".join(level._delivery_details), level._play_time_elapsed, [level.delivery_zone.delivered_count, level.second_zone.delivered_count])
	else:
		_finish_vote_state.rpc(generation, finish_serial, finish_votes)

@rpc("authority", "call_local", "reliable")
func _cancel_finish_vote(epoch: int, serial: int) -> void:
	if epoch != generation or serial != finish_serial or not finish_pending or finished: return
	_clear_finish_vote()
	_open_menu()
	status.text = "주문 마무리 요청을 취소했습니다\n배송 진행은 유지됩니다 · 계속하기로 재개하세요"

func _clear_finish_vote() -> void:
	finish_pending = false
	finish_votes = [false, false, false, false]
	if is_instance_valid(finish_panel): finish_panel.hide()
	if is_instance_valid(finish_request_button): finish_request_button.hide()

func host_game() -> void:
	_close_peer()
	peer = ENetMultiplayerPeer.new()
	var error := peer.create_server(int(port_input.value), MAX_PLAYERS - 1)
	if error != OK:
		status.text = "방 생성 실패 · 포트가 사용 중인지 확인하세요 (%d)" % error
		peer = null
		return
	hosting = true
	local_slot = 0
	multiplayer.multiplayer_peer = peer
	GameSettings.remember_server(GameSettings.last_server_ip, int(port_input.value))
	copy_addresses.clear()
	for ip in IP.get_local_addresses():
		if ":" not in ip and not ip.begins_with("127.") and not ip.begins_with("169.254."):
			copy_addresses.add_item("%s:%d" % [ip, int(port_input.value)])
	copy_addresses.add_item("127.0.0.1:%d" % int(port_input.value))
	status.text = _waiting_address_text("참가자 대기")
	_set_connecting(true)
	in_lobby = true
	lobby_joined = full_route
	_characters = [CharacterCatalog.resolve_id_or_default(GameSettings.selected_character_id), CharacterCatalog.get_default_id(), CharacterCatalog.get_default_id(), CharacterCatalog.get_default_id()]
	readiness = [false, false, false, false]
	_show_room()

func _waiting_address_text(message: String) -> String:
	var ips: PackedStringArray = []
	for ip in IP.get_local_addresses():
		if ":" not in ip and not ip.begins_with("127.") and not ip.begins_with("169.254."):
			ips.append(ip)
	return "%s · UDP %d\n이 PC: %s\n같은 PC 테스트: 127.0.0.1" % [message, int(port_input.value), ", ".join(ips)]

func join_game() -> void:
	var endpoint := parse_endpoint(address.text, int(port_input.value))
	if endpoint.is_empty():
		status.text = "올바른 IP 또는 IP:포트(1024~65535)를 입력하세요"
		return
	var ip: String = endpoint[0]
	address.text = ip
	port_input.value = endpoint[1]
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

static func parse_endpoint(value: String, fallback_port: int) -> Array:
	var ip := value.strip_edges()
	var port := fallback_port
	if not ip.is_valid_ip_address():
		var port_text := ""
		if ip.begins_with("[") and ip.contains("]:"):
			var closing := ip.find("]:")
			port_text = ip.substr(closing + 2)
			ip = ip.substr(1, closing - 1)
		elif ip.count(":") == 1:
			port_text = ip.get_slice(":", 1)
			ip = ip.get_slice(":", 0)
		else: return []
		if not port_text.is_valid_int() or port_text.length() > 5: return []
		port = port_text.to_int()
	if not ip.is_valid_ip_address() or port < 1024 or port > 65535: return []
	return [ip, port]

func _copy_address() -> void:
	if not hosting or not in_lobby or copy_addresses.item_count == 0: return
	DisplayServer.clipboard_set(copy_addresses.get_item_text(copy_addresses.selected))
	copy_button.text = "복사됨"

func _set_connecting(value: bool) -> void:
	cancel_button.visible = value
	host_button.disabled = value
	join_button.disabled = value
	address.editable = not value
	port_input.editable = not value

func _connected() -> void:
	# Keep the timeout until the host accepts our lobby handshake.
	_connect_started = Time.get_ticks_msec()
	status.text = "접속됨 · 빌라를 준비하고 있습니다"
	_hello.rpc_id(1, PROTOCOL, GameSettings.selected_character_id, full_route)

@rpc("any_peer", "call_remote", "reliable")
func _hello(version: int, character: String, route_mode := false) -> void:
	if not hosting: return
	var sender := multiplayer.get_remote_sender_id()
	if not in_lobby:
		_join_rejected.rpc_id(sender, "배송 진행 중입니다 · 호스트가 대기실로 돌아온 뒤 참가하세요")
		return
	if version != PROTOCOL:
		_join_rejected.rpc_id(sender, "빌드 버전이 다릅니다 · 모두 같은 Windows 빌드를 실행하세요")
		return
	if route_mode != full_route:
		_join_rejected.rpc_id(sender, "플레이 모드가 다릅니다 · 모두 전체 배송 또는 빌라 연습 중 같은 메뉴로 참가하세요")
		return
	if sender in peer_slots: return
	var slot: int = peer_slots.find(0)
	if slot < 1:
		peer.disconnect_peer(sender)
		return
	peer_slots[slot] = sender
	remote_id = peer_slots[occupied_slots()[1]]
	_characters[slot] = CharacterCatalog.resolve_id_or_default(character)
	lobby_joined = true
	readiness = [false, false, false, false]
	_lobby_state.rpc(_characters, readiness, order_id, order_revision, room_record, course, peer_slots)

@rpc("authority", "call_remote", "reliable")
func _join_rejected(message: String) -> void:
	_connection_ended(message)

func _show_room() -> void:
	copy_row.visible = hosting
	copy_button.text = "주소 복사"
	_panel_title.text = "배송 대기실 · 빌라 201호 / 202호"
	for item in [address, port_input, host_button, join_button]: item.hide()
	room_ui.show_state(_characters, readiness, lobby_joined, local_slot, hosting, order_id, peer_slots)
	room_ui.history_button.text = "방 기록 · %d건" % room_record.orders
	if history_panel.visible: history_text.text = _history_contents()
	if lobby_joined:
		status.text = "주문 확인 → 참가자 전원 준비 → 배송 시작\n호스트가 주문을 바꾸면 참가자 전원 다시 준비합니다"
	if not course.is_empty():
		room_ui.order_choice.select(DeliveryOrders.IDS.size())
		room_ui.order_brief.text = "코스 %d/3 · %s\n%s" % [course.index + 1, DeliveryOrders.get_order(order_id).title, DeliveryOrders.get_order(order_id).brief.get_slice("\n", 0)]
		if lobby_joined: status.text = "3연속 배송 · 일반 → 혼합 → 공동\n주문마다 참가자 전원 준비 · 다른 주문 선택 시 코스 종료"
	if full_route:
		_panel_title.text = "전체 배송 · 물류센터 → 빌라"
		status.text = "직접 적재 → 운전 → 하차·배송 → 평가\n혼자 시작 가능 · 최대 4명 전원 준비 후 출발"
		room_ui.order_brief.text += "\n제한 %s · 상태/시간/차량 손상으로 평가" % DeliveryOrders.format_time(FreightRun.LIMITS.get(order_id, 480.0))

@rpc("authority", "call_local", "reliable")
func _lobby_state(characters: Array, ready_states: Array, selected_order: String = "standard", revision: int = 0, record: Dictionary = {}, course_state: Dictionary = {}, participants: Array = []) -> void:
	_connect_started = 0
	if participants.size() == MAX_PLAYERS: peer_slots = participants.duplicate()
	if peer != null: local_slot = maxi(0, peer_slots.find(multiplayer.get_unique_id()))
	if not record.is_empty(): room_record = record.duplicate(true)
	course = course_state.duplicate(true)
	if not hosting and not in_lobby:
		GameSettings.remember_server(address.text, int(port_input.value))
	in_lobby = true
	lobby_joined = full_route or occupied_slots().size() >= 2
	_characters = characters.duplicate()
	readiness = ready_states.duplicate()
	order_id = DeliveryOrders.get_order(selected_order).id
	order_revision = revision
	_show_room()

func select_order(selected_order: String) -> void:
	if not hosting or not in_lobby: return
	if selected_order == "course":
		course = {"index": 0, "delivered": 0, "elapsed": 0.0, "completed": 0, "closed": false}
		order_id = COURSE_ORDERS[0]
	else:
		if selected_order not in DeliveryOrders.IDS or (selected_order == order_id and course.is_empty()): return
		course = {}
		order_id = selected_order
	order_revision += 1
	readiness = [false, false, false, false]
	_publish_lobby()

func select_lobby_character(character: String) -> void:
	if not in_lobby: return
	GameSettings.set_selected_character_id(character)
	if hosting:
		_characters[0] = CharacterCatalog.resolve_id_or_default(character)
		readiness[0] = false
		_publish_lobby()
	else:
		_lobby_choice.rpc_id(1, character, false, order_revision)

func toggle_ready() -> void:
	if not in_lobby or not lobby_joined: return
	if hosting:
		readiness[0] = not readiness[0]
		_publish_lobby()
	else:
		_lobby_choice.rpc_id(1, _characters[local_slot], not readiness[local_slot], order_revision)

@rpc("any_peer", "call_remote", "reliable")
func _lobby_choice(character: String, ready_state: bool, revision: int) -> void:
	var slot := _sender_slot()
	if not hosting or not in_lobby or slot < 1 or revision != order_revision: return
	var resolved := CharacterCatalog.resolve_id_or_default(character)
	readiness[slot] = ready_state if resolved == _characters[slot] else false
	_characters[slot] = resolved
	_publish_lobby()

func _publish_lobby() -> void:
	if lobby_joined: _lobby_state.rpc(_characters, readiness, order_id, order_revision, room_record, course, peer_slots)
	else: _show_room()

func start_delivery() -> void:
	if not hosting or not in_lobby or not lobby_joined or not _all_ready(): return
	in_lobby = false
	generation += 1
	_start_world.rpc(_characters, generation, order_id)

@rpc("authority", "call_local", "reliable")
func _start_world(characters: Array, epoch: int, selected_order: String = "standard") -> void:
	freight = null
	shipment_result = {}
	_clear_carry_help()
	history_panel.hide()
	_clear_finish_vote()
	order_id = DeliveryOrders.get_order(selected_order).id
	copy_row.hide()
	controls_panel.hide()
	controls_button.hide()
	settings_panel.hide()
	settings_button.hide()
	return_lobby_button.hide()
	in_lobby = false
	room_ui.hide()
	active = false
	finished = false
	menu_open = false
	generation = epoch
	loading = true
	_loading_started = Time.get_ticks_msec()
	ready_peers.clear()
	_local_world_ready = false
	_remote_world_ready = false
	panel.show()
	_panel_title.text = "배송 준비 중"
	status.text = DeliveryOrders.get_order(order_id).title + " · 빌라와 택배를 준비합니다"
	_hud_status.text = ""
	for item in [resume_button, personal_recover_button, recover_button, restart_button]: item.hide()
	cancel_button.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
		level = null
	# Give the loading panel a frame before constructing the level on the main thread.
	await get_tree().process_frame
	await get_tree().process_frame
	if not loading or generation != epoch or peer == null: return
	_targets.clear()
	_body_targets.clear()
	_remote_controls.clear()
	slot_inputs.clear()
	slot_last_input.clear()
	_personal_requests.clear()
	_personal_last.clear()
	_last_delivery = 0
	rtt_ms = -1
	_pending_pings.clear()
	_ping_time = 0
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
	level = preload("res://scenes/level/VillaDeliveryRun.tscn").instantiate()
	level.set_script(preload("res://scenes/network/OnlineLevel.gd"))
	level.order_id = order_id
	level.name = "Level"
	level.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(level)
	get_tree().paused = false
	level.set_process_unhandled_input(false)
	for name in ["PauseMenu", "OnboardingOverlay", "CompletionOverlay"]:
		var overlay: Node = level.get_node("UI/" + name)
		overlay.hide()
		overlay.set_process_unhandled_input(false)
	for i in MAX_PLAYERS:
		var courier: Player = _players()[i]
		courier.input_profile = Player.InputProfile.NETWORK
		courier.set_process_unhandled_input(false)
		courier.set_physics_process(false)
		courier.apply_character(characters[i])
		courier.camera_pivot.get_node("Camera3D").current = i == local_slot
		courier.visible = peer_slots[i] != 0
		if not courier.visible:
			courier.collision_layer = 0
			courier.collision_mask = 0
			courier.grab_collision_barrier.collision_layer = 0
			courier.grab_collision_barrier.collision_mask = 0
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
	if full_route:
		freight = FreightRun.new()
		freight.name = "FreightRun"
		freight.session = self
		level.add_child(freight)
	_local_world_ready = true
	if hosting and full_route and occupied_slots().size() == 1: _remote_world_ready = true
	status.text = "내 준비 완료 · 상대 PC의 준비를 기다립니다\n30초 동안 응답이 없으면 연결 화면으로 돌아갑니다"
	_last_snapshot = Time.get_ticks_msec()
	if not hosting:
		_ready_world.rpc_id(1, generation)
	else:
		_try_start_world()

@rpc("any_peer", "call_remote", "reliable")
func _ready_world(epoch: int) -> void:
	var slot := _sender_slot()
	if not hosting or not loading or slot < 1 or epoch != generation:
		return
	ready_peers[slot] = true
	_remote_world_ready = occupied_slots().all(func(index): return index == 0 or ready_peers.has(index))
	_try_start_world()

func _try_start_world() -> void:
	if not loading or not _local_world_ready or not _remote_world_ready: return
	remote_last_input = Time.get_ticks_msec()
	level.set_physics_process(true)
	for slot in occupied_slots():
		_players()[slot].set_physics_process(true)
		slot_last_input[slot] = Time.get_ticks_msec()
	_go.rpc(generation)
	_finish_loading()

func _finish_loading() -> void:
	loading = false
	active = true
	_last_snapshot = Time.get_ticks_msec()
	panel.hide()
	cancel_button.hide()
	Input.action_release("grab_object")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if _window_unfocused:
		_open_focus_menu()

func _on_window_focus_exited() -> void:
	_window_unfocused = true
	_clear_local_actions()
	if active and not finished and not menu_open:
		_open_focus_menu()

func _on_window_focus_entered() -> void:
	_window_unfocused = false
	# Returning to the window never resumes gameplay automatically.

func _clear_local_actions() -> void:
	for action in ["move_left", "move_right", "move_forward", "move_backward", "grab_object", "jump", "sprint"]:
		Input.action_release(action)

func _open_focus_menu() -> void:
	_open_menu()
	status.text = "창을 벗어나 내 조작을 멈췄습니다 · 잡은 택배는 놓습니다\n상대의 배송과 연결은 유지됩니다\n돌아온 뒤 계속하기 또는 Esc로 재개하세요"

@rpc("authority", "call_remote", "reliable")
func _go(epoch: int) -> void:
	if loading and _local_world_ready and epoch == generation:
		_finish_loading()

func _players() -> Array:
	return level.couriers

func occupied_slots() -> Array[int]:
	var result: Array[int] = []
	for slot in MAX_PLAYERS:
		if peer_slots[slot] != 0: result.append(slot)
	return result

func _sender_slot() -> int:
	var slot: int = peer_slots.find(multiplayer.get_remote_sender_id())
	return slot if slot > 0 else -1

func _all_ready() -> bool:
	return occupied_slots().size() >= (1 if full_route else 2) and occupied_slots().all(func(slot): return readiness[slot])

func _bodies() -> Array:
	var result: Array = []
	for child in level.get_node("Gameplay").get_children():
		if child is GrabbableBody:
			result.append(child)
	return result

func _input(event: InputEvent) -> void:
	if full_route and active and not menu_open and not finished and event is InputEventKey and event.pressed and not event.echo and event.physical_keycode in [KEY_F, KEY_E]:
		request_vehicle_action("seat" if event.physical_keycode == KEY_F else "door")
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.physical_keycode == KEY_G and event.pressed and not event.echo and active and not menu_open and not finished:
		request_carry_help()
		get_viewport().set_input_as_handled()
		return
	if history_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_history()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.physical_keycode == KEY_TAB and (manifest_held or (active and not menu_open and not finished)):
		if not event.echo:
			manifest_held = event.pressed and active and not menu_open and not finished
			_update_manifest()
		get_viewport().set_input_as_handled()
		return
	if finish_pending:
		if event.is_action_pressed("ui_cancel"):
			vote_order_finish(false)
			get_viewport().set_input_as_handled()
		return
	if controls_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_controls()
			get_viewport().set_input_as_handled()
		return
	if settings_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_settings()
			get_viewport().set_input_as_handled()
		return
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
	if loading and Time.get_ticks_msec() - _loading_started > LOAD_TIMEOUT_MS:
		_connection_ended("배송 준비 시간 초과 · 상대 PC 상태를 확인한 뒤 다시 접속하세요")
		return
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
		_advance_carry_help()
		_apply_input(level.player, move, local_yaw, local_pitch, grab, jump, sprint)
		for slot in occupied_slots():
			if slot == 0: continue
			var courier: Player = _players()[slot]
			if slot_inputs.has(slot):
				var input: Array = slot_inputs[slot]
				_apply_input(courier, input[0], input[1], input[2], input[3], input[4], input[5])
			if Time.get_ticks_msec() - int(slot_last_input.get(slot, 0)) > 500:
				_apply_input(courier, Vector2.ZERO, courier.rotation.y, courier.camera_pivot.rotation.x, false, false, false)
		if is_instance_valid(freight): freight.tick()
		if not full_route and not finished and level._delivered_total() == level._total_target():
			_complete.rpc(generation, "\n".join(level._delivery_details), level._play_time_elapsed)
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
		if _targets.size() == MAX_PLAYERS and not finished:
			for i in occupied_slots():
				var audio: LevelAudio = (level._feedback if i == 0 else level._second_feedback) if i < 2 else level.extra_audio[i - 2]
				audio.update_motion(_players()[i].held_grabbable, _targets[i][5], _targets[i][1], delta)
		if Time.get_ticks_msec() - _last_snapshot > 10000:
			_connection_ended("호스트 응답이 없습니다 · 연결을 종료했습니다")
			return
	_hud_status.text = "%s · %s · %s | %s · Tab 배송 목록" % [DeliveryOrders.get_order(order_id).title, DeliveryOrders.format_time(level._play_time_elapsed), "호스트" if hosting else "참가자", _connection_quality()]
	if not course.is_empty(): _hud_status.text = "코스 %d/3 · " % (course.index + 1) + _hud_status.text

func _connection_quality() -> String:
	if finished: return "배송 완료" if level._delivered_total() == level._total_target() else "주문 종료"
	if hosting and occupied_slots().size() == 1: return "혼자 배송 중 · 방에서 동료 초대 가능"
	if hosting:
		var delayed: PackedStringArray = []
		for slot in occupied_slots():
			if slot > 0 and Time.get_ticks_msec() - int(slot_last_input.get(slot, 0)) > 500:
				delayed.append("P%d" % (slot + 1))
		if not delayed.is_empty(): return ", ".join(delayed) + " 입력 지연 · 해당 플레이어 안전 정지 중"
	var age := Time.get_ticks_msec() - (remote_last_input if hosting else _last_snapshot)
	if age > 500:
		return "상대 입력 지연 · 안전 정지 중" if hosting else "상태 수신 지연 · 연결 확인 중"
	if hosting: return "참가자 연결됨"
	if rtt_ms < 0: return "연결됨 · 지연 측정 중"
	return "왕복 %d ms%s" % [rtt_ms, " · 반응 지연 가능" if rtt_ms >= 150 else ""]

@rpc("any_peer", "call_remote", "unreliable", 3)
func _ping(epoch: int, stamp: int) -> void:
	if hosting and active and epoch == generation and _sender_slot() > 0:
		_pong.rpc_id(multiplayer.get_remote_sender_id(), generation, stamp)

@rpc("authority", "call_remote", "unreliable", 3)
func _pong(epoch: int, stamp: int) -> void:
	if epoch == generation and _pending_pings.has(stamp):
		rtt_ms = int(Time.get_ticks_msec() - stamp)
		_pending_pings.erase(stamp)

func _apply_input(courier: Player, move: Vector2, yaw: float, pitch: float, grab: bool, jump: bool, sprint: bool) -> void:
	if is_instance_valid(freight) and freight.control(courier.player_slot, move, jump):
		courier.network_move = Vector2.ZERO
		courier.network_grab = false
		return
	courier.network_move = move.limit_length(1)
	courier.rotation.y = yaw
	courier.camera_pivot.rotation.x = pitch
	courier.network_grab = grab
	courier.network_jump = jump
	courier.network_sprint = sprint

@rpc("any_peer", "call_remote", "unreliable_ordered", 1)
func _controls(epoch: int, move: Vector2, yaw: float, pitch: float, grab: bool, jump: bool, sprint: bool) -> void:
	var slot := _sender_slot()
	if not hosting or not active or finished or epoch != generation or slot < 1:
		return
	if not move.is_finite() or not is_finite(yaw) or not is_finite(pitch):
		return
	remote_last_input = Time.get_ticks_msec()
	_remote_controls = [move, wrapf(yaw, -PI, PI), clampf(pitch, deg_to_rad(-80), deg_to_rad(55)), grab, jump, sprint]
	slot_inputs[slot] = _remote_controls.duplicate()
	slot_last_input[slot] = Time.get_ticks_msec()

func _send_snapshot() -> void:
	if remote_id == 0:
		return
	var players: Array = []
	for courier in _players():
		players.append([courier.transform, courier.velocity, courier.camera_pivot.rotation.x, str(courier.held_grabbable.name) if courier.held_grabbable != null else "", courier.network_sprint, courier.is_on_floor(), courier._last_grab_aim_state])
	var bodies: Array = []
	for body in _bodies():
		bodies.append([body.transform, body.is_delivered(), body.visible])
	_state.rpc(generation, players, bodies, [level.delivery_zone.delivered_count, level.second_zone.delivered_count], level.delivery_hud.get_node("RouteLabel").text, level._play_time_elapsed)
	# Keep each unreliable packet below ENet's MTU for four couriers + bulk cargo.
	if is_instance_valid(freight): _freight_state.rpc(generation, freight.snapshot())

@rpc("authority", "call_remote", "unreliable_ordered", 2)
func _freight_state(epoch: int, shipment: Dictionary) -> void:
	if epoch == generation and not finished and is_instance_valid(freight): freight.apply_snapshot(shipment)

@rpc("authority", "call_remote", "unreliable_ordered", 2)
func _state(epoch: int, players: Array, bodies: Array, counts: Array, route: String, elapsed: float = 0.0) -> void:
	if epoch != generation or not is_instance_valid(level):
		return
	_last_snapshot = Time.get_ticks_msec()
	_targets = players
	_body_targets = bodies
	if not finished: level._play_time_elapsed = maxf(level._play_time_elapsed, elapsed)
	# Completion is reliable; an older snapshot on another channel cannot undo it.
	counts[0] = maxi(counts[0], level.delivery_zone.delivered_count)
	counts[1] = maxi(counts[1], level.second_zone.delivered_count)
	level.delivery_zone.delivered_count = counts[0]
	level.second_zone.delivered_count = counts[1]
	level._update_stops()
	level.delivery_hud.update_progress(counts[0] + counts[1], level._total_target())
	level.delivery_hud.get_node("RouteLabel").text = route
	if counts[0] + counts[1] > _last_delivery:
		level._feedback.play_cue("delivery")
	_last_delivery = counts[0] + counts[1]
	level.delivery_hud.set_crosshair_state(players[local_slot][6])

func _process(delta: float) -> void:
	_update_manifest()
	for marker in partner_markers: marker.hide()
	if active and not finished and not menu_open and not manifest_held and is_instance_valid(level):
		var own: Player = _players()[local_slot]
		var index := 0
		for slot in occupied_slots():
			if slot == local_slot: continue
			var partner: Player = _players()[slot]
			partner_markers[index].update_partner(own.camera_pivot.get_node("Camera3D"), own.global_position, partner.global_position, "동료" if occupied_slots().size() == 2 else "P%d 동료" % (slot + 1))
			index += 1
	else:
		partner_marker.hide()
	_update_carry_help()
	if hosting or not active or _targets.size() != MAX_PLAYERS:
		return
	var weight := 1.0 - exp(-25.0 * delta)
	for i in occupied_slots():
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

func request_vehicle_action(kind: String) -> void:
	if not full_route or not active or finished or menu_open: return
	if hosting: _vehicle_notice.rpc(generation, 0, freight.action(0, kind))
	else: _vehicle_action.rpc_id(1, generation, kind)

@rpc("any_peer", "call_remote", "reliable")
func _vehicle_action(epoch: int, kind: String) -> void:
	var slot := _sender_slot()
	if not hosting or epoch != generation or not active or finished or not is_instance_valid(freight) or slot < 1: return
	_vehicle_notice.rpc(generation, slot, freight.action(slot, kind))

@rpc("authority", "call_local", "reliable")
func _vehicle_notice(epoch: int, slot: int, message: String) -> void:
	if "freight-test" in OS.get_cmdline_user_args(): print("VEHICLE_NOTICE P", slot + 1, " ", message)
	if epoch == generation and active and slot == local_slot and not message.is_empty(): level.delivery_hud.show_delivery_toast(message)

func finish_freight(reason: String) -> void:
	if not hosting or not active or finished or not is_instance_valid(freight): return
	_freight_result.rpc(generation, freight.evaluate(reason), [level.delivery_zone.delivered_count, level.second_zone.delivered_count], freight.snapshot())

@rpc("authority", "call_local", "reliable")
func _freight_result(epoch: int, evaluation: Dictionary, counts: Array, state: Dictionary) -> void:
	if epoch != generation or not active or finished or not is_instance_valid(freight): return
	shipment_result = evaluation.duplicate(true)
	if not hosting: freight.apply_snapshot(state)
	_display_result(epoch, evaluation.reason, evaluation.elapsed, counts)

@rpc("authority", "call_local", "reliable")
func _complete(epoch: int, details: String, elapsed: float = 0.0) -> void:
	if epoch != generation or not is_instance_valid(level):
		return
	_display_result(epoch, details, elapsed, [level.delivery_zone.target_package_count, level.second_zone.target_package_count])

@rpc("authority", "call_local", "reliable")
func _partial_result(epoch: int, details: String, elapsed: float, counts: Array) -> void:
	_display_result(epoch, details, elapsed, counts)

func _display_result(epoch: int, details: String, elapsed: float, counts: Array) -> void:
	if epoch != generation or not is_instance_valid(level) or finished: return
	_clear_carry_help()
	_clear_finish_vote()
	finished = true
	if is_instance_valid(freight): freight.stop()
	_record_order(elapsed, counts)
	for zone in [level.delivery_zone, level.second_zone]:
		zone.accepting_deliveries = false
		zone.set_deferred("monitoring", false)
	for body in _bodies():
		for courier in _players():
			body.remove_grabber(courier)
		body.freeze = true
	level._play_time_elapsed = elapsed
	level.delivery_zone.delivered_count = counts[0]
	level.second_zone.delivered_count = counts[1]
	level.delivery_hud.update_progress(level._delivered_total(), level._total_target())
	level._update_stops()
	level.set_physics_process(false)
	for courier in _players():
		courier.set_physics_process(false)
	_open_menu()
	_panel_title.text = ("주문 완료! · " if level._delivered_total() == level._total_target() else "주문 마무리 · ") + DeliveryOrders.get_order(order_id).title
	if details.is_empty(): details = "배달한 택배 없음 · 다음 주문에서 다시 도전하세요"
	status.text = "택배 %d/%d개 · 배송 시간 %s\n%s\n%s" % [level._delivered_total(), level._total_target(), DeliveryOrders.format_time(elapsed), details, "다음 주문은 대기실에서 선택 · 같은 주문은 바로 다시 시작" if hosting else "호스트가 다음 주문 준비 또는 같은 주문 재시작을 선택합니다"]
	resume_button.hide()
	personal_recover_button.hide()
	recover_button.hide()
	status.text += "\n이 방 누적 · 주문 %d건 / 배송 %d개" % [room_record.orders, room_record.delivered]
	if not course.is_empty():
		var course_title := "코스 완료!" if course.completed == 3 else ("코스 마무리" if course.closed else "코스 진행")
		status.text = status.text.replace("다음 주문은 대기실에서 선택 · 같은 주문은 바로 다시 시작", "대기실에서 코스 진행 또는 새 주문 선택").replace("호스트가 다음 주문 준비 또는 같은 주문 재시작을 선택합니다", "호스트가 대기실로 이동하면 함께 다음 배송을 준비합니다")
		status.text += "\n%s · %d/3 주문 완료 · %d/7개 · %s" % [course_title, course.completed, course.delivered, DeliveryOrders.format_time(course.elapsed)]
		restart_button.hide()
		return_lobby_button.text = "코스 종료 · 대기실로" if course.closed else "다음 코스 주문 준비 · 대기실로"
	else: return_lobby_button.text = "다음 주문 준비 · 함께 대기실로"
	if full_route and not shipment_result.is_empty():
		_panel_title.text = ("배송 성공" if shipment_result.success else "배송 실패·부분 결과") + " · " + shipment_result.grade + "등급"
		status.text = "%s · %d/%d개 · %s\n점수 %d / 1000 · 배송 택배 상태 %.0f%%\n차량 상태 %.0f%% · 전체 복구 %d회\n%s\n이 방 누적 · %d건 / %d점" % [shipment_result.reason, shipment_result.delivered, shipment_result.total, DeliveryOrders.format_time(shipment_result.elapsed), shipment_result.score, shipment_result.quality, shipment_result.vehicle, shipment_result.recoveries, "함께 운반 보너스 +20" if shipment_result.teamwork else "상태·시간·차량 손상과 복구 횟수로 평가", room_record.orders, room_record.get("score", 0)]
		if not course.is_empty(): status.text += "\n코스 %d/3 주문 완료 · %s" % [course.completed, "종료" if course.closed else "대기실에서 다음 배송 준비"]

func _open_menu() -> void:
	if is_instance_valid(level):
		level.delivery_hud.hide()
	controls_panel.hide()
	controls_button.show()
	settings_panel.hide()
	settings_button.show()
	menu_open = true
	panel.show()
	_panel_title.text = "온라인 메뉴"
	status.text = "메뉴를 열어도 상대의 게임은 계속됩니다\nWASD · 마우스 잡기 · Space 점프 · Shift 달리기\n개인 복구는 내 위치만 · 전체 복구/재시작은 호스트만"
	for item in [address, port_input, host_button, join_button]:
		item.hide()
	resume_button.visible = not finished
	personal_recover_button.visible = not finished
	recover_button.visible = hosting and not finished
	restart_button.visible = hosting and not (finished and not course.is_empty())
	return_lobby_button.visible = hosting and finished
	finish_request_button.visible = not finished and not loading
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _resume() -> void:
	if _window_unfocused or not active or finished or finish_pending:
		return
	controls_panel.hide()
	settings_panel.hide()
	menu_open = false
	panel.hide()
	level.delivery_hud.show()
	_clear_local_actions()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _open_settings() -> void:
	if not active or not menu_open or loading: return
	controls_panel.hide()
	panel.hide()
	settings_panel.show()
	settings_panel.grab_initial_focus()

func _close_settings() -> void:
	settings_panel.hide()
	panel.show()
	settings_button.grab_focus()

func _open_controls() -> void:
	if not active or not menu_open or loading: return
	settings_panel.hide()
	panel.hide()
	controls_panel.configure_online(hosting, level._total_target(), level.delivery_zone.destination_name + " / " + level.second_zone.destination_name)
	if full_route: controls_panel.configure_freight()
	controls_panel.show()
	controls_panel.grab_initial_focus()

func _close_controls() -> void:
	controls_panel.hide()
	panel.show()
	controls_button.grab_focus()

func recover_world() -> void:
	if not hosting or not active or finished:
		return
	if is_instance_valid(freight): freight.recover()
	else: level.recover_all()
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
	var slot := _sender_slot()
	if hosting and active and not finished and epoch == generation and slot > 0:
		_personal_requests[slot] = true

func _restore_personal(slot: int) -> void:
	if finished: return
	var now := Time.get_ticks_msec()
	if now - int(_personal_last.get(slot, -1000)) < 1000:
		_personal_result.rpc(generation, slot, false)
		return
	_personal_last[slot] = now
	if is_instance_valid(freight): freight.exit_seat(slot, true)
	level.recover_slot(slot)
	slot_inputs.erase(slot)
	_apply_input(_players()[slot], Vector2.ZERO, PI, 0, false, false, false)
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
	if not hosting or not active or (finished and not course.is_empty()):
		return
	generation += 1
	_start_world.rpc(_characters, generation, order_id)

func return_to_lobby() -> void:
	if not hosting or not active or not finished: return
	_return_lobby.rpc(generation + 1)

@rpc("authority", "call_local", "reliable")
func _return_lobby(epoch: int) -> void:
	if finished and not course.is_empty():
		if course.closed:
			course = {}
			order_id = "standard"
		else:
			course.index += 1
			order_id = COURSE_ORDERS[course.index]
		order_revision += 1
	_clear_carry_help()
	_clear_finish_vote()
	loading = false
	_local_world_ready = false
	_remote_world_ready = false
	partner_marker.hide()
	controls_panel.hide()
	controls_button.hide()
	settings_panel.hide()
	settings_button.hide()
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
	_lobby_state(_characters, [false, false, false, false], order_id, order_revision, room_record, course, peer_slots)

func _peer_left(id: int) -> void:
	var slot: int = peer_slots.find(id)
	if hosting and slot > 0:
		var interrupted := not in_lobby
		if interrupted:
			# Local cleanup only: the departing peer cannot receive a lobby RPC.
			_return_lobby.rpc(generation + 1)
		else:
			generation += 1
		peer_slots[slot] = 0
		remote_id = peer_slots[occupied_slots()[1]] if occupied_slots().size() > 1 else 0
		lobby_joined = full_route or occupied_slots().size() > 1
		readiness = [false, false, false, false]
		_characters[slot] = CharacterCatalog.get_default_id()
		status.text = _waiting_address_text("연결 종료 · 배송 초기화 · 재참가 대기" if interrupted else "참가자 퇴장 · 새 참가자 대기")
		_publish_lobby()

func _connection_ended(message: String) -> void:
	_clear_finish_vote()
	copy_row.hide()
	controls_panel.hide()
	controls_button.hide()
	settings_panel.hide()
	settings_button.hide()
	return_lobby_button.hide()
	in_lobby = false
	lobby_joined = false
	readiness = [false, false, false, false]
	room_ui.hide()
	active = false
	finished = false
	_close_peer()
	if is_instance_valid(level):
		remove_child(level)
		level.queue_free()
		level = null
	panel.show()
	_panel_title.text = "전체 배송 · 1~4인" if full_route else "온라인 협동 · 2~4인"
	status.text = message
	_hud_status.text = ""
	for item in [address, port_input, host_button, join_button]:
		item.show()
	for item in [resume_button, personal_recover_button, recover_button, restart_button]:
		item.hide()
	_set_connecting(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _close_peer() -> void:
	peer_slots = [1, 0, 0, 0]
	slot_inputs.clear()
	slot_last_input.clear()
	ready_peers.clear()
	course = {}
	_clear_carry_help()
	room_record = {"orders": 0, "complete": 0, "delivered": 0, "target": 0, "elapsed": 0.0, "recent": []}
	if is_instance_valid(history_panel): history_panel.hide()
	_clear_finish_vote()
	finish_serial = 0
	loading = false
	_local_world_ready = false
	_remote_world_ready = false
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
