extends Node3D

@onready var delivery_zone: DeliveryZone = $Gameplay/DeliveryZone
@onready var delivery_hud: DeliveryHUD = $UI/DeliveryHUD
@onready var player: Player = $Gameplay/Player


func _ready() -> void:
	delivery_zone.package_delivered.connect(_on_package_delivered)
	player.grab_aim_state_changed.connect(delivery_hud.set_crosshair_state)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		get_tree().reload_current_scene()


func _on_package_delivered(_package: RigidBody3D) -> void:
	delivery_hud.show_success()
