# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'staccato/rack/version'

Gem::Specification.new do |spec|
  spec.name          = 'staccato-rack'
  spec.version       = Staccato::Rack::VERSION
  spec.authors       = ['Grant Speelman']
  spec.email         = ['grant.speelman@ubxd.com']

  spec.summary       = 'TODO: Write a short summary, because Rubygems requires one.'
  spec.description   = 'TODO: Write a longer description or delete this line.'
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(/^(test|spec|features)\//) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(/^exe\//) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rack'
  spec.add_dependency 'staccato'

  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'minitest', '>= 0.8.0'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'rake', '~> 10.0'
end
