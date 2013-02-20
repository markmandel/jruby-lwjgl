#external stuff
require 'java/lwjgl.jar'
require 'java/lwjgl_util.jar'

#monkey patching
require 'extensions/math'

#define the default modules
module OpenGL
end

#internal pieces
require "opengl/version"

#include all the files.
Dir.new(File.join(File.dirname(__FILE__), "opengl")).find_all { |item| item.end_with?('.rb') }.each do |item|
	require "opengl/#{item}"
end