# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "smapi_tester/version"


Gem::Specification.new do |spec|
  spec.name          = "smapi_tester"
  spec.version       = SMAPITester::VERSION
  spec.authors       = ["sarkonovich"]
  spec.email         = ["arkonovs @ reed. edu"]

  spec.summary       = "A SMAPI framework to test Alexa Skills"
  spec.description   = "A SMAPI framework to test Alexa Skills"
  spec.homepage      = "https://github.com/sarkonovich/AlexaTester"
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://mygemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "httparty"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "webmock"
end
