require 'coveralls'
Coveralls.wear!

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rubyipmi'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.

# Dir["#{File.dirname(__FILE__)}/unit/**/*.rb"].each {|f| require f}

def command_is_eql?(source, expected)
  src = source.split(' ')
  exp = expected.split(' ')
  exp - src
end

def verify_freeipmi_command(cmdobj, exp_args_count, expcmd)
  actual = cmdobj.lastcall
  expect(actual.first).to eq(expcmd)
  args_match = actual.select { |arg| arg.match?(/^(-{2}[\w-]*=?[-\w\/]*)/) }
  # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
  # args_match.should =~ exp_args
  expect(args_match.count).to eq(exp_args_count)
end

def verify_ipmitool_command(cmdobj, exp_args_count, expcmd, required_args)
  actual = cmdobj.lastcall
  expect(actual.first).to eq(expcmd)
  args_match = actual.select { |arg| arg.match?(/^(-\w)/) }
  expect(actual.include?(required_args)).to eq true
  # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
  # args_match.should =~ exp_args
  expect(args_match.count).to eq(exp_args_count)
end

def mock_success_status
  instance_double(Process::Status, success?: true)
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:expect]
  end
end
