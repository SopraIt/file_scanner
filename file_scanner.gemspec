# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "file_scanner/version"

Gem::Specification.new do |s|
  s.name = "file_scanner"
  s.version = FileScanner::VERSION
  s.authors = ["costajob"]
  s.email = ["costajob@gmail.com"]
  s.summary = "A scanner that collect files basing on custom policies and apply a set of custom rules"
  s.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec|test|s|features)/}) }
  s.bindir = "bin"
  s.executables = %w[file_scanner]
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 1.15"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "benchmark-ips", "~> 2.7"
end
