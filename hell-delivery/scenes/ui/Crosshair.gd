class_name Crosshair
extends Control

# 상태값은 Player.gd의 GRAB_AIM_NONE/TARGETING/HOLDING(0/1/2)과 동일한 정수 규약을 공유한다
# (별도 enum 결합 없이 정수로만 주고받는다 — T073).
const _RADIUS_NONE: float = 2.0
const _RADIUS_TARGETING: float = 5.0
const _RADIUS_HOLDING: float = 4.0
const _COLOR_NONE: Color = Color(1.0, 1.0, 1.0, 0.6)
const _COLOR_TARGETING: Color = Color(1.0, 0.9, 0.2, 0.9)
const _COLOR_HOLDING: Color = Color(0.3, 1.0, 0.6, 0.9)

var _state: int = 0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_state(state: int) -> void:
	if state == _state:
		return
	_state = state
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	match _state:
		1:
			draw_circle(center, _RADIUS_TARGETING, _COLOR_TARGETING)
		2:
			draw_rect(Rect2(center - Vector2.ONE * _RADIUS_HOLDING, Vector2.ONE * _RADIUS_HOLDING * 2.0), _COLOR_HOLDING, false, 2.0)
		_:
			draw_circle(center, _RADIUS_NONE, _COLOR_NONE)
