
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "lotify/version"

Gem::Specification.new do |spec|
  spec.name          = "lotify"
  spec.version       = Lotify::VERSION
  spec.authors       = ["etrex kuo"]
  spec.email         = ["et284vu065k3@gmail.com"]

  spec.summary       = "LINE Notify SDK"
  spec.description   = "LINE Notify SDK for bot oauth and api send"
  spec.homepage      = "https://github.com/etrex/lotify"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
