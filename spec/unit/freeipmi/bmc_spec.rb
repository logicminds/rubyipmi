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

    @conn = Rubyipmi.connect(user, pass, host, provider, :debug => true)
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

  it "reads the firmware revision from bmc-info output" do
    data = File.read("spec/fixtures/freeipmi/bmc_info.txt")
    allow(@bmc).to receive(:info).and_call_original
    allow(Rubyipmi).to receive(:locate_command).with('bmc-info').and_return("#{@path}/bmc-info")
    allow(Rubyipmi).to receive(:capture3).and_return([data, '', mock_success_status])

    expect(@bmc.info['Firmware Revision']).to eq('2.09')
  end

  it "cold reset asks the device to cold-reset" do
    allow(Rubyipmi).to receive(:locate_command).with('bmc-device').and_return("#{@path}/bmc-device")
    allow(Rubyipmi).to receive(:capture3).and_return(['', '', mock_success_status])

    expect(@bmc.reset('cold')).to eq(true)
    expect(@bmc.device.lastcall.join(' ')).to include('--cold-reset')
  end

  it "raises when an error has no automatic fix" do
    expect do
      @bmc.find_fix('this is not a known freeipmi error')
    end.to raise_error(RuntimeError, /Could not find fix/)
  end
end
