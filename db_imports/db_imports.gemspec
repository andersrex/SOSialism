# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'db_imports/version'

Gem::Specification.new do |spec|
  spec.name          = "db_imports"
  spec.version       = DbImports::VERSION
  spec.authors       = ["Hotloo Xiranood"]
  spec.email         = ["hotloo.xiranood@gmail.com"]
  spec.description   = %q{We pour data}
  spec.summary       = %q{We pour data}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rake'
  spec.add_dependency 'neography'
  spec.add_dependency 'mongo'
  spec.add_dependency 'bson_ext'

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_dependency "rake"
end
