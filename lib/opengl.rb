#external stuff
require 'java'
require 'java/lwjgl.jar'

#monkey patching

#define the default modules
module OpenGL
end

#internal pieces
require "opengl/version"

#include all the files.
Dir.new(File.join(File.dirname(__FILE__), "opengl")).find_all { |item| item.end_with?('.rb') }.each do |item|
	require "opengl/#{item}"
end