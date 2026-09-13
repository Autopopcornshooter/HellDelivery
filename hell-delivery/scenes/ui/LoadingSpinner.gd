class_name LoadingSpinner
extends Control

# 품질 업그레이드: 온라인 연결/월드 준비 대기 화면에 정적 텍스트만 있어 "멈춘 건지 진행 중인지"
# 확신을 주기 어려웠다 - 외부 텍스처 없이 코드로 그리는 최소한의 회전 인디케이터만 추가한다.

const _RADIUS := 12.0
const _LINE_WIDTH := 3.0
const _COLOR := Color(0.55, 0.88, 0.9, 0.9)
const _SPIN_SPEED := TAU * 0.9 # TODO: 프로토타입 값, 튜닝 필요


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(_RADIUS, _RADIUS) * 2.0
	pivot_offset = custom_minimum_size / 2.0
	visibility_changed.connect(func(): set_process(visible))
	set_process(visible) # 숨겨져 있을 때는 매 프레임 회전할 필요가 없다.


func _process(delta: float) -> void:
	rotation += _SPIN_SPEED * delta


func _draw() -> void:
	draw_arc(size / 2.0, _RADIUS, 0.0, TAU * 0.75, 20, _COLOR, _LINE_WIDTH, true)
