shader_type canvas_item;

uniform vec2 size = vec2(32.0, 28.0);
// If you intend to read from mipmaps with `textureLod()` LOD values greater than `0.0`,
// use `filter_nearest_mipmap` instead. This shader doesn't require it.
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 uvn = SCREEN_UV;
	uvn.x += sin(TIME*1.0+uvn.y*8.0)*0.002;
	uvn.y += cos(TIME*2.2+uvn.x*16.0)*0.002;

        COLOR = textureLod(screen_texture, uvn, 0.0);
}
