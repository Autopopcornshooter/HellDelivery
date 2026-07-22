class_name DeliveryHUD
extends CanvasLayer

@onready var success_panel: Control = $SuccessPanel


func _ready() -> void:
	success_panel.visible = false


func show_success() -> void:
	success_panel.visible = true
