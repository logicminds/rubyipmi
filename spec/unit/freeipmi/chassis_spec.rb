# frozen_string_literal: true

require 'spec_helper'

describe Rubyipmi::Freeipmi::Chassis do
  before :each do
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return('/usr/local/bin/ipmipower')
    @chassis = Rubyipmi.connect('ipmiuser', 'impipass', 'ipmihost', 'freeipmi', :debug => true).chassis
    allow(Rubyipmi).to receive(:locate_command).with('ipmi-chassis').and_return('/usr/local/bin/ipmi-chassis')
    allow(Rubyipmi).to receive(:locate_command).with('ipmi-chassis-config').and_return('/usr/local/bin/ipmi-chassis-config')
    allow(Rubyipmi).to receive(:capture3).and_return(["System Power : on\n", '', mock_success_status])
  end

  it 'forces the identify light on when the delay is not positive' do
    expect(@chassis.identify(true, 0)).to eq(true)
    expect(@chassis.lastcall.join(' ')).to include('--chassis-identify=FORCE')
  end

  it 'blinks the identify light for the requested delay' do
    expect(@chassis.identify(true, 15)).to eq(true)
    expect(@chassis.lastcall.join(' ')).to include('--chassis-identify=15')
  end

  it 'turns the identify light off' do
    expect(@chassis.identify(false)).to eq(true)
    expect(@chassis.lastcall.join(' ')).to include('--chassis-identify=TURN-OFF')
  end

  it 'parses chassis status fields' do
    expect(@chassis.status).to eq('System Power' => 'on')
  end

  it 'returns false when chassis status cannot be read' do
    allow(@chassis).to receive(:runcmd).and_return(false)

    expect(@chassis.status).to eq(false)
  end

  it 'commits a persistent boot flag' do
    expect(@chassis.config.bootpersistent(true)).to eq(true)
    expect(@chassis.config.lastcall.join(' ')).to include('Boot_Flags_Persistent=Yes')
  end

  it 'commits a one-time boot flag' do
    expect(@chassis.config.bootpersistent(false)).to eq(true)
    expect(@chassis.config.lastcall.join(' ')).to include('Boot_Flags_Persistent=No')
  end
end
