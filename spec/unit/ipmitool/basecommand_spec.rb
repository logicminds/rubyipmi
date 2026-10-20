# frozen_string_literal: true

require 'spec_helper'

describe Rubyipmi::Ipmitool::BaseCommand do
  let(:options) do
    opts = Rubyipmi::ObservableHash.new
    opts['H'] = 'bmc.example'
    opts['U'] = 'operator'
    opts['P'] = 'test-pass'
    opts['I'] = 'lanplus'
    opts
  end

  let(:command) { described_class.new('ipmitool', options) }

  before do
    Rubyipmi.log_level = nil
    Rubyipmi.logger = nil
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/bin/ipmitool')
    allow(Rubyipmi).to receive(:capture3).and_return(['', '', mock_success_status])
  end

  after do
    Rubyipmi.log_level = nil
    Rubyipmi.logger = nil
  end

  it 'ends global options before the subcommand' do
    options['cmdargs'] = 'chassis status'
    command.run

    separator = command.lastcall.index('--')
    expect(separator).not_to be_nil
    expect(command.lastcall[0...separator]).to include('-H', 'bmc.example', '-f')
    expect(command.lastcall[(separator + 1)..]).to eq(['chassis', 'status'])
    expect(command.lastcall.join(' ')).not_to include('test-pass')
  end

  it 'keeps a dash-prefixed subcommand field after the separator' do
    options['cmdargs'] = 'lan set 1 vlan id -1'
    command.run

    separator = command.lastcall.index('--')
    expect(command.lastcall[(separator + 1)..]).to eq(['lan', 'set', '1', 'vlan', 'id', '-1'])
  end

  it 'does not add a separator when there is no subcommand' do
    options['V'] = nil
    command.run

    expect(command.lastcall).not_to include('--')
    expect(command.lastcall).to include('-V')
  end
end
