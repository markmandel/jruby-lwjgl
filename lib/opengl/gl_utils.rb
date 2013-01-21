java_import org.lwjgl.opengl.GL20
java_import org.lwjgl.opengl.GL11

module OpenGL::GLUtils

		#pre calculate the byte size of items. Useful.
		FLOAT_SIZE = (java.lang.Float::SIZE/8)
		SHORT_SIZE = (java.lang.Short::SIZE/8)

		# initialised the program with the shaders that have been passed through
		# @param [String] vertex_shader
		# @param [String] frag_shader
		def compile_program(vertex_shader, frag_shader)
			vertex_shader = compile_shader(GL20::GL_VERTEX_SHADER, vertex_shader)
			frag_shader = compile_shader(GL20::GL_FRAGMENT_SHADER, frag_shader)

			program_id = GL20.gl_create_program

			GL20.gl_attach_shader(program_id, vertex_shader)
			GL20.gl_attach_shader(program_id, frag_shader)
			GL20.gl_link_program(program_id)
			GL20.gl_validate_program(program_id)

			puts "Validate Program", GL20.gl_get_program_info_log(program_id, 200)

			GL20.gl_delete_shader(vertex_shader)
			GL20.gl_delete_shader(frag_shader)

			program_id
		end

		# create a shader for you, and return the id
		# @param [Integer] shader_type the GL20 shader type int
		# @param [String] file_name the name of the glsl file
		# @return [Integer] the shader id
		def compile_shader(shader_type, file_name)
			shader_id = GL20.gl_create_shader(shader_type)
			shader_file = File.new File.expand_path("../../glsl/#{file_name}", __FILE__)

			GL20.gl_shader_source(shader_id, shader_file.read)
			GL20.gl_compile_shader(shader_id)

			puts file_name, GL20.gl_get_shader_info_log(shader_id, 200)

			raise "Error compiling shader #{file_name}" if (GL20.gl_get_shader(shader_id, GL20::GL_COMPILE_STATUS) == GL11::GL_FALSE)

			shader_id
		end

		# run the render loop
		# @param [Proc] display
		def render_loop(&display_block)

			while(!Display.is_close_requested)
				display_block.call

				# we'll force it down to 60 FPS
				Display.sync(60)
				Display.update()
			end

		end

		def destroy_display
			Display.destroy
		end

		def create_display(title, width=800, height=600)
			Display.display_mode = DisplayMode.new(width, height)
			Display.title = title
			Display.create
		end

		# hook for class methods
		def self.included(base)
			base.extend(ClassMethods)
		end

		module ClassMethods

			# creates a start script for this item
			def add_start
				class << self
					define_method :start do
						self.new
					end
				end
			end

		end

end
