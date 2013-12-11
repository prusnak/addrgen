# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "bitcoin_addrgen/version"

Gem::Specification.new do |s|
  s.name        = "bitcoin-addrgen"
  s.version     = BitcoinAddrgen::VERSION
  s.authors     = ["Pavol Rusnak"]
  s.email       = ["stick@gk2.sk"]
  s.homepage    = "https://github.com/prusnak/addrgen"
  s.summary     = "Deterministic Bitcoin Address Generator"
  s.description = "Deterministic Bitcoin Address Generator."

  s.rubyforge_project = "bitcoin-addrgen"

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency 'ffi', '~> 1.9.3'
  s.add_development_dependency 'rspec', '~> 2.13.0'
  s.add_development_dependency 'rake', '~> 10.0.4'
end
