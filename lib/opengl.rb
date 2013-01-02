#external stuff
require 'java'
require 'java/lwjgl.jar'

#monkey patching

#define the default modules
module OpenGL
end

#internal pieces
require "opengl/version"
require 'opengl/basic_display'
