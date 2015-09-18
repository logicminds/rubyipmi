require 'spec_helper'

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
    expect(@conn.chassis.power.on).to be_truthy
    sleep(2)
    expect(@conn.chassis.power.status).to eq('on')
  end

  it "test power status" do
    expect(@conn.chassis.power.status).to eq('off')
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
    expect(@conn.chassis.power.off?).to be true
  end
end
