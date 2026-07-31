class_name CharacterVisual
extends Node3D

## T085D: 외부 Kenney 모델을 Player(또는 미리보기)에 느슨하게 연결하는 Wrapper. 원본 GLB는
## 직접 수정하지 않고, 여기서 인스턴스 생성·교체·스케일 보정만 담당한다. 캐릭터 교체 시 이전
## 인스턴스를 완전히 제거해(remove_child 이후 queue_free) 같은 프레임 안에서도 새/구 인스턴스가
## 함께 tree에 남아 있는 순간이 없게 한다.

signal character_changed(character_id: String)

@onready var model_root: Node3D = $ModelRoot
@onready var animation_controller: CharacterAnimationController = $CharacterAnimationController

var current_character_id: String = ""

var _current_instance: Node3D = null
var _head_node: Node3D = null


## use_preview_transform=true면 player_scale 대신 preview_scale/preview_rotation_degrees를
## 적용한다(CharacterSelectPanel의 3D 미리보기 전용 — 실제 Player 적용에는 쓰지 않는다).
func set_character(character_id: String, use_preview_transform: bool = false) -> void:
	var def: CharacterDefinition = CharacterCatalog.get_by_id(character_id)
	if def == null or def.model_scene == null:
		push_warning("CharacterVisual: unknown character id '%s'" % character_id)
		return
	_apply_definition(def, use_preview_transform)


func get_head_node() -> Node3D:
	return _head_node


func _apply_definition(def: CharacterDefinition, use_preview_transform: bool) -> void:
	if _current_instance != null and is_instance_valid(_current_instance):
		model_root.remove_child(_current_instance)
		_current_instance.queue_free()
	_current_instance = null
	_head_node = null

	var instance: Node3D = def.model_scene.instantiate()
	model_root.add_child(instance)
	if use_preview_transform:
		instance.scale = Vector3.ONE * def.preview_scale
		instance.rotation_degrees.y = def.preview_rotation_degrees
	else:
		instance.scale = Vector3.ONE * def.player_scale

	var anim_player := _find_node(instance, def.animation_player_path, "AnimationPlayer") as AnimationPlayer
	var head := _find_node(instance, def.head_node_path, "head") as Node3D
	var arm_left := _find_node(instance, def.left_arm_path, "arm-left") as Node3D
	var arm_right := _find_node(instance, def.right_arm_path, "arm-right") as Node3D

	_current_instance = instance
	_head_node = head
	current_character_id = def.id

	animation_controller.setup(anim_player, arm_left, arm_right)
	character_changed.emit(def.id)


func _find_node(instance: Node3D, override_path: NodePath, fallback_name: String) -> Node:
	if override_path != NodePath(""):
		var found := instance.get_node_or_null(override_path)
		if found != null:
			return found
	return instance.find_child(fallback_name, true, false)
