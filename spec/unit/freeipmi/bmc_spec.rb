require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')



describe "Bmc" do
  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    Rubyipmi.stub(:locate_command).with('ipmipower').and_return("#{@path}/ipmipower")

    @conn = Rubyipmi.connect(user, pass, host, provider,{:debug => true})
    @bmc = @conn.bmc
    data = nil
    File.open("spec/fixtures/#{provider}/bmc_info.txt",'r') do |file|
      data = file.read
    end
    @bmc.stub(:guid).and_return("guid")
    @bmc.stub(:info).and_return("info")
  end

  it "bmc should not be nil" do
    @bmc.should_not be nil
  end

  it "lan should not be nil" do
    @bmc.lan.should_not be_nil
  end

  it "guid should not be nil" do
     @bmc.guid.should_not be_nil
  end

  it "info should not be nill" do
    @bmc.info.should_not be_nil
  end

end
