class_name Package
extends GrabbableBody

@export var delivery_address: String = ""

func _ready() -> void:
	super._ready()
	if delivery_address != "":
		_add_shipping_labels()

func configure_address(address: String) -> void:
	delivery_address = address
	var old := get_node_or_null("ShippingLabels")
	if old != null:
		remove_child(old)
		old.queue_free()
	if is_inside_tree() and delivery_address != "":
		_add_shipping_labels()

func _add_shipping_labels() -> void:
	var labels := Node3D.new()
	labels.name = "ShippingLabels"
	add_child(labels)
	var paper := StandardMaterial3D.new()
	paper.albedo_color = Color("e1eef0") if delivery_address == "201" else Color("f0e4cb")
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
		label.text = delivery_address + "호"
		label.font_size = 48
		label.pixel_size = 0.003
		label.modulate = Color("263b3c")
		label.outline_size = 0
		label.position.z = 0.01
		mount.add_child(label)
