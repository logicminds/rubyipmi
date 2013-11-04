# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubyipmi/version'

Gem::Specification.new do |s|
  s.name                      = "rubyipmi"
  s.version                   = Rubyipmi::VERSION

  s.authors                   = ["Corey Osman"]
  s.date                      = "2013-10-17"
  s.description               = "Provides a library for controlling IPMI devices using pure ruby code"
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

  # use rspec expect syntax, needs >= 2.11
  s.add_development_dependency 'rspec', ">= 2.11.0"
  s.add_development_dependency 'rdoc', "~> 3.12"
  s.add_development_dependency 'bundler', ">= 1.1.5"
  s.add_development_dependency 'highline'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'coveralls'
  #
  # mime-types > 2.0 don't support ruby18
  s.add_development_dependency 'mime-types', '~> 1.0'

  if RUBY_VERSION > "1.9"
    # use simplecov with ruby19 and up
    s.add_development_dependency 'simplecov'
  else
    s.add_development_dependency 'rcov'
  end
end
