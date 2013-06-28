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

  it "bmc should not be nil" do
    @conn.bmc.should_not be nil
  end

  it "lan should not be nil" do
    @conn.bmc.lan.should_not be_nil
  end

  it "guid should not be nil" do
     @conn.bmc.guid.should_not be_nil
  end

  it "reset cold should return correct options" do
    value = @conn.bmc.reset
    value.should match(/.*ipmitool -f .*/)
    value.should match(/.*-P impipass -U ipmiuser -H ipmihost  bmc reset cold.*/)
  end

  it "reset warm should return correct options" do
    value = @conn.bmc.reset('warm')
    value.should match(/.*ipmitool -f .*/)
    value.should match(/.*-P impipass -U ipmiuser -H ipmihost  bmc reset warm.*/)
  end

  it "info should not be nill" do
    @conn.bmc.info.should_not be_nil
  end

end
