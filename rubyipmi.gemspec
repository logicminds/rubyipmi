lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubyipmi/version'

Gem::Specification.new do |s|
  s.name = "rubyipmi"
  s.version = Rubyipmi::VERSION

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
  s.license = "LGPL-2.1-only"
  s.summary = "A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi"
  s.require_paths = ['lib']
  s.add_dependency 'observer', '~> 0.1.0'
  s.add_dependency 'logger'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdoc', "~> 7.1"
  s.add_development_dependency 'bundler', ">= 2.0"
  s.add_development_dependency 'highline', '>= 1.0', '< 4'
  s.add_development_dependency 'rake', '~> 13'
end
