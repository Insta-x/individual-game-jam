shader_type spatial;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform vec3 albedo : source_color;
uniform vec3 fresnel_albedo : source_color;
uniform float metallic : hint_range(0.0, 1.0) = 0;
uniform float roughness : hint_range(0.0, 1.0) = 0.02;

uniform sampler2D normal_texture;
uniform sampler2D normal_texture2;
uniform vec2 wave_direction = vec2(1.0, 0.0);
uniform vec2 wave_direction2 = vec2(0.0, 1.0);
uniform float wave_time_scale = 0.025;

uniform sampler2D wave;
uniform float noise_scale = 10.0;
uniform float height_scale = 0.15;

uniform vec4 color_deep : source_color;
uniform vec4 color_shallow : source_color;
uniform float beers_law = 2.0;
uniform float depth_offset = -0.75;

uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

uniform sampler2D simulation_texture;
uniform float amplitude = 0.1;

varying float height;
varying vec3 world_pos;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

float edge(float depth) {
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}

void vertex() {
	// Collision Simulation
	float simulation_height = texture(simulation_texture, UV).r * amplitude;
	VERTEX += simulation_height * NORMAL;
	
	// Wave Displacement
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	height = texture(wave, world_pos.xz / noise_scale + TIME * wave_time_scale).r;
	VERTEX.y += height * height_scale;
}

void fragment() {
	float depth_texture = texture(DEPTH_TEXTURE, SCREEN_UV).r * 2.0 - 1.0;
	float depth = PROJECTION_MATRIX[3][2] / (depth_texture + PROJECTION_MATRIX[2][2]);
	float depth_blend = exp((depth + VERTEX.z + depth_offset) * -beers_law);
	depth_blend = clamp(1.0 - depth_blend, 0.0, 1.0);
	float depth_blend_power = clamp(pow(depth_blend, 2.5), 0.0, 1.0);
	
	// Retrieving depth color and applying the deep and shallow colors
	vec3 screen_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, depth_blend_power * 2.5).rgb;
	vec3 depth_color = mix(color_shallow.rgb, color_deep.rgb, depth_blend_power);
	vec3 color = mix(screen_color * depth_color, depth_color * 0.25, depth_blend_power * 0.5);
	
	// Getting edge depth calc
	float z_depth = edge(texture(DEPTH_TEXTURE, SCREEN_UV).x);
	float z_pos = edge(FRAGCOORD.z);
	float z_dif = z_depth - z_pos;
	
	// Time offset for wave normal maps
	vec2 wave_offset = (TIME * wave_direction) * wave_time_scale;
	vec2 wave_offset2 = (TIME * wave_direction2) * wave_time_scale;
	
	vec3 normal_blend = mix(texture(normal_texture, world_pos.xz + wave_offset).rgb, texture(normal_texture2, world_pos.xz + wave_offset2).rgb, 0.5);
	
	// Calculate Fresnel
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 surface_color = mix(albedo, fresnel_albedo, fresnel);
	
	vec3 depth_color_adj = mix(edge_color, color, step(edge_scale, z_dif));
	
	// Simulation Normal
	vec3 duv = vec3(4.0 / 512.0, 4.0 / 512.0, 0);
	float v1 = texture(simulation_texture, UV - duv.xz).y;
	float v2 = texture(simulation_texture, UV + duv.xz).y;
	float v3 = texture(simulation_texture, UV - duv.zy).y;
	float v4 = texture(simulation_texture, UV + duv.zy).y;

	vec3 simulation_normal = normalize(vec3(v1 - v2, v3 - v4, 0.3));
	
	ALBEDO = clamp(surface_color + depth_color_adj, vec3(0.0), vec3(1.0));
	METALLIC = metallic;
	ROUGHNESS = roughness;
	NORMAL_MAP = mix(normal_blend, simulation_normal, 0.15);
}