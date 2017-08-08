# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "file_scanner/version"

Gem::Specification.new do |s|
  s.name = "file_scanner"
  s.version = FileScanner::VERSION
  s.authors = ["costajob"]
  s.email = ["costajob@gmail.com"]
  s.summary = "A scanner routine that collect file paths basing on specified filters and apply to them a set of custom policies"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|test|s|features)/}) }
  s.require_paths = ["lib"]
  s.license = "MIT"
  s.required_ruby_version = ">= 2.1.2"

  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
end
