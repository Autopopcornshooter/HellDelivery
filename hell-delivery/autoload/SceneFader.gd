extends CanvasLayer

# 품질 업그레이드: 메뉴/레벨/결과 전환이 즉시 컷으로 바뀌어 화면이 뚝 끊기던 문제를 완화한다.
# 씬 트리 자체가 교체되는 동안에도 오버레이가 남아 있어야 하므로 Autoload가 필요하다
# (교체되는 씬의 자식으로는 이 역할을 할 수 없다).

const FADE_DURATION := 0.22 # TODO: 프로토타입 값, 튜닝 필요

var _rect: ColorRect


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_rect = ColorRect.new()
	_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_rect)


func change_scene(path: String) -> void:
	# 전환 전 화면을 즉시(트윈 없이) 검게 덮어 이전 씬이 사라지는 "컷"을 가리고,
	# 새 씬이 들어온 뒤에만 부드럽게 걷어낸다 — 전환 자체를 트윈으로 지연시키면
	# 헤드리스 자동 테스트가 가정하는 "버튼 클릭 → 즉시 씬 전환" 타이밍이 깨진다.
	_rect.color.a = 1.0
	await get_tree().process_frame
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	var tween := create_tween()
	tween.tween_property(_rect, "color:a", 0.0, FADE_DURATION)
