# Opengl

Examples of using [LWJGL](http://www.lwjgl.org/) with [JRuby](http://jruby.org/).

As I'm learning LWJGL and OpenGL, I'm uploading examples here and writing blog posts on my [blog](http://www.compoundtheory.com)

The study material is [Learning Modern 3D Graphics Programming](http://arcsynthesis.org/gltut/)

This is set up as a gem for convenience, although I can't see why you would want to install it.

Please note: This was developed and tested on Linux. The native extensions for Windows and OSX are in this repository as well, but I've done
no testing. So pull requests to make it work on other platforms will be appreciated!

## Usage

You may want to install JRuby with RVM, as the .rvmrc sets up the appropriate JRUBY_OPTS environment variables to tell JRuby
to tell the JVM to load up the native extensions that LWJGL needs.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create new Pull Request
