class_name DeliveryZone
extends Area3D

signal package_delivered(package: RigidBody3D)

var is_delivered: bool = false
var delivered_package: RigidBody3D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("package"):
		return
	if is_delivered:
		return
	is_delivered = true
	delivered_package = body
	print("Delivery Success")
	package_delivered.emit(body)
