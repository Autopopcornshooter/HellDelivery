extends "res://scenes/level/LocalCoopTest.gd"

var _pad_missing := false
var _device_notice: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Level.process_mode = Node.PROCESS_MODE_PAUSABLE
	var devices := Input.get_connected_joypads()
	if not devices.is_empty():
		player2.gamepad_device = devices[0]
	super._ready()
	_p2_character_panel.gamepad_device = player2.gamepad_device
	Input.joy_connection_changed.connect(_on_pad_connection_changed)
	_device_notice = Label.new()
	_device_notice.name = "DeviceNotice"
	_device_notice.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_device_notice.add_theme_font_size_override("font_size", 18)
	_device_notice.text = ""
	$Level/UI/PauseMenu/Control/CenterContainer/VBoxContainer.add_child(_device_notice)
	$SplitScreen.layer = 0
	$SplitScreen/Layout/LeftContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$SplitScreen/Layout/RightContainer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Level/UI/OnboardingOverlay.visible = false
	$Level/UI/PauseMenu.set_process_unhandled_input(false)
	$Level.set_process_unhandled_input(false)
	$Level/UI/DeliveryHUD.visible = false
	_character_select_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for panel in [_p1_character_panel, _p2_character_panel]:
		panel._preview_viewport.own_world_3d = true
		panel.closed.connect(_back_to_menu)
		panel._confirm_button.focus_mode = Control.FOCUS_NONE
		panel._left_button.focus_mode = Control.FOCUS_NONE
		panel._right_button.focus_mode = Control.FOCUS_NONE
		panel._back_button.focus_mode = Control.FOCUS_NONE
	_p1_character_panel.get_node("P1Label").text = "P1 키보드·마우스"
	_p2_character_panel.get_node("P2Label").text = "P2 게임패드 · 마우스로도 선택 가능"
	# Mouse selection avoids GUI focus crossing between simultaneous panels.
	_p1_character_panel.confirmed.connect(func(_id): _p1_character_panel._confirm_button.text = "준비 완료")
	_p2_character_panel.confirmed.connect(func(_id): _p2_character_panel._confirm_button.text = "준비 완료")

func _on_character_confirmed(character_id: String) -> void:
	super._on_character_confirmed(character_id)
	if not _character_select_overlay.visible:
		$Level/UI/PauseMenu.set_process_unhandled_input(true)
		$Level.set_process_unhandled_input(true)
		$Level/UI/DeliveryHUD.visible = true
		$Level/UI/DeliveryHUD.show_goal()
		Input.action_release("grab_object")
		get_tree().paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(_event: InputEvent) -> void:
	# The level owns restart/recovery so an input cannot reload twice.
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton and event.device == player2.gamepad_device and event.button_index == JOY_BUTTON_START and event.pressed:
		if _character_select_overlay.visible:
			return
		var cancel := InputEventAction.new()
		cancel.action = "ui_cancel"
		cancel.pressed = true
		$Level/UI/PauseMenu._unhandled_input(cancel)
		get_viewport().set_input_as_handled()

func _on_pad_connection_changed(device: int, connected: bool) -> void:
	if connected:
		if not _pad_missing and Input.get_connected_joypads().has(player2.gamepad_device):
			return
		player2.gamepad_device = device
		_p2_character_panel.gamepad_device = device
		_pad_missing = false
		_device_notice.text = "P2 패드 연결됨 · 계속하기를 눌러 재개"
		_p2_character_panel.get_node("P2Label").text = "P2 게임패드 · 연결됨"
		return
	if device != player2.gamepad_device:
		return
	_pad_missing = true
	_device_notice.text = "P2 패드 연결 끊김 · 다시 연결해 주세요"
	_p2_character_panel.get_node("P2Label").text = "P2 패드 연결 끊김"
	# Freeze the shared world before a missing controller can drop a carried parcel.
	var pause_menu: PauseMenu = $Level/UI/PauseMenu
	if not _character_select_overlay.visible and not $Level/UI/CompletionOverlay.visible and not pause_menu.visible:
		pause_menu._open_pause()

func _back_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")
