# encoding: utf-8

require 'rubygems'
require 'bundler'


begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rubyipmi"
  gem.homepage = "http://github.com/logicminds/rubyipmi"
  gem.license = "GPLv3"
  gem.summary = %Q{A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi}
  gem.description = %Q{A ruby wrapper for ipmi command line tools that supports ipmitool and freeipmi}
  gem.email = "corey@logicminds.biz"
  gem.authors = ["Corey Osman"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rubyipmi #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "send diagnostics to logicminds for testing for the given host"
task :send_diag, :user, :pass, :host do |t, args |
  require 'rubyipmi'
  require 'net/smtp'
  require 'json'
  require "highline/import"

  if args.count < 3
    raise "You must provide arguments: rake send_diag[user, pass, host]"
  end
  data = Rubyipmi.get_diag(args[:user], args[:pass], args[:host])
  emailto = 'corey@logicminds.biz'
  subject = "Rubyipmi diagnostics data"
  puts data.inspect
  send_email(emailto, data.to_json, {:subject => subject})

end

def send_email(to,data, opts={})
  gmail_id = ask("Enter your gmail account:  ")
  pass = ask("Enter your gmail password:  ") { |q| q.echo = '*' }
  opts[:from] = gmail_id
  opts[:server]      ||= 'smtp.gmail.com'
  opts[:from_alias]  ||= gmail_id
  opts[:subject]     ||= @subject
  opts[:body]        ||= data
  opts[:to]          ||= to
  opts[:port]        ||= 587
  msg = <<END_OF_MESSAGE
From: #{opts[:from_alias]} <#{opts[:from]}>
To: <#{to}>
Subject: #{opts[:subject]}
Date: #{Time.now.rfc2822}

  #{opts[:body]}
END_OF_MESSAGE

  smtp = Net::SMTP.new(opts[:server],opts[:port])
  smtp.enable_starttls
  smtp.start(opts[:server],gmail_id,pass,:login) do
    smtp.send_message(msg, gmail_id, to)
  end
end
