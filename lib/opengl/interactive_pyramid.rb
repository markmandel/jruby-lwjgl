java_import org.lwjgl.opengl.GL11
java_import org.lwjgl.opengl.GL15
java_import org.lwjgl.opengl.GL20
java_import org.lwjgl.opengl.GL30
java_import org.lwjgl.opengl.GL32
java_import org.lwjgl.BufferUtils

require "opengl/gl_utils"
require "pry"

#
#  Attempting to do a pyramid that is interactive.
#
class OpenGL::InteractivePyramid
	include OpenGL::GLUtils
	add_start

	#position constants
	RIGHT_EXTENT = 0.5
	LEFT_EXTENT = -RIGHT_EXTENT
	TOP_EXTENT = 0.5
	BOTTOM_EXTENT = -TOP_EXTENT
	FRONT_EXTENT = -1.0
	REAR_EXTENT = -1.5

	#colour constants
	GREEN_COLOUR = [0.75, 0.75, 1.0, 1.0]
	BLUE_COLOUR = [0.0, 0.5, 0.0, 1.0]
	RED_COLOUR = [1.0, 0.0, 0.0, 1.0]
	GREY_COLOUR = [0.8, 0.8, 0.8, 1.0]
	BROWN_COLOUR = [0.5, 0.5, 0.0, 1.0]

	# Constructor
	def initialize

		init_vertex_data

		create_display("Interactive Pyramid");

		#initialise the viewport
		GL11.gl_viewport(0, 0, Display.width, Display.height)
		init_program
		init_vertex_buffer
		init_vertex_array_objects

		GL11.gl_enable(GL11::GL_CULL_FACE)
		GL11.gl_cull_face(GL11::GL_BACK)
		GL11.gl_front_face(GL11::GL_CW)

		GL11.gl_enable(GL11::GL_DEPTH_TEST)
		GL11.gl_depth_mask(true)
		GL11.gl_depth_func(GL11::GL_LEQUAL)
		GL11.gl_depth_range(0.0, 1.0)

		render_loop { display }

		destroy_display

	end

	#initialise the vertex buffer
	def init_vertex_buffer
		@vertex_buffer_id = GL15.gl_gen_buffers
		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, @vertex_buffer_id)

		buffer = BufferUtils.create_float_buffer(@vertex_data.size).put(@vertex_data.to_java(:float)).flip
		GL15.gl_buffer_data(GL15::GL_ARRAY_BUFFER, buffer, GL15::GL_STATIC_DRAW)

		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, 0)


		@index_buffer_id = GL15.gl_gen_buffers
		GL15.gl_bind_buffer(GL15::GL_ELEMENT_ARRAY_BUFFER, @index_buffer_id)

		buffer = BufferUtils.create_short_buffer(@index_data.size).put(@index_data.to_java(:short)).flip
		GL15.gl_buffer_data(GL15::GL_ELEMENT_ARRAY_BUFFER, buffer, GL15::GL_STATIC_DRAW)

		GL15.gl_bind_buffer(GL15::GL_ELEMENT_ARRAY_BUFFER, 0)

	end

	# initialise the vertex array objects
	def init_vertex_array_objects
		#first object
		@vao_id = GL30.gl_gen_vertex_arrays
		GL30.gl_bind_vertex_array(@vao_id)

		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, @vertex_buffer_id)
		GL20.gl_enable_vertex_attrib_array(0)
		GL20.gl_enable_vertex_attrib_array(1)
		GL20.gl_vertex_attrib_pointer(0, 3, GL11::GL_FLOAT, false, 0, 0)
		GL20.gl_vertex_attrib_pointer(1, 4, GL11::GL_FLOAT, false, 0, 5 * 3 * FLOAT_SIZE)

		GL15.gl_bind_buffer(GL15::GL_ELEMENT_ARRAY_BUFFER, @index_buffer_id)

		GL30.gl_bind_vertex_array(0)

	end

	# render a frame
	def display

		#set the colour to clear.
		GL11.gl_clear_color(0.0, 0.0, 0.0, 0.0)

		#clear the buffer. Remember that Java static types come back as Ruby Constants.
		GL11.gl_clear(GL11::GL_COLOR_BUFFER_BIT | GL11::GL_DEPTH_BUFFER_BIT)
		GL20.gl_use_program(@program_id)

		GL30.gl_bind_vertex_array(@vao_id)
		GL11.gl_draw_elements(GL11::GL_TRIANGLES, @index_data.size, GL11::GL_UNSIGNED_SHORT, 0)

		#cleanup
		GL30.gl_bind_vertex_array(0)
		GL20.gl_use_program(0)

	end

	# initialise the program
	def init_program
		@program_id = compile_program('perspective_matrix_vertex_basic.glsl', 'colour_passthrough.glsl')
		@perspective_matrix_location = GL20.gl_get_uniform_location(@program_id, "perspectiveMatrix")

		#set up the perspective matrix
		z_near = 1.0
		z_far = 3.0
		frustrum_scale = 1

		perspective_matrix = BufferUtils.create_float_buffer(16)
		perspective_matrix.put(0, frustrum_scale)
		perspective_matrix.put(5, frustrum_scale)
		perspective_matrix.put(10, (z_far + z_near) / (z_near - z_far))
		perspective_matrix.put(14, (2 * z_far * z_near) / (z_near - z_far))
		perspective_matrix.put(11, -1)

		GL20.gl_use_program(@program_id)
		GL20.gl_uniform_matrix4(@perspective_matrix_location, false, perspective_matrix)
		GL20.gl_use_program(0)

	end

	#initialise the vertex data
	def init_vertex_data
		@vertex_data = [
			#pyramid positions

			# -- bottom square
			LEFT_EXTENT, BOTTOM_EXTENT, FRONT_EXTENT,
			RIGHT_EXTENT, BOTTOM_EXTENT, FRONT_EXTENT,
			RIGHT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,
			LEFT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,

			# -- top position
			((LEFT_EXTENT + RIGHT_EXTENT)/2), TOP_EXTENT, ((FRONT_EXTENT + REAR_EXTENT)/2),

			#Colours
			RED_COLOUR,
			RED_COLOUR,
			RED_COLOUR,
			RED_COLOUR,
			RED_COLOUR
		]

		#flatten out all the colours.
		@vertex_data.flatten!

		@index_data = [
			0, 4, 1
		]
	end

end