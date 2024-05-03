#version 450

// Vertex Attributes
layout(location = 0) in vec3 vPos; // Vertex position in model space
layout(location = 1) in vec3 vNormal; // Vertex position in model space
layout(location = 2) in vec3 vTangent; // Tangent
layout(location = 3) in vec2 vTexCoord; // Vertex texture coordinate (UV)

uniform mat4 _Model; // Model -> World Matrix
uniform mat4 _ViewProjection; // Combined View -> Projection Matrix
uniform mat4 _LightViewProjection; // View + Projection of light source camera
// Vertex Animation Vars
uniform float time;
uniform int movement;
uniform vec3 centerPoint;



uniform vec4 _ClipPlane;
//const vec4 _ClipPlane = vec4(0, -1, 0, -5); //culls everything above height (15)


out vec4 LightSpacePos;
out Surface {
	vec3 WorldPos; // Vertex position in world space
	vec3 WorldNormal; // Vertex normal in world space
	vec2 TexCoord;
	mat3 TBN; // TBN matrix
}vs_out;

// Fish Movement 
vec3 wave(vec3 pos){

	float frequency = 1;
    float amplitude = 0.5;

    float displacement = amplitude * sin(time * frequency + pos.z);
    
    vec3 newPos = vPos + vec3(displacement, 0, 0);

	return newPos;
}
// Tree Movement
vec3 sway(vec3 pos){

	float frequency = 0.5;
    float amplitude = 0.05;

    float displacement = amplitude * sin(time * frequency );

	float displacement2 = (amplitude / 2) * sin(time * (frequency / 2));
    
	if(pos.y > centerPoint.y){
		vec3 newPos = vPos + vec3(0, displacement2, displacement);
		return newPos;
	}else {
		return pos;
	}
	
}


void main() {
	// Transform vertex position to World Space
	vs_out.WorldPos = vec3(_Model * vec4(vPos, 1.0));

	gl_ClipDistance[0] = dot((_Model * vec4(vPos, 1.0)), _ClipPlane);

	// Vertex position in light space to pass to fragment shader
	LightSpacePos = _LightViewProjection * _Model * vec4(vPos, 1);

	// Transform vertex normal to World Space using Normal Matrix
	vs_out.WorldNormal = transpose(inverse(mat3(_Model))) * vNormal;

	// TBN Matrix
	vec3 T = normalize(vec3(_Model * vec4(vTangent, 0.0)));
	vec3 B = normalize(vec3(_Model * vec4(cross(vNormal, T), 0.0)));
	vec3 N = normalize(vec3(_Model * vec4(vNormal, 0.0)));
	vs_out.TBN = mat3(T, B, N);

	vs_out.TexCoord = vTexCoord;

	// checking to see for vertex shifter
	vec3 newPos;
	if (movement == 1){
		newPos = wave(vPos);
	}else if(movement == 2){
		newPos = sway(vPos);
	}else
	{
		newPos = vPos;
	} 

	
	// Transform vertex position to homogeneous clip space
	gl_Position = _ViewProjection * _Model * vec4(newPos, 1.0);
}