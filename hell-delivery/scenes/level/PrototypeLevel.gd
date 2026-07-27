extends Node3D

@onready var delivery_zone: DeliveryZone = $Gameplay/DeliveryZone
@onready var delivery_hud: DeliveryHUD = $UI/DeliveryHUD
@onready var completion_overlay: CompletionOverlay = $UI/CompletionOverlay
@onready var player: Player = $Gameplay/Player
@onready var onboarding_overlay: OnboardingOverlay = $UI/OnboardingOverlay

var _play_time_elapsed: float = 0.0


func _ready() -> void:
	delivery_zone.package_delivered.connect(_on_package_delivered)
	delivery_zone.all_packages_delivered.connect(_on_all_packages_delivered)
	player.grab_aim_state_changed.connect(delivery_hud.set_crosshair_state)
	delivery_hud.update_progress(delivery_zone.delivered_count, DeliveryZone.TARGET_PACKAGE_COUNT)
	# T080: 첫 실행 안내가 떠 있는 동안에는 그것을 닫은 직후에 목표 문구를 보여주고, 이미 본 적
	# 있으면(재진입·Restart) 안내 없이 곧바로 보여준다 — "항상 큰 튜토리얼" 대신 짧게만 표시.
	if onboarding_overlay.visible:
		onboarding_overlay.closed.connect(delivery_hud.show_goal, CONNECT_ONE_SHOT)
	else:
		delivery_hud.show_goal()


func _physics_process(delta: float) -> void:
	# T081: 온보딩/Pause/완료 화면 전부 get_tree().paused를 사용하고, 이 노드는 기본
	# process_mode(Pausable)라 paused 동안에는 이 함수 자체가 호출되지 않는다 — 별도 조건 없이
	# 실제 플레이 시간만 자연히 누적된다(T079 Pause 자동 정지와 동일한 원리).
	_play_time_elapsed += delta


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_package_delivered(_package: RigidBody3D, delivered_count: int, target_count: int) -> void:
	delivery_hud.update_progress(delivered_count, target_count)
	delivery_hud.show_delivery_toast()


func _on_all_packages_delivered() -> void:
	completion_overlay.show_completion(DeliveryZone.TARGET_PACKAGE_COUNT, _play_time_elapsed)
