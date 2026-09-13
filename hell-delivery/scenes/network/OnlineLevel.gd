extends "res://scenes/level/VillaCoopLevel.gd"

var order_id := "standard"
var couriers: Array[Player] = []
var extra_spawns: Array[Transform3D] = []
var extra_audio: Array[LevelAudio] = []

func _ready() -> void:
	super._ready()
	couriers = [player, player2]
	for slot in range(2, 4):
		var courier: Player = preload("res://scenes/player/Player.tscn").instantiate()
		courier.name = "Player%d" % (slot + 1)
		courier.player_slot = slot
		courier.input_profile = Player.InputProfile.NETWORK
		courier.collision_mask = player.collision_mask
		courier.floor_snap_length = player.floor_snap_length
		courier.position = Vector3(-3.5 if slot == 2 else 3.5, 1, -14)
		courier.rotation.y = PI
		$Gameplay.add_child(courier)
		couriers.append(courier)
		extra_spawns.append(courier.global_transform)
		for step in $Environment.get_children():
			if step is StaticBody3D and str(step.name).begins_with("Step"):
				courier.add_collision_exception_with(step)
		var audio := LevelAudio.new()
		audio.name = "Player%dAudio" % (slot + 1)
		add_child(audio)
		extra_audio.append(audio)
	var extra_index := 0
	for zone in destinations:
		var stop := DeliveryOrders.get_stop(order_id, zone.destination_id)
		zone.target_package_count = stop.count
		for index in range(1, int(stop.count)):
			var parcel: Package = preload("res://scenes/package/Package.tscn").instantiate()
			parcel.name = "Extra" + zone.destination_id if index == 1 else "Extra%s_%d" % [zone.destination_id, index]
			parcel.destination_id = zone.destination_id
			parcel.display_name = zone.display_name
			parcel.position = Vector3(-1.65, 0.95, -9.3 + extra_index * 1.4)
			extra_index += 1
			$Gameplay.add_child(parcel)
			$Presentation.dress_package(parcel)
			_spawn_transforms[parcel] = parcel.global_transform
			parcel.body_entered.connect(_on_object_contact.bind(parcel))
	for parcel in $Gameplay.get_children():
		if not parcel is Package: continue
		var order := DeliveryOrders.get_stop(order_id, parcel.destination_id)
		parcel.mass = order.mass
		if order.parcel_scale > 1.0:
			var collision: CollisionShape3D = parcel.get_node("CollisionShape3D")
			collision.shape = collision.shape.duplicate()
			collision.shape.size *= order.parcel_scale
			for visual_name in ["FactoryParcelVisual", "ShippingLabels", "MeshInstance3D"]:
				var visual: Node3D = parcel.get_node_or_null(visual_name)
				if visual != null:
					visual.scale *= order.parcel_scale
					visual.position *= order.parcel_scale
			if not order.has("kind"):
				for label in parcel.get_node("ShippingLabels").find_children("*", "Label3D", true, false):
					label.text = "%s\n45kg · 공동" % parcel.display_name
					label.font_size = 22
		if order.has("kind"):
			var preset: Dictionary = DeliveryOrders.KIND_PRESETS[order.kind]
			parcel.damage_impact_threshold = preset.damage_threshold
			parcel.damage_impact_multiplier = preset.damage_multiplier
			var mesh_instance: MeshInstance3D = parcel.get_node("MeshInstance3D")
			var material := StandardMaterial3D.new()
			material.albedo_color = preset.color
			material.roughness = 0.6
			mesh_instance.material_override = material
			for label in parcel.get_node("ShippingLabels").find_children("*", "Label3D", true, false):
				label.text = "%s\n%s" % [parcel.display_name, preset.label_suffix]
				label.font_size = 20
	_configure_goal()
	for sign in $Presentation.find_children("*", "Label3D", true, false):
		if sign.text.begins_with("HELL DELIVERY\n출발"):
			sign.text = "HELL DELIVERY\n출발 · 택배 %d개" % _total_target()
	_update_stops()

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	for index in extra_audio.size():
		var courier: Player = couriers[index + 2]
		if not courier.visible: continue
		extra_audio[index].update_player(courier, delta)
		if courier.global_position.y < FALL_LIMIT: recover_slot(index + 2)
	_update_stops()

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
	for slot in range(2, couriers.size()): recover_slot(slot)

func _update_stops() -> void:
	if second_zone == null: return
	for zone in destinations:
		var complete: bool = zone.delivered_count >= zone.target_package_count
		for label in zone.find_children("*", "Label3D", false, false):
			if label == _stop_visuals.get(zone):
				label.visible = complete
			else:
				label.visible = not complete
				label.text = "%s · %d/%d개" % [zone.display_name, zone.delivered_count, zone.target_package_count]
	if player2 != null:
		var carriers: Array[String] = []
		for slot in couriers.size():
			if couriers[slot].visible: carriers.append("P%d %s" % [slot + 1, _carrying(couriers[slot])])
		var stops := " · ".join(destinations.map(func(zone): return "%s %d/%d" % [zone.display_name, zone.delivered_count, zone.target_package_count]))
		delivery_hud.get_node("RouteLabel").text = " | ".join(carriers) + " | " + stops

func _on_package_delivered(package: RigidBody3D, delivered_count: int, target_count: int) -> void:
	super._on_package_delivered(package, delivered_count, target_count)
	var zone := destination(package.destination_id)
	if delivered_count < target_count:
		zone.get_node("MeshInstance3D").material_override.albedo_color = Color(0.18, 0.85, 0.49, 0.5)

func _on_all_packages_delivered() -> void:
	# Online menus must not pause SceneTree/network polling or another player's input.
	pass
