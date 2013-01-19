java_import org.lwjgl.opengl.Display
java_import org.lwjgl.opengl.DisplayMode
java_import org.lwjgl.opengl.GL11
java_import org.lwjgl.opengl.GL15
java_import org.lwjgl.opengl.GL20
java_import org.lwjgl.opengl.GL30
java_import org.lwjgl.BufferUtils

require "opengl/gl_utils"

#
# Let's display a triangle, with a gradient
class OpenGL::ShowTriangleColours
	include OpenGL::GLUtils
	add_start

	# initialise
	def initialize

		@vertex_data = [
			0.0,    0.5, 0.0, 1.0,
			0.5, -0.366, 0.0, 1.0,
			-0.5, -0.366, 0.0, 1.0,
			1.0,    0.0, 0.0, 1.0,
			0.0,    1.0, 0.0, 1.0,
			0.0,    0.0, 1.0, 1.0,
		]

		#pre calculate the byte size of a float.
		@float_size = (java.lang.Float::SIZE/8)

		create_display("I am a triangle! (with different colours!)")

		#initialise the viewport
		GL11.gl_viewport(0, 0, Display.width, Display.height)

		@program_id = compile_program 'colour_gradient_vertex.glsl', 'colour_grandient_fragment.glsl'
		init_vertex_buffers

		render_loop { display }

		destroy_display


	end

	# display loop
	def display

		#set the colour to clear.
		GL11.gl_clear_color(0.0, 0.0, 0.0, 0.0)

		#clear the buffer. Remember that Java static types come back as Ruby Constants.
		GL11.gl_clear(GL11::GL_COLOR_BUFFER_BIT)
		GL20.gl_use_program(@program_id)

		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, @buffer_id)

		# we have 2 points
		GL20.gl_enable_vertex_attrib_array(0)
		GL20.gl_enable_vertex_attrib_array(1)

		GL20.gl_vertex_attrib_pointer(0, 4, GL11::GL_FLOAT, false, 0, 0)

		#Floats are 4 bytes, and there are 12 of them = 48 offset
		GL20.gl_vertex_attrib_pointer(1, 4, GL11::GL_FLOAT, false, 0, @float_size * 12)
		GL11.gl_draw_arrays(GL11::GL_TRIANGLES, 0, 3)

		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, 0)
		GL20.gl_disable_vertex_attrib_array(0)
		GL20.gl_disable_vertex_attrib_array(1)
		GL20.gl_use_program(0)

	end

	# initialise the vertex buffers
	def init_vertex_buffers
		#vao_id = GL30.gl_gen_vertex_arrays
		#GL30.gl_bind_vertex_array(vao_id)

		@buffer_id = GL15.gl_gen_buffers
		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, @buffer_id)

		float_buffer = BufferUtils.create_float_buffer(@vertex_data.size)
		float_buffer.put(@vertex_data.to_java(:float))

		#MUST FLIP THE BUFFER! THIS PUTS IT BACK TO THE BEGINNING!
		float_buffer.flip

		GL15.gl_buffer_data(GL15::GL_ARRAY_BUFFER, float_buffer, GL15::GL_STATIC_DRAW)

		# cleanup
		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, 0)
		#GL30.gl_bind_vertex_array(0)
	end

end