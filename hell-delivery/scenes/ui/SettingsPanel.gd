class_name SettingsPanel
extends Control

# T079: MainMenu와 PauseMenu 양쪽에서 그대로 재사용하는 공용 설정 화면. GameSettings(Autoload)를
# 유일한 값 출처로 삼아 표시만 하고, 조작 시 즉시 GameSettings에 반영한다(적용 버튼 없음).

signal closed

@onready var window_mode_option: OptionButton = $Panel/VBoxContainer/WindowModeOption
@onready var resolution_option: OptionButton = $Panel/VBoxContainer/ResolutionOption
@onready var mouse_sensitivity_slider: HSlider = $Panel/VBoxContainer/MouseSensitivitySlider
@onready var gamepad_sensitivity_slider: HSlider = $Panel/VBoxContainer/GamepadSensitivitySlider
@onready var invert_y_check: CheckButton = $Panel/VBoxContainer/InvertYCheck
@onready var master_volume_slider: HSlider = $Panel/VBoxContainer/MasterVolumeSlider
@onready var reset_button: Button = $Panel/VBoxContainer/ResetButton
@onready var back_button: Button = $Panel/VBoxContainer/BackButton

var _updating_ui := false # GameSettings -> UI 반영 중에는 UI -> GameSettings 되먹임을 막는다.


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # PauseMenu 아래에서 paused 상태에도 조작 가능해야 함.
	window_mode_option.item_selected.connect(_on_window_mode_selected)
	resolution_option.item_selected.connect(_on_resolution_selected)
	mouse_sensitivity_slider.value_changed.connect(_on_mouse_sensitivity_changed)
	gamepad_sensitivity_slider.value_changed.connect(_on_gamepad_sensitivity_changed)
	invert_y_check.toggled.connect(_on_invert_y_toggled)
	master_volume_slider.value_changed.connect(_on_master_volume_changed)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_on_back_pressed)
	GameSettings.settings_changed.connect(_refresh_from_settings)
	_refresh_from_settings()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func grab_initial_focus() -> void:
	window_mode_option.grab_focus()


func _refresh_from_settings() -> void:
	_updating_ui = true
	window_mode_option.selected = GameSettings.window_mode
	var res_index: int = GameSettings.RESOLUTIONS.find(GameSettings.window_resolution)
	resolution_option.selected = maxi(res_index, 0)
	resolution_option.disabled = GameSettings.window_mode == GameSettings.WindowMode.FULLSCREEN
	mouse_sensitivity_slider.value = GameSettings.mouse_sensitivity
	gamepad_sensitivity_slider.value = GameSettings.gamepad_look_sensitivity
	invert_y_check.button_pressed = GameSettings.invert_gamepad_y
	master_volume_slider.value = GameSettings.master_volume * 100.0
	_updating_ui = false


func _on_window_mode_selected(index: int) -> void:
	if _updating_ui:
		return
	GameSettings.set_window_mode(index)


func _on_resolution_selected(index: int) -> void:
	if _updating_ui:
		return
	GameSettings.set_window_resolution(GameSettings.RESOLUTIONS[index])


func _on_mouse_sensitivity_changed(value: float) -> void:
	if _updating_ui:
		return
	GameSettings.set_mouse_sensitivity(value)


func _on_gamepad_sensitivity_changed(value: float) -> void:
	if _updating_ui:
		return
	GameSettings.set_gamepad_look_sensitivity(value)


func _on_invert_y_toggled(pressed: bool) -> void:
	if _updating_ui:
		return
	GameSettings.set_invert_gamepad_y(pressed)


func _on_master_volume_changed(value: float) -> void:
	if _updating_ui:
		return
	GameSettings.set_master_volume(value / 100.0)


func _on_reset_pressed() -> void:
	GameSettings.reset_to_defaults()


func _on_back_pressed() -> void:
	AudioManager.play_ui(AudioManager.Sfx.UI_BACK)
	closed.emit()
