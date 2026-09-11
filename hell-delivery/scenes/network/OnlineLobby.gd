extends VBoxContainer

signal character_changed(character_id: String)
signal ready_pressed
signal start_pressed
signal order_changed(order_id: String)
signal history_pressed
var history_button: Button

var ready_button: Button
var start_button: Button
var cards: Array[Label] = []
var previews: Array[CharacterVisual] = []
var _character_id := ""
var order_choice: OptionButton
var order_brief: Label

func _ready() -> void:
	add_theme_constant_override("separation", 6)
	order_choice = OptionButton.new()
	for id in DeliveryOrders.IDS:
		order_choice.add_item(DeliveryOrders.get_order(id).title)
	order_choice.add_item("3연속 배송 코스 · 일반 → 혼합 → 공동")
	order_choice.item_selected.connect(func(index): order_changed.emit("course" if index == DeliveryOrders.IDS.size() else DeliveryOrders.IDS[index]))
	add_child(order_choice)
	order_brief = Label.new()
	order_brief.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	order_brief.add_theme_font_size_override("font_size", 16)
	add_child(order_brief)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	add_child(row)
	for slot in 4:
		var card := VBoxContainer.new()
		row.add_child(card)
		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 14)
		card.add_child(label)
		cards.append(label)
		var container := SubViewportContainer.new()
		container.custom_minimum_size = Vector2(136, 130)
		container.stretch = true
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(container)
		var viewport := SubViewport.new()
		viewport.own_world_3d = true
		viewport.transparent_bg = true
		viewport.size = Vector2i(136, 130)
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
	var actions := HBoxContainer.new()
	add_child(actions)
	ready_button = Button.new()
	ready_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ready_button.custom_minimum_size.y = 42
	ready_button.pressed.connect(func(): ready_pressed.emit())
	actions.add_child(ready_button)
	start_button = Button.new()
	start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start_button.text = "배송 시작 · 호스트"
	start_button.custom_minimum_size.y = 42
	start_button.pressed.connect(func(): start_pressed.emit())
	actions.add_child(start_button)
	history_button = Button.new()
	history_button.text = "방 기록"
	history_button.custom_minimum_size = Vector2(120, 42)
	history_button.pressed.connect(func(): history_pressed.emit())
	actions.add_child(history_button)

func cycle_character(direction: int) -> void:
	var ids: Array[String] = []
	for definition in CharacterCatalog.get_all(): ids.append(definition.id)
	character_changed.emit(ids[wrapi(ids.find(_character_id) + direction, 0, ids.size())])

func show_state(characters: Array, readiness: Array, joined: bool, local_slot: int, host: bool, order_id: String = "standard", participants: Array = []) -> void:
	show()
	var order := DeliveryOrders.get_order(order_id)
	order_choice.select(DeliveryOrders.IDS.find(order.id))
	order_choice.disabled = not host
	order_brief.text = order.brief
	_character_id = characters[local_slot]
	for slot in 4:
		var present: bool = participants[slot] != 0 if participants.size() == 4 else (slot == 0 or (slot == 1 and joined))
		previews[slot].visible = present
		if present:
			if previews[slot].current_character_id != characters[slot]:
				previews[slot].set_character(characters[slot], true)
			cards[slot].text = "P%d %s · %s\n%s" % [slot + 1, "나" if slot == local_slot else ("호스트" if slot == 0 else "동료"), "준비" if readiness[slot] else "대기", CharacterCatalog.get_by_id(characters[slot]).display_name]
		else:
			cards[slot].text = "P%d 빈자리\nIP로 참가" % (slot + 1)
		cards[slot].modulate = Color(0.55, 1, 0.7) if present and readiness[slot] else Color.WHITE
	ready_button.text = "준비 취소" if readiness[local_slot] else "준비하기"
	ready_button.disabled = not joined
	start_button.visible = host
	var all_ready: bool = joined
	for slot in characters.size():
		if participants.is_empty() or participants[slot] != 0: all_ready = all_ready and readiness[slot]
	start_button.disabled = not all_ready
