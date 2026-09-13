extends "res://scenes/level/PrototypeLevel.gd"

# "엘리베이터 고장 아파트" 배송 노선의 온라인 레벨 스크립트. VillaCoopLevel.gd/OnlineLevel.gd와
# 같은 역할(최대 4인 스폰, 온라인 세션이 기대하는 범용 인터페이스 제공)을 하지만, 그 두 스크립트는
# 빌라 전용 다중 목적지(201/202) 로직이 함께 있어 그대로 상속할 수 없다 — 이 레벨은 목적지가
# 하나뿐이라(TARGET_DOOR) PrototypeLevel.gd의 기본 단일 배송 동작을 그대로 쓰고, 그 위에 온라인
# 세션이 요구하는 다인원 스캐폴딩만 추가한다.
var order_id := "apartment"
var destinations: Array[DeliveryZone] = []
var player2: Player
var couriers: Array[Player] = []
var extra_spawns: Array[Transform3D] = []
var extra_audio: Array[LevelAudio] = []
var _second_spawn: Transform3D
var _second_feedback: LevelAudio
var _delivery_details: PackedStringArray = []


func _ready() -> void:
	var building: ApartmentBuilding = $Environment/Building
	delivery_zone.destination_id = DeliveryOrders.APARTMENT_604
	delivery_zone.display_name = "604호"
	delivery_zone.destination_name = "행복아파트 6층 604호"
	delivery_zone.target_package_count = 1
	delivery_zone.global_position = building.door_position
	destinations = [delivery_zone]
	var package: Package = $Gameplay/Package
	package.configure_destination(DeliveryOrders.APARTMENT_604, "604호")
	player2 = preload("res://scenes/player/Player.tscn").instantiate()
	player2.name = "Player2"
	player2.player_slot = 1
	player2.input_profile = Player.InputProfile.GAMEPAD
	player2.position = Vector3(-1.5, 1, 2)
	player2.rotation.y = PI
	$Gameplay.add_child(player2)
	super._ready()
	player2.collision_mask = player.collision_mask
	player2.floor_snap_length = player.floor_snap_length
	$UI/PauseMenu.controls_panel.configure_coop()
	_feedback.player_pan = -0.55
	_second_feedback = LevelAudio.new()
	_second_feedback.name = "Player2Audio"
	_second_feedback.player_pan = 0.55
	add_child(_second_feedback)
	_second_spawn = player2.global_transform
	couriers = [player, player2]
	for slot in range(2, 4):
		var courier: Player = preload("res://scenes/player/Player.tscn").instantiate()
		courier.name = "Player%d" % (slot + 1)
		courier.player_slot = slot
		courier.input_profile = Player.InputProfile.NETWORK
		courier.collision_mask = player.collision_mask
		courier.floor_snap_length = player.floor_snap_length
		courier.position = Vector3(-3.5 if slot == 2 else 3.5, 1, 2)
		courier.rotation.y = PI
		$Gameplay.add_child(courier)
		couriers.append(courier)
		extra_spawns.append(courier.global_transform)
		var audio := LevelAudio.new()
		audio.name = "Player%dAudio" % (slot + 1)
		add_child(audio)
		extra_audio.append(audio)


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


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_second_feedback.update_player(player2, delta)
	if player2.global_position.y < FALL_LIMIT:
		_recover_second()
	for index in extra_audio.size():
		var courier: Player = couriers[index + 2]
		if not courier.visible: continue
		extra_audio[index].update_player(courier, delta)
		if courier.global_position.y < FALL_LIMIT: recover_slot(index + 2)
	_update_stops()


func _update_stops() -> void:
	# OnlineSession이 스냅샷 동기화 시 범용적으로 호출한다(villa OnlineLevel.gd와 동일한 훅).
	# 목적지가 하나뿐이라 빌라만큼 복잡한 라벨 갱신은 필요 없고, 상태 요약 문구만 갱신한다.
	var carriers: Array[String] = []
	for slot in couriers.size():
		if couriers[slot].visible: carriers.append("P%d %s" % [slot + 1, _carrying(couriers[slot])])
	var status: String = "604호 완료" if delivery_zone.delivered_count > 0 else "604호 배송 대기"
	delivery_hud.get_node("RouteLabel").text = " | ".join(carriers) + " | " + status


func _carrying(courier: Player) -> String:
	var parcel := courier.held_grabbable as Package
	return "%s 운반" % parcel.display_name if parcel != null and not parcel.is_delivered() else "빈손"


func recover_slot(slot: int) -> void:
	if slot == 0: recover_player(); return
	if slot == 1: _recover_second(); return
	var courier: Player = couriers[slot]
	if courier.held_grabbable != null: courier.held_grabbable.remove_grabber(courier)
	courier.global_transform = extra_spawns[slot - 2]
	courier.velocity = Vector3.ZERO
	courier.camera_pivot.rotation = Vector3.ZERO
	courier.grab_collision_barrier.global_transform = courier.global_transform
	courier.reset_physics_interpolation()
	courier.character_visual.animation_controller.reset()


func recover_all() -> void:
	super.recover_all()
	_recover_second()
	for slot in range(2, couriers.size()): recover_slot(slot)


func _recover_second() -> void:
	if player2.held_grabbable != null:
		player2.held_grabbable.remove_grabber(player2)
	player2.global_transform = _second_spawn
	player2.velocity = Vector3.ZERO
	player2.camera_pivot.rotation = Vector3.ZERO
	player2.grab_collision_barrier.global_transform = _second_spawn
	player2.reset_physics_interpolation()
	player2.character_visual.animation_controller.reset()


func _on_package_delivered(package: RigidBody3D, delivered_count: int, target_count: int) -> void:
	super._on_package_delivered(package, delivered_count, target_count)
	_delivery_details.append("%s 배송 완료 · %s" % [delivery_zone.display_name, completion_overlay._format_time(_play_time_elapsed)])


func _on_all_packages_delivered() -> void:
	pass # 온라인 메뉴는 화면을 일시정지/완료 연출로 막지 않는다(OnlineLevel.gd와 동일한 이유).
