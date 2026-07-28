class_name DeliveryZone
extends Area3D

# T081: 단일 배송 판정에서 "Package 여러 개를 반복 배송" 흐름으로 확장했다. 목표 개수는
# 이 상수 하나로만 관리하며(UI 문구들도 전부 이 값을 그대로 읽어 표시한다 — 하드코딩 중복 없음),
# "Package" 그룹 기반 판정(PhysicsCrate/Barrel/SmallBox 등은 이 그룹에 없어 자동으로 제외)은 그대로 유지한다.
const TARGET_PACKAGE_COUNT: int = 3 # TODO: 프로토타입 값, 실측 재검증 필요 — 데모 배송 목표 개수.

# T082: 목표 공간임을 알아보기 쉽도록 느린 밝기 Pulse만 추가한다(빠른 점멸·강한 화면 효과 금지 —
# 광과민 위험 없음). CollisionShape3D/Area3D 판정 로직은 전혀 건드리지 않고, MeshInstance3D의
# 재질(순수 시각 요소)만 매 프레임 밝기를 오갈 뿐이라 Grab·배송 판정 범위에 영향이 없다.
const _PULSE_PERIOD: float = 2.4 # 초 단위 — 느린 Pulse(빠른 점멸 아님)
const _PULSE_MIN_ENERGY: float = 0.35
const _PULSE_MAX_ENERGY: float = 1.1
const _EMISSION_COLOR: Color = Color(0.3, 0.75, 1.0)

signal package_delivered(package: RigidBody3D, delivered_count: int, target_count: int)
signal all_packages_delivered

var delivered_count: int = 0
var _delivered_packages: Dictionary = {} # RigidBody3D -> true. 같은 Package가 Zone을 다시 드나들어도 중복 집계하지 않기 위함.
var _pulse_time: float = 0.0
@onready var _mesh: MeshInstance3D = get_node_or_null("MeshInstance3D")
var _pulse_material: StandardMaterial3D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_setup_pulse_material()


func _setup_pulse_material() -> void:
	if _mesh == null:
		return
	_pulse_material = StandardMaterial3D.new()
	_pulse_material.albedo_color = _EMISSION_COLOR
	_pulse_material.emission_enabled = true
	_pulse_material.emission = _EMISSION_COLOR
	_pulse_material.emission_energy_multiplier = _PULSE_MIN_ENERGY
	_mesh.material_override = _pulse_material


func _process(delta: float) -> void:
	if _pulse_material == null:
		return
	_pulse_time += delta
	var wave: float = (sin(_pulse_time * TAU / _PULSE_PERIOD) + 1.0) * 0.5 # 0..1
	_pulse_material.emission_energy_multiplier = lerpf(_PULSE_MIN_ENERGY, _PULSE_MAX_ENERGY, wave)


func _on_body_entered(body: Node3D) -> void:
	if not body.is_in_group("package"):
		return
	if _delivered_packages.has(body):
		return
	if delivered_count >= TARGET_PACKAGE_COUNT:
		return # 목표를 이미 달성한 뒤에는(레벨에 여분의 Package가 있어도) 추가 집계하지 않는다.
	_delivered_packages[body] = true
	delivered_count += 1
	if body is GrabbableBody:
		body.deliver() # Grab 안전 해제 + 이후 Grab 불가 + 물리 정리(GrabbableBody.gd 참고)
	print("Delivery Success: ", delivered_count, "/", TARGET_PACKAGE_COUNT)
	package_delivered.emit(body, delivered_count, TARGET_PACKAGE_COUNT)
	if delivered_count >= TARGET_PACKAGE_COUNT:
		all_packages_delivered.emit()
