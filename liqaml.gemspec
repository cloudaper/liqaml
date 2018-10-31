
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "liqaml/version"

Gem::Specification.new do |spec|
  spec.name          = "liqaml"
  spec.version       = Liqaml::VERSION
  spec.authors       = ["Cloudaper"]

  spec.summary       = %q{Use Liquid template language with Yaml to process nested translations}

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # TODO host = "https://github.com/cloudaper/liqaml" ?
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir['lib/**/*.rb']

  spec.add_runtime_dependency "message_format", "~> 0.0.5"
  spec.add_runtime_dependency "liquid",         "~> 4.0"

  spec.add_development_dependency "bundler",  "~> 1.16"
  spec.add_development_dependency "rake",     "~> 10.0"
  spec.add_development_dependency "rspec",    "~> 3.0"
end
