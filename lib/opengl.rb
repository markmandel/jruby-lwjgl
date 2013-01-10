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
require 'opengl/show_triangle'
require 'opengl/show_triangle_gradient'
require 'opengl/show_triangle_colours'
require 'opengl/show_triangle_vert_offset'
require 'opengl/show_triangle_vert_frag_offset'
