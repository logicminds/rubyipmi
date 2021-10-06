lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubyipmi/version'

Gem::Specification.new do |s|
  s.name = "rubyipmi"
  s.version = Rubyipmi::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Corey Osman"]
  s.date = "2021-09-29"
  s.description = "Controls IPMI devices via command line wrapper for ipmitool and freeipmi"
  s.email = "corey@logicminds.biz"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(/^(\.|test|spec|features)/) || f.match(/^*.tar\.gz/)
  end
  s.homepage = "https://github.com/logicminds/rubyipmi"
  s.licenses = ["LGPLv2.1"]
  s.rubygems_version = "2.4.5"
  s.summary = "A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi"
  s.require_paths = ['lib']
  s.add_development_dependency(%q<rspec>, ["~> 3.1"])
  s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
  s.add_development_dependency(%q<bundler>, [">= 1.1.5"])
  s.add_development_dependency(%q<highline>, [">= 0"])
  s.add_development_dependency(%q<rake>, [">= 0"])
end

