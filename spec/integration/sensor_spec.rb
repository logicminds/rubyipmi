require 'spec_helper'
describe "Sensors" do
  attr_accessor :provider
  before :each do
    user = ENV["ipmiuser"] || 'admin'
    pass = ENV["ipmipass"] || 'password'
    host = ENV["ipmihost"] || "10.0.1.16"
    provider = ENV["ipmiprovider"] || 'ipmitool'
    @conn = Rubyipmi.connect(user, pass, host, provider)
  end

  it "test get all sensors" do
    expect(@conn.sensors.list.count).to be > 1
  end

  it "test should refresh data" do
    old = @conn.sensors.list
    @conn.sensors.refresh
    new = @conn.sensors.list
    expect(old).not_to equal(new)
  end

  it "test should return count greater than 1" do
    expect(@conn.sensors.count).to be > 1
  end

  it "test should return names" do
    expect(@conn.sensors.names.count).to be > 1
  end

  it "test should return list of fans" do
    expect(@conn.sensors.fanlist.count).to be > 1
  end

  it "test should return list of temps" do
    expect(@conn.sensors.templist.count).to be > 1
  end
end
