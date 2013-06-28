$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rubyipmi'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.

#Dir["#{File.dirname(__FILE__)}/unit/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  
end
