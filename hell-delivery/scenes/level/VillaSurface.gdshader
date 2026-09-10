shader_type spatial;
uniform vec4 base_color : source_color = vec4(0.7, 0.65, 0.55, 1.0);
uniform float tile_size = 0.75;
uniform float seam_strength = 0.13;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 n = abs(world_normal);
	vec2 plane = world_position.xz;
	if (n.x > n.y && n.x > n.z) { plane = world_position.zy; }
	else if (n.z > n.y) { plane = world_position.xy; }
	vec2 cell = plane / tile_size;
	vec2 edge = min(fract(cell), 1.0 - fract(cell));
	vec2 aa = max(fwidth(cell), vec2(0.001));
	vec2 seam = 1.0 - smoothstep(vec2(0.012), vec2(0.012) + aa, edge);
	float variation = fract(sin(dot(floor(cell), vec2(127.1, 311.7))) * 43758.5453);
	ALBEDO = base_color.rgb * (0.97 + variation * 0.06 - max(seam.x, seam.y) * seam_strength);
	ROUGHNESS = 0.88;
}
