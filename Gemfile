# frozen_string_literal: true

source "https://rubygems.org"

gemspec

group :development do
  gem 'coveralls_reborn', :require => false
  gem 'pry'
  gem 'pry-rescue'
  gem "reline"
  gem "rubocop", :require => false
  # 1.2 requires Ruby >= 3.2. Coverage runs on the 3.3 job only, so older
  # matrix cells keep resolving the simplecov that coveralls_reborn allows.
  gem 'simplecov', '~> 1.2', :require => false if RUBY_VERSION >= '3.2'
end
