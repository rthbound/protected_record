# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "protected_record/version"

Gem::Specification.new do |s|
  s.name        = "protected_record"
  s.version     = ProtectedRecord::VERSION
  s.authors     = ["Tad Hosford"]
  s.email       = ["tad.hosford@gmail.com"]
  s.homepage    = "http://github.com/rthbound/protected_record"
  s.description = %q{
                      Filters changes & logs changes to protected records.
                      Creates change requests when changes are attempted on protected attrs
                    }
  s.summary     = %q{  }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency     "pay_dirt"
  s.add_runtime_dependency "activerecord"
  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
end
