# frozen_string_literal: true

require 'spec_helper'

describe Rubyipmi::Ipmitool::Chassis do
  before :each do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/local/bin/ipmitool')
    @chassis = Rubyipmi.connect('ipmiuser', 'impipass', 'ipmihost', 'ipmitool', :debug => true).chassis
    allow(Rubyipmi).to receive(:capture3).and_return(['', '', mock_success_status])
  end

  it 'identifies for a delay inside the supported range' do
    expect(@chassis.identify(true, 10)).to eq(true)
    expect(@chassis.lastcall.join(' ')).to include('chassis identify 10')
  end

  it 'caps an out-of-range identify delay at 255' do
    expect(@chassis.identify(true, 0)).to eq(true)
    expect(@chassis.lastcall.join(' ')).to include('chassis identify 255')
  end

  it 'turns identify off' do
    expect(@chassis.identify(false)).to eq(true)
    expect(@chassis.lastcall.join(' ')).to include('chassis identify 0')
  end

  it 'sets a persistent boot device with bootdev' do
    expect(@chassis.config.bootdevice('pxe', true)).to eq(true)
    expect(@chassis.config.lastcall.join(' ')).to include('chassis bootdev pxe')
  end

  it 'forces a one-time boot device with a boot flag' do
    expect(@chassis.config.bootdevice('disk', false)).to eq(true)
    expect(@chassis.config.lastcall.join(' ')).to include('chassis bootparam set bootflag force_disk')
  end
end
