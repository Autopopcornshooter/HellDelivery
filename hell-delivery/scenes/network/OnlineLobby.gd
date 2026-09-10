extends VBoxContainer

signal character_changed(character_id: String)
signal ready_pressed
signal start_pressed

var ready_button: Button
var start_button: Button
var cards: Array[Label] = []
var previews: Array[CharacterVisual] = []
var _character_id := ""

func _ready() -> void:
	add_theme_constant_override("separation", 10)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	add_child(row)
	for slot in 2:
		var card := VBoxContainer.new()
		row.add_child(card)
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 19)
		card.add_child(label)
		cards.append(label)
		var container := SubViewportContainer.new()
		container.custom_minimum_size = Vector2(272, 200)
		container.stretch = true
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(container)
		var viewport := SubViewport.new()
		viewport.own_world_3d = true
		viewport.transparent_bg = true
		viewport.size = Vector2i(272, 200)
		viewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
		container.add_child(viewport)
		var camera := Camera3D.new()
		viewport.add_child(camera)
		camera.position = Vector3(0, 1.1, 3.2)
		camera.look_at(Vector3(0, 0.9, 0))
		camera.current = true
		var light := DirectionalLight3D.new()
		light.rotation_degrees = Vector3(-35, -30, 0)
		viewport.add_child(light)
		var fill := DirectionalLight3D.new()
		fill.rotation_degrees = Vector3(-20, 145, 0)
		fill.light_energy = 0.5
		viewport.add_child(fill)
		var visual: CharacterVisual = preload("res://scenes/character/CharacterVisual.tscn").instantiate()
		viewport.add_child(visual)
		previews.append(visual)
	var choices := HBoxContainer.new()
	choices.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(choices)
	for direction in [-1, 1]:
		var button := Button.new()
		button.text = "◀ 내 캐릭터" if direction == -1 else "내 캐릭터 ▶"
		button.custom_minimum_size = Vector2(240, 38)
		button.pressed.connect(func(): cycle_character(direction))
		choices.add_child(button)
	ready_button = Button.new()
	ready_button.custom_minimum_size.y = 42
	ready_button.pressed.connect(func(): ready_pressed.emit())
	add_child(ready_button)
	start_button = Button.new()
	start_button.text = "배송 시작 · 호스트"
	start_button.custom_minimum_size.y = 42
	start_button.pressed.connect(func(): start_pressed.emit())
	add_child(start_button)

func cycle_character(direction: int) -> void:
	var ids: Array[String] = []
	for definition in CharacterCatalog.get_all(): ids.append(definition.id)
	character_changed.emit(ids[wrapi(ids.find(_character_id) + direction, 0, ids.size())])

func show_state(characters: Array, readiness: Array, joined: bool, local_slot: int, host: bool) -> void:
	show()
	_character_id = characters[local_slot]
	for slot in 2:
		var present := slot == 0 or joined
		previews[slot].visible = present
		if present:
			if previews[slot].current_character_id != characters[slot]:
				previews[slot].set_character(characters[slot], true)
			cards[slot].text = "%s%s · %s\n%s" % ["호스트" if slot == 0 else "참가자", " (나)" if slot == local_slot else "", "준비 완료" if readiness[slot] else "준비 전", CharacterCatalog.get_by_id(characters[slot]).display_name]
		else:
			cards[slot].text = "참가자 대기 중\n친구가 IP로 참가하면 표시됩니다"
		cards[slot].modulate = Color(0.55, 1, 0.7) if readiness[slot] else Color.WHITE
	ready_button.text = "준비 취소" if readiness[local_slot] else "준비하기"
	ready_button.disabled = not joined
	start_button.visible = host
	start_button.disabled = not joined or not (readiness[0] and readiness[1])
