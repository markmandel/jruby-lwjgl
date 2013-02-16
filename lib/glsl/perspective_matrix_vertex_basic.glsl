#version 330

layout(location = 0) in vec4 position;
layout(location = 1) in vec4 colour;

smooth out vec4 theColour;

uniform mat4 perspectiveMatrix;
uniform mat4 transformMatrix;

void main()
{
	gl_Position =  perspectiveMatrix * transformMatrix * position;
	theColour = colour;
}