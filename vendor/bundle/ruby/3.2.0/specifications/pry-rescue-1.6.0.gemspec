# -*- encoding: utf-8 -*-
# stub: pry-rescue 1.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "pry-rescue".freeze
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Conrad Irwin".freeze, "banisterfiend".freeze, "epitron".freeze]
  s.date = "2024-01-10"
  s.description = "Allows you to wrap code in Pry::rescue{ } to open a pry session at any unhandled exceptions".freeze
  s.email = ["conrad.irwin@gmail.com".freeze, "jrmair@gmail.com".freeze, "chris@ill-logic.com".freeze]
  s.executables = ["kill-pry-rescue".freeze, "rescue".freeze]
  s.files = ["bin/kill-pry-rescue".freeze, "bin/rescue".freeze]
  s.homepage = "https://github.com/ConradIrwin/pry-rescue".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Open a pry session on any unhandled exceptions".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<pry>.freeze, [">= 0.12.0"])
  s.add_runtime_dependency(%q<interception>.freeze, [">= 0.5"])
  s.add_development_dependency(%q<pry-stack_explorer>.freeze, [">= 0"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
  s.add_development_dependency(%q<redcarpet>.freeze, [">= 0"])
  s.add_development_dependency(%q<capybara>.freeze, [">= 0"])
end
