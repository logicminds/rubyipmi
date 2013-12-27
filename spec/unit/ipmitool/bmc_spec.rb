require 'spec_helper'

describe Rubyipmi::Ipmitool::Bmc do

  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil
    provider = "ipmitool"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    Rubyipmi.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @bmc = @conn.bmc
    data = nil
    File.open("spec/fixtures/#{provider}/bmc_info.txt",'r') do |file|
      data = file.read
    end

    @bmc.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    $?.stub(:success?).and_return(true)

    @bmc.stub(:guid).and_return("guid")

    # stub the real command, and set the current @result
    Open3.stub(:popen2e) { @bmc.instance_variable_set(:@result, data) }
    @bmc.stub(:validate_status).and_return(true)
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

  it "info should not be nil" do
    @bmc.info.should_not be_nil
  end

  it "info should parse as expected" do
    @bmc.info.should eq(RETRIEVE)
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
