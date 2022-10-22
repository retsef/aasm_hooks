# frozen_string_literal: true

require_relative "lib/aasm_callbacks/version"

Gem::Specification.new do |spec|
  spec.name = "aasm_callbacks"
  spec.version = AasmHooks::VERSION
  spec.authors = ["Roberto Scinocca", "retsef"]
  spec.email = ["roberto.scinocca@gmail.com"]

  spec.summary = "Allow to use callbacks with AASM outside aasm block"
  spec.homepage = "https://github.com/retsef/aasm_callbacks"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'aasm', '>= 4.2'
end
