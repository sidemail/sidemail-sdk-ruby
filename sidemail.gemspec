# frozen_string_literal: true

require_relative "lib/sidemail/version"

Gem::Specification.new do |spec|
  spec.name          = "sidemail"
  spec.version       = Sidemail::VERSION
  spec.authors       = ["Sidemail"]
  spec.email         = ["support@sidemail.io"]

  spec.summary       = "Official Sidemail.io Ruby SDK"
  spec.description   = "Official Sidemail.io Ruby library providing convenient access to the Sidemail API."
  spec.homepage      = "https://sidemail.io"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{lib}/**/*", "README.md", "LICENSE.txt"]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "base64"
  spec.add_dependency "fiddle"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "webmock", "~> 3.18"
end
