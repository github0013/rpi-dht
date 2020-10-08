lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rpi/dht/version"

Gem::Specification.new do |spec|
  spec.name = "rpi-dht"
  spec.version = RPi::Dht::VERSION
  spec.authors = %w[github0013]
  spec.email = %w[github0013@gmail.com]

  spec.summary = "Pure Ruby implementation of DHT11/22 sensor"
  spec.description = "Fully written in Ruby (except external gems)"
  spec.homepage = "https://github.com/github0013/rpi-dht"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/github0013/rpi-dht"
    spec.metadata["changelog_uri"] = "https://github.com/github0013/rpi-dht/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
            "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files =
    Dir.chdir(File.expand_path("..", __FILE__)) do
      `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
    end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency "rpi_gpio"

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "naught"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "guard-rspec"
end
