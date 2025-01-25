shader_type spatial;
uniform float speed = 2.0;
uniform float size = 0.06;
//void vertex() {
uniform vec4 outline_color : source_color = vec4(0.0157, 0.851, 0.545, 1.0);
uniform vec4 target_color : source_color = vec4( 0.592, 0.239, 0.949, 1.0 );

uniform float outline_ratio = 1.0;
uniform float noise_speed = 0.2;
uniform float noise_scale = 0.5;


void vertex( )
{
	vec3 v = clamp( cos( VERTEX * 10.0 + vec3( TIME * speed ) ) + vec3( 1.0 ), 0.0, 1.0 );
	VERTEX *= 1.0 + dot( v, v ) * size;
}

void fragment()
{	
	METALLIC = 0.1;
	ROUGHNESS = 0.01;
	
	float outline_alpha = clamp( ( 1.0 - dot( NORMAL, VIEW ) ) * outline_ratio, 0.0, 1.0 );
	vec3 tc = vec3(target_color.x,target_color.y,target_color.z);
	vec3 color = tc * noise_scale;

	ALBEDO = mix( color, outline_color.rgb, max( outline_alpha - 0.3, 0.0 ) );
	ALPHA = outline_color.a * outline_alpha;
}



//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
