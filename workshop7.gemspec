# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'workshop7/version'

Gem::Specification.new do |spec|
  spec.name          = "workshop7"
  spec.version       = Workshop7::VERSION
  spec.authors       = ["Mateusz Palyz"]
  spec.email         = ["m.palyz@pilot.co"]
  spec.summary       = %q{workshop 7}
  spec.description   = %q{workshop 7 tasks}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "dotenv-rails"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "xml-simple"
end
