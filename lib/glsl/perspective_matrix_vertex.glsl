#version 330

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 colour;

smooth out vec4 theColour;

uniform vec3 offset;
uniform mat4 perspectiveMatrix;

void main()
{
	vec4 cameraPos = position + vec4(offset.x, offset.y, offset.z, 0.0);

	gl_Position = perspectiveMatrix * cameraPos;
	theColour = colour;
}