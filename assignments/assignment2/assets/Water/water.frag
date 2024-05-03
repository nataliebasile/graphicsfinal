#version 450 core

in Surface {
	vec3 WorldPos; // Vertex position in world space
	vec3 WorldNormal; // Vertex normal in world space
	vec2 TexCoord;
	mat3 TBN; // TBN matrix
}fs_in;

in vec4 ClipSpacePos;

uniform sampler2D _ReflectionTexture;
uniform sampler2D _RefractionTexture;
uniform sampler2D _DUDVTexture;

uniform float deltaTime;

const float distortionStrength = 0.02;

out vec4 FragColor;

void main() {
	// Convert clip space to NDC
	vec3 NDC = ClipSpacePos.xyz/ClipSpacePos.w;

	// Convert NDC to screen space
	vec3 screenSpaceCoord = NDC/2.0 + 0.5;

	// Get TexCoord for refraction and reflection
	vec2 refractionTextureCoord = vec2(screenSpaceCoord.x, screenSpaceCoord.y);
	vec2 reflectionTextureCoord = vec2(screenSpaceCoord.x, -screenSpaceCoord.y);

	vec2 distortion = (texture(_DUDVTexture, vec2(fs_in.TexCoord.x + (deltaTime/5.0f), fs_in.TexCoord.y)).rg * 2.0 - 1.0) * distortionStrength;
	refractionTextureCoord += distortion;
	refractionTextureCoord = clamp(refractionTextureCoord, 0.001f, 0.999f);
	reflectionTextureCoord += distortion;
	reflectionTextureCoord.x = clamp(reflectionTextureCoord.x, 0.001f, 0.999f);
	reflectionTextureCoord.y = clamp(reflectionTextureCoord.y, -0.999f, -0.001f);
	
	vec4 reflectionColor = texture(_ReflectionTexture, reflectionTextureCoord);
	vec4 refractionColor = texture(_RefractionTexture, refractionTextureCoord);

	//FragColor = refractionColor;
	FragColor = mix(reflectionColor, refractionColor, 0.5);
}