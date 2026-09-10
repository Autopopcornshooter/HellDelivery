extends "res://scenes/level/PrototypeLevel.gd"

var second_zone: DeliveryZone
var _last_rejection_ms: int = -2000
var _completion_requested: bool = false
var _delivery_details: PackedStringArray = []
var _stop_visuals: Dictionary = {}

func _ready() -> void:
	delivery_zone.delivery_address = "201"
	var first: Package = $Gameplay/Package
	first.configure_address("201")
	var second: Package = preload("res://scenes/package/Package.tscn").instantiate()
	second.name = "Package202"
	second.delivery_address = "202"
	second.position = Vector3(1.65, 0.95, -9.3)
	$Gameplay.add_child(second)
	$Presentation.dress_package(second)
	second_zone = preload("res://scenes/delivery/DeliveryZone.tscn").instantiate()
	second_zone.name = "DeliveryZone202"
	second_zone.target_package_count = 1
	second_zone.delivery_address = "202"
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
	for zone in [delivery_zone, second_zone]:
		zone.package_rejected.connect(_on_wrong_address.bind(zone))
	super._ready()
	for zone in [delivery_zone, second_zone]:
		var stop_marker: MeshInstance3D = zone.get_node("MeshInstance3D")
		var material := StandardMaterial3D.new()
		material.albedo_color = Color(0.18, 0.85, 0.49, 0.5)
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		stop_marker.material_override = material
		var receipt := Label3D.new()
		receipt.name = "DeliveryReceipt"
		receipt.text = zone.delivery_address + "호 배송 완료"
		# Lift above the thin zone mesh; face the entrance approach for each door.
		receipt.position = Vector3(0.55, -0.42, 0) if zone == delivery_zone else Vector3(0, -0.42, 0.25)
		receipt.rotation.x = -PI / 2
		if zone == delivery_zone:
			receipt.rotation.y = -PI / 2
		receipt.font_size = 40
		receipt.pixel_size = 0.003
		receipt.visible = false
		zone.add_child(receipt)
		_stop_visuals[zone] = receipt
	for destination_label in delivery_zone.find_children("*", "Label3D", false, false):
		if destination_label == _stop_visuals[delivery_zone]:
			continue
		destination_label.text = "201호 · 택배 1개"
		destination_label.font_size = 32
		destination_label.position.y = 1.5
	for sign in $Presentation.find_children("*", "Label3D", true, false):
		if sign.text.begins_with("HELL DELIVERY\n출발"):
			sign.text = "HELL DELIVERY\n출발 · 택배 %d개" % _total_target()
	_update_stops()

func _total_target() -> int:
	return delivery_zone.target_package_count + second_zone.target_package_count

func _delivered_total() -> int:
	return delivery_zone.delivered_count + second_zone.delivered_count

func _configure_goal() -> void:
	var destination := "2층 201호·202호 (상자 주소에 맞춰 배송)"
	delivery_hud.configure_delivery_goal(_total_target(), destination)
	delivery_hud.update_progress(_delivered_total(), _total_target())
	onboarding_overlay.configure_delivery_goal(_total_target(), destination)
	$UI/PauseMenu.controls_panel.configure_delivery_goal(_total_target(), destination)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_update_stops()

func _update_stops() -> void:
	for zone in [delivery_zone, second_zone]:
		for destination_label in zone.find_children("*", "Label3D", false, false):
			destination_label.visible = (zone.delivered_count > 0) if destination_label == _stop_visuals.get(zone) else (zone.delivered_count == 0)
	var held := player.held_grabbable as Package
	var carrying := ("운반 중: %s호 | " % held.delivery_address) if held != null and not held.is_delivered() else "상자 주소에 맞춰 배송 | "
	if held == null and _delivered_total() == 1:
		var pending: Package = $Gameplay/Package if not $Gameplay/Package.is_delivered() else $Gameplay/Package202
		var at_truck := pending.position.distance_to(Vector3(0, 0.5, -9.3)) < 4.0
		carrying = ("트럭으로 돌아가 %s호 택배를 가져오세요 | " if at_truck else "남은 %s호 택배를 다시 잡으세요 · F5 복구 | ") % pending.delivery_address
	var progress := "201호 %s · 202호 %s" % ["완료" if delivery_zone.delivered_count > 0 else "대기", "완료" if second_zone.delivered_count > 0 else "대기"]
	delivery_hud.get_node("RouteLabel").text = carrying + progress

func _on_package_delivered(package: RigidBody3D, _delivered_count: int, _target_count: int) -> void:
	_delivery_details.append("%s호  배송 완료 · %s" % [package.delivery_address, completion_overlay._format_time(_play_time_elapsed)])
	var zone: DeliveryZone = delivery_zone if package.delivery_address == "201" else second_zone
	zone.get_node("MeshInstance3D").material_override.albedo_color = Color(0.2, 0.35, 0.36, 0.65)
	delivery_hud.update_progress(_delivered_total(), _total_target())
	delivery_hud.show_delivery_toast("%s호 배송 완료!" % package.delivery_address)
	delivery_hud.show_goal()
	_feedback.play_cue("delivery")
	_update_stops()

func _on_wrong_address(package: RigidBody3D, zone: DeliveryZone) -> void:
	if Time.get_ticks_msec() - _last_rejection_ms < 1500:
		return
	_last_rejection_ms = Time.get_ticks_msec()
	var address: String = package.delivery_address if package is Package else "주소 없음"
	delivery_hud.show_delivery_toast("여기는 %s호입니다. 이 상자는 %s호로 배달하세요." % [zone.delivery_address, address])

func _on_all_packages_delivered() -> void:
	if _delivered_total() < _total_target() or _completion_requested:
		return
	_completion_requested = true
	completion_overlay.show_completion.call_deferred(_total_target(), _play_time_elapsed, "\n".join(_delivery_details))
