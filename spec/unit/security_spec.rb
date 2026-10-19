# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'logger'
require 'open3'

describe 'credential and command handling' do
  before do
    Rubyipmi.log_level = nil
    Rubyipmi.logger = nil
  end

  after do
    Rubyipmi.log_level = nil
    Rubyipmi.logger = nil
  end

  def freeipmi_command(username:, password:)
    opts = Rubyipmi::ObservableHash.new
    opts['hostname'] = 'bmc.example'
    opts['username'] = username
    opts['password'] = password
    Rubyipmi::Freeipmi::BmcInfo.new(opts)
  end

  def config_body_for(command)
    body = nil
    allow(Rubyipmi).to receive(:locate_command).and_return('/usr/bin/bmc-info')
    allow(Rubyipmi).to receive(:capture3) do |argv|
      config = argv.find { |arg| arg.to_s.start_with?('--config-file=') }
      body = File.read(config.split('=', 2).last)
      ['', '', mock_success_status]
    end
    command.guid
    body
  end

  it 'stores the debug log in a private directory' do
    legacy = File.join(Dir.tmpdir, 'rubyipmi.log')
    File.write(legacy, 'old')
    File.chmod(0o644, legacy)

    Rubyipmi.log_level = Logger::INFO
    Rubyipmi.logger.info('hello')

    log = Rubyipmi.log_path
    expect(File.stat(log).mode & 0o777).to eq(0o600)
    expect(File.stat(File.dirname(log)).mode & 0o777).to eq(0o700)
    expect(File.exist?(legacy)).to be false
    expect(File.read(log)).to include('hello')
  end

  it 'refuses to follow a symlink for a private file' do
    path = File.join(Rubyipmi::SecureFiles.private_runtime_dir, 'rubyipmi_diag_data.txt')
    FileUtils.rm_f(path)
    File.symlink('elsewhere', path)

    expect do
      Rubyipmi::SecureFiles.open_private('rubyipmi_diag_data.txt')
    end.to raise_error(RuntimeError, /symlink/)
  ensure
    FileUtils.rm_f(path) if path
  end

  it 'writes diagnostics without using a public /tmp name' do
    data_path = nil
    allow(Rubyipmi).to receive(:is_provider_installed?).and_return(false)
    expect { data_path = Rubyipmi.diag_path }.not_to raise_error
    FileUtils.rm_f(data_path)

    Rubyipmi.get_diag('user', 'pw', 'host')

    expect(File.exist?(data_path)).to be true
    expect(File.stat(data_path).mode & 0o777).to eq(0o600)
    expect(File.exist?(File.join(Dir.tmpdir, 'rubyipmi_diag_data.txt'))).to be false
  ensure
    FileUtils.rm_f(data_path) if data_path
  end

  it 'looks up commands without a shell' do
    status = instance_double(Process::Status, :success? => true)
    expect(Open3).to receive(:capture3).with('which', 'ipmitool').and_return(["/bin/ipmitool\n", '', status])

    expect(Rubyipmi.locate_command('ipmitool')).to eq('/bin/ipmitool')
  end

  it 'passes a command name through as one argument' do
    status = instance_double(Process::Status, :success? => false)
    expect(Open3).to receive(:capture3).with('which', 'not a command').and_return(['', 'missing', status])

    expect(Rubyipmi.locate_command('not a command')).to be_nil
  end

  it 'keeps the ipmitool password out of the command arguments' do
    password = 's3cret-value'
    pass_path = nil
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/bin/ipmitool')
    allow(Rubyipmi).to receive(:capture3) do |argv|
      pass_path = argv[argv.index('-f') + 1]
      expect(File.read(pass_path)).to eq(password)
      expect(File.stat(pass_path).mode & 0o777).to eq(0o600)
      expect(pass_path).to start_with("#{Rubyipmi::SecureFiles.private_runtime_dir}/")
      expect(argv.join("\n")).not_to include(password)
      ['', '', mock_success_status]
    end

    conn = Rubyipmi.connect('user', password, 'bmc.example', 'ipmitool')
    conn.bmc.guid

    expect(pass_path).not_to be_nil
    expect(File.exist?(pass_path)).to be false
  end

  it 'does not split an ipmitool value that contains whitespace' do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/bin/ipmitool')
    allow(Rubyipmi).to receive(:capture3).and_return(['', '', mock_success_status])
    conn = Rubyipmi.connect('user', 'pw', 'bmc.example', 'ipmitool')
    lan = conn.bmc.lan

    lan.ip = '10.1.1.1 extra'

    expect(lan.lastcall).to include('10.1.1.1 extra')
    expect(lan.lastcall).not_to include('extra')
  end

  it 'writes a FreeIPMI config without putting the password on the command line' do
    command = freeipmi_command(:username => 'alice', :password => 'sec#ret')

    expect(config_body_for(command)).to eq("username alice\npassword sec\\#ret\n")
    expect(command.lastcall.join("\n")).not_to include('sec#ret')
    expect(command.lastcall.join("\n")).not_to include('alice')
  end

  it 'rejects a FreeIPMI credential that would change the config structure' do
    command = freeipmi_command(:username => "alice\nmore", :password => 'secret')
    allow(Rubyipmi).to receive(:locate_command).and_return('/usr/bin/bmc-info')

    expect { command.guid }.to raise_error(RuntimeError, /cannot be stored safely/)
  end
end
