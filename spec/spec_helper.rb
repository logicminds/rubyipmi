if RUBY_VERSION >= '1.9'
  require 'coveralls'
  require 'simplecov'
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/spec/'
    add_group 'freeipmi', 'lib/rubyipmi/freeipmi'
    add_group 'ipmitool', 'lib/rubyipmi/ipmitool'
  end
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '../', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rubyipmi'
require 'pry'


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
  actual.scan(/(^#{Regexp.escape(expcmd)})/) do |cmd_match|
    cmd_match.first.should eq(expcmd)
  end
  args_match = actual.scan(/(\-{2}[\w-]*=?[-\w\/]*)/)
  # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
  #args_match.should =~ exp_args
  args_match.count.should eq(exp_args_count)
end


def verify_ipmitool_command(cmdobj, exp_args_count, expcmd, required_args)
  actual = cmdobj.lastcall
  actual.scan(/(^#{Regexp.escape(expcmd)})/) do |cmd_match|
    args_match = actual.scan(/(-\w\s[\w\d\S]*)/)
    actual.include?(required_args).should be_true
    # not sure how to exactly test for arguments since they could vary, so we will need to use count for now
    #args_match.should =~ exp_args
    args_match.count.should eq(exp_args_count)
  end
end


RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.filter_run_excluding :slow unless ENV["SLOW_SPECS"]

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
