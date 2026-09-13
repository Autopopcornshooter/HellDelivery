class_name FreightRun
extends Node

# One physical route and tunable prototype evaluation. No persistent economy.
const LIMITS := {"standard": 480.0, "bulk": 720.0, "team": 720.0, "mixed": 660.0, "appliance": 540.0, "apartment": 480.0, "mansion": 480.0}
# villa-79: 노선이 셋(빌라/아파트/대저택)으로 늘면서, 노선마다 다른 좌표/문구를 개별 불리언
# 대신 하나의 표에서 조회한다 — 빌라 값은 기존 상수와 완전히 같아 회귀가 없다.
const ROUTE_DEFAULTS := {
	"pickup_center": Vector3(-7, 0.65, -72), "player_spawn_z": -71.0,
	"walk_in": Vector3(-4, 1, -13), "walk_spacing": 2.6, "arrived_recovery": Vector3(-4, 1, -12),
	"drive_hint": "빌라 ↑ · 표시된 주차 구역에 정차", "delivery_hint": "2층 201·202호",
}
const ROUTES := {
	"apartment": {
		"pickup_center": Vector3(-1, 0.65, -42), "player_spawn_z": -44.0,
		"walk_in": Vector3(-3, 1, 2), "walk_spacing": 2.0, "arrived_recovery": Vector3(-3, 1, 5),
		"drive_hint": "행복아파트 ↑ · 표시된 주차 구역에 정차", "delivery_hint": "6층 604호",
	},
	"mansion": {
		"pickup_center": Vector3(-1, 0.65, -34), "player_spawn_z": -36.0,
		"walk_in": Vector3(-3, 1, -16), "walk_spacing": 2.0, "arrived_recovery": Vector3(-3, 1, -14),
		"drive_hint": "대저택 ↑ · 정원 입구 주차 구역에 정차", "delivery_hint": "정원 안쪽 현관",
	},
}
var session: Node
var level: Node
var truck: DeliveryVan
var parcels: Array[Package] = []
var deadline := 480.0
var _park_position := Vector3.ZERO # villa-77: 노선마다 다른 적재소/주차 위치를 쓸 수 있도록 depot에서 읽어 저장한다.
var _depot_start := Vector3.ZERO
var _pickup_center := Vector3.ZERO
var stage := "적재"
var arrived := false
var recoveries := 0
var wrong_address_attempts := 0 # 반복 플레이 동기부여용 "정확도" 신호(안 2) — 완벽 배송 배지 판정에만 쓰인다.
var result: Dictionary = {}
const LOW_TIME_WARNING_SECONDS := 60.0 # TODO: 프로토타입 값, 튜닝 필요 - 남은 시간이 이 아래로 내려가면 1회 경고음
var _low_time_warned := false
var _truck_target := Transform3D.IDENTITY
var _normal_masks: Array[int] = []
var _normal_layers: Array[int] = []
var _exit_frames: Array[int] = [0, 0, 0, 0]

func _route(key: String):
	return ROUTES.get(session.order_id, {}).get(key, ROUTE_DEFAULTS[key])

func _ready() -> void:
	level = get_parent()
	deadline = LIMITS.get(session.order_id, 480.0)
	# villa-77/79: 빌라 외에 다른 노선(아파트/대저택)이 생기면서, 이 레벨에만 있던 장식 정리/
	# 적재소/좌표들을 노선별로 나눴다 — 빌라 쪽 값은 전부 원래 그대로다(if-분기의 else 그대로 유지).
	var neighborhood: Node = level.get_node_or_null("Neighborhood")
	if neighborhood != null:
		for child in neighborhood.get_children():
			if not child is Node3D: continue
			if "Truck" in str(child.name) or child.position.distance_to(Vector3(0, 2.15, -8.62)) < 0.1 or child.position.distance_to(Vector3(0, 0.01, -9.3)) < 0.1 or (child.position.z <= -32 and absf(child.position.x) < 1):
				neighborhood.remove_child(child)
				child.queue_free()
	var depot: Node3D
	match session.order_id:
		"apartment": depot = ApartmentDepot.new()
		"mansion": depot = MansionDepot.new()
		_: depot = FreightDepot.new()
	depot.name = "FreightDepot"
	level.add_child(depot)
	match session.order_id:
		"apartment": _park_position = ApartmentDepot.PARK; _depot_start = ApartmentDepot.START
		"mansion": _park_position = MansionDepot.PARK; _depot_start = MansionDepot.START
		_: _park_position = FreightDepot.PARK; _depot_start = FreightDepot.START
	truck = DeliveryVan.new()
	truck.name = "DeliveryVan"
	truck.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	truck.position = _depot_start
	truck.authority = session.hosting
	truck._audio = level._feedback
	level.add_child(truck)
	truck.freeze = not session.hosting
	if not session.hosting:
		truck.collision_layer = 0
		truck.collision_mask = 0
	truck.set_door(true)
	_truck_target = truck.transform
	_pickup_center = _route("pickup_center")
	var index := 0
	for body in session._bodies():
		if not body is Package: continue
		parcels.append(body)
		body.enable_shipment(session.hosting, level._feedback)
		body.position = _pickup_center + Vector3((index % 2) * 1.8, 0, -(index / 2) * 1.8)
		level._spawn_transforms[body] = body.transform
		index += 1
	var player_spawn_z: float = _route("player_spawn_z")
	for slot in 4:
		var courier: Player = session._players()[slot]
		courier.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
		courier.position = Vector3([-4, -2, 2, 4][slot], 1, player_spawn_z)
		courier.rotation.y = PI
		if courier.visible and session.hosting: courier.collision_mask |= 8
		_normal_masks.append(courier.collision_mask)
		_normal_layers.append(courier.collision_layer)
		set_spawn(slot, courier.transform)
	for zone in level.destinations:
		zone.accepting_deliveries = false
		# Counts every rejected delivery attempt at this zone as a mistake, on top
		# of the existing rejection toast (_on_wrong_address) -- purely additive,
		# does not change what already happens when a package is rejected.
		zone.package_rejected.connect(_on_delivery_mistake)
	var presentation: Node = level.get_node_or_null("Presentation")
	if presentation != null:
		for sign in presentation.find_children("*", "Label3D", true, false):
			if sign.text.begins_with("HELL DELIVERY\n출발"): sign.text = "빌라 도착\n왼쪽 골목 → 2층 배송"
	level.delivery_hud.goal_timer.stop()

func _on_delivery_mistake(_package: RigidBody3D) -> void:
	if not session.hosting: return # Only the authoritative host's count feeds evaluate().
	wrong_address_attempts += 1

func set_spawn(slot: int, at: Transform3D) -> void:
	if slot == 0: level._player_spawn = at
	elif slot == 1: level._second_spawn = at
	else: level.extra_spawns[slot - 2] = at

func control(slot: int, move: Vector2, brake: bool) -> bool:
	var seat := truck.seat_of(slot)
	if seat < 0: return false
	if seat == 0:
		truck.throttle = -move.y
		truck.steer_input = move.x
		# Only the brake button engages hard braking; releasing the accelerator
		# alone should coast, not slam to a stop (see DeliveryVan.COAST_DRAG).
		truck.braking = brake
	return true

func action(slot: int, kind: String) -> String:
	if not session.hosting or not session.active or session.finished: return ""
	var courier: Player = session._players()[slot]
	if kind == "door":
		if truck.linear_velocity.length() > 0.8: return "정차한 뒤 화물 문을 조작하세요"
		if courier.global_position.distance_to(truck.to_global(Vector3(0, 1, -3.1))) > 3.0: return "트럭 뒤 화물 문 가까이에서 E"
		# Do not close a solid door over a parcel/person in its swept area.
		if truck.door_open:
			for body in parcels:
				var at := truck.to_local(body.global_position)
				if not body.is_delivered() and absf(at.x) < 1.6 and at.z < -2.65 and at.z > -5.3 and at.y < 3.5: return "문 주변 택배를 먼저 옮겨주세요"
			for other_slot in session.occupied_slots():
				var at: Vector3 = truck.to_local(session._players()[other_slot].global_position)
				if absf(at.x) < 1.6 and at.z < -2.65 and at.z > -5.3: return "문 주변에서 옆으로 비켜선 뒤 닫아주세요"
		truck.set_door(not truck.door_open)
		return "화물 문 열림 · 주행 중 낙하 주의" if truck.door_open else "화물 문 닫힘"
	if kind != "seat": return ""
	if truck.linear_velocity.length() > 0.8: return "차량이 멈춘 뒤 탑승·하차하세요"
	var seat := truck.seat_of(slot)
	if seat >= 0:
		if not exit_seat(slot): return "하차 공간이 막혀 있습니다 · 조금 이동하거나 내 위치 복구"
		return "하차했습니다"
	if courier.global_position.distance_to(truck.global_position) > 5: return "트럭 가까이에서 F로 탑승하세요"
	if courier.held_grabbable != null: return "택배를 먼저 내려놓고 탑승하세요"
	seat = truck.seats.find(-1)
	if seat < 0: return "빈 좌석이 없습니다"
	truck.seats[seat] = slot
	_sync_seats()
	return "운전석 · WASD 운전 / Space 브레이크 / F 하차" if seat == 0 else "동승석 · 정차 후 F 하차"

func exit_seat(slot: int, emergency := false) -> bool:
	var seat := truck.seat_of(slot)
	if seat < 0:
		if emergency:
			_exit_frames[slot] = 3
			_sync_seats()
		return true
	var courier: Player = session._players()[slot]
	var point := Vector3.ZERO
	var found := false
	for side in [-1, 1]:
		var candidate := truck.to_global(Vector3(side * 2.35, 1.0, 1.8 if seat < 2 else 0.0))
		var ray := PhysicsRayQueryParameters3D.create(candidate + Vector3.UP * 2, candidate - Vector3.UP * 4, 1)
		var ground := truck.get_world_3d().direct_space_state.intersect_ray(ray)
		if ground.is_empty(): continue
		candidate.y = ground.position.y + 1.08
		var reserved := false
		for other in session.occupied_slots():
			if other != slot and truck.seat_of(other) < 0 and session._players()[other].global_position.distance_to(candidate) < 0.9: reserved = true
		if reserved: continue
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = courier.get_node("CollisionShape3D").shape
		query.transform = Transform3D(Basis.IDENTITY, candidate)
		query.collision_mask = 31
		query.exclude = [courier.get_rid(), truck.get_rid()]
		if not truck.get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty(): continue
		point = candidate
		found = true
		break
	if not found and not emergency: return false
	_exit_frames[slot] = 3
	truck.seats[seat] = -1
	if seat == 0: truck.throttle = 0; truck.braking = true
	_sync_seats()
	if found: courier.global_position = point
	courier.velocity = Vector3.ZERO
	courier.grab_collision_barrier.global_transform = courier.global_transform
	return true

func _sync_seats() -> void:
	for slot in 4:
		var courier: Player = session._players()[slot]
		var seated := truck.seat_of(slot) >= 0
		var isolated := seated or _exit_frames[slot] > 0
		courier.set_physics_process(session.hosting and session.active and courier.visible and not isolated and not session.finished)
		courier.collision_layer = 0 if isolated else _normal_layers[slot]
		courier.collision_mask = 0 if isolated else _normal_masks[slot]
		courier.grab_collision_barrier.collision_layer = 0 if isolated or not courier.visible else 32
		courier.grab_collision_barrier.sync_to_physics = not isolated
		courier.network_move = Vector2.ZERO if seated else courier.network_move
		courier.network_grab = false if seated else courier.network_grab
		# 좁은 운전석 모델에 캐릭터가 그대로 앉으면 앞유리/지붕 밖으로 몸이 튀어나와 보인다
		# (사용자 실제 플레이 발견) — 탑승 중에는 캐릭터 외형만 숨기고(콜리전/물리는 그대로),
		# 하차하면 원래대로 되돌린다.
		courier.character_visual.visible = not seated
	var own_seated := truck.seat_of(session.local_slot) >= 0
	var active_camera: Camera3D = truck.camera if own_seated else session._players()[session.local_slot].camera_pivot.get_node("Camera3D")
	if not active_camera.current: active_camera.make_current()

func tick() -> void:
	if not session.hosting or not session.active or session.finished: return
	truck.enabled = true
	for slot in 4: _exit_frames[slot] = maxi(0, _exit_frames[slot] - 1)
	for parcel in parcels:
		if not parcel.is_delivered() and parcel.global_position.y < -8: parcel.mark_lost()
		if truck.cargo_contains(parcel) and not parcel.loaded_once:
			parcel.loaded_once = true
			if parcel._audio: parcel._audio.play_cue("scan")
	if truck.global_position.y < -8: recover()
	if Vector2(truck.position.x - _park_position.x, truck.position.z - _park_position.z).length() < 6 and truck.linear_velocity.length() < 0.8:
		arrived = true
		var walk_in: Vector3 = _route("walk_in")
		var walk_spacing: float = _route("walk_spacing")
		for slot in 4: set_spawn(slot, Transform3D(Basis(Vector3.UP, PI), walk_in + Vector3(slot * walk_spacing, 0, 0)))
	for zone in level.destinations: zone.accepting_deliveries = arrived
	stage = "배송" if arrived else ("운전" if parcels.all(func(p): return p.loaded_once or p.shipment_failed) else "적재")
	_sync_seats()
	var resolved := parcels.filter(func(p): return p.is_delivered() or p.shipment_failed).size()
	if truck.health <= 0:
		session.finish_freight("차량 파손 · 운행 불가")
	elif level._play_time_elapsed >= deadline:
		session.finish_freight("시간 초과")
	elif resolved == parcels.size():
		session.finish_freight("배송 완료" if level._delivered_total() == level._total_target() else "택배 파손·분실")

func recover() -> void:
	for slot in session.occupied_slots(): exit_seat(slot, true)
	recoveries += 1
	truck.recover(Transform3D(Basis.IDENTITY, _park_position + Vector3(0, 0.12, 0) if arrived else _depot_start))
	truck.set_door(true)
	var arrived_recovery: Vector3 = _route("arrived_recovery")
	for index in parcels.size():
		var parcel := parcels[index]
		if not parcel.is_delivered() and not parcel.shipment_failed:
			parcel.recover_to(Transform3D(Basis.IDENTITY, arrived_recovery + Vector3(-index * 1.1, 0, 0) if arrived else _pickup_center + Vector3((index % 2) * 1.8, 0.35, -(index / 2) * 1.8)))
	for slot in session.occupied_slots(): level.recover_slot(slot)

func snapshot() -> Dictionary:
	return {"truck": truck.transform, "velocity": truck.linear_velocity, "door": truck.door_open, "seats": truck.seats, "health": truck.health, "arrived": arrived, "stage": stage, "recoveries": recoveries, "parcels": parcels.map(func(p): return p.shipment_state())}

func apply_snapshot(data: Dictionary) -> void:
	if data.is_empty(): return
	_truck_target = data.truck
	truck.linear_velocity = data.velocity
	truck.set_door(data.door)
	truck.seats.assign(data.seats)
	# Non-hosting clients never run DeliveryVan's own physics-authoritative damage
	# check (authority is false for them), so this mirrors the impact VFX from the
	# synced health value, matching the same pattern used for Package damage.
	if data.health < truck.health:
		ImpactEffect.spawn(level, truck.global_position + Vector3.UP * 1.0, Color(1.0, 0.55, 0.2))
		if truck._audio: truck._audio.play_cue("damage")
		truck._shake_intensity = clampf((truck.health - data.health) / 20.0, 0.0, 1.0) * 0.15
	truck.health = data.health
	arrived = data.arrived
	stage = data.stage
	recoveries = data.recoveries
	for index in parcels.size(): parcels[index].apply_shipment_state(data.parcels[index])
	_sync_seats()

func evaluate(reason: String) -> Dictionary:
	var delivered: int = level._delivered_total()
	var quality := 0.0
	var failed := 0
	var cooperation := false
	for parcel in parcels:
		if parcel.is_delivered(): quality += parcel.condition
		if parcel.shipment_failed: failed += 1
		cooperation = cooperation or parcel.teamwork
	var success: bool = delivered == parcels.size() and level._play_time_elapsed < deadline and truck.health > 0
	# Breakdown terms mirror the score formula below one-for-one so the result
	# screen can show "why" the score is what it is (반복 플레이 동기부여 안 1).
	# Each term is rounded on its own for display, so it can differ from the
	# single combined rounding of `score` by a point or two -- cosmetic only,
	# the score itself (and grade thresholds) are unchanged from before.
	var breakdown := {
		"delivery": roundi(700.0 * delivered / parcels.size()),
		"quality": roundi(2.0 * quality / parcels.size()),
		"time": roundi(100.0 * maxf(0, 1.0 - level._play_time_elapsed / deadline)),
		"vehicle": -(100 - roundi(truck.health)),
		"recovery": -recoveries * 50,
		"teamwork": 20 if cooperation else 0,
	}
	var score := roundi(700.0 * delivered / parcels.size() + 2.0 * quality / parcels.size() + 100.0 * maxf(0, 1.0 - level._play_time_elapsed / deadline) - (100 - truck.health) - recoveries * 50 + (20 if cooperation else 0))
	score = clampi(score, 0, 1000 if success else 599) if delivered > 0 else 0
	var grade := "F" if delivered == 0 else ("S" if success and score >= 900 else ("A" if success and score >= 750 else ("B" if success and score >= 550 else "C")))
	# Badges (안 2): each checks exactly one axis so they stay achievable on their
	# own -- time, accuracy/mistakes, and cooperation -- instead of one big
	# all-or-nothing condition. Purely informational, never saved, never affects score.
	var badges := {
		"lightning": delivered > 0 and level._play_time_elapsed <= deadline * 0.5, # TODO: 프로토타입 값, 튜닝 필요
		"perfect": delivered == parcels.size() and quality >= 100.0 * delivered and wrong_address_attempts == 0 and recoveries == 0,
		"teamwork": cooperation,
	}
	return {"success": success, "reason": reason, "score": score, "grade": grade, "delivered": delivered, "total": parcels.size(), "failed": failed, "quality": quality / maxi(delivered, 1), "vehicle": truck.health, "recoveries": recoveries, "elapsed": level._play_time_elapsed, "teamwork": cooperation, "breakdown": breakdown, "badges": badges, "wrong_address_attempts": wrong_address_attempts}

func stop() -> void:
	truck.enabled = false
	truck.freeze = true
	for parcel in parcels: parcel.damage_authority = false

func _process(delta: float) -> void:
	if not is_instance_valid(truck) or not session.active: return
	if not _low_time_warned and not session.finished and deadline - level._play_time_elapsed <= LOW_TIME_WARNING_SECONDS:
		_low_time_warned = true
		level._feedback.play_cue("warning")
	if not session.hosting:
		truck.transform = truck.transform.interpolate_with(_truck_target, 1 - exp(-25 * delta)) if truck.position.distance_to(_truck_target.origin) < 4 else _truck_target
	for seat in 4:
		var slot := truck.seats[seat]
		if slot < 0: continue
		var courier: Player = session._players()[slot]
		courier.global_position = truck.seat_position(seat)
		courier.rotation.y = truck.rotation.y + PI
		courier.velocity = Vector3.ZERO
		courier.character_visual.animation_controller.update_locomotion(0, false, true)
	if session.finished: return
	var remaining: float = maxf(0, deadline - level._play_time_elapsed)
	var loaded := parcels.filter(func(p): return p.loaded_once).size()
	var drive_hint: String = _route("drive_hint")
	var delivery_hint: String = _route("delivery_hint")
	level.delivery_hud.goal_label.text = "%s · %s · 남은 %s" % [stage, ("적재 확인 %d/%d" % [loaded, parcels.size()]) if stage == "적재" else (drive_hint if stage == "운전" else delivery_hint), DeliveryOrders.format_time(remaining)]
	level.delivery_hud.goal_label.show()
	var seat := truck.seat_of(session.local_slot)
	level.delivery_hud.get_node("HelpLabel").text = "WASD 운전 · Space 브레이크 · F 하차 | 차량 %d%% · %d km/h" % [truck.health, truck.linear_velocity.length() * 3.6] if seat >= 0 else "WASD 이동 · 클릭 잡기 · Tab 상태 · Esc 메뉴"
	_update_context_prompt(seat)

# 품질 업그레이드: "F 탑승 · E 화물문"을 항상 띄우는 대신, 실제로 그 동작이 가능한 트럭의
# 해당 부위(탑승은 앞부분, 화물 문은 뒷부분) 가까이에 있을 때만 크로스헤드 옆에 표시한다.
# action()이 실제로 사용하는 것과 정확히 같은 기준점/반경을 재사용해 "표시는 되는데 안 눌린다"가
# 생기지 않게 한다.
func _update_context_prompt(seat: int) -> void:
	if seat >= 0 or truck.linear_velocity.length() > 0.8:
		level.delivery_hud.hide_context_prompt()
		return
	var courier: Player = session._players()[session.local_slot]
	var local_pos := truck.to_local(courier.global_position)
	if local_pos.z <= 0.0 and courier.global_position.distance_to(truck.to_global(Vector3(0, 1, -3.1))) <= 3.0:
		level.delivery_hud.show_context_prompt(("E 화물 문 닫기" if truck.door_open else "E 화물 문 열기"))
	elif local_pos.z > 0.0 and courier.global_position.distance_to(truck.global_position) <= 5.0 and courier.held_grabbable == null:
		level.delivery_hud.show_context_prompt("F 탑승")
	else:
		level.delivery_hud.hide_context_prompt()
