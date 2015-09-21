require 'spec_helper'

describe "Bmc" do
  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil
    provider = "ipmitool"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    @conn = Rubyipmi.connect(user, pass, host, provider, :debug => true)
    @bmc = @conn.bmc
    data = nil
    File.open("spec/fixtures/#{provider}/bmc_info.txt", 'r') do |file|
      data = file.read
    end

    allow(@bmc).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    allow(@bmc).to receive(:`).and_return(data)
    allow($CHILD_STATUS).to receive(:success?).and_return(true)

    allow(@bmc).to receive(:guid).and_return("guid")
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

  it "info should not be nil" do
    expect(@bmc.info).not_to be_nil
  end

  it "info should parse as expected" do
    expect(@bmc.info).to eq(RETRIEVE)
  end
end

RETRIEVE = {
  'Device ID' => '17',
  'Device Revision' => '1',
  'Firmware Revision' => '2.9',
  'IPMI Version' => '2.0',
  'Manufacturer ID' => '11',
  'Manufacturer Name' => 'Hewlett-Packard',
  'Product ID' => '8192 (0x2000)',
  'Product Name' => 'Unknown (0x2000)',
  'Device Available' => 'yes',
  'Provides Device SDRs' => 'yes',
  'Additional Device Support' => [
    'Sensor Device',
    'SDR Repository Device',
    'SEL Device',
    'FRU Inventory Device'
  ],
  'Aux Firmware Rev Info' => [
    '0x00',
    '0x00',
    '0x00',
    '0x30'
  ]
}
