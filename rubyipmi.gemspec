# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "rubyipmi"
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Corey Osman"]
  s.date = "2013-04-03"
  s.description = "A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi"
  s.email = "corey@logicminds.biz"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/rubyipmi.rb",
    "lib/rubyipmi/commands/basecommand.rb",
    "lib/rubyipmi/freeipmi/commands/basecommand.rb",
    "lib/rubyipmi/freeipmi/commands/bmc.rb",
    "lib/rubyipmi/freeipmi/commands/bmcconfig.rb",
    "lib/rubyipmi/freeipmi/commands/bmcinfo.rb",
    "lib/rubyipmi/freeipmi/commands/chassis.rb",
    "lib/rubyipmi/freeipmi/commands/chassisconfig.rb",
    "lib/rubyipmi/freeipmi/commands/fru.rb",
    "lib/rubyipmi/freeipmi/commands/lan.rb",
    "lib/rubyipmi/freeipmi/commands/power.rb",
    "lib/rubyipmi/freeipmi/commands/sensors.rb",
    "lib/rubyipmi/freeipmi/connection.rb",
    "lib/rubyipmi/freeipmi/errorcodes.rb",
    "lib/rubyipmi/ipmitool/commands/basecommand.rb",
    "lib/rubyipmi/ipmitool/commands/bmc.rb",
    "lib/rubyipmi/ipmitool/commands/chassis.rb",
    "lib/rubyipmi/ipmitool/commands/chassisconfig.rb",
    "lib/rubyipmi/ipmitool/commands/fru.rb",
    "lib/rubyipmi/ipmitool/commands/lan.rb",
    "lib/rubyipmi/ipmitool/commands/power.rb",
    "lib/rubyipmi/ipmitool/commands/sensors.rb",
    "lib/rubyipmi/ipmitool/connection.rb",
    "lib/rubyipmi/ipmitool/errorcodes.rb",
    "lib/rubyipmi/observablehash.rb",
    "rubyipmi.gemspec",
    "spec/bmc_spec.rb",
    "spec/chassis_config_spec.rb",
    "spec/chassis_spec.rb",
    "spec/connection_spec.rb",
    "spec/fru_spec.rb",
    "spec/lan_spec.rb",
    "spec/power_spec.rb",
    "spec/rubyipmi_spec.rb",
    "spec/sensor_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/logicminds/rubyipmi"
  s.licenses = ["GPLv3"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.1.5"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.1.5"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.1.5"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

