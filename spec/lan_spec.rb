require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Lan" do

  before :each do
            user = ENV["ipmiuser"]
            pass = ENV["ipmipass"]
            host = ENV["ipmihost"]
            provider = ENV["ipmiprovider"]
            @conn = Rubyipmi.connect(user, pass, host, provider)



  end

  it "get ip address" do
      @conn.bmc.lan.ip.should_not be nil
  end

  it "get subnet" do
    @conn.bmc.lan.subnet.should_not be nil
  end

  it "get gateway address" do
    @conn.bmc.lan.gateway.should_not be nil
  end

  it "get mac address" do
    @conn.bmc.lan.mac.should_not be nil
  end

  it "get static or dhcp" do
    @conn.bmc.lan.dhcp?.should_not be nil
  end

  it "static should be opposite of dhcp" do
    @conn.bmc.lan.dhcp?.should_not == @conn.bmc.lan.static?
  end

  it "dhcp should be opposite of static" do
      @conn.bmc.lan.static?.should_not == @conn.bmc.lan.dhcp?
  end


  it "should set gateway address" do
    gw = @conn.bmc.lan.gateway
        @conn.bmc.lan.set_gateway(gw).should_not be nil
  end

  it "should set subnet" do
    netmask = @conn.bmc.lan.subnet
    @conn.bmc.lan.set_subnet(netmask).should_not be nil
  end

  it "should set ip address" do
    ip = @conn.bmc.lan.ip
    @conn.bmc.lan.set_ip(ip).should_not be nil
  end


end
