require 'spec_helper'

describe "Lan" do
  before :all do
    @user ||= ENV["ipmiuser"] || "admin"
    @pass ||= ENV["ipmipass"] || "password"
    @host ||= ENV["ipmihost"] || "10.0.1.16"
    @provider ||= ENV["ipmiprovider"] || "ipmitool"
  end
  let(:conn) { Rubyipmi.connect(@user, @pass, @host, @provider) }

  it "get ip address" do
    expect(conn.bmc.lan.ip).to eq(@host)
  end

  it "get netmask" do
    expect(conn.bmc.lan.netmask).to be_truthy
  end

  it "get gateway address" do
    expect(conn.bmc.lan.gateway).to be_truthy
  end

  it "get mac address" do
    expect(conn.bmc.lan.mac).to be_truthy
  end

  it "get static or dhcp" do
    expect(conn.bmc.lan.dhcp?).to be_truthy
  end

  it "static should be opposite of dhcp" do
    expect(conn.bmc.lan.dhcp? ).to_not eq(conn.bmc.lan.static?)
  end

  it "should set gateway address" do
    gw = conn.bmc.lan.gateway
    conn.bmc.lan.gateway = gw
    expect(conn.bmc.lan.gateway = gw).to be_truthy
  end

  it "should set netmask" do
    netmask = conn.bmc.lan.netmask
    expect(conn.bmc.lan.netmask = netmask).to be_truthy
  end

  it "should set ip address" do
    ip = conn.bmc.lan.ip
    expect(conn.bmc.lan.ip = ip).to be_truthy
  end
end
