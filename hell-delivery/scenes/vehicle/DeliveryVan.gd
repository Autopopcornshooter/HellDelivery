class_name DeliveryVan
extends RigidBody3D

# Arcade prototype: the cargo remains independent rigid bodies, never parented
# or teleported with the van. Forces accelerate/brake the chassis.
const MODEL := preload("res://assets/environment/kenney_car-kit/Models/delivery.glb")
const MAX_SPEED := 12.0
const DRIVE_FORCE := 6000.0
var throttle := 0.0
var steering := 0.0
var braking := true
var authority := true
var enabled := false
var door_open := false
var health := 100.0
var seats: Array[int] = [-1, -1, -1, -1]
var gate: CollisionShape3D
var gate_visual: MeshInstance3D
var camera: Camera3D
var _reset_pending := false
var _reset_transform := Transform3D.IDENTITY
var _impact_cooldown := 0.0
var _engine_audio: AudioStreamPlayer3D

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
	var model: Node3D = MODEL.instantiate()
	model.scale = Vector3.ONE * 2
	add_child(model)
	var old_door := model.get_node_or_null("door")
	if old_door != null: old_door.hide()
	_shape(Vector3(0, 0.68, 0), Vector3(2.5, 0.35, 5.8))
	_shape(Vector3(0, 1.0, -1.1), Vector3(2.5, 0.14, 3.8))
	_shape(Vector3(0, 1.35, 1.9), Vector3(2.5, 1.5, 2.0))
	for side in [-1, 1]:
		_shape(Vector3(side * 1.25, 2.0, -1.1), Vector3(0.15, 2, 4))
	_shape(Vector3(0, 3, -1.1), Vector3(2.5, 0.12, 4))
	for axle in [-1.22, 2.02]:
		for side in [-1, 1]:
			var wheel := CollisionShape3D.new()
			var shape := SphereShape3D.new()
			shape.radius = 0.55
			wheel.shape = shape
			wheel.position = Vector3(side * 1.0, 0.55, axle)
			add_child(wheel)
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
	camera = Camera3D.new()
	camera.name = "VehicleCamera"
	add_child(camera)
	camera.position = Vector3(0, 5.5, -9)
	camera.look_at(to_global(Vector3(0, 1.3, 0.7)))
	_engine_audio = AudioStreamPlayer3D.new()
	_engine_audio.name = "EngineAudio"
	_engine_audio.stream = _engine_sound()
	_engine_audio.unit_size = 10
	_engine_audio.max_distance = 45
	_engine_audio.volume_db = -20
	add_child(_engine_audio)
	_engine_audio.play()

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

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _reset_pending:
		state.transform = _reset_transform
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		_reset_pending = false
		_impact_cooldown = 1.0
	if not authority: return
	_impact_cooldown = maxf(0, _impact_cooldown - state.step)
	if not enabled: return
	var forward := state.transform.basis.z
	var right := state.transform.basis.x
	var speed := state.linear_velocity.dot(forward)
	var drive := throttle * DRIVE_FORCE
	if (speed > MAX_SPEED and drive > 0) or (speed < -5 and drive < 0): drive = 0
	state.apply_central_force(forward * drive)
	state.apply_central_force(-right * state.linear_velocity.dot(right) * mass * 5)
	var drag := 7.5 if braking or absf(throttle) < 0.05 else 0.25
	state.apply_central_force(-forward * speed * mass * drag)
	state.angular_velocity.y = clampf(speed / 3.8, -1.2, 1.2) * steering * 0.7
	if _impact_cooldown <= 0:
		var total_impulse := Vector3.ZERO
		for index in state.get_contact_count():
			total_impulse += state.get_contact_impulse(index)
		var impulse := Vector2(total_impulse.x, total_impulse.z).length() / mass
		if impulse > 2.5:
			if "freight-test" in OS.get_cmdline_user_args(): print("VAN_IMPACT ", impulse, " speed=", state.linear_velocity, " contacts=", get_colliding_bodies())
			health = maxf(0, health - (impulse - 2.5) * 8)
			_impact_cooldown = 0.5

func recover(at: Transform3D) -> void:
	_reset_transform = at
	_reset_pending = true
	throttle = 0
	steering = 0
	braking = true
	sleeping = false

func seat_of(slot: int) -> int:
	return seats.find(slot)

func seat_position(seat: int) -> Vector3:
	return to_global(Vector3(-0.58 if seat % 2 == 0 else 0.58, 1.15, 1.9 if seat < 2 else 0.55))

func cargo_contains(body: Node3D) -> bool:
	var at := to_local(body.global_position)
	return absf(at.x) < 1.15 and at.z > -2.95 and at.z < 0.55 and at.y > 1.05 and at.y < 2.95

func _process(_delta: float) -> void:
	_engine_audio.pitch_scale = 0.65 + minf(linear_velocity.length() / 12, 1.0)
	_engine_audio.volume_db = -18 if enabled else -32

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
