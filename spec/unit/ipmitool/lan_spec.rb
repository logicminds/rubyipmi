require 'spec_helper'

describe "Lan" do
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
    @conn = Rubyipmi.connect(user, pass, host, provider, {:debug => true})
    @lan = @conn.bmc.lan
    data = nil
    File.open("spec/fixtures/#{provider}/lan.txt", 'r') do |file|
      data = file.read
    end

    allow(@lan).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    allow(@lan).to receive(:`).and_return(data)
    allow($CHILD_STATUS).to receive(:success?).and_return(true)
  end

  it "cmd should be lan with correct number of arguments" do
    @lan.info
    verify_ipmitool_command(@lan, 4, "#{@path}/ipmitool", 'lanplus')
  end

  it "can return a lan information" do
    expect(@lan.info).not_to be_nil
  end

  it "can print valid lan info" do
    expect(@lan.info.length).to be > 1
  end

  it 'should print valid ip address' do
    expect(@lan.ip).to eq('192.168.1.41')
  end

  it 'should print valid snmp string' do
    expect(@lan.snmp).to be_nil
  end

  it 'should print correct mac address' do
    expect(@lan.mac).to eq('00:17:a4:49:ab:70')
  end

  it 'should print correct netmask' do
    expect(@lan.netmask).to eq('255.255.255.0')
  end

  it 'should print correct gateway' do
    expect(@lan.gateway).to eq('192.168.1.1')
  end

  it 'should print vlanid' do
    expect(@lan.vlanid).to be_nil
  end

  it 'dhcp should return true' do
    expect(@lan.dhcp?).to eq true
  end

  it 'static should return false' do
    expect(@lan.static?).to eq false
  end

  # it 'should attempt to apply fix and fail, then switch to channel 1' do
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
  # end
end
