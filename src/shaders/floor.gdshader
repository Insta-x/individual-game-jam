shader_type spatial;

void fragment() {
	ALPHA = clamp(1.0 - pow(length(UV - vec2(0.5)) * 2.0, 14.0), 0.0, 1.0);
}
