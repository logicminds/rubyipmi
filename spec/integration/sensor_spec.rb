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
    @conn.sensors.list.count.should be > 1
  end

  it "test should refresh data" do
    old = @conn.sensors.list
    @conn.sensors.refresh
    new = @conn.sensors.list
    old.should_not equal(new)
  end

  it "test should return count greater than 1" do
    @conn.sensors.count.should be > 1
  end

  it "test should return names" do
    @conn.sensors.names.count.should be > 1
  end

  it "test should return list of fans" do
    @conn.sensors.fanlist.count.should be > 1
  end

  it "test should return list of temps" do
    @conn.sensors.templist.count.should be > 1
  end



end
