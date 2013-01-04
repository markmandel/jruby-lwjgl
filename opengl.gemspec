# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'opengl/version'

Gem::Specification.new do |gem|
  gem.name          = "jruby-lwjgl"
  gem.version       = Opengl::VERSION
  gem.authors       = ["Mark Mandel"]
  gem.email         = ["mark.mandel@gmail.com"]
  gem.description   = %q{Examples of using OpenGL with LWJGL with JRuby}
  gem.summary       = %q{Examples of using OpenGL with LWJGL with JRuby}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  # development stuff I can't live without
  gem.add_development_dependency "rake"
  gem.add_development_dependency "yard"
  gem.add_development_dependency "kramdown"
  gem.add_development_dependency "pry"
  gem.add_development_dependency "pry-doc"
  gem.add_development_dependency "pry-nav"

end
