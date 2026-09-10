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
	_key_goal_label.text = "HUD에 표시된 택배를 초록색 배송 구역으로 운반"
	back_button.pressed.connect(_on_back_pressed)
	var grid: GridContainer = $Panel/VBoxContainer/Grid
	for row in [["Jump", "점프", "Space"], ["Sprint", "달리기", "Shift 유지"]]:
		var action := Label.new()
		action.name = "Action" + row[0]
		action.text = row[1]
		grid.add_child(action)
		var key := Label.new()
		key.name = "Key" + row[0]
		key.text = row[2]
		grid.add_child(key)
		grid.move_child(action, grid.get_node("ActionPause").get_index())
		grid.move_child(key, action.get_index() + 1)


func configure_coop() -> void:
	$Panel/VBoxContainer/TitleLabel.text = "협동 조작법 · P1 키보드 / P2 패드"
	var grid: GridContainer = $Panel/VBoxContainer/Grid
	grid.get_node("KeyMove").text = "P1 WASD  |  P2 왼쪽 스틱"
	grid.get_node("KeyLook").text = "P1 마우스  |  P2 오른쪽 스틱"
	grid.get_node("KeyGrab").text = "P1 왼쪽 클릭 유지  |  P2 RT 또는 A 유지\n놓기: 버튼 해제 · 같은 상자를 함께 잡을 수 있음"
	grid.get_node("KeyJump").text = "P1 Space  |  P2 X"
	grid.get_node("KeySprint").text = "P1 Shift 유지  |  P2 L3 유지"
	grid.get_node("KeyPause").text = "Esc 또는 P2 Start · 메뉴 선택은 P1"
	grid.get_node("KeyRestart").text = "R 전체 재시작 · F5 두 사람/미배송 택배 복구\nF5와 메뉴 복구는 완료한 배송을 유지"


func configure_goal(zone: DeliveryZone) -> void:
	configure_delivery_goal(zone.target_package_count, zone.destination_name)

func configure_delivery_goal(count: int, destination: String) -> void:
	_key_goal_label.text = "택배 %d개 → %s" % [count, destination]


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


func grab_initial_focus() -> void:
	back_button.grab_focus()


func _on_back_pressed() -> void:
	closed.emit()
