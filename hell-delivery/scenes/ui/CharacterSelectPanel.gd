class_name CharacterSelectPanel
extends Control

## T085D: 표시와 입력만 담당한다 — 예약 로직은 CharacterSelectionManager(로컬 협동일 때만 주입),
## 캐릭터 데이터는 CharacterCatalog가 소유한다. selection_manager가 null이면 싱글플레이 모드로
## 동작해 전체 18종 중 자유롭게 고르고, 확인 시 confirmed 시그널만 낸다(GameSettings 저장은
## 호출부가 담당).

signal confirmed(character_id: String)
signal closed

enum InputProfile { KEYBOARD_MOUSE, GAMEPAD }

@export var player_index: int = 0
@export var input_profile: InputProfile = InputProfile.KEYBOARD_MOUSE
@export var gamepad_device: int = 0

@onready var _name_label: Label = $Panel/VBoxContainer/NameLabel
@onready var _left_button: Button = $Panel/VBoxContainer/PreviewRow/LeftButton
@onready var _right_button: Button = $Panel/VBoxContainer/PreviewRow/RightButton
@onready var _preview_container: SubViewportContainer = $Panel/VBoxContainer/PreviewRow/PreviewContainer
@onready var _preview_viewport: SubViewport = $Panel/VBoxContainer/PreviewRow/PreviewContainer/PreviewViewport
@onready var _no_characters_label: Label = $Panel/VBoxContainer/NoCharactersLabel
@onready var _confirm_button: Button = $Panel/VBoxContainer/ButtonRow/ConfirmButton
@onready var _back_button: Button = $Panel/VBoxContainer/ButtonRow/BackButton
@onready var _reserved_hint_label: Label = $Panel/VBoxContainer/ReservedHintLabel

## null이면 싱글플레이 모드(전체 목록, 예약 없음). 로컬 협동은 열기 전에 이 값을 지정한다.
var selection_manager: CharacterSelectionManager = null

var _preview_visual: CharacterVisual = null
var _available_ids: Array[String] = []
var _current_index: int = 0


func _ready() -> void:
	visible = false
	var preview_scene: PackedScene = load("res://scenes/character/CharacterVisual.tscn")
	_preview_visual = preview_scene.instantiate()
	_preview_viewport.add_child(_preview_visual)

	_left_button.pressed.connect(_on_left_pressed)
	_right_button.pressed.connect(_on_right_pressed)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	_back_button.pressed.connect(_on_back_pressed)


## selection_manager는 open() 이전에 설정해 둔다(로컬 협동일 때만). preferred_id는 이전에
## 보고 있었거나 이미 확정했던 캐릭터 — 목록에 있으면 그 위치에서 다시 시작한다.
func open(preferred_id: String) -> void:
	visible = true
	if selection_manager != null and not selection_manager.reservation_changed.is_connected(_on_reservation_changed):
		selection_manager.reservation_changed.connect(_on_reservation_changed)
	_refresh_available_list(preferred_id)
	if not _available_ids.is_empty():
		_left_button.grab_focus()


func close() -> void:
	visible = false
	if selection_manager != null and selection_manager.reservation_changed.is_connected(_on_reservation_changed):
		selection_manager.reservation_changed.disconnect(_on_reservation_changed)


func _refresh_available_list(preferred_id: String) -> void:
	if selection_manager != null:
		_available_ids = selection_manager.get_available_ids(player_index)
	else:
		var all_ids: Array[String] = []
		for def in CharacterCatalog.get_all():
			all_ids.append(def.id)
		_available_ids = all_ids

	var has_characters := not _available_ids.is_empty()
	_no_characters_label.visible = not has_characters
	_preview_container.visible = has_characters
	_name_label.visible = has_characters
	_left_button.disabled = not has_characters
	_right_button.disabled = not has_characters
	_confirm_button.disabled = not has_characters
	if not has_characters:
		return

	var idx := _available_ids.find(preferred_id)
	_current_index = idx if idx >= 0 else 0
	_show_current()


func _show_current() -> void:
	var id: String = _available_ids[_current_index]
	var def: CharacterDefinition = CharacterCatalog.get_by_id(id)
	_name_label.text = def.display_name
	_preview_visual.set_character(id, true)
	if selection_manager != null:
		selection_manager.set_temp_selection(player_index, id)
	_update_reserved_hint()


func _update_reserved_hint() -> void:
	if _reserved_hint_label == null:
		return
	if selection_manager == null or selection_manager.get_num_players() <= 1:
		_reserved_hint_label.visible = false
		return
	var total: int = CharacterCatalog.get_all().size()
	var reserved: int = total - _available_ids.size()
	_reserved_hint_label.visible = reserved > 0
	if reserved > 0:
		_reserved_hint_label.text = "다른 플레이어가 선택한 캐릭터는 목록에서 제외됩니다."


func _cycle(direction: int) -> void:
	if _available_ids.is_empty():
		return
	_current_index = wrapi(_current_index + direction, 0, _available_ids.size())
	_show_current()


func _on_left_pressed() -> void:
	_cycle(-1)


func _on_right_pressed() -> void:
	_cycle(1)


func _on_confirm_pressed() -> void:
	if _available_ids.is_empty():
		return
	var id: String = _available_ids[_current_index]
	if selection_manager != null:
		if not selection_manager.confirm(player_index, id):
			# 동시 확정 충돌으로 실패 — 목록을 다시 계산해 다음 사용 가능 캐릭터를 보여준다.
			_refresh_available_list(id)
			return
	confirmed.emit(id)


func _on_back_pressed() -> void:
	closed.emit()


func _on_reservation_changed() -> void:
	if not visible:
		return
	var current_id := _available_ids[_current_index] if _current_index < _available_ids.size() else ""
	_refresh_available_list(current_id)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if not _event_matches_device(event):
		return
	if event.is_action_pressed("ui_left"):
		_cycle(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_cycle(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_on_back_pressed()
		get_viewport().set_input_as_handled()


## 로컬 협동에서 두 Panel이 동시에 열려 있을 때, 서로 다른 입력 장치(키보드 vs 특정 게임패드
## 번호)에만 반응하게 한다. selection_manager가 없는 싱글플레이 모드에서는 항상 모든 장치를 받는다
## (메인 메뉴에서 게임패드로도 자유롭게 탐색할 수 있어야 하므로).
func _event_matches_device(event: InputEvent) -> bool:
	if selection_manager == null:
		return true
	var is_joypad := event is InputEventJoypadButton or event is InputEventJoypadMotion
	if input_profile == InputProfile.GAMEPAD:
		if not is_joypad:
			return false
		return event.device == gamepad_device
	return not is_joypad
