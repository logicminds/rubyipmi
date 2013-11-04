require 'spec_helper'

describe Rubyipmi::Ipmitool::Connection do

  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    provider = "ipmitool"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    Rubyipmi.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    @conn = Rubyipmi.connect(user, pass, host, provider, true)

  end

  it "connection should not be nil" do
    @conn.should_not be_nil
  end

  it "fru should not be nil" do
    @conn.fru.should_not be_nil
  end

  it "provider should not be nil" do
    @conn.provider.should_not be_nil
  end

  it "provider should be ipmitool" do
    @conn.provider.should == "ipmitool"
  end

  it "bmc should not be nil" do
    @conn.bmc.should_not be_nil
  end

  it "sensors should not be nil" do
    @conn.sensors.should_not be_nil

  end

  it "chassis should not be nill" do
    @conn.chassis.should_not be_nil
  end

  it "provider should return ipmitool" do
    @conn.provider.should eq("ipmitool")
  end

  it "debug value should be true" do
    @conn.debug.should be_true
  end



end
