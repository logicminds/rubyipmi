require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

require 'spec_helper'


describe "Bmc" do

  before :each do
            provider = "ipmitool"
            user = "ipmiuser"
            pass = "impipass"
            host = "ipmihost"
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


end