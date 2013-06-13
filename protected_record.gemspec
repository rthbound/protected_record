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
                      Change filter, change log, and change request system. No callbacks.
                    }
  s.summary     = %q{
                      Opt in to use #attributes= and ActiveModel::Dirty
                      to filter changes to certain keys, to log change requests,
                      ant to log changes to any protected record.

                      Built modularly so you can use the pieces independently
                      if you like.
                    }

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency     "pay_dirt",     "~> 1.0.0"
  s.add_runtime_dependency     "activerecord"

  s.add_development_dependency "minitest"
  s.add_development_dependency "rake"
  s.add_development_dependency "pry"
end
