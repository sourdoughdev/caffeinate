# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'caffeinate/version'

Gem::Specification.new do |spec|
  spec.name          = "caffeinate"
  spec.version       = Caffeinate::VERSION
  spec.authors       = ["Thomas McGoey-Smith"]
  spec.email         = ["thomas@tamcgoey.com"]
  spec.summary       = %q{Simple api wrapper to purchase eGifts from Starbucks.com (USA and CAN only)}
  spec.description   = %q{Simple api purchase eGifts from Starbucks.com (USA and CAN only)}
  spec.homepage      = "http://tamcgoey.com/gems/caffeinate/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.3"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.3"

  spec.add_runtime_dependency "mechanize", "~> 2.7"
end
