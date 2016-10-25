# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "gothonweb"
  spec.version       = '1.0'
  spec.authors       = ["Ovsjah"]
  spec.email         = ["ovsjah@gmail.com"]
  spec.summary       = %q{The game about invaders}
  spec.description   = %q{The game about invaders from planet Percal #25}
  spec.homepage      = "http://domainforproject.com/"
  spec.license       = "MIT"
  
  spec.files         = ['lib/gothonweb.rb']
  spec.executables   = ['bin/app.rb']
  spec.test_files    = ['tests/test_map.rb']
  spec.require_paths = ["lib"]
end
