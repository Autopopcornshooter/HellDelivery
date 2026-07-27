class_name DeliveryHUD
extends CanvasLayer

@onready var crosshair: Crosshair = $Crosshair
@onready var goal_label: Label = $GoalLabel
@onready var goal_timer: Timer = $GoalTimer
@onready var progress_label: Label = $ProgressLabel
@onready var delivery_toast_label: Label = $DeliveryToastLabel
@onready var delivery_toast_timer: Timer = $DeliveryToastTimer


func _ready() -> void:
	goal_label.text = "Package %d개를 Delivery Zone으로 운반하세요" % DeliveryZone.TARGET_PACKAGE_COUNT
	goal_label.visible = false
	delivery_toast_label.visible = false
	goal_timer.timeout.connect(_on_goal_timer_timeout)
	delivery_toast_timer.timeout.connect(_on_delivery_toast_timer_timeout)
	update_progress(0, DeliveryZone.TARGET_PACKAGE_COUNT)


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


func show_delivery_toast() -> void:
	# T081: Package 1개가 배송될 때마다 짧게(1초 안팎) 표시하는 피드백 — 3개를 모두 배송했을 때의
	# CompletionOverlay(전체 화면 완료 연출)와는 별개의, 가벼운 개별 배송 알림이다.
	delivery_toast_label.visible = true
	delivery_toast_timer.start()


func _on_delivery_toast_timer_timeout() -> void:
	delivery_toast_label.visible = false
