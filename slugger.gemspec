# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "slugger/version"

Gem::Specification.new do |s|
  s.name        = "slugger"
  s.version     = Slugger::VERSION
  s.authors     = ["Seth Faxon"]
  s.email       = ["seth.faxon@gmail.com"]
  s.homepage    = "https://github.com/sfaxon/slugger"
  s.summary     = %q{Slugger is yet another slug generator.}
  s.description = %q{Slugger is yet another slug generator.}

  s.rubyforge_project = "slugger"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.extra_rdoc_files = [
    "MIT-LICENSE",
    "README.rdoc"
  ]
  
  # specify any dependencies here; for example:
  s.add_dependency "activerecord", ">= 4.0.0"
  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "sqlite3", "~> 1.3.5"
end
