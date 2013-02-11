#version 330

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 colour;

smooth out vec4 theColour;

uniform mat4 cameraToClipMatrix;
uniform mat4 modelToCameraMatrix;

void main()
{
	vec4 cameraPos = modelToCameraMatrix * position;
	gl_Position = cameraToClipMatrix * cameraPos;
	theColour = colour;
}