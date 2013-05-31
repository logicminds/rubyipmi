require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe "Bmc" do

  before :each do
            user = ENV["ipmiuser"]
            pass = ENV["ipmipass"]
            host = ENV["ipmihost"]
            provider = ENV["ipmiprovider"]
            @conn = Rubyipmi.connect(user, pass, host, provider)

  end

  it "creates a bmc object" do
    @conn.bmc.should_not be_nil

  end

  #it "options should change after calling info" do
  #  info = @conn.bmc.info
  #  before = info.options.clone
  #  @conn.bmc.info.retrieve
  #  after = info.options.clone
  #  before.length.should be < after.length
  #end

  it "should reset the bmc device" do
    @conn.bmc.reset('cold').should_not be_nil
  end

  it "should reset the bmc device warmly" do
    @conn.bmc.reset('warm').should_not be_nil
  end

  it "reset should fail when type is wrong" do
    @conn.bmc.reset('freezing').should_be nil
  end

  it "is able to retrieve the bmc info" do
    @conn.bmc.info.should_not be_nil
  end

  it "is able to retrieve the guid" do
    @conn.bmc.guid.should_not be_nil
  end

end