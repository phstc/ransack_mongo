# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ransack_mongo/version'

Gem::Specification.new do |spec|
  spec.name          = 'ransack_mongo'
  spec.version       = RansackMongo::VERSION
  spec.authors       = ['Pablo Cantero']
  spec.email         = ['pablo@pablocantero.com']
  spec.homepage      = 'https://github.com/phstc/ransack_mongo'
  spec.summary       = %q{Query params based searching for MongoDB}
  spec.description   = %q{Ransack Mongo is based on Ransack but for MongoDB}
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
