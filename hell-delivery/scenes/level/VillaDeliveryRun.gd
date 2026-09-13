extends "res://scenes/level/PrototypeLevel.gd"

var second_zone: DeliveryZone
# Registry of every delivery destination in this level. Generic code (order
# spawning, HUD text, network sync, delivery judgment) iterates this instead
# of naming specific zones, so adding a destination means adding it here plus
# its own map geometry/data -- not touching that generic code.
var destinations: Array[DeliveryZone] = []
var _last_rejection_ms: int = -2000
var _completion_requested: bool = false
var _delivery_details: PackedStringArray = []
var _stop_visuals: Dictionary = {}
var _delivery_streak := 0 # 품질 업그레이드: 오배송 없이 연속 배송한 횟수를 실시간으로 알려준다(결과 화면 배지와 별개).

func _ready() -> void:
	delivery_zone.destination_id = DeliveryOrders.VILLA_201
	delivery_zone.display_name = "201호"
	delivery_zone.receipt_offset = Vector3(0.55, -0.42, 0)
	delivery_zone.receipt_rotation_y = -PI / 2
	var first: Package = $Gameplay/Package
	first.configure_destination(DeliveryOrders.VILLA_201, "201호")
	var second: Package = preload("res://scenes/package/Package.tscn").instantiate()
	second.name = "Package202"
	second.destination_id = DeliveryOrders.VILLA_202
	second.display_name = "202호"
	second.position = Vector3(1.65, 0.95, -9.3)
	$Gameplay.add_child(second)
	$Presentation.dress_package(second)
	second_zone = preload("res://scenes/delivery/DeliveryZone.tscn").instantiate()
	second_zone.name = "DeliveryZone202"
	second_zone.target_package_count = 1
	second_zone.destination_id = DeliveryOrders.VILLA_202
	second_zone.display_name = "202호"
	second_zone.destination_name = "언덕 빌라 2층 202호"
	second_zone.position = Vector3(5.3, 3.7, 7.55)
	var shape: CollisionShape3D = second_zone.get_node("CollisionShape3D")
	shape.shape = shape.shape.duplicate()
	shape.shape.radius = 0.65
	var marker: MeshInstance3D = second_zone.get_node("MeshInstance3D")
	marker.mesh = marker.mesh.duplicate()
	marker.mesh.top_radius = 0.65
	marker.mesh.bottom_radius = 0.65
	marker.scale.y = 0.035
	marker.position.y = -0.4775
	$Gameplay.add_child(second_zone)
	var label := Label3D.new()
	label.text = "202호 · 택배 1개"
	label.position.y = 1.5
	label.font_size = 32
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color(0.45, 1, 0.6)
	second_zone.add_child(label)
	second_zone.package_delivered.connect(_on_package_delivered)
	second_zone.all_packages_delivered.connect(_on_all_packages_delivered)
	destinations = [delivery_zone, second_zone]
	for zone in destinations:
		zone.package_rejected.connect(_on_wrong_address.bind(zone))
	super._ready()
	for zone in destinations:
		var stop_marker: MeshInstance3D = zone.get_node("MeshInstance3D")
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.18, 0.85, 0.49, 0.5)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		stop_marker.material_override = material
		var receipt := Label3D.new()
		receipt.name = "DeliveryReceipt"
		receipt.text = zone.display_name + " 배송 완료"
		receipt.position = zone.receipt_offset
		receipt.rotation.x = -PI / 2
		receipt.rotation.y = zone.receipt_rotation_y
		receipt.font_size = 40
		receipt.pixel_size = 0.003
		receipt.visible = false
		zone.add_child(receipt)
		_stop_visuals[zone] = receipt
	for destination_label in delivery_zone.find_children("*", "Label3D", false, false):
		if destination_label == _stop_visuals[delivery_zone]:
			continue
		destination_label.text = "%s · 택배 1개" % delivery_zone.display_name
		destination_label.font_size = 32
		destination_label.position.y = 1.5
	for sign in $Presentation.find_children("*", "Label3D", true, false):
		if sign.text.begins_with("HELL DELIVERY\n출발"):
			sign.text = "HELL DELIVERY\n출발 · 택배 %d개" % _total_target()
	_update_stops()

func destination(id: String) -> DeliveryZone:
	for zone in destinations:
		if zone.destination_id == id: return zone
	return null

func _total_target() -> int:
	var total := 0
	for zone in destinations: total += zone.target_package_count
	return total

func _delivered_total() -> int:
	var total := 0
	for zone in destinations: total += zone.delivered_count
	return total

func _configure_goal() -> void:
	var destination_text := "2층 " + "·".join(destinations.map(func(zone): return zone.display_name)) + " (상자 주소에 맞춰 배송)"
	delivery_hud.configure_delivery_goal(_total_target(), destination_text)
	delivery_hud.update_progress(_delivered_total(), _total_target())
	onboarding_overlay.configure_delivery_goal(_total_target(), destination_text)
	$UI/PauseMenu.controls_panel.configure_delivery_goal(_total_target(), destination_text)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_stops()

func _update_stops() -> void:
	for zone in destinations:
		for destination_label in zone.find_children("*", "Label3D", false, false):
			destination_label.visible = (zone.delivered_count > 0) if destination_label == _stop_visuals.get(zone) else (zone.delivered_count == 0)
	var held := player.held_grabbable as Package
	var carrying := ("운반 중: %s | " % held.display_name) if held != null and not held.is_delivered() else "상자 주소에 맞춰 배송 | "
	if held == null and _delivered_total() == 1:
		var pending: Package = $Gameplay/Package if not $Gameplay/Package.is_delivered() else $Gameplay/Package202
		var at_truck := pending.position.distance_to(Vector3(0, 0.5, -9.3)) < 4.0
		carrying = ("트럭으로 돌아가 %s 택배를 가져오세요 | " if at_truck else "남은 %s 택배를 다시 잡으세요 · F5 복구 | ") % pending.display_name
	var progress := " · ".join(destinations.map(func(zone): return "%s %s" % [zone.display_name, "완료" if zone.delivered_count > 0 else "대기"]))
	delivery_hud.get_node("RouteLabel").text = carrying + progress

func _on_package_delivered(package: RigidBody3D, _delivered_count: int, _target_count: int) -> void:
	_delivery_details.append("%s  배송 완료 · %s" % [package.display_name, completion_overlay._format_time(_play_time_elapsed)])
	var zone := destination(package.destination_id)
	zone.get_node("MeshInstance3D").material_override.albedo_color = Color(0.2, 0.35, 0.36, 0.65)
	delivery_hud.update_progress(_delivered_total(), _total_target())
	_delivery_streak += 1
	var streak_suffix := " · %d연속!" % _delivery_streak if _delivery_streak >= 2 else ""
	delivery_hud.show_delivery_toast("%s 배송 완료!%s" % [package.display_name, streak_suffix], 2.5, "success")
	delivery_hud.show_goal()
	_feedback.play_cue("delivery")
	ImpactEffect.spawn(self, zone.global_position + Vector3.UP * 0.6, Color(0.35, 0.95, 0.6))
	_update_stops()

func _on_wrong_address(package: RigidBody3D, zone: DeliveryZone) -> void:
	if Time.get_ticks_msec() - _last_rejection_ms < 1500:
		return
	_last_rejection_ms = Time.get_ticks_msec()
	_delivery_streak = 0
	_feedback.play_cue("mistake")
	if package is Package and package.damage_enabled:
		if package.shipment_failed:
			delivery_hud.show_delivery_toast(package.failure_reason + " 택배는 배송할 수 없습니다. 남은 택배를 배달하세요.", 2.5, "warning")
			return
		if not package.loaded_once:
			delivery_hud.show_delivery_toast("차량 적재가 확인되지 않았습니다. 먼저 트럭 화물칸에 실어 주세요.", 2.5, "warning")
			return
	var label: String = package.display_name if package is Package else "주소 없음"
	delivery_hud.show_delivery_toast("여기는 %s입니다. 이 상자는 %s로 배달하세요." % [zone.display_name, label], 2.5, "warning")

func _on_all_packages_delivered() -> void:
	if _delivered_total() < _total_target() or _completion_requested:
		return
	_completion_requested = true
	completion_overlay.show_completion.call_deferred(_total_target(), _play_time_elapsed, "\n".join(_delivery_details))
