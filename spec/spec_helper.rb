$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rubyipmi'

if RUBY_VERSION >= '1.9'
  require 'simplecov'
end

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.

#Dir["#{File.dirname(__FILE__)}/unit/**/*.rb"].each {|f| require f}

def command_is_eql?(source, expected)
  src = source.split(' ')
  exp = expected.split(' ')
  return exp - src
end

def verify_freeipmi_command(cmdobj, exp_args_count, expcmd)
  actual = cmdobj.lastcall
  cmd_match = actual.scan(/(^#{Regexp.escape(expcmd)})/)
  args_match = actual.scan(/(\-{2}[\w-]*=?[-\w\/]*)/)
  cmd_match.to_s.should eq(expcmd)
  # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
  #args_match.should =~ exp_args
  args_match.count.should eq(exp_args_count)
end


def verify_ipmitool_command(cmdobj, exp_args_count, expcmd, required_args)
  actual = cmdobj.lastcall
  cmd_match = actual.scan(/(^#{Regexp.escape(expcmd)})/)
  args_match = actual.scan(/(-\w\s[\w\d\S]*)/)
  cmd_match.to_s.should eq(expcmd)
  actual.include?(required_args).should be_true
  # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
  #args_match.should =~ exp_args
  args_match.count.should eq(exp_args_count)
end


RSpec.configure do |config|

end

if RUBY_VERSION >= '1.9'
  SimpleCov.start do
    add_filter '/spec/'
  end
end
