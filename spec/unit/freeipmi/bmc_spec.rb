require 'spec_helper'

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
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return("#{@path}/ipmipower")

    @conn = Rubyipmi.connect(user, pass, host, provider, {:debug => true})
    @bmc = @conn.bmc
    data = nil
    File.open("spec/fixtures/#{provider}/bmc_info.txt", 'r') do |file|
      data = file.read
    end
    allow(@bmc).to receive(:guid).and_return("guid")
    allow(@bmc).to receive(:info).and_return("info")
  end

  it "bmc should not be nil" do
    expect(@bmc).not_to be nil
  end

  it "lan should not be nil" do
    expect(@bmc.lan).not_to be_nil
  end

  it "guid should not be nil" do
    expect(@bmc.guid).not_to be_nil
  end

  it "info should not be nill" do
    expect(@bmc.info).not_to be_nil
  end
end
