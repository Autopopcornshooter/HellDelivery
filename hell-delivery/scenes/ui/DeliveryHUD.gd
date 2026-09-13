class_name DeliveryHUD
extends CanvasLayer

@onready var crosshair: Crosshair = $Crosshair
@onready var goal_label: Label = $GoalLabel
@onready var goal_timer: Timer = $GoalTimer
@onready var progress_label: Label = $ProgressLabel
@onready var delivery_toast_label: Label = $DeliveryToastLabel
@onready var delivery_toast_timer: Timer = $DeliveryToastTimer
@onready var damage_vignette: ColorRect = $DamageVignette
@onready var context_prompt_label: Label = $ContextPrompt

const _DAMAGE_FLASH_PEAK := 0.4 # TODO: 프로토타입 값, 튜닝 필요
const _DAMAGE_FLASH_DURATION := 0.4

# 품질 점검 권장 8번(UI 비주얼): 이전에는 성공/경고 토스트가 전부 같은 짙은 회색이라
# 정보 종류가 색으로 구분되지 않았다 — 상태별 accent만 최소로 추가.
const _TOAST_DEFAULT_COLOR := Color(0.025, 0.055, 0.065, 0.88)
const _TOAST_ACCENT_COLORS := {
	"success": Color(0.05, 0.28, 0.09, 0.9),
	"warning": Color(0.34, 0.09, 0.05, 0.9),
}


func _ready() -> void:
	# Keep text readable against both the bright plaster and the outdoor sky.
	for label: Label in [goal_label, $RouteLabel, progress_label, delivery_toast_label]:
		label.add_theme_stylebox_override("normal", _toast_style(_TOAST_DEFAULT_COLOR))
		label.minimum_size_changed.connect(_fit_background.bind(label))
		_fit_background.call_deferred(label)
	goal_label.visible = false
	delivery_toast_label.visible = false
	goal_timer.timeout.connect(_on_goal_timer_timeout)
	delivery_toast_timer.timeout.connect(_on_delivery_toast_timer_timeout)
	add_to_group("delivery_hud")
	# 크로스헤드 옆 근접 상호작용 안내(품질 업그레이드: 상시 표시 문구 축소) — 고정 폭 상자라
	# 다른 라벨들과 달리 텍스트 길이에 맞춰 매번 재배치하지 않는다(중앙 앵커라 재배치하면
	# 크로스헤드 위로 다시 옮겨가 버림).
	context_prompt_label.add_theme_stylebox_override("normal", _toast_style(_TOAST_DEFAULT_COLOR))
	context_prompt_label.visible = false


# 품질 업그레이드: 택배 파손 순간 화면 가장자리가 붉게 잠깐 번쩍여 "지금 실수했다"를
# 직관적으로 알린다. 파손은 호스트/클라이언트 양쪽에서(Package.apply_damage /
# apply_shipment_state) 발생하므로, 어느 쪽에서 호출해도 화면에 있는 모든 로컬 HUD가
# 반응하도록 static 헬퍼로 그룹 전체에 방송한다(스플릿 스크린이면 HUD가 여러 개 존재).
static func flash_damage_all(tree: SceneTree) -> void:
	for hud in tree.get_nodes_in_group("delivery_hud"):
		if hud is DeliveryHUD:
			hud.flash_damage()


func flash_damage() -> void:
	damage_vignette.color.a = _DAMAGE_FLASH_PEAK
	create_tween().tween_property(damage_vignette, "color:a", 0.0, _DAMAGE_FLASH_DURATION)


func _toast_style(bg_color: Color) -> StyleBoxFlat:
	var backing := StyleBoxFlat.new()
	backing.bg_color = bg_color
	backing.content_margin_left = 12
	backing.content_margin_right = 12
	backing.content_margin_top = 4
	backing.content_margin_bottom = 4
	backing.set_corner_radius_all(6)
	return backing


func _fit_background(label: Label) -> void:
	# Label's minimum width includes shaped text and the style's side padding.
	var half_width := ceilf(label.get_minimum_size().x / 2.0)
	label.offset_left = -half_width
	label.offset_right = half_width


func configure_goal(zone: DeliveryZone) -> void:
	configure_delivery_goal(zone.target_package_count, zone.destination_name)
	update_progress(zone.delivered_count, zone.target_package_count)

func configure_delivery_goal(count: int, destination: String) -> void:
	goal_label.text = "택배 %d개 → %s" % [count, destination]


func set_crosshair_state(state: int) -> void:
	crosshair.set_state(state)


func show_goal() -> void:
	# T080: 목표 문구는 한 번 보여준 뒤 Timer로 자동으로 사라진다 — 별도로 다시 호출하는
	# 곳이 없으므로(첫 실행 안내 종료 직후 또는 씬 진입 직후 1회) Delivery 성공 후 재표시되지 않는다.
	goal_label.visible = true
	goal_timer.start()


func _on_goal_timer_timeout() -> void:
	goal_label.visible = false


func update_progress(delivered_count: int, target_count: int) -> void:
	progress_label.text = "배송 완료 %d / %d" % [delivered_count, target_count]


func show_delivery_toast(message: String = "배송 완료!", duration: float = 2.5, kind: String = "info") -> void:
	# T081: Package 1개가 배송될 때마다 짧게(1초 안팎) 표시하는 피드백 — 3개를 모두 배송했을 때의
	# CompletionOverlay(전체 화면 완료 연출)와는 별개의, 가벼운 개별 배송 알림이다.
	delivery_toast_label.text = message
	delivery_toast_label.add_theme_stylebox_override("normal", _toast_style(_TOAST_ACCENT_COLORS.get(kind, _TOAST_DEFAULT_COLOR)))
	_fit_background(delivery_toast_label)
	delivery_toast_label.visible = true
	delivery_toast_timer.start(duration)
	if kind == "success":
		_punch(delivery_toast_label) # 품질 업그레이드: 배송 완료 순간의 타격감(순수 시각 효과).


func _punch(label: Label) -> void:
	label.pivot_offset = label.size / 2.0
	label.scale = Vector2(1.3, 1.3)
	create_tween().tween_property(label, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _on_delivery_toast_timer_timeout() -> void:
	delivery_toast_label.visible = false


func show_context_prompt(text: String) -> void:
	context_prompt_label.text = text
	context_prompt_label.visible = true


func hide_context_prompt() -> void:
	context_prompt_label.visible = false
