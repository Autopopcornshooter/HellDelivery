class_name PauseMenu
extends CanvasLayer

# T079: PrototypeLevel 안에 항상 존재하되 평소에는 숨겨진 일시정지 메뉴(동적 인스턴스 생성이
# 아니라 Scene에 미리 배치된 하나의 노드라 중복 생성 자체가 불가능하다). ui_cancel(Esc) 하나로
# Settings -> Pause -> 게임플레이 세 단계를 순서대로 닫는 우선순위를 이 스크립트가 전담한다.

const MAIN_MENU_SCENE_PATH := "res://scenes/ui/MainMenu.tscn"
var _paused_hud: DeliveryHUD
var _hud_was_visible: bool = true

@onready var resume_button: Button = $Control/CenterContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $Control/CenterContainer/VBoxContainer/RestartButton
@onready var controls_button: Button = $Control/CenterContainer/VBoxContainer/ControlsButton
@onready var settings_button: Button = $Control/CenterContainer/VBoxContainer/SettingsButton
@onready var main_menu_button: Button = $Control/CenterContainer/VBoxContainer/MainMenuButton
@onready var quit_button: Button = $Control/CenterContainer/VBoxContainer/QuitButton
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var controls_panel: ControlsPanel = $ControlsPanel
@onready var _onboarding_overlay: Node = get_node_or_null("../OnboardingOverlay") # T080: 형제 노드,
# 없을 수도 있는 다른 상위 구조에 대비해 get_node_or_null로 방어적으로 참조한다.
@onready var _completion_overlay: Node = get_node_or_null("../CompletionOverlay") # T081: 완료 화면이
# 떠 있는 동안에는 Esc로 게임 재개/일시정지 열기 모두 하지 않는다(완료 화면은 버튼으로만 나갈 수 있음).


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS # paused 상태에서도 이 메뉴 자신은 계속 동작해야 함.
	visible = false
	settings_panel.visible = false
	controls_panel.visible = false
	resume_button.pressed.connect(_resume)
	$Control/CenterContainer/VBoxContainer/RecoverButton.pressed.connect(_on_recover_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	controls_button.pressed.connect(_open_controls)
	settings_button.pressed.connect(_open_settings)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_panel.closed.connect(_close_settings)
	controls_panel.closed.connect(_close_controls)


func _unhandled_input(event: InputEvent) -> void:
	if _onboarding_overlay != null and is_instance_valid(_onboarding_overlay) and _onboarding_overlay.visible:
		return # T080: 첫 실행 안내가 떠 있는 동안에는 이 입력을 Overlay 스스로 처리하게 둔다
		# (여기서 손대지 않고, set_input_as_handled()도 호출하지 않는다).
	if _completion_overlay != null and is_instance_valid(_completion_overlay) and _completion_overlay.visible:
		return # T081: 완료 화면은 Esc로 닫히지 않는다 — 여기서도 아무것도 하지 않고 반환한다.
	if not event.is_action_pressed("ui_cancel"):
		return
	# 우선순위: ControlsPanel -> SettingsPanel -> Pause 재개 -> Pause 열기.
	if controls_panel.visible:
		_close_controls()
	elif settings_panel.visible:
		_close_settings()
	elif visible:
		_resume()
	else:
		_open_pause()
	get_viewport().set_input_as_handled()


func _open_pause() -> void:
	var level := get_parent().get_parent()
	var summary: Label = $Control/CenterContainer/VBoxContainer/DeliverySummary
	var hud := level.get_node_or_null("UI/DeliveryHUD") as DeliveryHUD
	summary.text = hud.progress_label.text if hud != null else ""
	if hud != null:
		summary.text += "\n" + hud.get_node("RouteLabel").text
		_paused_hud = hud
		_hud_was_visible = hud.visible
		hud.visible = false
	$Control/CenterContainer/VBoxContainer/RecoverButton.visible = level.has_method("recover_all")
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	resume_button.grab_focus()


func _on_recover_pressed() -> void:
	var level := get_parent().get_parent()
	if not level.has_method("recover_all"):
		return
	# Recover while paused, then resume without forwarding the menu click to grab.
	Input.action_release("grab_object")
	level.recover_all()
	_resume()
	level.get_node("UI/DeliveryHUD").show_delivery_toast("출발 위치로 복구했습니다 · 완료한 배송은 유지됩니다")


func _resume() -> void:
	if is_instance_valid(_paused_hud):
		_paused_hud.visible = _hud_was_visible
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _open_settings() -> void:
	controls_panel.visible = false
	settings_panel.visible = true
	settings_panel.grab_initial_focus()


func _close_settings() -> void:
	settings_panel.visible = false
	resume_button.grab_focus()


func _open_controls() -> void:
	settings_panel.visible = false
	controls_panel.visible = true
	controls_panel.grab_initial_focus()


func _close_controls() -> void:
	controls_panel.visible = false
	resume_button.grab_focus()


func _on_restart_pressed() -> void:
	# Scene 전환 전에는 항상 pause를 먼저 해제한다 — paused 상태가 SceneTree 전역 플래그라
	# 새 Scene에도 그대로 남아 있으면 재시작된 게임이 처음부터 멈춰 있는 상태가 된다.
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
