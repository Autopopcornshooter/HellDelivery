class_name DeliveryZone
extends Area3D

# T081: 단일 배송 판정에서 "Package 여러 개를 반복 배송" 흐름으로 확장했다. 목표 개수는
# 이 상수 하나로만 관리하며(UI 문구들도 전부 이 값을 그대로 읽어 표시한다 — 하드코딩 중복 없음),
# "Package" 그룹 기반 판정(PhysicsCrate/Barrel/SmallBox 등은 이 그룹에 없어 자동으로 제외)은 그대로 유지한다.
const TARGET_PACKAGE_COUNT: int = 3 # TODO: 프로토타입 값, 실측 재검증 필요 — 데모 배송 목표 개수.

signal package_delivered(package: RigidBody3D, delivered_count: int, target_count: int)
signal all_packages_delivered

var delivered_count: int = 0
var _delivered_packages: Dictionary = {} # RigidBody3D -> true. 같은 Package가 Zone을 다시 드나들어도 중복 집계하지 않기 위함.


func _ready() -> void:
	body_entered.connect(_on_body_entered)


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
