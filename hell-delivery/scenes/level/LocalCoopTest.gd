extends Node3D

# T074: 로컬 2인 협동 물리 검증용 테스트 Scene. 기존 PrototypeLevel(레벨 지오메트리·물리 오브젝트·
# DeliveryZone·Package)을 그대로 인스턴스해 재사용하고, Player2를 같은 Gameplay 아래 형제 노드로
# 추가한다 — 레벨과 물리 월드는 단 하나만 존재하며(SubViewport마다 중복 생성하지 않음), 두 화면은
# 그 하나의 World3D를 공유하는 SubViewport 2개로만 분리된다.
# T075: 각 화면에 Grab 상태 UX(협동 표시, Release 피드백, P1/P2 구분 표시)를 추가한다.

const _FLASH_COLOR_DISTANCE: Color = Color(1.0, 0.7, 0.1) # 최대 거리 초과
const _FLASH_COLOR_BLOCKED: Color = Color(1.0, 0.2, 0.2) # 정적 장애물/안전 조건

@onready var player1: Player = $Level/Gameplay/Player
@onready var player2: Player = $Level/Gameplay/Player2
@onready var _left_viewport: SubViewport = $SplitScreen/Layout/LeftContainer/SubViewport
@onready var _right_viewport: SubViewport = $SplitScreen/Layout/RightContainer/SubViewport
@onready var _left_camera: Camera3D = $SplitScreen/Layout/LeftContainer/SubViewport/ViewCamera
@onready var _right_camera: Camera3D = $SplitScreen/Layout/RightContainer/SubViewport/ViewCamera
@onready var _left_crosshair: Crosshair = $SplitScreen/Layout/LeftContainer/SubViewport/Crosshair
@onready var _right_crosshair: Crosshair = $SplitScreen/Layout/RightContainer/SubViewport/Crosshair
@onready var _left_coop_status: Label = $SplitScreen/Layout/LeftContainer/SubViewport/CoopStatus
@onready var _right_coop_status: Label = $SplitScreen/Layout/RightContainer/SubViewport/CoopStatus

var _left_coop_shown: bool = false
var _right_coop_shown: bool = false


func _ready() -> void:
	# 두 SubViewport가 같은 물리 월드를 보도록 World3D를 공유한다(레벨을 각 Viewport 안에
	# 별도로 두지 않고, 메인 트리에 하나만 두는 것과 짝을 이루는 설정).
	var shared_world: World3D = get_viewport().world_3d
	_left_viewport.world_3d = shared_world
	_right_viewport.world_3d = shared_world

	# 각 Player 자신의 Camera3D(Grab 판정에도 쓰이는 실제 눈 위치)가 이미 _ready()에서 계산해 둔
	# cull_mask를 그대로 복사한다 — "자기 화면에서만 자기 모델이 안 보인다"를 뷰 카메라에도 적용.
	_left_camera.cull_mask = player1.camera_pivot.get_node("Camera3D").cull_mask
	_right_camera.cull_mask = player2.camera_pivot.get_node("Camera3D").cull_mask

	# 조준점은 각자의 Player가 이미 계산해 둔 Grab 판정 상태만 그대로 전달받는다(중복 탐색 없음, T073과 동일 원칙).
	player1.grab_aim_state_changed.connect(_left_crosshair.set_state)
	player2.grab_aim_state_changed.connect(_right_crosshair.set_state)

	# T075: Release 피드백 — 사용자가 직접 놓은 경우(MANUAL)는 조준점 상태 변화만으로 충분해
	# 별도 점멸을 주지 않는다. 거리 초과/정적 차단만 짧게 점멸한다.
	player1.grab_connection_lost.connect(_on_grab_connection_lost.bind(_left_crosshair))
	player2.grab_connection_lost.connect(_on_grab_connection_lost.bind(_right_crosshair))

	# 기존 싱글플레이용 DeliveryHUD의 조준점은 분할 화면에서는 쓰지 않는다(각 SubViewport가
	# 자기 조준점을 따로 가짐) — DeliveryHUD 자체(배송 성공 패널)는 그대로 두어 배송 시 공통으로 보이게 한다.
	var delivery_hud: DeliveryHUD = $Level/UI/DeliveryHUD
	delivery_hud.crosshair.visible = false


func _on_grab_connection_lost(reason: int, crosshair: Crosshair) -> void:
	match reason:
		GrabbableBody.DisconnectReason.DISTANCE_EXCEEDED:
			crosshair.flash(_FLASH_COLOR_DISTANCE)
		GrabbableBody.DisconnectReason.BLOCKED:
			crosshair.flash(_FLASH_COLOR_BLOCKED)
		_:
			pass # MANUAL: 사용자가 직접 놓은 경우 — 별도 피드백 없음(조준점 상태 변화로 충분).


func _physics_process(_delta: float) -> void:
	# T075: "같은 물체를 두 명이 잡고 있는가"는 각 Player가 이미 들고 있는 held_grabbable의
	# get_grabber_count()만 확인하면 된다(2명뿐인 씬이라 count>=2면 곧 상대방과 함께 잡은 것).
	# 물리 tick마다 확인해 최대 1 physics frame 안에 표시가 갱신되도록 한다.
	var left_coop := player1.held_grabbable != null and player1.held_grabbable.get_grabber_count() >= 2
	if left_coop != _left_coop_shown:
		_left_coop_shown = left_coop
		_left_coop_status.visible = left_coop

	var right_coop := player2.held_grabbable != null and player2.held_grabbable.get_grabber_count() >= 2
	if right_coop != _right_coop_shown:
		_right_coop_shown = right_coop
		_right_coop_status.visible = right_coop


func _process(_delta: float) -> void:
	# 실제 렌더 카메라는 각 Player의 CameraPivot/Camera3D 위치를 그대로 따라간다 — Player의 이동/
	# 회전 로직은 전혀 건드리지 않고, 뷰 카메라만 매 프레임 그 위치를 복사하는 방식(레벨 중복 없음).
	_left_camera.global_transform = player1.camera_pivot.get_node("Camera3D").global_transform
	_right_camera.global_transform = player2.camera_pivot.get_node("Camera3D").global_transform
