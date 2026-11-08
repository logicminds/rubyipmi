# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../spec_helper")
require 'fileutils'

describe :Rubyipmi do
  before :each do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
  end

  it 'is provider installed should return ipmitool true' do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/local/bin/ipmitool')
    expect(Rubyipmi.is_provider_installed?('ipmitool')).to eq true
  end

  it 'is locate command should return command in /usr/local/bin' do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/local/bin/ipmitool')
    expect(Rubyipmi.locate_command('ipmitool')).to eq('/usr/local/bin/ipmitool')
  end

  it 'is provider installed should return freeipmi true' do
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return('/usr/local/bin/ipmipower')
    expect(Rubyipmi.is_provider_installed?('freeipmi')).to eq true
  end

  it 'is provider installed should return false when bad provider' do
    expect { Rubyipmi.is_provider_installed?('bad_provider') }.to_not raise_error
    expect(Rubyipmi.is_provider_installed?('bad_provider')).to be_falsey
  end

  it 'converts string to symbols' do
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    provider = "ipmitool"
    conn = Rubyipmi.connect(user, pass, host, provider, 'driver' => 'lan15')
    expect(conn.options).to eq("H" => "ipmihost", "U" => "ipmiuser", "P" => "impipass", "I" => "lan")
  end

  it 'does not error when converting strings to symbols' do
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    provider = "ipmitool"
    conn = Rubyipmi.connect(user, pass, host, provider, :driver => 'lan15')
    expect(conn.options).to eq("H" => "ipmihost", "U" => "ipmiuser", "P" => "impipass", "I" => "lan")
  end

  it 'delegates capture3 to Open3 and returns the process triple' do
    status = instance_double(Process::Status, :success? => true)
    expect(Open3).to receive(:capture3).with('ipmitool', '-I', 'lanplus').and_return(['ok', '', status])

    expect(Rubyipmi.capture3(['ipmitool', '-I', 'lanplus'])).to eq(['ok', '', status])
  end

  it 'reports no provider when neither command is installed' do
    allow(Rubyipmi).to receive(:locate_command).and_return(nil)

    expect(Rubyipmi.providers_installed).to eq([])
    expect(Rubyipmi.provider_installed?).to eq(false)
  end

  it 'reports ipmitool when only that command is installed' do
    allow(Rubyipmi).to receive(:locate_command).and_return(nil)
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/bin/ipmitool')

    expect(Rubyipmi.providers_installed).to eq(['ipmitool'])
    expect(Rubyipmi.provider_installed?).to eq(true)
  end

  it 'writes freeipmi diagnostics when that provider is installed' do
    path = '/tmp/rubyipmi_diag_data.txt'
    payload = {:frus => ['board']}
    connection = instance_double(Rubyipmi::Freeipmi::Connection, :get_diag => payload)
    calls = []
    allow(Rubyipmi).to receive(:is_provider_installed?) { |name| name == 'freeipmi' }
    allow(Rubyipmi).to receive(:connect) do |*args|
      calls << args
      connection
    end

    expect { Rubyipmi.get_diag('user', 'pass', 'host') }.to output(/Retrieving freeipmi data/).to_stdout
    expect(calls).to eq([['user', 'pass', 'host', 'freeipmi', {:driver => 'lan20', :timeout => 'default'}]])
    expect(File.read(path)).to include('frus')
  ensure
    FileUtils.rm_f(path)
  end

  it 'writes an empty diagnostic file when no provider is installed' do
    path = '/tmp/rubyipmi_diag_data.txt'
    allow(Rubyipmi).to receive(:is_provider_installed?).and_return(false)
    expect(Rubyipmi).not_to receive(:connect)

    expect { Rubyipmi.get_diag('user', 'pass', 'host') }.to output(/Created file/).to_stdout
    expect(File.read(path)).to eq('{}')
  ensure
    FileUtils.rm_f(path)
  end

  it 'publishes a frozen gem version' do
    require 'rubyipmi/version'

    expect(Rubyipmi::VERSION).to eq('0.13.0')
    expect(Rubyipmi::VERSION).to be_frozen
  end
end
