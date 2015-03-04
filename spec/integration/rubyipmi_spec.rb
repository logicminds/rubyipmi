require 'spec_helper'
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
    expect((value|value2)).to eq true

  end

    it "should create a connection object if freeipmi is present" do
      begin
        conn = Rubyipmi.connect(@user, @pass, @host, "freeipmi")
        conn.kind_of?(Rubyipmi::Freeipmi::Connection).should eq true
      rescue Exception => e
        e.message.match(/freeipmi\ is\ not\ installed/).should eq true
        puts "#{e.message}"
      end
    end

    it "should create a connection object if ipmitool is present" do
      begin
        conn = Rubyipmi.connect(@user, @pass, @host, "ipmitool")
      rescue Exception => e
        expect(e.message).to match(/ipmitool\ is\ not\ installed/)
        puts "#{e.message}"
        return true
      end
      conn.kind_of?(Rubyipmi::Ipmitool::Connection).should eq true
    end

  it "should not create a connection object if a provider is not present" do
    begin
      conn = Rubyipmi.connect(@user, @pass, @host, "bogus")
    rescue Exception => e
        expect(e.message).to match(/Invalid/)
    end
  end

  it "check to find any available installed providers" do
    Rubyipmi.providers_installed?.length.should be > 0
  end



end

