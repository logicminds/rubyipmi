# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubyipmi/version'

Gem::Specification.new do |s|
  s.name                      = "rubyipmi"
  s.version                   = Rubyipmi::VERSION

  s.authors                   = ["Corey Osman"]
  s.date                      = "2013-09-12"
  s.description               = "A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi"
  s.summary                   = "A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi"
  s.email                     = "corey@logicminds.biz"
  s.files                     = `git ls-files`.split($/)
  s.test_files                = s.files.grep(%r{^(test|spec|features)/})
  s.homepage                  = "http://github.com/logicminds/rubyipmi"
  s.licenses                  = ["GPLv3"]
  s.require_paths             = ["lib"]
  s.rubygems_version          = "1.8.23"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "README.rdoc"
  ]

  s.add_development_dependency 'rspec', ">= 2.8.0"
  s.add_development_dependency 'rdoc', "~> 3.12"
  s.add_development_dependency 'bundler', ">= 1.1.5"
  s.add_development_dependency 'highline'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'

  if RUBY_VERSION > "1.9"
    # use simplecov with ruby19 and up
    s.add_development_dependency 'simplecov'
  else
    s.add_development_dependency 'rcov'
  end
end
