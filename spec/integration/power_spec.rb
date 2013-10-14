require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Power" do

  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "10.0.1.16"
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

  it "test power status" do
    @conn.chassis.power.status.should eq('off')

  end

  it "test to check if power status is off" do
    @conn.chassis.power.off
    max_count = 12
    while 0 < max_count
      if @conn.chassis.power.off?
        break
      else
        sleep(5)
        max_count = max_count - 1
      end
    end
    @conn.chassis.power.off?.should be_true
  end

end