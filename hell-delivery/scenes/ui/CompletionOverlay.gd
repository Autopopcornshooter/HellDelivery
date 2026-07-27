class_name CompletionOverlay
extends CanvasLayer

# T081: Package TARGET_PACKAGE_COUNT개를 전부 배송했을 때 표시하는 최종 완료 화면. PauseMenu와
# 같은 구조(CanvasLayer, process_mode=ALWAYS, paused=true)를 따르되, Esc로는 절대 닫히지 않는다
# (사용자 지시 — "다시 플레이"/"메인 메뉴" 버튼으로만 나갈 수 있다). PrototypeLevel이 존재하는
# 동안 항상 존재하되 평소 숨겨진 단일 인스턴스라 중복 생성 자체가 불가능하다.

const MAIN_MENU_SCENE_PATH := "res://scenes/ui/MainMenu.tscn"

@onready var subtitle_label: Label = $Control/CenterContainer/VBoxContainer/SubtitleLabel
@onready var time_label: Label = $Control/CenterContainer/VBoxContainer/TimeLabel
@onready var replay_button: Button = $Control/CenterContainer/VBoxContainer/ReplayButton
@onready var main_menu_button: Button = $Control/CenterContainer/VBoxContainer/MainMenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	replay_button.pressed.connect(_on_replay_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)


func show_completion(target_count: int, elapsed_seconds: float) -> void:
	subtitle_label.text = "Package %d개를 모두 배송했습니다" % target_count
	time_label.text = "완료 시간 %s" % _format_time(elapsed_seconds)
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	replay_button.grab_focus()


func _format_time(seconds: float) -> String:
	var total_seconds: int = int(seconds)
	return "%02d:%02d" % [total_seconds / 60, total_seconds % 60]


func _on_replay_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
