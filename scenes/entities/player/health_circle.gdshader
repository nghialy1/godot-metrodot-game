shader_type canvas_item;

uniform vec2 center = vec2(0.5, 0.5);
uniform float radius: hint_range(0.0, 1.0) = 0.3;
uniform float width: hint_range(0.0, 1.0) = 0.2;
uniform vec3 color: source_color = vec3(1.0);
uniform float alpha: hint_range(0.0, 1.0) = 1.0;
uniform float progress: hint_range(0.0, 1.0) = 1.0;

void fragment() {
	float outer_circle = step(distance(center, UV), radius);
	float inner_circle = step(distance(center, UV), radius - width);
	float cutout = step((1.0 - progress) * TAU, atan(UV.x - center.x, UV.y - center.y) + PI);
	
	COLOR.a = (outer_circle - inner_circle) * alpha * cutout;
	COLOR.rgb = color;
}
