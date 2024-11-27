shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec3 screen = round(textureLod(screen_texture, SCREEN_UV, 0.0).rgb);
	COLOR.rgb = screen;;
}