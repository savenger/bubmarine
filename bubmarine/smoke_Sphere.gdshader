shader_type spatial;
uniform float speed = 2.0;
uniform float size = 0.06;
uniform float cell_size = 0.06;
uniform vec3 dot_Dir = vec3(12.9898, 78.233, 37.719);


//void vertex() {
uniform vec4 outline_color : source_color = vec4(0.0157, 0.851, 0.545, 1.0);
uniform vec4 dark_color : source_color = vec4( 0.592, 0.239, 0.949, 0.5 );
uniform vec4 bright_color : source_color = vec4( 0.592, 0.239, 0.949, 1.0);
uniform vec4 border_color : source_color = vec4( 0.0, 0.0, 0.0, 0.0 );


uniform float outline_ratio = 1.0;
uniform float noise_speed = 0.2;
uniform float noise_scale = 0.5;

//float rand2dTo1d(vec2 value, vec2 dotDir){
//	vec2 smallValue = sin(value);
//	float random = dot(smallValue, dotDir);
//	random = fract(sin(random) * 143758.5453);
//	return random;
//}
//
//vec2 rand2dTo2d(vec2 value){
//	return vec2(
//		rand2dTo1d(value, vec2(12.989, 78.233)),
//		rand2dTo1d(value, vec2(39.346, 11.135))
//	);
//}
float rand3dTo1d(vec3 value, vec3 dotDir){
	//make value smaller to avoid artefacts
	vec3 smallValue = sin(value);
	//get scalar value from 3d vector
	float random = dot(smallValue, dotDir);
	//make value more random by making it bigger and then taking the factional part
	random = fract(sin(random) * 143758.5453);
	return random;
}
vec3 rand3dTo3d(vec3 value){
	return vec3(
		rand3dTo1d(value, vec3(12.989, 78.233, 37.719)),
		rand3dTo1d(value, vec3(39.346, 11.135, 83.155)),
		rand3dTo1d(value, vec3(73.156, 52.235, 09.151))
	);
}
float voronoiNoise(vec2 _value){
	vec3 value = vec3(_value,0.0);
    vec3 baseCell = vec3(floor(value));

    //first pass to find the closest cell
    float minDistToCell = 10.0;
    //vec3 toClosestCell;
    //vec3 closestCell;
    for(float x1=-1.0; x1<=1.0; x1++){
        for(float y1=-1.0; y1<=1.0; y1++){
            for(float z1=-1.0; z1<=1.0; z1++){
                vec3 cell = baseCell + vec3(x1, y1, z1);
                vec3 cellPosition = cell + rand3dTo3d(cell);
                vec3 toCell = cellPosition - value;
                float distToCell = length(toCell);
                if(distToCell < minDistToCell){
                    minDistToCell = distToCell;
                    //closestCell = cell;
                    //toClosestCell = toCell;
                }
            }
        }
    }
	
	////second pass to find the distance to the closest edge
    //float minEdgeDistance = 10.0;
    //for(float x2=-1.0; x2<=1.0; x2++){
    //    for(float y2=-1.0; y2<=1.0; y2++){
    //        for(float z2=-1.0; z2<=1.0; z2++){
    //            vec3 cell = baseCell + vec3(x2, y2, z2);
    //            vec3 cellPosition = cell + rand3dTo3d(cell);
    //            vec3 toCell = cellPosition - value;
//
    //            vec3 diffToClosestCell = abs(closestCell - cell);
    //            bool isClosestCell = diffToClosestCell.x + diffToClosestCell.y + diffToClosestCell.z < 0.1;
    //            if(!isClosestCell){
    //                vec3 toCenter = (toClosestCell + toCell) * 0.5;
    //                vec3 cellDifference = normalize(toCell - toClosestCell);
    //                float edgeDistance = dot(toCenter, cellDifference);
    //                minEdgeDistance = min(minEdgeDistance, edgeDistance);
    //            }
    //        }
    //    }
    //}

    //float random = rand3dTo1d(closestCell , dot_Dir);
    return minDistToCell;// vec3(minDistToCell, random, minEdgeDistance);
}
vec3 firePalette(float i){

    float T = 1400. + 1300.*i; // Temperature range (in Kelvin).
    vec3 L = vec3(7.4, 5.6, 4.4); // Red, green, blue wavelengths (in hundreds of nanometers).
    L = pow(L,vec3(5)) * (exp(1.43876719683e5/(T*L)) - 1.);
    return 1. - exp(-5e8/L); // Exposure level. Set to "50." For "70," change the "5" to a "7," etc.
}

void vertex( )
{
	vec3 v = clamp( cos( VERTEX * 10.0 + vec3( TIME * speed ) ) + vec3( 1.0 ), 0.0, 1.0 );
	VERTEX *= 1.0 + dot( v, v ) * size;
}

void fragment()
{	
	METALLIC = 0.1;
	ROUGHNESS = 0.01;
	//
	vec2 value = UV / cell_size;
	value += TIME;
	vec3 rd = normalize(vec3(UV.x, UV.y, 3.1415926535898/8.));
	float noise = voronoiNoise(value);
	//float valueChange = fwidth(value).x * 0.5;
    //float isBorder = 1.0 - smoothstep(0.05 - valueChange, 0.05 + valueChange, noise);
	
	float outline_alpha = clamp( ( 1.0 - dot( NORMAL, VIEW ) ) * outline_ratio, 0.0, 1.0 );
	vec4 tc = mix(dark_color, bright_color, noise);
    //col = mix(col, col.zyx*.1+ c*.9, clamp((1.+rd.x+rd.y)*0.45, 0., 1.)); // Color dispersion.
	tc *= noise_scale;
	tc = mix(tc, outline_color, max( outline_alpha - 0.3, 0.0 ) );
	ALPHA = tc.a;
	ALBEDO = tc.xyz; //vec3(noise,noise,noise);
}



//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
