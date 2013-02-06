java_import org.lwjgl.opengl.GL11
java_import org.lwjgl.opengl.GL15
java_import org.lwjgl.opengl.GL20
java_import org.lwjgl.opengl.GL30
java_import org.lwjgl.BufferUtils

require "opengl/gl_utils"
require "pry"

#
#  overlapping items, but with no depth.
#  http://arcsynthesis.org/gltut/Positioning/Tutorial%2005.html
class OpenGL::OverlapNoDepth
	include OpenGL::GLUtils
	add_start

	#position constants
	RIGHT_EXTENT = 0.8
	LEFT_EXTENT = -RIGHT_EXTENT
	TOP_EXTENT = 0.20
	MIDDLE_EXTENT = 0.0
	BOTTOM_EXTENT = -TOP_EXTENT
	FRONT_EXTENT = -1.25
	REAR_EXTENT = -1.75

	#colour constants
	GREEN_COLOUR = [0.75, 0.75, 1.0, 1.0]
	BLUE_COLOUR = [0.0, 0.5, 0.0, 1.0]
	RED_COLOUR = [1.0, 0.0, 0.0, 1.0]
	GREY_COLOUR = [0.8, 0.8, 0.8, 1.0]
	BROWN_COLOUR = [0.5, 0.5, 0.0, 1.0]

	# Constructor
	def initialize

		init_vertex_data

		create_display("Overlap with No Depth");

		#initialise the viewport
		GL11.gl_viewport(0, 0, Display.width, Display.height)
		init_program
		init_vertex_buffer
		init_vertex_array_objects

		GL11.gl_enable(GL11::GL_CULL_FACE)
		GL11.gl_cull_face(GL11::GL_BACK)
		GL11.gl_front_face(GL11::GL_CW)

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
		@vao1_id = GL30.gl_gen_vertex_arrays
		GL30.gl_bind_vertex_array(@vao1_id)

		GL15.gl_bind_buffer(GL15::GL_ARRAY_BUFFER, @vertex_buffer_id)
		GL20.gl_enable_vertex_attrib_array(0)
		GL20.gl_enable_vertex_attrib_array(1)
		GL20.gl_vertex_attrib_pointer(0, 3, GL11::GL_FLOAT, false, 0, 0)
		GL20.gl_vertex_attrib_pointer(1, 4, GL11::GL_FLOAT, false, 0, 36 * 3 * FLOAT_SIZE)

		GL15.gl_bind_buffer(GL15::GL_ELEMENT_ARRAY_BUFFER, @index_buffer_id)

		GL30.gl_bind_vertex_array(0)

		# second object
		@vao2_id = GL30.gl_gen_vertex_arrays
		GL30.gl_bind_vertex_array(@vao2_id)

		GL20.gl_enable_vertex_attrib_array(0)
		GL20.gl_enable_vertex_attrib_array(1)

		GL20.gl_vertex_attrib_pointer(0, 3, GL11::GL_FLOAT, false, 0, (36 / 2) * 3 * FLOAT_SIZE)
		GL20.gl_vertex_attrib_pointer(1, 4, GL11::GL_FLOAT, false, 0, (36 * 3 * FLOAT_SIZE) + ((36/2) * 4 * FLOAT_SIZE))
		GL15.gl_bind_buffer(GL15::GL_ELEMENT_ARRAY_BUFFER, @index_buffer_id)

		GL30.gl_bind_vertex_array(0)
	end

	# render a frame
	def display

		#set the colour to clear.
		GL11.gl_clear_color(0.0, 0.0, 0.0, 0.0)

		#clear the buffer. Remember that Java static types come back as Ruby Constants.
		GL11.gl_clear(GL11::GL_COLOR_BUFFER_BIT)
		GL20.gl_use_program(@program_id)

		GL30.gl_bind_vertex_array(@vao1_id)
		GL20.gl_uniform3f(@offset_location, 0.0, 0.0, 0.0)
		GL11.gl_draw_elements(GL11::GL_TRIANGLES, @index_data.size, GL11::GL_UNSIGNED_SHORT, 0)

		GL30.gl_bind_vertex_array(@vao2_id)
		GL20.gl_uniform3f(@offset_location, 0.0, 0.0, -1.0)
		GL11.gl_draw_elements(GL11::GL_TRIANGLES, @index_data.size, GL11::GL_UNSIGNED_SHORT, 0)

		#cleanup
		GL30.gl_bind_vertex_array(0)
		GL20.gl_use_program(0)

	end

	# initialise the program
	def init_program
		@program_id = compile_program('perspective_matrix_vertex.glsl', 'colour_passthrough.glsl')
		@offset_location = GL20.gl_get_uniform_location(@program_id, "offset")
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
			#Object 1 positions
			LEFT_EXTENT, TOP_EXTENT, REAR_EXTENT,
			LEFT_EXTENT, MIDDLE_EXTENT, FRONT_EXTENT,
			RIGHT_EXTENT, MIDDLE_EXTENT, FRONT_EXTENT,
			RIGHT_EXTENT, TOP_EXTENT, REAR_EXTENT,

			LEFT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,
			LEFT_EXTENT, MIDDLE_EXTENT, FRONT_EXTENT,
			RIGHT_EXTENT, MIDDLE_EXTENT, FRONT_EXTENT,
			RIGHT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,

			LEFT_EXTENT, TOP_EXTENT, REAR_EXTENT,
			LEFT_EXTENT, MIDDLE_EXTENT, FRONT_EXTENT,
			LEFT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,

			RIGHT_EXTENT, TOP_EXTENT, REAR_EXTENT,
			RIGHT_EXTENT, MIDDLE_EXTENT, FRONT_EXTENT,
			RIGHT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,

			LEFT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,
			LEFT_EXTENT, TOP_EXTENT, REAR_EXTENT,
			RIGHT_EXTENT, TOP_EXTENT, REAR_EXTENT,
			RIGHT_EXTENT, BOTTOM_EXTENT, REAR_EXTENT,

			#Object 2 positions
			TOP_EXTENT, RIGHT_EXTENT, REAR_EXTENT,
			MIDDLE_EXTENT, RIGHT_EXTENT, FRONT_EXTENT,
			MIDDLE_EXTENT, LEFT_EXTENT, FRONT_EXTENT,
			TOP_EXTENT, LEFT_EXTENT, REAR_EXTENT,

			BOTTOM_EXTENT, RIGHT_EXTENT, REAR_EXTENT,
			MIDDLE_EXTENT, RIGHT_EXTENT, FRONT_EXTENT,
			MIDDLE_EXTENT, LEFT_EXTENT, FRONT_EXTENT,
			BOTTOM_EXTENT, LEFT_EXTENT, REAR_EXTENT,

			TOP_EXTENT, RIGHT_EXTENT, REAR_EXTENT,
			MIDDLE_EXTENT, RIGHT_EXTENT, FRONT_EXTENT,
			BOTTOM_EXTENT, RIGHT_EXTENT, REAR_EXTENT,

			TOP_EXTENT, LEFT_EXTENT, REAR_EXTENT,
			MIDDLE_EXTENT, LEFT_EXTENT, FRONT_EXTENT,
			BOTTOM_EXTENT, LEFT_EXTENT, REAR_EXTENT,

			BOTTOM_EXTENT, RIGHT_EXTENT, REAR_EXTENT,
			TOP_EXTENT, RIGHT_EXTENT, REAR_EXTENT,
			TOP_EXTENT, LEFT_EXTENT, REAR_EXTENT,
			BOTTOM_EXTENT, LEFT_EXTENT, REAR_EXTENT,

			#Object 1 COLOURs
			GREEN_COLOUR,
			GREEN_COLOUR,
			GREEN_COLOUR,
			GREEN_COLOUR,

			BLUE_COLOUR,
			BLUE_COLOUR,
			BLUE_COLOUR,
			BLUE_COLOUR,

			RED_COLOUR,
			RED_COLOUR,
			RED_COLOUR,

			GREY_COLOUR,
			GREY_COLOUR,
			GREY_COLOUR,

			BROWN_COLOUR,
			BROWN_COLOUR,
			BROWN_COLOUR,
			BROWN_COLOUR,

			#Object 2 COLOURs
			RED_COLOUR,
			RED_COLOUR,
			RED_COLOUR,
			RED_COLOUR,

			BROWN_COLOUR,
			BROWN_COLOUR,
			BROWN_COLOUR,
			BROWN_COLOUR,

			BLUE_COLOUR,
			BLUE_COLOUR,
			BLUE_COLOUR,

			GREEN_COLOUR,
			GREEN_COLOUR,
			GREEN_COLOUR,

			GREY_COLOUR,
			GREY_COLOUR,
			GREY_COLOUR,
			GREY_COLOUR,
		]

		#flatten out all the colours.
		@vertex_data.flatten!

		@index_data = [
			0, 2, 1,
			3, 2, 0,

			4, 5, 6,
			6, 7, 4,

			8, 9, 10,
			11, 13, 12,

			14, 16, 15,
			17, 16, 14,
		]
	end

end