require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Sensors" do

  attr_accessor :provider
  before :each do
    user = ENV["ipmiuser"]
    pass = ENV["ipmipass"]
    host = ENV["ipmihost"]
    provider = ENV["ipmiprovider"]
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

  it "test should create new Sensor" do
    if provider == "ipmitool"
      Rubyipmi::Ipmitool::Sensor.new("fakesensor").should_not be nil
    else
      Rubyipmi::Freeipmi::Sensor.new("fakesensor").should_not be nil
    end
  end

  it "test missing method with known good method" do
    @conn.sensors.fan_1.should_not be nil
  end

  it "test missing method with known bad method" do
    expect {@conn.sensors.blah}.to raise_exception
  end


end
