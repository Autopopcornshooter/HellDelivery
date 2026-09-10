extends "res://scenes/level/VillaCoopLevel.gd"

func _on_all_packages_delivered() -> void:
	# Online menus must not pause SceneTree/network polling or another player's input.
	pass
