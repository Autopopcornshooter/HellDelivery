class_name DeliveryVan
extends VehicleBody3D

# Arcade prototype: the cargo remains independent rigid bodies, never parented
# or teleported with the van. Real front-wheel steering + rear-wheel drive via
# Godot's built-in VehicleBody3D/VehicleWheel3D (villa-62, replacing the earlier
# "no wheels, just apply_central_force + direct angular_velocity" prototype —
# 사용자 피드백: 지형에 걸림/속도감 부족/방향전환이 후륜구동+앞바퀴 조향이 아님).
const MODEL := preload("res://assets/environment/kenney_car-kit/Models/delivery.glb")
const ENGINE_FORCE_MAX := 3000.0 # TODO: 프로토타입 값, 튜닝 필요 - 속도감 개선(사용자 피드백 "속도감 있어도 될거같다")
const BRAKE_FORCE := 90.0 # TODO: 프로토타입 값, 튜닝 필요 - VehicleBody3D.brake 단위(바퀴별 제동력 배분). 지나치게 높은 값(관측: 220)은 오히려 정지 중 속도가 서서히 증가하는 불안정 현상을 유발해 중간값으로 조정.
const MAX_STEER_ANGLE := deg_to_rad(32.0) # TODO: 프로토타입 값, 튜닝 필요 - 실제 앞바퀴 조향각
const COAST_DRAG := 0.9 # TODO: 프로토타입 값, 튜닝 필요 - 가속 입력만 없을 때 자연 감속(구름 저항 보조, 제동과 구분)
const WHEEL_RADIUS := 0.55
const BODY_LEAN_MAX := deg_to_rad(3.5) # TODO: 프로토타입 값, 튜닝 필요 - 조향 시 관성으로 기울어지는 정도(순수 시각 효과, Collision/물리에는 영향 없음). 바퀴 펜더 여유가 좁아 9도는 바퀴가 차체 밖으로 튀어나와 보였다 -> 축소.
const BODY_LEAN_GAIN := 0.35
const BODY_LEAN_SMOOTH := 7.0
# Third-person free-look camera rig (PUBG-style): CameraPivot's rotation is
# driven directly in world space every frame (see _process), decoupled from
# the van's own steering rotation, so looking around never fights the wheel.
const CAMERA_DISTANCE := 6.5 # TODO: 프로토타입 값, 튜닝 필요
const CAMERA_HEIGHT := 0.6 # TODO: 프로토타입 값, 튜닝 필요 - CameraPivot 기준 추가 높이
const CAMERA_DEFAULT_PITCH := -0.22 # TODO: 프로토타입 값, 튜닝 필요 (약 -12.6도)
const CAMERA_COLLISION_MASK := 1 # World 레이어만 — Player/Package/PhysicsObject 등에는 카메라가 걸리지 않는다.
const CAMERA_COLLISION_MARGIN := 0.3 # TODO: 프로토타입 값, 튜닝 필요 - 벽/바닥 표면에서 카메라를 얼마나 띄워둘지
const CAMERA_MIN_DISTANCE_RATIO := 0.15 # TODO: 프로토타입 값, 튜닝 필요 - 좁은 공간에서도 카메라가 CameraPivot(운전석 근처)까지 완전히 붙지는 않도록 하는 최소 비율
var throttle := 0.0
var steer_input := 0.0 # -1..1 input; native VehicleBody3D.steering (radians) is derived from this each physics step.
var braking := true
var authority := true
var enabled := false
var door_open := false
var health := 100.0
var _audio: LevelAudio
var seats: Array[int] = [-1, -1, -1, -1]
var gate: CollisionShape3D
var gate_visual: MeshInstance3D
var camera: Camera3D
var camera_pivot: Node3D
var look_yaw := PI # PI matches this van's forward (+Z); consistent with on-foot local_yaw baseline.
var look_pitch := CAMERA_DEFAULT_PITCH
var _reset_pending := false
var _reset_transform := Transform3D.IDENTITY
var _impact_cooldown := 0.0
var _engine_audio: AudioStreamPlayer3D
var model: Node3D
var _body_lean := 0.0
var _wheel_visuals: Array[Dictionary] = [] # [{wheel: VehicleWheel3D, mesh: MeshInstance3D}, ...] -- 굴러가는 자연스러운 연출(회전)용.
var _shake_intensity := 0.0
const CAMERA_SHAKE_DECAY := 5.0 # TODO: 프로토타입 값, 튜닝 필요 - 충격 시 카메라 흔들림이 가라앉는 속도(품질 업그레이드: 타격감).
var _headlights: Array[SpotLight3D] = []

func _ready() -> void:
	mass = 1100.0
	can_sleep = false
	collision_layer = 8
	collision_mask = 31
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	continuous_cd = true
	contact_monitor = true
	max_contacts_reported = 16
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = 0.25
	model = MODEL.instantiate()
	model.scale = Vector3.ONE * 2
	add_child(model)
	var old_door := model.get_node_or_null("door")
	if old_door != null: old_door.hide()
	# 실제 조향/구름 연출이 있는 VehicleWheel3D 바퀴를 별도로 붙이므로, 모델에 원래 포함된
	# (회전하지 않는) 정적 바퀴 메시는 겹쳐 보이지 않도록 숨긴다.
	for wheel_node_name in ["wheel-front-right", "wheel-front-left", "wheel-back-right", "wheel-back-left"]:
		var old_wheel := model.get_node_or_null(wheel_node_name)
		if old_wheel != null: old_wheel.hide()
	_shape(Vector3(0, 0.68, 0), Vector3(2.5, 0.35, 5.8))
	_shape(Vector3(0, 1.0, -1.1), Vector3(2.5, 0.14, 3.8))
	_shape(Vector3(0, 1.35, 1.9), Vector3(2.5, 1.5, 2.0))
	for side in [-1, 1]:
		_shape(Vector3(side * 1.25, 2.0, -1.1), Vector3(0.15, 2, 4))
	_shape(Vector3(0, 3, -1.1), Vector3(2.5, 0.12, 4))
	# forward is +Z here (opposite Godot's default -Z): axle z=2.02 is the front
	# (steering) axle, z=-1.22 is the rear (traction) axle -- real RWD + front steering.
	for entry in [Vector2(2.02, 1), Vector2(-1.22, 0)]:
		var axle: float = entry.x
		var is_front: bool = entry.y > 0.5
		for side in [-1, 1]:
			var wheel := VehicleWheel3D.new()
			wheel.position = Vector3(side * 1.0, 0.55, axle)
			wheel.wheel_radius = WHEEL_RADIUS
			wheel.wheel_rest_length = 0.22
			wheel.suspension_travel = 0.22
			wheel.suspension_stiffness = 55.0
			wheel.damping_compression = 0.8
			wheel.damping_relaxation = 0.85
			wheel.wheel_friction_slip = 10.0
			wheel.use_as_traction = not is_front
			wheel.use_as_steering = is_front
			add_child(wheel)
			var visual := _wheel_visual()
			wheel.add_child(visual)
			_wheel_visuals.append({"wheel": wheel, "mesh": visual})
	gate = _shape(Vector3(0, 2, -3.05), Vector3(2.35, 2, 0.12))
	gate_visual = MeshInstance3D.new()
	var gate_mesh := BoxMesh.new()
	gate_mesh.size = Vector3(2.35, 2, 0.12)
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Color("f4cc55")
	gate_mesh.material = paint
	gate_visual.mesh = gate_mesh
	add_child(gate_visual)
	_set_gate()
	var plate := Label3D.new()
	plate.text = "HELL DELIVERY"
	plate.position = Vector3(0, 1.7, -3.13)
	plate.rotation.y = PI
	plate.font_size = 32
	plate.pixel_size = 0.004
	plate.outline_size = 0
	# Lettering follows the visible rear gate.
	gate_visual.add_child(plate)
	plate.position = Vector3(0, 0, -0.08)
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	camera_pivot.position = Vector3(0, 1.7, 0)
	# 이 카메라는 매 _process 프레임 회전/충격 셰이크를 직접 갱신한다(아래) — Physics Interpolation이
	# 그 값을 물리 틱 사이로 보간하면 화면이 번지는 잔상처럼 보일 수 있어(Player.gd에서 실제로 확인된
	# 문제와 동일 원인) 이 카메라는 보간 대상에서 제외한다.
	camera_pivot.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF
	camera = Camera3D.new()
	camera.name = "VehicleCamera"
	camera_pivot.add_child(camera)
	camera.position = Vector3(0, CAMERA_HEIGHT, CAMERA_DISTANCE)
	_engine_audio = AudioStreamPlayer3D.new()
	_engine_audio.name = "EngineAudio"
	_engine_audio.bus = "SFX"
	_engine_audio.stream = _engine_sound()
	_engine_audio.unit_size = 10
	_engine_audio.max_distance = 45
	_engine_audio.volume_db = -20
	add_child(_engine_audio)
	_engine_audio.play()
	# 헤드라이트(품질 업그레이드) — 차량이 "켜져 있다"는 시각적 신호. 엔진 활성 여부(enabled)에 맞춰
	# 매 프레임 밝기를 켜고 끈다(전조등 자체를 새 게임플레이 규칙으로 만들지 않는다 — 순수 장식).
	for side in [-1, 1]:
		var light := SpotLight3D.new()
		light.position = Vector3(side * 0.9, 0.85, 2.95)
		light.rotation.y = PI # SpotLight3D 기본 조사 방향은 -Z인데 이 차량 전방은 +Z라 180도 돌려야 앞을 비춘다(gate/plate 등 기존 코드와 동일한 관례).
		light.spot_range = 22.0
		light.spot_angle = 32.0
		light.light_color = Color("fff6e0")
		light.light_energy = 3.0
		light.shadow_enabled = false
		add_child(light)
		_headlights.append(light)

func _wheel_visual() -> Node3D:
	# 타이어(짙은 고무) + 안쪽 림(밝은 금속) + 허브캡 3단 구성으로 단순한 원기둥 하나보다
	# 실제 바퀴처럼 보이게 한다(사용자 요청 "바퀴 퀄리티 올려주고"). CylinderMesh의 기본
	# 굴대(Y)를 차량 좌우(X)로 맞추려면 Z축으로 90도 회전해야 한다(villa-64에서 확인).
	var root := Node3D.new()
	root.rotation.z = PI / 2
	var tire_mesh := CylinderMesh.new()
	tire_mesh.top_radius = WHEEL_RADIUS
	tire_mesh.bottom_radius = WHEEL_RADIUS * 0.96 # 살짝 테이퍼를 줘 타이어 옆면 볼록함 표현.
	tire_mesh.height = 0.34
	tire_mesh.radial_segments = 24
	var tire_material := StandardMaterial3D.new()
	tire_material.albedo_color = Color("161616")
	tire_material.roughness = 0.9
	tire_mesh.material = tire_material
	var tire := MeshInstance3D.new()
	tire.mesh = tire_mesh
	root.add_child(tire)
	var rim_mesh := CylinderMesh.new()
	rim_mesh.top_radius = WHEEL_RADIUS * 0.56
	rim_mesh.bottom_radius = WHEEL_RADIUS * 0.56
	rim_mesh.height = 0.36
	rim_mesh.radial_segments = 16
	var rim_material := StandardMaterial3D.new()
	rim_material.albedo_color = Color("c7cdd2")
	rim_material.metallic = 0.6
	rim_material.roughness = 0.35
	rim_mesh.material = rim_material
	var rim := MeshInstance3D.new()
	rim.mesh = rim_mesh
	root.add_child(rim)
	var hub_mesh := CylinderMesh.new()
	hub_mesh.top_radius = WHEEL_RADIUS * 0.14
	hub_mesh.bottom_radius = WHEEL_RADIUS * 0.14
	hub_mesh.height = 0.38
	hub_mesh.radial_segments = 12
	var hub_material := StandardMaterial3D.new()
	hub_material.albedo_color = Color("3a3f44")
	hub_mesh.material = hub_material
	var hub := MeshInstance3D.new()
	hub.mesh = hub_mesh
	root.add_child(hub)
	return root

func _shape(at: Vector3, size: Vector3) -> CollisionShape3D:
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	collider.position = at
	add_child(collider)
	return collider

func set_door(open: bool) -> void:
	door_open = open
	_set_gate()

func _set_gate() -> void:
	if gate == null: return
	var angle := deg_to_rad(-120) if door_open else 0.0
	gate.rotation.x = angle
	gate.position = Vector3(0, 1, -3.05) + Basis(Vector3.RIGHT, angle) * Vector3.UP
	gate_visual.transform = gate.transform

func _physics_process(_delta: float) -> void:
	if not authority or _reset_pending: return
	if not enabled:
		engine_force = 0.0
		brake = BRAKE_FORCE
		return
	# Empirically (verified via automated drive test), VehicleBody3D applies engine_force
	# directly along the chassis's own +Z here -- no sign flip needed despite this van's
	# forward being +Z (opposite Godot's usual -Z convention elsewhere in the project).
	engine_force = throttle * ENGINE_FORCE_MAX
	brake = BRAKE_FORCE if braking else 0.0
	steering = -clampf(steer_input, -1.0, 1.0) * MAX_STEER_ANGLE
	if not braking and absf(throttle) < 0.05:
		var forward := global_transform.basis.z
		apply_central_force(-forward * linear_velocity.dot(forward) * mass * COAST_DRAG)

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _reset_pending:
		state.transform = _reset_transform
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		_reset_pending = false
		_impact_cooldown = 1.0
	if not authority: return
	_impact_cooldown = maxf(0, _impact_cooldown - state.step)
	if _impact_cooldown <= 0:
		var total_impulse := Vector3.ZERO
		for index in state.get_contact_count():
			total_impulse += state.get_contact_impulse(index)
		var impulse := Vector2(total_impulse.x, total_impulse.z).length() / mass
		if impulse > 2.5:
			if "freight-test" in OS.get_cmdline_user_args(): print("VAN_IMPACT ", impulse, " speed=", state.linear_velocity, " contacts=", get_colliding_bodies())
			var before := health
			health = maxf(0, health - (impulse - 2.5) * 8)
			if health < before:
				ImpactEffect.spawn(get_parent(), global_position + Vector3.UP * 1.0, Color(1.0, 0.55, 0.2))
				if _audio: _audio.play_cue("damage")
				_shake_intensity = clampf((impulse - 2.5) / 10.0, 0.0, 1.0) * 0.15 # 충격 시 화면 흔들림(품질 업그레이드: 타격감).
			_impact_cooldown = 0.5

func recover(at: Transform3D) -> void:
	_reset_transform = at
	_reset_pending = true
	throttle = 0
	steer_input = 0
	steering = 0
	braking = true
	sleeping = false

func seat_of(slot: int) -> int:
	return seats.find(slot)

# Purely local/visual: each client drives its own camera from its own mouse
# input, so this never needs network replication.
func set_look(yaw: float, pitch: float) -> void:
	look_yaw = yaw
	look_pitch = pitch

func seat_position(seat: int) -> Vector3:
	return to_global(Vector3(-0.58 if seat % 2 == 0 else 0.58, 1.15, 1.9 if seat < 2 else 0.55))

func cargo_contains(body: Node3D) -> bool:
	var at := to_local(body.global_position)
	return absf(at.x) < 1.15 and at.z > -2.95 and at.z < 0.55 and at.y > 1.05 and at.y < 2.95

func _process(delta: float) -> void:
	camera_pivot.global_rotation = Vector3(look_pitch, look_yaw, 0)
	_engine_audio.pitch_scale = 0.65 + minf(linear_velocity.length() / 12, 1.0)
	_engine_audio.volume_db = -8 if enabled else -32 # TODO: 프로토타입 값, 튜닝 필요 - 사용자 실제 플레이 피드백("차소리 너무 작음")으로 -18 -> -8 상향
	# 조향 시 관성으로 살짝 기울어지는 시각 효과(사용자 요청) — 실제 각속도(angular_velocity.y)를
	# 기준으로 삼아 스티어링 부호를 다시 추론할 필요 없이 항상 실제 회전 방향과 일치시킨다.
	# Collision Shape/물리 Body는 그대로 두고 모델(Mesh)만 기울인다.
	var lean_target := clampf(angular_velocity.y * BODY_LEAN_GAIN, -BODY_LEAN_MAX, BODY_LEAN_MAX)
	_body_lean = lerp_angle(_body_lean, lean_target, 1.0 - exp(-BODY_LEAN_SMOOTH * delta))
	model.rotation.z = _body_lean
	# 뒷문(gate_visual)은 model의 자식이 아니라 별도 Collision 대응 Mesh라서, 차체가
	# 기울어질 때 같이 기울여주지 않으면 문만 수평으로 남아 튀어나와 보인다(사용자 실제 플레이 발견).
	# _set_gate()가 매번 새로 쓰는 것은 position/rotation.x(여닫힘)뿐이라 rotation.z만 덧붙여도 안전하다.
	gate_visual.rotation.z = _body_lean
	# 실제 구르는 느낌(사용자 요청 "좀 더 자연스러운 연출") — 각 바퀴의 실제 회전 속도(get_rpm())만큼
	# 메시 자신의 축(재배치 이전 기준 Y, rotate_object_local이라 재배치 회전과 무관하게 항상 굴대 방향)을 돌린다.
	for entry in _wheel_visuals:
		var wheel: VehicleWheel3D = entry.wheel
		var mesh: Node3D = entry.mesh
		mesh.rotate_object_local(Vector3.UP, wheel.get_rpm() * TAU / 60.0 * delta)
	for light in _headlights:
		light.light_energy = 3.0 if enabled else 0.0
	# 충격 시 화면 흔들림(품질 업그레이드) — 카메라 실제 위치는 그대로 두고 화면상 시야만
	# 짧게 흔든 뒤 감쇠한다. 순수 시각 효과라 조향/주행 물리와는 무관하다.
	_shake_intensity = move_toward(_shake_intensity, 0.0, CAMERA_SHAKE_DECAY * delta)
	var shake := Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake_intensity
	camera.position = _collision_safe_camera_offset() + Vector3(shake.x, shake.y, 0.0)

func _collision_safe_camera_offset() -> Vector3:
	# 자유 시점 카메라라 시점 회전에 따라 벽/바닥 뒤로 CameraPivot에서 멀리 떨어진 지점을
	# 그대로 카메라 위치로 쓰면 지형을 뚫고 들어가 보인다(사용자 실제 플레이 발견). 목표
	# 지점까지 Ray를 쏴 막혀 있으면 같은 방향을 유지한 채 거리(및 높이)를 비례해서 당겨온다.
	var desired_local := Vector3(0, CAMERA_HEIGHT, CAMERA_DISTANCE)
	var desired_world: Vector3 = camera_pivot.global_transform * desired_local
	var from := camera_pivot.global_position
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, desired_world, CAMERA_COLLISION_MASK, [get_rid()])
	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return desired_local
	var full_length := from.distance_to(desired_world)
	if full_length <= 0.001:
		return desired_local
	var hit_ratio := from.distance_to(hit.position) / full_length
	var ratio := clampf(hit_ratio - CAMERA_COLLISION_MARGIN / full_length, CAMERA_MIN_DISTANCE_RATIO, 1.0)
	return desired_local * ratio

func _engine_sound() -> AudioStreamWAV:
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = 22050
	sound.loop_mode = AudioStreamWAV.LOOP_FORWARD
	sound.loop_end = 22050
	var data := PackedByteArray()
	data.resize(44100)
	for index in 22050:
		var t := float(index) / 22050
		var sample := int((sin(TAU * 55 * t) * 0.55 + sin(TAU * 110 * t) * 0.25 + sin(TAU * 165 * t) * 0.1) * 5000)
		data.encode_s16(index * 2, sample)
	sound.data = data
	return sound
