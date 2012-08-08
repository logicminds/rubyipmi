require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "freeipmi" do
    before :each do
        @user = ENV["ipmiuser"]
        @pass = ENV["ipmipass"]
        @host = ENV["ipmihost"]


    end
  it "creates a connection object" do
    @conn = Rubyipmi.connect(@user, @pass, @host)
    @conn.should_not be_nil
  end

  it "should test if a provider is present" do
    Rubyipmi.is_provider_present?("ipmitool")?.should_not be_nil
    Rubyipmi.is_provider_present?("freeipmi")?.should_not be_nil

  end

  it "should create a connection object if freeipmi is present" do
    @conn = Rubyipmi.connect(@user, @pass, @host, "freeipmi")
    @conn.should be instance_of(Rubyipmi::Freeipmi::Connection)
  end

  it "should create a connection object if ipmitool is present" do
    @conn = Rubyipmi.connect(@user, @pass, @host, "ipmitool")
    @conn.should be instance_of(Rubyipmi::Ipmitool::Connection)
  end

  it "should not create a connection object if a provider is not present" do
    @conn = Rubyipmi.connect(@user, @pass, @host, "bogus")
    @conn.should be nil


  end



end

