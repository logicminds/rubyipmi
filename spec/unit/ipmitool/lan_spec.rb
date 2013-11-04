require 'spec_helper'

describe Rubyipmi::Ipmitool::Lan do

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
    @lan = @conn.bmc.lan
    data = nil
    File.open("spec/fixtures/#{provider}/lan.txt",'r') do |file|
      data = file.read
    end

    @lan.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    @lan.stub(:`).and_return(data)
    $?.stub(:success?).and_return(true)
  end

  it "cmd should be lan with correct number of arguments" do
    @lan.info
    verify_ipmitool_command(@lan, 3, "#{@path}/ipmitool", 'lan')
  end

  it "can return a lan information" do
    @lan.info.should_not be_nil
  end

  it "can print valid lan info" do
    @lan.info.length.should > 1
  end

  it 'should print valid ip address' do
    @lan.ip.should eq('192.168.1.41')
  end

  it 'should print valid snmp string' do
    @lan.snmp.should be_nil

  end

  it 'should print correct mac address' do
    @lan.mac.should eq('00:17:a4:49:ab:70')
  end

  it 'should print correct netmask' do
    @lan.netmask.should eq('255.255.255.0')
  end

  it 'should print correct gateway' do
    @lan.gateway.should eq('192.168.1.1')
  end

  it 'should print vlanid' do
    @lan.vlanid.should be_nil
  end

  it 'dhcp should return true' do
    @lan.dhcp?.should be_true
  end

  it 'static should return false' do
    @lan.static?.should be_false
  end

  #it 'should attempt to apply fix and fail, then switch to channel 1' do
  #  channelbefore = @lan.channel
  #  error = "some lan channel problem"
  #  @lan.stub(:`).and_return(error)
  #  $?.stub(:success?).and_return(false)
  #  @lan.ip
  #  channelbefore = @lan.channel
  #
  #  data = nil
  #  File.open("spec/fixtures/#{provider}/lan.txt",'r') do |file|
  #    data = file.read
  #  end
  #
  #  @lan.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
  #  @lan.stub(:`).and_return(data)
  #  $?.stub(:success?).and_return(true)
  #
  #end

end

