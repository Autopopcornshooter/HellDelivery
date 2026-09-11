extends PanelContainer

var label: Label
var offscreen := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.12, 0.13, 0.88)
	style.set_corner_radius_all(5)
	style.content_margin_left = 9
	style.content_margin_right = 9
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	add_theme_stylebox_override("panel", style)
	label = Label.new()
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.7, 1, 0.88))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	hide()

func update_partner(camera: Camera3D, own_position: Vector3, partner_position: Vector3, caption: String = "동료", near_distance: float = 2.5, marker_height: float = 1.6) -> void:
	var distance := own_position.distance_to(partner_position)
	if distance < near_distance:
		hide()
		return
	var viewport_size := get_viewport_rect().size
	var center := viewport_size * 0.5
	var head := partner_position + Vector3(0, marker_height, 0)
	var behind := camera.is_position_behind(head)
	var screen := camera.unproject_position(head) if not behind else center
	var bounds := Rect2(Vector2(100, 150), viewport_size - Vector2(200, 260))
	offscreen = behind or not bounds.has_point(screen)
	var direction := screen - center
	if behind:
		var local := camera.to_local(head)
		direction = Vector2(local.x, maxf(absf(local.z), 0.1))
	var arrow := ""
	if offscreen:
		direction = direction.normalized()
		var half := bounds.size * 0.5
		var extent := minf(half.x / maxf(absf(direction.x), 0.001), half.y / maxf(absf(direction.y), 0.001))
		screen = bounds.get_center() + direction * extent
		arrow = ("→ " if direction.x > 0 else "← ") if absf(direction.x) > absf(direction.y) else ("↓ " if direction.y > 0 else "↑ ")
	var height_hint := ""
	if partner_position.y - own_position.y > 2: height_hint = " · 위쪽"
	elif partner_position.y - own_position.y < -2: height_hint = " · 아래쪽"
	label.text = "%s%s · %dm%s" % [arrow, caption, roundi(distance), height_hint]
	size = get_combined_minimum_size()
	position = screen - size * 0.5
	position.x = clampf(position.x, 12, viewport_size.x - size.x - 12)
	position.y = clampf(position.y, 145, viewport_size.y - size.y - 95)
	show()
