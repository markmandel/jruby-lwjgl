java_import org.lwjgl.opengl.Display
java_import org.lwjgl.opengl.DisplayMode
java_import org.lwjgl.opengl.GL11
java_import org.lwjgl.opengl.GL15
java_import org.lwjgl.opengl.GL20
java_import org.lwjgl.opengl.GL30
java_import org.lwjgl.BufferUtils
java_import org.lwjgl.Sys
require "opengl/gl_utils"

#
# Let's display a triangle!
class OpenGL::ShowTriangleVertOffset
	include OpenGL::GLUtils

	add_start

	# initialise
	def initialize

		@vertex_positions = [
			0.75, 0.75, 0.0, 1.0,
			0.75, -0.75, 0.0, 1.0,
			-0.75, -0.75, 0.0, 1.0,
		]

		create_display("I am a triangle! (with vertex offsets!)")

		#initialise the viewport
		GL11.gl_viewport(0, 0, Display.width, Display.height)

		@program_id = compile_program("offset_vertex.glsl", "basic_fragment.glsl")

		init_vertex_buffers

		render_loop { display }

		destroy_display

	end

	# display loop
	def display

		x_offset, y_offset = compute_position_offsets

		#set the colour to clear.
		GL11.gl_clear_color(0.0, 0.0, 0.0, 0.0)

		#clear the buffer. Remember that Java static types come back as Ruby Constants.
		GL11.gl_clear(GL11::GL_COLOR_BUFFER_BIT)

		GL20.gl_use_program(@program_id)

		GL20.gl_uniform2f(@offset_location, x_offset, y_offset)

		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, @buffer_id)
		GL20.gl_enable_vertex_attrib_array(0)
		GL20.gl_vertex_attrib_pointer(0, 4, GL11::GL_FLOAT, false, 0, 0)
		GL11.gl_draw_arrays(GL11::GL_TRIANGLES, 0, 3)

		GL20.gl_disable_vertex_attrib_array(0)
		GL20.gl_use_program(0)

	end

	# compute the offsets based on the time
	# @return [Float] [Float] the x_offset, y_offset
	def compute_position_offsets
		loop_duration = 5
		scale = (Math::PI * 2.0) / loop_duration
		elapsed_time = Sys.get_time / 1000.0
		current_time_through_loop = elapsed_time % loop_duration

		x_offset = Math.cos(current_time_through_loop * scale) * 0.5
		y_offset = Math.sin(current_time_through_loop * scale) * 0.5

		return x_offset, y_offset

	end

	# initialise the vertex buffers
	def init_vertex_buffers
		#vao_id = GL30.gl_gen_vertex_arrays
		#GL30.gl_bind_vertex_array(vao_id)

		@buffer_id = GL15.gl_gen_buffers
		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, @buffer_id)

		float_buffer = BufferUtils.create_float_buffer(@vertex_positions.size)
		float_buffer.put(@vertex_positions.to_java(:float))

		#MUST FLIP THE BUFFER! THIS PUTS IT BACK TO THE BEGINNING!
		float_buffer.flip

		GL15.gl_buffer_data(GL15::GL_ARRAY_BUFFER, float_buffer, GL15::GL_STATIC_DRAW)

		# cleanup
		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, 0)
		#GL30.gl_bind_vertex_array(0)
	end

end