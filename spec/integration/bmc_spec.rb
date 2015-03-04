require 'spec_helper'

describe "Bmc" do

  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "10.0.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(user, pass, host, provider)

  end

  it "creates a bmc object" do
    @conn.bmc.should_not be_nil
  end

  it "options should change after calling info" do
    before = @conn.bmc.options.clone
    info = @conn.bmc.info
    after = @conn.bmc.options.clone
    before.length.should be < after.length
  end

  it 'should retrun a max retry count' do
    @conn.bmc.max_retry_count.should > 0
  end

  it "should reset the bmc device" do
    @conn.bmc.reset('cold').should_not be_nil
  end

  it "should reset the bmc device warmly" do
    @conn.bmc.reset('warm').should_not be_nil
  end

  it "reset should fail when type is wrong" do
    expect{@conn.bmc.reset('freezing')}.to raise_exception
  end

  it "is able to retrieve the bmc info" do
    @conn.bmc.info.should_not be_nil
  end

  it "is able to retrieve the guid" do
    @conn.bmc.guid.should_not be_nil
  end
end