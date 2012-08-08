require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe "Bmc" do
  before :each do
          user = ENV["ipmiuser"]
          pass = ENV["ipmipass"]
          host = ENV["ipmihost"]
          @conn = Freeipmi.connect(user, pass, host)

  end

  it "creates a bmc info object" do
    Freeipmi::BmcInfo.new(@conn.options).should_not be_nil

  end

  it "options should change after calling findtype" do
    info = @conn.bmc.info
    before = info.options.clone
    @conn.bmc.info.retrieve
    after = info.options.clone
    before.length.should be < after.length
  end


  it "is able to retrieve the bmc info" do
    @conn.bmc.info.retrieve.should_not be_nil

  end
end