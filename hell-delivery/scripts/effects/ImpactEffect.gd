class_name ImpactEffect
extends CPUParticles3D

# 절차적 1회성 파티클(외부 텍스처/모델 없음, 프로젝트 기존 방식과 동일하게 코드로만 생성).
# 배송 성공/택배·차량 파손 순간의 최소 시각 피드백용 — 게임플레이에는 전혀 관여하지 않는다.
# GPUParticles3D 대신 CPUParticles3D를 쓴다 — 헤드리스(--headless, GPU 없는 자동 검사)에서도
# 컴퓨트 셰이더 없이 동일하게 동작해 자동 회귀에서 안전하다.
# add_child를 물리 콜백(_integrate_forces 등) 밖에서만 안전하게 호출하기 위해 항상
# call_deferred로 붙이고, 실제 파티클 설정은 트리에 들어온 뒤 _ready()에서 마친다.

var _spawn_at := Vector3.ZERO
var _spawn_color := Color.WHITE
var _spawn_spread := 50.0
var _spawn_count := 16

static func spawn(container: Node, at: Vector3, color: Color, spread_degrees: float = 50.0, count: int = 16) -> void:
	if not is_instance_valid(container): return
	var effect := ImpactEffect.new()
	effect._spawn_at = at
	effect._spawn_color = color
	effect._spawn_spread = spread_degrees
	effect._spawn_count = count
	container.add_child.call_deferred(effect)

func _ready() -> void:
	global_position = _spawn_at
	amount = _spawn_count
	lifetime = 0.6 # TODO: 프로토타입 값, 튜닝 필요
	one_shot = true
	explosiveness = 0.9
	emitting = false
	direction = Vector3(0, 1, 0)
	spread = _spawn_spread
	gravity = Vector3(0, -6.0, 0)
	initial_velocity_min = 1.2 # TODO: 프로토타입 값, 튜닝 필요
	initial_velocity_max = 2.8
	scale_amount_min = 0.6
	scale_amount_max = 1.3
	color = _spawn_color
	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.05
	particle_mesh.height = 0.1
	particle_mesh.radial_segments = 6
	particle_mesh.rings = 3
	var mesh_material := StandardMaterial3D.new()
	mesh_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_material.vertex_color_use_as_albedo = true # CPUParticles3D.color only shows through vertex-color tinting.
	mesh_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	particle_mesh.material = mesh_material
	mesh = particle_mesh
	emitting = true
	get_tree().create_timer(lifetime + 0.3).timeout.connect(queue_free)
