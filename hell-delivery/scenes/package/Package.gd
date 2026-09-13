class_name Package
extends GrabbableBody

@export var destination_id: String = "" # DeliveryZone.destination_id와 매칭되는 배송지 키(예: "villa_2f_201").
@export var display_name: String = "" # 짧은 표시용 라벨(예: "201호"). UI/매니페스트는 이 값만 사용한다.
@export var damage_impact_threshold := 3.5 # TODO: 프로토타입 값, 튜닝 필요 - 이 값을 넘는 충격부터 파손 시작(특수 택배는 DeliveryOrders.KIND_PRESETS로 재설정)
@export var damage_impact_multiplier := 8.0 # TODO: 프로토타입 값, 튜닝 필요
@export var carried_damage_grace_multiplier := 1.5 # TODO: 프로토타입 값, 튜닝 필요 - 실제로 들고 있는 동안(계단 모서리 등에 스치는 정도)은 자유낙하/투척보다 관대하게 판정. 실측: 계단으로 직접 들고 나르다 impact 4.23이 기본 임계값 3.5를 살짝 넘겨 파손된 사례(WINDOWS_PLAYTEST villa-51 실제 완주 검증).
var condition := 100.0
var shipment_failed := false
var failure_reason := ""
var damage_enabled := false
var damage_authority := false
var loaded_once := false
var teamwork := false
var _damage_cooldown := 1.0
var _condition_label: Label3D
var _teleport_frames := 0
var _restore_mask := 0
var _restore_layer := 0
var _audio: LevelAudio

func recover_to(at: Transform3D) -> void:
	if not damage_enabled:
		super.recover_to(at)
		return
	if is_delivered() or _recovery_pending or _teleport_frames > 0: return
	super.recover_to(at)
	# A CCD parcel moved across the map must not sweep through its old van.
	# Disable contact for the teleport, then restore it at the new location.
	_restore_mask = collision_mask
	_restore_layer = collision_layer
	collision_mask = 0
	collision_layer = 0
	_teleport_frames = 3

func enable_shipment(authority: bool, audio: LevelAudio = null) -> void:
	damage_enabled = true
	damage_authority = authority
	_audio = audio
	if authority: collision_mask |= 8
	_condition_label = Label3D.new()
	_condition_label.position.y = 0.8
	_condition_label.font_size = 24
	_condition_label.pixel_size = 0.0025
	_condition_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(_condition_label)
	_update_condition_label()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var recovering := _recovery_pending
	super._integrate_forces(state)
	if _teleport_frames > 0:
		_teleport_frames -= 1
		if _teleport_frames == 0:
			collision_mask = _restore_mask
			collision_layer = _restore_layer
	if recovering: _damage_cooldown = 0.8
	if not damage_enabled or not damage_authority or is_delivered() or shipment_failed: return
	teamwork = teamwork or get_grabber_count() >= 2
	_damage_cooldown = maxf(0, _damage_cooldown - state.step)
	if _damage_cooldown > 0: return
	var impulse := Vector3.ZERO
	for index in state.get_contact_count():
		impulse += state.get_contact_impulse(index)
	var impact := impulse.length() / mass
	var threshold := damage_impact_threshold * (carried_damage_grace_multiplier if get_grabber_count() > 0 else 1.0)
	if impact > threshold:
		if "freight-test" in OS.get_cmdline_user_args(): print("PARCEL_IMPACT ", name, " ", impact, " threshold=", threshold, " speed=", state.linear_velocity, " contacts=", get_colliding_bodies())
		apply_damage((impact - threshold) * damage_impact_multiplier)
		_damage_cooldown = 0.4

func apply_damage(amount: float) -> void:
	if not damage_enabled or not damage_authority or is_delivered() or shipment_failed: return
	var before := condition
	condition = clampf(condition - maxf(0, amount), 0, 100)
	if condition <= 0:
		shipment_failed = true
		failure_reason = "파손"
	if condition < before:
		ImpactEffect.spawn(get_parent(), global_position + Vector3.UP * 0.3, Color(1.0, 0.55, 0.2))
		if _audio: _audio.play_cue("failure" if shipment_failed else "damage")
		DeliveryHUD.flash_damage_all(get_tree())
	_update_condition_label()

func mark_lost() -> void:
	if is_delivered() or shipment_failed: return
	shipment_failed = true
	failure_reason = "분실"
	for holder in grab_connections.keys(): remove_grabber(holder)
	freeze = true
	visible = false
	if _audio: _audio.play_cue("failure")
	_update_condition_label()

func shipment_state() -> Array:
	return [condition, shipment_failed, failure_reason, loaded_once, teamwork]

func deliver() -> void:
	super.deliver()
	_update_condition_label()

func apply_shipment_state(data: Array) -> void:
	# Non-hosting clients never run the physics-authoritative apply_damage() above
	# (damage_authority is false for them), so this mirrors it from the synced
	# condition value to still show the damage VFX on their own screen.
	var before := condition
	var was_loaded := loaded_once
	var was_failed := shipment_failed
	condition = data[0]
	shipment_failed = data[1]
	failure_reason = data[2]
	loaded_once = data[3]
	teamwork = data[4]
	if condition < before:
		ImpactEffect.spawn(get_parent(), global_position + Vector3.UP * 0.3, Color(1.0, 0.55, 0.2))
		if _audio: _audio.play_cue("damage")
		DeliveryHUD.flash_damage_all(get_tree())
	if shipment_failed and not was_failed and _audio: _audio.play_cue("failure")
	if loaded_once and not was_loaded and _audio: _audio.play_cue("scan")
	_update_condition_label()

func _update_condition_label() -> void:
	if _condition_label == null: return
	_condition_label.text = "%s · %s" % [display_name, failure_reason if shipment_failed else "%d%%" % roundi(condition)]
	_condition_label.modulate = Color("fa655b") if condition < 40 or shipment_failed else Color("fff0ba")
	_condition_label.visible = not is_delivered()

func _ready() -> void:
	super._ready()
	if destination_id != "":
		_add_shipping_labels()

func configure_destination(id: String, label: String) -> void:
	destination_id = id
	display_name = label
	var old := get_node_or_null("ShippingLabels")
	if old != null:
		remove_child(old)
		old.queue_free()
	if is_inside_tree() and destination_id != "":
		_add_shipping_labels()

func _add_shipping_labels() -> void:
	var labels := Node3D.new()
	labels.name = "ShippingLabels"
	add_child(labels)
	var paper := StandardMaterial3D.new()
	# Deterministic two-tone alternation per destination (purely cosmetic, no meaning beyond variety).
	paper.albedo_color = Color("e1eef0") if hash(destination_id) % 2 == 0 else Color("f0e4cb")
	for face in [Vector3(0, 0, 0.411), Vector3(0, 0, -0.411), Vector3(0.411, 0, 0), Vector3(-0.411, 0, 0), Vector3(0, 0.311, 0)]:
		var mount := Node3D.new()
		mount.position = face
		if face.y > 0:
			mount.rotation.x = -PI / 2
		else:
			mount.rotation.y = atan2(face.x, face.z)
		labels.add_child(mount)
		var board := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.56, 0.26, 0.008)
		mesh.material = paper
		board.mesh = mesh
		mount.add_child(board)
		var label := Label3D.new()
		label.text = display_name
		label.font_size = 48
		label.pixel_size = 0.003
		label.modulate = Color("263b3c")
		label.outline_size = 0
		label.position.z = 0.01
		mount.add_child(label)
