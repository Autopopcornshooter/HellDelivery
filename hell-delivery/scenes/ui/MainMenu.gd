class_name MainMenu
extends Control

# T078: 실행 시 곧바로 테스트 레벨로 들어가는 대신 먼저 보여줄 메인 메뉴. 데모 시작·게임 종료를
# 담당하고(T078), T079에서 설정 화면 진입을 추가했다. 일시정지·온보딩은 T080 이후 범위.

const DEMO_SCENE_PATH := "res://scenes/level/PrototypeLevel.tscn"

@onready var button_container: VBoxContainer = $CenterContainer/VBoxContainer
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var controls_button: Button = $CenterContainer/VBoxContainer/ControlsButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var controls_panel: ControlsPanel = $ControlsPanel


func _ready() -> void:
	# 메뉴에서는 항상 마우스 커서가 보이고 자유롭게 움직여야 한다 — 캡처 해제는 여기서만 하고,
	# 데모 진입 후 재캡처는 기존 Player.gd._ready()가 그대로 담당한다(중복 처리 없음).
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	settings_panel.visible = false
	controls_panel.visible = false
	start_button.pressed.connect(_on_start_pressed)
	controls_button.pressed.connect(_open_controls)
	settings_button.pressed.connect(_open_settings)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_panel.closed.connect(_close_settings)
	controls_panel.closed.connect(_close_controls)
	start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if controls_panel.visible:
		_close_controls()
		get_viewport().set_input_as_handled()
	elif settings_panel.visible:
		_close_settings()
		get_viewport().set_input_as_handled()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(DEMO_SCENE_PATH)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _open_settings() -> void:
	button_container.visible = false
	controls_panel.visible = false
	settings_panel.visible = true
	settings_panel.grab_initial_focus()


func _close_settings() -> void:
	settings_panel.visible = false
	button_container.visible = true
	settings_button.grab_focus()


func _open_controls() -> void:
	button_container.visible = false
	settings_panel.visible = false
	controls_panel.visible = true
	controls_panel.grab_initial_focus()


func _close_controls() -> void:
	controls_panel.visible = false
	button_container.visible = true
	controls_button.grab_focus()
