# -*- encoding: utf-8 -*-
# stub: interception 0.5 ruby lib
# stub: ext/extconf.rb

Gem::Specification.new do |s|
  s.name = "interception".freeze
  s.version = "0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Conrad Irwin".freeze]
  s.date = "2014-03-06"
  s.description = "Provides a cross-platform ability to intercept all exceptions as they are raised.".freeze
  s.email = "conrad.irwin@gmail.com".freeze
  s.extensions = ["ext/extconf.rb".freeze]
  s.files = ["ext/extconf.rb".freeze]
  s.homepage = "http://github.com/ConradIrwin/interception".freeze
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Intercept exceptions as they are being raised".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
end
