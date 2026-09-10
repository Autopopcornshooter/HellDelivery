class_name DeliveryHUD
extends CanvasLayer

@onready var crosshair: Crosshair = $Crosshair
@onready var goal_label: Label = $GoalLabel
@onready var goal_timer: Timer = $GoalTimer
@onready var progress_label: Label = $ProgressLabel
@onready var delivery_toast_label: Label = $DeliveryToastLabel
@onready var delivery_toast_timer: Timer = $DeliveryToastTimer


func _ready() -> void:
	# Keep text readable against both the bright plaster and the outdoor sky.
	for label: Label in [goal_label, $RouteLabel, progress_label, delivery_toast_label]:
		var backing := StyleBoxFlat.new()
		backing.bg_color = Color(0.025, 0.055, 0.065, 0.88)
		backing.content_margin_left = 12
		backing.content_margin_right = 12
		backing.content_margin_top = 4
		backing.content_margin_bottom = 4
		backing.set_corner_radius_all(6)
		label.add_theme_stylebox_override("normal", backing)
		label.minimum_size_changed.connect(_fit_background.bind(label))
		_fit_background.call_deferred(label)
	goal_label.visible = false
	delivery_toast_label.visible = false
	goal_timer.timeout.connect(_on_goal_timer_timeout)
	delivery_toast_timer.timeout.connect(_on_delivery_toast_timer_timeout)


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


func show_delivery_toast(message: String = "배송 완료!", duration: float = 2.5) -> void:
	# T081: Package 1개가 배송될 때마다 짧게(1초 안팎) 표시하는 피드백 — 3개를 모두 배송했을 때의
	# CompletionOverlay(전체 화면 완료 연출)와는 별개의, 가벼운 개별 배송 알림이다.
	delivery_toast_label.text = message
	delivery_toast_label.visible = true
	delivery_toast_timer.start(duration)


func _on_delivery_toast_timer_timeout() -> void:
	delivery_toast_label.visible = false
