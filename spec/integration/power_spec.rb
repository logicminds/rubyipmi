require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Power" do

  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "192.168.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(user, pass, host, provider)
    @conn.chassis.power.off
    sleep(1)
  end

  it "test to turn power on" do
    @conn.chassis.power.on.should be_true
    sleep(2)
    @conn.chassis.power.status.should eq('on')
  end

  it "test to turn power off" do
    @conn.chassis.power.on
    # I am seeing strange errors when trying to turn off the system
    # Unable to set Chassis Power Control to Down/Off
    # this could be due to the fact I am rapidly flipping the state on/off
    sleep(5)
    @conn.chassis.power.off.should be_true
    @conn.chassis.power.status.should eq('off')

  end

  it "test power status" do
    @conn.chassis.power.status.should eq('off')

  end

  it "test to check that options automatically change" do
    before = @conn.chassis.power.options.clone
    @conn.chassis.power.off
    after = @conn.chassis.power.options.clone
    after.length.should be > before.length
  end

  it "test to check if power status if off" do
    before = @conn.chassis.power.options.clone
    @conn.chassis.power.off
    after = @conn.chassis.power.options.clone
    sleep(2)
    @conn.chassis.power.off?.should be_true
  end

end