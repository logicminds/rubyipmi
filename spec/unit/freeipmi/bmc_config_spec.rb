# frozen_string_literal: true

require 'spec_helper'

describe Rubyipmi::Freeipmi::BmcConfig do
  let(:path) { '/usr/local/bin' }

  let(:config) do
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return("#{path}/ipmipower")
    Rubyipmi.connect('ipmiuser', 'impipass', 'ipmihost', 'freeipmi', :debug => true).bmc.config
  end

  before :each do
    allow(Rubyipmi).to receive(:locate_command).with('bmc-config').and_return("#{path}/bmc-config")
  end

  it 'lists sections from a long bmc-config result and then uses the cache' do
    body = (['User1'] * 30).join("\n")
    allow(Rubyipmi).to receive(:capture3).once.and_return([body, '', mock_success_status])

    expect(config.listsections).to eq(body.split("\n"))
    expect(config.listsections).to eq(body.split("\n"))
  end

  it 'accepts bmc-config output only when it is long and the process succeeded' do
    config.instance_variable_set(:@result, 'x' * 101)

    expect(config.validate_status(mock_success_status)).to eq(true)
  end

  it 'rejects a short bmc-config result even when the process succeeded' do
    config.instance_variable_set(:@result, 'too short')

    expect { config.validate_status(mock_success_status) }.to raise_error(RuntimeError, 'Error occurred')
  end

  it 'rejects a long bmc-config result when the process failed' do
    config.instance_variable_set(:@result, 'x' * 101)
    failed = instance_double(Process::Status, :success? => false)

    expect { config.validate_status(failed) }.to raise_error(RuntimeError, 'Error occurred')
  end
end
