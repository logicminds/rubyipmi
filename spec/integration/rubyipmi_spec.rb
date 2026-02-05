# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'
require 'logger'

describe "rubyipmi" do
  before :each do
    @user ||= ENV["ipmiuser"] || "admin"
    @pass ||= ENV["ipmipass"] || "password"
    @host ||= ENV["ipmihost"] || "10.0.1.16"
    @provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider)
  end

  it "creates a connection object" do
    conn = Rubyipmi.connect(@user, @pass, @host, @provider)
    expect(conn).to be_truthy
  end

  it "should test if a provider is present" do
    value = Rubyipmi.is_provider_installed?("ipmitool")
    value2 = Rubyipmi.is_provider_installed?("freeipmi")
    expect(value | value2).to eq true
  end

  it "should create a connection object if freeipmi is present" do
    conn = Rubyipmi.connect(@user, @pass, @host, "freeipmi")
    expect(conn.kind_of?(Rubyipmi::Freeipmi::Connection)).to eq true
  rescue Exception => e
    expect(e.message.match(/freeipmi\ is\ not\ installed/)).to eq true
    puts e.message
  end

  it "should create a connection object if ipmitool is present" do
    begin
      conn = Rubyipmi.connect(@user, @pass, @host, "ipmitool")
    rescue Exception => e
      expect(e.message).to match(/ipmitool\ is\ not\ installed/)
      puts e.message
      return true
    end
    expect(conn.kind_of?(Rubyipmi::Ipmitool::Connection)).to eq true
  end

  it "should not create a connection object if a provider is not present" do
    Rubyipmi.connect(@user, @pass, @host, "bogus")
  rescue Exception => e
    expect(e.message).to match(/The IPMI provider: bogus is not installed/)
  end

  it "check to find any available installed providers" do
    expect(Rubyipmi.providers_installed.length).to be > 0
  end

  it 'can get diag info' do
    # must have both freeipmi and ipmitool for this to pass
    Rubyipmi.get_diag(@user, @pass, @host)
    expect(File.exist?('/tmp/rubyipmi_diag_data.txt')).to be true
    FileUtils.rm('/tmp/rubyipmi_diag_data.txt')
  end

  describe :logger do
    before :each do
      FileUtils.rm_f('/tmp/rubyipmi.log')
      Rubyipmi.log_level = nil
      Rubyipmi.logger = nil
    end

    it 'should only create an info log level' do
      Rubyipmi.log_level = Logger::INFO
      Rubyipmi.get_diag(@user, @pass, @host)
      expect(File.exist?('/tmp/rubyipmi.log')).to be true
      size = File.open('/tmp/rubyipmi.log', 'r') { |f| f.read.length }
      expect(size).to be_within(60).of(100)
    end

    it 'should create a log with debug level' do
      Rubyipmi.log_level = Logger::DEBUG
      Rubyipmi.get_diag(@user, @pass, @host)
      expect(File.exist?('/tmp/rubyipmi.log')).to be true
      size = File.open('/tmp/rubyipmi.log', 'r') { |f| f.read.length }
      expect(size).to be > 100
    end

    it 'should use custom logger' do
      FileUtils.rm_f('/tmp/rubyipmi_custom.log')
      logger = Logger.new('/tmp/rubyipmi_custom.log')
      logger.level = Logger::DEBUG
      Rubyipmi.logger = logger
      Rubyipmi.get_diag(@user, @pass, @host)
      expect(File.exist?('/tmp/rubyipmi_custom.log')).to be true
      size = File.open('/tmp/rubyipmi_custom.log', 'r') { |f| f.read.length }
      expect(size).to be > 100
      FileUtils.rm_f('/tmp/rubyipmi_custom.log')
    end

    it 'should not create a log file when log level is nil' do
      Rubyipmi.get_diag(@user, @pass, @host)
      expect(Rubyipmi.logger.instance_of?(NullLogger)).to be true
      expect(File.exist?('/tmp/rubyipmi.log')).to be false
    end

    it 'should not create a log file when logger is set to nil and log_level is nil' do
      Rubyipmi.get_diag(@user, @pass, @host)
      expect(Rubyipmi.logger.instance_of?(NullLogger)).to be true
      expect(File.exist?('/tmp/rubyipmi.log')).to be false
    end
  end
end
