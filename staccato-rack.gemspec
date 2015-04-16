# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'staccato/rack/version'

Gem::Specification.new do |spec|
  spec.name          = 'staccato-rack'
  spec.version       = Staccato::Rack::VERSION
  spec.authors       = ['Grant Speelman']
  spec.email         = ['grant.speelman@ubxd.com']

  spec.summary       = 'Simple rack middleware using Staccato'
  spec.description   = 'Rack middleware to send analytics to google using Staccato with the aim to be used for apis'
  spec.homepage      = 'https://github.com/unboxed/staccato-rack'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'rack'
  spec.add_dependency 'staccato', '>= 0.3.0'

  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'minitest', '>= 0.8.0'
  spec.add_development_dependency 'rr'
  spec.add_development_dependency 'minitest-reporters'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
end
