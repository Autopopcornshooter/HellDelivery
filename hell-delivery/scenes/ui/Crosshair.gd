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

const _FLASH_DURATION: float = 0.4 # T075: Release 피드백(거리 초과/정적 차단)용 짧은 점멸 지속 시간(0.3~0.7초 권장 범위 내).
const _FLASH_RADIUS: float = _RADIUS_HOLDING + 4.0

var _state: int = 0
var _flash_time_left: float = 0.0
var _flash_color: Color = Color.WHITE


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false) # 점멸 중일 때만 _process가 필요하므로 평소에는 꺼 둔다.


func set_state(state: int) -> void:
	if state == _state:
		return
	_state = state
	queue_redraw()


func flash(color: Color) -> void:
	# T075: 사용자가 직접 놓은 경우가 아니라, 거리 초과·정적 장애물 등으로 "예상치 못하게" 연결이
	# 끊겼을 때만 호출된다(Player.gd의 grab_connection_lost, MANUAL 사유는 호출하지 않음). 텍스트
	# 없이 조준점 주변에 짧게(0.4초) 링을 점멸시키는 정도로만 표시한다(과도한 화면 효과 금지).
	_flash_color = color
	_flash_time_left = _FLASH_DURATION
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_flash_time_left = maxf(_flash_time_left - delta, 0.0)
	queue_redraw()
	if _flash_time_left <= 0.0:
		set_process(false)


func _draw() -> void:
	var center := size * 0.5
	match _state:
		1:
			draw_circle(center, _RADIUS_TARGETING, _COLOR_TARGETING)
		2:
			draw_rect(Rect2(center - Vector2.ONE * _RADIUS_HOLDING, Vector2.ONE * _RADIUS_HOLDING * 2.0), _COLOR_HOLDING, false, 2.0)
		_:
			draw_circle(center, _RADIUS_NONE, _COLOR_NONE)
	if _flash_time_left > 0.0:
		var alpha := _flash_time_left / _FLASH_DURATION
		draw_arc(center, _FLASH_RADIUS, 0.0, TAU, 24, Color(_flash_color.r, _flash_color.g, _flash_color.b, alpha), 2.0)
