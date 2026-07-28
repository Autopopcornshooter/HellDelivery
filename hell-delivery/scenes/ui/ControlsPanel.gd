class_name ControlsPanel
extends Control

# T080: MainMenu와 PauseMenu 양쪽에서 그대로 재사용하는 공용 조작법 화면. 정적인 안내문만
# 표시하므로 SettingsPanel과 달리 GameSettings를 구독하지 않는다(표시할 값 자체가 없음).

signal closed

@onready var back_button: Button = $Panel/VBoxContainer/BackButton
@onready var _key_goal_label: Label = $Panel/VBoxContainer/Grid/KeyGoal


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # PauseMenu 아래에서 paused 상태에도 조작 가능해야 함.
	# T081: 목표 개수를 DeliveryZone.TARGET_PACKAGE_COUNT 하나에서만 읽어와 실제 배송 목표와
	# 항상 일치시킨다(문구를 따로 하드코딩하지 않음).
	_key_goal_label.text = "Package %d개를 Delivery Zone으로 운반" % DeliveryZone.TARGET_PACKAGE_COUNT
	back_button.pressed.connect(_on_back_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func grab_initial_focus() -> void:
	back_button.grab_focus()


func _on_back_pressed() -> void:
	AudioManager.play_ui(AudioManager.Sfx.UI_BACK)
	closed.emit()
