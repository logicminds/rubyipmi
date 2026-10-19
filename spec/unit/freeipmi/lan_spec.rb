# frozen_string_literal: true

require 'spec_helper'

describe Rubyipmi::Freeipmi::Lan do
  before :each do
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return('/usr/local/bin/ipmipower')
    @lan = Rubyipmi.connect('ipmiuser', 'impipass', 'ipmihost', 'freeipmi', :debug => true).bmc.lan
  end

  it 'accepts a dotted ipv4 address' do
    expect(@lan.validaddr?('10.0.0.1')).to eq(true)
  end

  it 'rejects an address outside the ipv4 range' do
    expect { @lan.validaddr?('999.1.1.1') }.to raise_error(RuntimeError, /999\.1\.1\.1 is not a valid address/)
  end

  it 'parses tab-separated lan fields and caches them' do
    raw = +"\tIP_Address    10.0.0.5\n"
    allow(@lan.config).to receive(:section).with('Lan_Conf').once.and_return(raw)

    expect(@lan.ip).to eq('10.0.0.5')
    expect(@lan.ip).to eq('10.0.0.5')
  end
end
