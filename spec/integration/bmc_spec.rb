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
    expect(@conn.bmc).not_to be_nil
  end

  it "options should change after calling info" do
    before = @conn.bmc.options.clone
    info = @conn.bmc.info
    after = @conn.bmc.options.clone
    expect(before.length).to be < after.length
  end

  it 'should retrun a max retry count' do
    expect(@conn.bmc.max_retry_count).to be > 0
  end

  it "should reset the bmc device" do
    expect(@conn.bmc.reset('cold')).not_to be_nil
  end

  it "should reset the bmc device warmly" do
    expect(@conn.bmc.reset('warm')).not_to be_nil
  end

  it "reset should fail when type is wrong" do
    expect{ @conn.bmc.reset('freezing') }.to raise_exception
  end

  it "is able to retrieve the bmc info" do
    expect(@conn.bmc.info).not_to be_nil
  end

  it "is able to retrieve the guid" do
    expect(@conn.bmc.guid).not_to be_nil
  end
end
