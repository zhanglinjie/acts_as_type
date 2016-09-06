lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acts_as_type/version'

Gem::Specification.new do |spec|
  spec.name          = "acts_as_type"
  spec.version       = ActsAsType::VERSION
  spec.authors       = ["Franky"]
  spec.email         = ["zhanglinjie412@gmail.com"]
  spec.description   = %q{A gem make a model attribute acts as a type}
  spec.summary       = %q{}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # spec.add_dependency 'engtagger'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'activerecord', ">= 3.0"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end