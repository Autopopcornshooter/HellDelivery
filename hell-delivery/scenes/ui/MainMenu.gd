class_name MainMenu
extends Control

# T078: 실행 시 곧바로 테스트 레벨로 들어가는 대신 먼저 보여줄 메인 메뉴. 데모 시작·게임 종료를
# 담당하고(T078), T079에서 설정 화면 진입을 추가했다. 일시정지·온보딩은 T080 이후 범위.

const DEMO_SCENE_PATH := "res://scenes/level/Stage01HillsideVilla.tscn"
const DELIVERY_RUN_PATH := "res://scenes/level/VillaDeliveryRun.tscn"
const MENU_BGM_PATH := "res://assets/audio/courier_dash.mp3"

var _menu_bgm: AudioStreamPlayer

@onready var button_container: VBoxContainer = $LeftColumn/CenterContainer/VBoxContainer
@onready var start_button: Button = $LeftColumn/CenterContainer/VBoxContainer/StartButton
@onready var utility_row: HBoxContainer = $UtilityRow
@onready var character_button: Button = $UtilityRow/CharacterButton
@onready var controls_button: Button = $UtilityRow/ControlsButton
@onready var settings_button: Button = $UtilityRow/SettingsButton
@onready var quit_button: Button = $UtilityRow/QuitButton
@onready var settings_panel: SettingsPanel = $SettingsPanel
@onready var controls_panel: ControlsPanel = $ControlsPanel
@onready var character_select_panel: CharacterSelectPanel = $CharacterSelectPanel
@onready var title_block: VBoxContainer = $TitleBlock


func _ready() -> void:
	# Test build only: exercise the actual packed resources through an explicit CLI entry.
	if OS.is_debug_build() and "self-test" in OS.get_cmdline_user_args() and not get_tree().has_meta("self_test_started"):
		get_tree().set_meta("self_test_started", true)
		get_tree().change_scene_to_file.call_deferred("res://tests/Playtest.tscn")
		return
	# 메뉴에서는 항상 마우스 커서가 보이고 자유롭게 움직여야 한다 — 캡처 해제는 여기서만 하고,
	# 데모 진입 후 재캡처는 기존 Player.gd._ready()가 그대로 담당한다(중복 처리 없음).
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if "network-test-host" in OS.get_cmdline_user_args() or "network-test-client" in OS.get_cmdline_user_args():
		get_tree().change_scene_to_file.call_deferred("res://scenes/network/OnlineSession.tscn")
		return
	_play_menu_bgm()
	var freight_button := Button.new()
	freight_button.name = "FullDeliveryButton"
	freight_button.text = "전체 배송 · 적재 / 운전 / 빌라 · 1~4인"
	freight_button.custom_minimum_size.y = 44
	freight_button.add_theme_font_size_override("font_size", 20)
	_apply_primary_style(freight_button)
	button_container.add_child(freight_button)
	button_container.move_child(freight_button, start_button.get_index())
	freight_button.pressed.connect(func(): SceneFader.change_scene("res://scenes/network/FullDeliverySession.tscn"))
	var online_button := Button.new()
	online_button.name = "OnlineButton"
	online_button.text = "빌라 연습 · 온라인 협동"
	online_button.custom_minimum_size.y = 44
	online_button.add_theme_font_size_override("font_size", 20)
	button_container.add_child(online_button)
	button_container.move_child(online_button, $LeftColumn/CenterContainer/VBoxContainer/CoopButton.get_index() + 1)
	online_button.pressed.connect(func(): SceneFader.change_scene("res://scenes/network/OnlineSession.tscn"))
	settings_panel.visible = false
	controls_panel.visible = false
	start_button.pressed.connect(_on_start_pressed)
	$LeftColumn/CenterContainer/VBoxContainer/CoopButton.pressed.connect(func(): SceneFader.change_scene("res://scenes/level/VillaCoop.tscn"))
	$LeftColumn/CenterContainer/VBoxContainer/DeliveryRunButton.pressed.connect(func(): SceneFader.change_scene(DELIVERY_RUN_PATH))
	character_button.pressed.connect(_open_character_select)
	controls_button.pressed.connect(_open_controls)
	settings_button.pressed.connect(_open_settings)
	quit_button.pressed.connect(_on_quit_pressed)
	settings_panel.closed.connect(_close_settings)
	controls_panel.closed.connect(_close_controls)
	character_select_panel.closed.connect(_close_character_select)
	character_select_panel.confirmed.connect(_on_character_confirmed)
	freight_button.grab_focus()
	# 메뉴 안내도 실제 시작 레벨의 배송 설정을 읽는다.
	var demo: Node = load(DEMO_SCENE_PATH).instantiate()
	var zone: DeliveryZone = demo.get_node("Gameplay/DeliveryZone")
	controls_panel.configure_goal(zone)
	demo.free()
	_fade_in_menu()


func _apply_primary_style(button: Button) -> void:
	# 여러 모드 중 가장 먼저 눌러볼 만한 항목임을 강조하는 강조색 버튼 — 전역 테마 위에 이 버튼만 덮어쓴다.
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.157, 0.494, 0.522, 0.95)
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_right = 6
	normal.corner_radius_bottom_left = 6
	normal.content_margin_left = 14.0
	normal.content_margin_top = 6.0
	normal.content_margin_right = 14.0
	normal.content_margin_bottom = 6.0
	var hover := normal.duplicate()
	hover.bg_color = Color(0.2, 0.62, 0.65, 1.0)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", hover)


func _fade_in_menu() -> void:
	# TODO: 프로토타입 값, 튜닝 필요 - 메뉴 진입 시 살짝 떠오르는 느낌만 주는 최소한의 연출.
	# position은 건드리지 않는다 -- CenterContainer/HBoxContainer가 자체적으로 자식 위치를
	# 재계산하므로, 스크립트가 position을 직접 tween하면 레이아웃 확정 타이밍과 경합해
	# 버튼이 잘못된 위치에 잠깐(또는 캡처 시점에) 렌더링되는 문제가 있었다.
	for node: Control in [title_block, button_container, utility_row]:
		node.modulate.a = 0.0
		create_tween().tween_property(node, "modulate:a", 1.0, 0.35)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if controls_panel.visible:
		_close_controls()
		get_viewport().set_input_as_handled()
	elif settings_panel.visible:
		_close_settings()
		get_viewport().set_input_as_handled()
	elif character_select_panel.visible:
		_close_character_select()
		get_viewport().set_input_as_handled()


func _play_menu_bgm() -> void:
	_menu_bgm = AudioStreamPlayer.new()
	_menu_bgm.name = "MenuBgm"
	_menu_bgm.bus = "BGM"
	var stream: AudioStream = load(MENU_BGM_PATH)
	if stream is AudioStreamMP3: stream.loop = true
	_menu_bgm.stream = stream
	_menu_bgm.volume_db = -6.0 # TODO: 프로토타입 값, 튜닝 필요 - 절차적 효과음 대비 상대 볼륨. Master 볼륨 설정을 그대로 따른다.
	add_child(_menu_bgm)
	_menu_bgm.play()
	# Stop promptly when leaving the menu (scene change) rather than letting a
	# still-playing MP3 linger until the node is freed with the tree.
	tree_exiting.connect(_menu_bgm.stop)


func _on_start_pressed() -> void:
	SceneFader.change_scene(DEMO_SCENE_PATH)


func _on_quit_pressed() -> void:
	if is_instance_valid(_menu_bgm) and _menu_bgm.playing:
		# Quitting while an MP3 stream is still actively playing can leave the
		# audio thread mid-decode at process teardown (harmless but noisy engine
		# diagnostic) -- stop it and give the mixer a beat to actually release it.
		_menu_bgm.stop()
		await get_tree().create_timer(0.3).timeout
	get_tree().quit()


func _open_settings() -> void:
	button_container.visible = false
	utility_row.visible = false
	controls_panel.visible = false
	settings_panel.visible = true
	settings_panel.grab_initial_focus()


func _close_settings() -> void:
	settings_panel.visible = false
	button_container.visible = true
	utility_row.visible = true
	settings_button.grab_focus()


func _open_controls() -> void:
	button_container.visible = false
	utility_row.visible = false
	settings_panel.visible = false
	controls_panel.visible = true
	controls_panel.grab_initial_focus()


func _close_controls() -> void:
	controls_panel.visible = false
	button_container.visible = true
	utility_row.visible = true
	controls_button.grab_focus()


func _open_character_select() -> void:
	button_container.visible = false
	utility_row.visible = false
	settings_panel.visible = false
	controls_panel.visible = false
	# T085D: 싱글플레이 모드이므로 selection_manager는 설정하지 않는다(전체 18종에서 자유 선택).
	# 이전에 저장된 선택이 있으면 그 위치에서 다시 시작한다.
	character_select_panel.open(GameSettings.selected_character_id)


func _close_character_select() -> void:
	character_select_panel.close()
	button_container.visible = true
	utility_row.visible = true
	character_button.grab_focus()


func _on_character_confirmed(character_id: String) -> void:
	GameSettings.set_selected_character_id(character_id)
	_close_character_select()
