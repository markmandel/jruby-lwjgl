java_import org.lwjgl.opengl.Display
java_import org.lwjgl.opengl.DisplayMode
java_import org.lwjgl.opengl.GL11
java_import org.lwjgl.opengl.GL15
java_import org.lwjgl.opengl.GL20
java_import org.lwjgl.opengl.GL30
java_import org.lwjgl.BufferUtils

#
# Let's display a triangle, with a gradient
class OpenGL::ShowTriangleColours

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

		Display.display_mode = DisplayMode.new(800, 600)
		Display.title = "I am a triangle! (with different colours!)"
		Display.create

		#initialise the viewport
		GL11.gl_viewport(0, 0, Display.width, Display.height)

		init_program
		init_vertex_buffers

		while(!Display.is_close_requested)

			display

			# we'll force it down to 60 FPS
			Display.sync(60)
			Display.update()
		end

		Display.destroy


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

	# initialise the program
	def init_program
		vertex_shader = create_shader(GL20::GL_VERTEX_SHADER, 'colour_gradient_vertex.glsl')
		frag_shader = create_shader(GL20::GL_FRAGMENT_SHADER, 'colour_grandient_fragment.glsl')

		@program_id = GL20.gl_create_program
		GL20.gl_attach_shader(@program_id, vertex_shader)
		GL20.gl_attach_shader(@program_id, frag_shader)
		GL20.gl_link_program(@program_id)
		GL20.gl_validate_program(@program_id)

		puts "Validate Program", GL20.gl_get_program_info_log(@program_id, 200)

		GL20.gl_delete_shader(vertex_shader)
		GL20.gl_delete_shader(frag_shader)

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

	# create a shader for you, and return the id
	# @param [Integer] shader_type the GL20 shader type int
	# @param [String] file_name the name of the glsl file
	# @return [Integer] the shader id
	def create_shader(shader_type, file_name)
		shader_id = GL20.gl_create_shader(shader_type)
		shader_file = File.new File.expand_path("../../glsl/#{file_name}", __FILE__)

		GL20.gl_shader_source(shader_id, shader_file.read)
		GL20.gl_compile_shader(shader_id)

		puts file_name, GL20.gl_get_shader_info_log(shader_id, 200)

		shader_id
	end

	# off we go
	def self.start
		OpenGL::ShowTriangleColours.new
	end

end