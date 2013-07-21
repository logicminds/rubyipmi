require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "rubyipmi" do
  before :each do
    @user ||= ENV["ipmiuser"] || "admin"
    @pass ||= ENV["ipmipass"] || "password"
    @host ||= ENV["ipmihost"] || "192.168.1.16"
    @provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider)

    end
  it "creates a connection object" do
    conn = Rubyipmi.connect(@user, @pass, @host, @provider)
    conn.should_not be_nil
  end

  it "should test if a provider is present" do
    value = Rubyipmi.is_provider_installed?("ipmitool")
    value2 = Rubyipmi.is_provider_installed?("freeipmi")
    (value|value2).should_not be false

  end

    it "should create a connection object if freeipmi is present" do
      begin
        conn = Rubyipmi.connect(@user, @pass, @host, "freeipmi")
        conn.kind_of?(Rubyipmi::Freeipmi::Connection).should be_true
      rescue Exception => e
        e.message.match(/freeipmi\ is\ not\ installed/).should be_true
        puts "#{e.message}"
      end
    end

    it "should create a connection object if ipmitool is present" do
      begin
        conn = Rubyipmi.connect(@user, @pass, @host, "ipmitool")
      rescue Exception => e
        e.message.match(/ipmitool\ is\ not\ installed/).should be_true
        puts "#{e.message}"
        return true
      end
      conn.kind_of?(Rubyipmi::Ipmitool::Connection).should be_true
    end

  it "should not create a connection object if a provider is not present" do
    begin
      conn = Rubyipmi.connect(@user, @pass, @host, "bogus")
    rescue Exception => e
        e.message.match(/Invalid/).should be_true
    end
  end

  it "check to find any available installed providers" do
    Rubyipmi.providers_installed?.length.should be > 0
  end



end

