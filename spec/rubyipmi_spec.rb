require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "rubyipmi" do
    before :each do
        @user = ENV["ipmiuser"]
        @pass = ENV["ipmipass"]
        @host = ENV["ipmihost"]
        @provider = ENV["ipmiprovider"]

    end
  it "creates a connection object" do
    conn = Rubyipmi.connect(@user, @pass, @host, @provider)
    conn.should_not be_nil
  end

  it "should test if a provider is present" do
    Rubyipmi.is_provider_installed?("ipmitool").should_not be false
    Rubyipmi.is_provider_installed?("freeipmi").should_not be false

  end

  it "should create a connection object if freeipmi is present" do
    conn = Rubyipmi.connect(@user, @pass, @host, "freeipmi")
    conn.should be instance_of(Rubyipmi::Freeipmi::Connection)
  end

  it "should create a connection object if ipmitool is present" do
    conn = Rubyipmi.connect(@user, @pass, @host, "ipmitool")
    conn.should be instance_of(Rubyipmi::Ipmitool::Connection)
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

