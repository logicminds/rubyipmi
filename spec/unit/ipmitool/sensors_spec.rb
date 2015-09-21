require 'spec_helper'

describe :Sensors do
  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil

    data = nil
    provider = "ipmitool"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")

    @conn = Rubyipmi.connect(user, pass, host, provider, :debug => true)
    @sensors = @conn.sensors
    File.open("spec/fixtures/#{provider}/sensors.txt", 'r') do |file|
      data = file.read
    end
    allow(@sensors).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    allow(@sensors).to receive(:`).and_return(data)

    # this is causing an error: An expectation of :success? was set on nil
    allow($CHILD_STATUS).to receive(:success?).and_return(true)
  end

  # it 'should figure out to add the -I lanplus' do
  #  error = 'Authentication type NONE not supported'
  #  @sensors.stub(:`).and_return(error)
  #  @sensors.list
  #  @sensors.lastcall.includes?('-I lanplus')
  # end

  # it "cmd should be ipmi-sensors with three arguments" do
  #  @sensors.list
  #  verify_ipmitool_command(@sensors, 3, "#{@path}/ipmitool", 'sensor')
  # end

  it "can return a list of sensors" do
    expect(@sensors.list).not_to be_nil
  end

  it "should return a count of sensors" do
    expect(@sensors.count).to eq(99)
  end

  it "should return a list of fan names" do
    expect(@sensors.fanlist.count).to eq(17)
  end

  it 'should return a list of temp names' do
    expect(@sensors.templist.count).to eq(43)
    @sensors.templist.each do |temp|
    end
  end

  it 'should return a list of sensor names as an array' do
    expect(@sensors.names).to be_an_instance_of(Array)
    expect(@sensors.names.count).to eq(99)
  end

  it 'should return an empty list if no data exists' do
    allow(@sensors).to receive(:getsensors).and_return(nil)
    expect(@sensors.names.count).to eq(0)
  end

  it 'should return a sensor using method missing' do
    @sensors.names.each do |name|
      sensor = @sensors.send(name)
      expect(sensor).to be_an_instance_of(Rubyipmi::Ipmitool::Sensor)
    end
  end

  it "test should create new Sensor" do
    expect(Rubyipmi::Ipmitool::Sensor.new("fakesensor")).not_to be nil
  end

  # it 'fix should be added to options after error occurs' do
  #  error = nil
  #  File.open("spec/fixtures/ipmitool/errors.txt",'r') do |file|
  #    error = file.read
  #  end
  #  @sensors.stub(:`).and_return(error)
  #  $?.stub(:success?).and_return(false)
  #  @sensors.list
  #  after = @sensors.options.fetch('I', false).should_not be_false
  # end
end
