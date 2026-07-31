class_name CharacterDefinition
extends Resource

## T085D: 캐릭터 1종의 데이터. 18개 Kenney 캐릭터가 모두 동일한 노드 구조(character-X2/
## character-X/root/{leg-left, leg-right, torso{arm-left, arm-right, head}} + 형제
## AnimationPlayer)를 가지므로, 파츠 경로는 기본적으로 CharacterVisual이 이름으로 찾아 쓰고
## (find_child), 이 Resource에는 구조가 다른 예외 캐릭터가 생길 때만 아래 *_path 필드를 채운다.

@export var id: String = ""
@export var display_name: String = ""
@export var model_scene: PackedScene = null
@export var preview_scale: float = 1.0
@export var preview_rotation_degrees: float = 20.0
@export var player_scale: float = 0.75 # T085D: 원본 모델 높이(약 2.7m)를 Player CapsuleShape3D 높이(2.0m)에 맞춘 공통 보정값(2.0/2.7).

## 아래는 전부 선택 사항이다 — 비어 있으면(NodePath("")) CharacterVisual이 표준 이름
## ("root", "AnimationPlayer", "head", "arm-left", "arm-right")으로 자동 탐색한다.
@export var model_root_path: NodePath = NodePath("")
@export var animation_player_path: NodePath = NodePath("")
@export var head_node_path: NodePath = NodePath("")
@export var left_arm_path: NodePath = NodePath("")
@export var right_arm_path: NodePath = NodePath("")
