# -*- encoding: utf-8 -*-
$:.push File.dirname(__FILE__)
#$:.push File.join( File.dirname(__FILE__),'ipreader' )
require "ipreader/version"

Gem::Specification.new do |s|
  s.name        = "ipreader"
  s.version     = Ipreader::Backup::Reader::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Rabbich"]
  s.email       = ["davidrabbich@yahoo.co.uk"]
  s.homepage    = "http://rubygems.org/gems/ipreader"
  s.summary     = %q{ Reads an unencrypted IPhone backup store and queries the sms data within it. }
  s.description = %q{ Takes as input a directory location of the Apple backup store and interrogates the back up data for SMS data }

  s.rubyforge_project = "ipreader"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
