shader_type spatial;

uniform vec4 base_color : source_color = vec4(0.72, 0.71, 0.66, 1.0);
uniform vec4 lower_color : source_color = vec4(0.55, 0.58, 0.54, 1.0);
uniform bool painted_wall = false;
uniform float band_top = 4.3;
varying vec3 world_position;
varying vec3 world_normal;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	if (painted_wall) {
		float band = 1.0 - smoothstep(band_top - 0.003, band_top + 0.003, world_position.y);
		ALBEDO = mix(base_color.rgb, lower_color.rgb, band);
		ROUGHNESS = 0.91;
	} else {
		vec3 n = abs(world_normal);
		vec2 p = world_position.xz;
		if (n.x > n.y && n.x > n.z) { p = world_position.zy; }
		else if (n.z > n.y) { p = world_position.xy; }
		vec2 cells = p * 65.0;
		float h = hash(floor(cells));
		vec2 center = vec2(0.2) + vec2(h, hash(floor(cells) + vec2(17.3))) * 0.6;
		vec2 fragment_position = fract(cells) - center;
		float width = max(fwidth(cells.x), fwidth(cells.y));
		float chip = 1.0 - smoothstep(0.08 + h * 0.12, 0.19 + h * 0.12 + width, length(fragment_position));
		chip *= 1.0 - smoothstep(0.35, 1.2, width);
		vec3 chip_color = h < 0.3 ? vec3(0.40, 0.42, 0.39) : vec3(0.84, 0.81, 0.74);
		ALBEDO = mix(base_color.rgb, chip_color, chip * 0.45);
		ROUGHNESS = 0.78;
	}
}
