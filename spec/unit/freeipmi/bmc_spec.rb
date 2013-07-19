require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')



describe "Bmc" do

  before :each do
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @bmc = @conn.bmc
    data = nil
    File.open("spec/fixtures/#{provider}/bmc_info.txt",'r') do |file|
      data = file.read
    end
    @bmc.stub(:info).and_return(data)
    @bmc.stub(:guid).and_return("guid")

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
