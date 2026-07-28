class_name CompletionOverlay
extends CanvasLayer

# T081: Package TARGET_PACKAGE_COUNT개를 전부 배송했을 때 표시하는 최종 완료 화면. PauseMenu와
# 같은 구조(CanvasLayer, process_mode=ALWAYS, paused=true)를 따르되, Esc로는 절대 닫히지 않는다
# (사용자 지시 — "다시 플레이"/"메인 메뉴" 버튼으로만 나갈 수 있다). PrototypeLevel이 존재하는
# 동안 항상 존재하되 평소 숨겨진 단일 인스턴스라 중복 생성 자체가 불가능하다.

const MAIN_MENU_SCENE_PATH := "res://scenes/ui/MainMenu.tscn"
const _ENTRANCE_DURATION: float = 0.35 # T082: 0.2~0.5초 권장 범위 내

@onready var subtitle_label: Label = $Control/CenterContainer/VBoxContainer/SubtitleLabel
@onready var time_label: Label = $Control/CenterContainer/VBoxContainer/TimeLabel
@onready var replay_button: Button = $Control/CenterContainer/VBoxContainer/ReplayButton
@onready var main_menu_button: Button = $Control/CenterContainer/VBoxContainer/MainMenuButton
@onready var _root_control: Control = $Control
@onready var _content: Control = $Control/CenterContainer/VBoxContainer


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
	_play_entrance()


func _play_entrance() -> void:
	# T082: Fade + 살짝 확대되며 들어오는 연출(0.35초) — CanvasLayer가 PROCESS_MODE_ALWAYS라
	# 위에서 이미 paused=true가 된 뒤에도 Tween이 계속 진행된다. Focus는 위에서 이미 준 뒤이므로
	# 이 연출이 버튼 입력 자체를 막지 않는다(Modulate/Scale만 바뀌고 mouse_filter는 무변경).
	_content.pivot_offset = _content.size / 2.0
	_root_control.modulate.a = 0.0
	_content.scale = Vector2.ONE * 0.9
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_root_control, "modulate:a", 1.0, _ENTRANCE_DURATION)
	tween.tween_property(_content, "scale", Vector2.ONE, _ENTRANCE_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _format_time(seconds: float) -> String:
	var total_seconds: int = int(seconds)
	return "%02d:%02d" % [total_seconds / 60, total_seconds % 60]


func _on_replay_pressed() -> void:
	AudioManager.play_ui(AudioManager.Sfx.UI_SELECT)
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	AudioManager.play_ui(AudioManager.Sfx.UI_SELECT)
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
