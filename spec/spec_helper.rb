$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rubyipmi'
require 'coveralls'
Coveralls.wear!
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
  actual.scan(/(^#{Regexp.escape(expcmd)})/) do |cmd_match|
    expect(cmd_match.first).to eq(expcmd)
  end
  args_match = actual.scan(/(\-{2}[\w-]*=?[-\w\/]*)/)
  # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
  # args_match.should =~ exp_args
  expect(args_match.count).to eq(exp_args_count)
end

def verify_ipmitool_command(cmdobj, exp_args_count, expcmd, required_args)
  actual = cmdobj.lastcall
  actual.scan(/(^#{Regexp.escape(expcmd)})/) do |cmd_match|
    expect(cmd_match.first).to eq(expcmd)
  end
  args_match = actual.scan(/(-\w\s[\w\d\S]*)/)
  expect(actual.include?(required_args)).to eq true
  # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
  # args_match.should =~ exp_args
  expect(args_match.count).to eq(exp_args_count)
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:expect]
  end
end
