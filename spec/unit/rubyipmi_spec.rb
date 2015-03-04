require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe :Rubyipmi do


  before :each do

  end

  it 'is provider installed should return ipmitool true' do
    Rubyipmi.stub(:locate_command).with('ipmitool').and_return('/usr/local/bin/ipmitool')
    Rubyipmi.is_provider_installed?('ipmitool').should eq true
  end

  it 'is locate command should return command in /usr/local/bin' do
    Rubyipmi.stub(:locate_command).with('ipmitool').and_return('/usr/local/bin/ipmitool')
    Rubyipmi.locate_command('ipmitool').should eq('/usr/local/bin/ipmitool')
  end

  it 'is provider installed should return freeipmi true' do
    Rubyipmi.stub(:locate_command).with('ipmipower').and_return('/usr/local/bin/ipmipower')
    Rubyipmi.is_provider_installed?('freeipmi').should eq true
  end

  it 'is provider installed should return error with ipmitool' do
    expect{Rubyipmi.is_provider_installed?('bad_provider')}.to raise_error
  end

end


