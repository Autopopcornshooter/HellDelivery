class_name OnboardingOverlay
extends CanvasLayer

# T080: PrototypeLevel 최초 진입 시 한 번만 보여주는 조작법 안내. GameSettings.onboarding_seen을
# 유일한 판단 기준으로 삼아 스스로 표시 여부를 결정한다(PrototypeLevel.gd는 표시 여부를 몰라도 됨).

signal closed

@onready var _title_label: Label = $Control/CenterContainer/VBoxContainer/TitleLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # paused 상태에서도 이 Overlay 자신은 입력을 받아야 함.
	# T081: 목표 개수를 DeliveryZone.TARGET_PACKAGE_COUNT 하나에서만 읽어와 실제 배송 목표와
	# 항상 일치시킨다(문구를 따로 하드코딩하지 않음).
	_title_label.text = "Package %d개를 잡아 Delivery Zone까지 운반하세요" % DeliveryZone.TARGET_PACKAGE_COUNT
	if GameSettings.onboarding_seen:
		visible = false
		return
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not _is_dismiss_event(event):
		return
	get_viewport().set_input_as_handled()
	_dismiss()


func _is_dismiss_event(event: InputEvent) -> bool:
	# "아무 키나 눌러 시작" — 키보드/마우스/게임패드 버튼 아무 press나 닫기로 인정한다
	# (마우스 이동 같은 비-press 이벤트는 제외).
	if event is InputEventKey:
		return event.pressed and not event.is_echo()
	if event is InputEventMouseButton:
		return event.pressed
	if event is InputEventJoypadButton:
		return event.pressed
	return false


func _dismiss() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# 닫는 입력이 마우스 왼쪽 버튼(grab_object와 같은 바인딩)이었을 경우, 그 press가 곧바로
	# Player의 just_pressed로 새어 들어가 물체를 즉시 잡아버리지 않도록 명시적으로 정리한다.
	Input.action_release("grab_object")
	GameSettings.set_onboarding_seen(true)
	closed.emit()
