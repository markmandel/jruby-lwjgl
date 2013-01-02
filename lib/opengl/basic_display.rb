java_import org.lwjgl.opengl.Display
java_import org.lwjgl.opengl.DisplayMode

#
# Just a basic display using lwjgl
class OpenGL::BasicDisplay

	# initialise
	def initialize
		Display.display_mode = DisplayMode.new(800, 600)
		Display.create

		while(!Display.is_close_requested)
			Display.update()
		end

		Display.destroy

	end

	def self.start
		OpenGL::BasicDisplay.new
	end

end