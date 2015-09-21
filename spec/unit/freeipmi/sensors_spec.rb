require 'spec_helper'

describe :Sensors do
  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil
    data = nil
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    # this stub allows us to mock the command that would be used to verify provider installation
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return("#{@path}/ipmipower")

    @conn = Rubyipmi.connect(user, pass, host, provider, {:debug => true})
    @sensors = @conn.sensors
    File.open("spec/fixtures/#{provider}/sensors.txt", 'r') do |file|
      data = file.read
    end
    # this stub allows us to mock the command that is used with this test case
    allow(@sensors).to receive(:locate_command).with('ipmi-sensors').and_return('/usr/local/bin/ipmi-sensors')

    # these stubs allow us to run the command and return the fixtures
    allow(@sensors).to receive(:`).and_return(data)
    allow($?).to receive(:success?).and_return(true)
  end

  it "cmd should be ipmi-sensors with six arguments" do
    @sensors.list
    verify_freeipmi_command(@sensors, 6, "#{@path}/ipmi-sensors")
  end

  it "can return a list of sensors" do
    expect(@sensors.list).not_to be_nil
  end

  it "should return a count of sensors" do
    expect(@sensors.count).to eq(29)
  end

  it "should return a list of fan names" do
    expect(@sensors.fanlist.count).to eq(13)
  end

  it 'should return a list of temp names' do
    expect(@sensors.templist.count).to eq(7)
  end

  it 'should return a list of sensor names as an array' do
    expect(@sensors.names).to be_an_instance_of(Array)
    expect(@sensors.names.count).to eq(29)
  end

  it 'should return an empty list if no data exists' do
    allow(@sensors).to receive(:getsensors).and_return(nil)
    expect(@sensors.names.count).to eq(0)
  end

  it 'should return a sensor using method missing' do
    @sensors.names.each do |name|
      sensor = @sensors.send(name)
      expect(sensor).to be_an_instance_of(Rubyipmi::Freeipmi::Sensor)
      expect(sensor[:name]).to eq(name)
    end
  end

  #it 'fix should be added to options after error occurs' do
  #  error = nil
  #  File.open("spec/fixtures/freeipmi/errors.txt",'r') do |file|
  #    error = file.read
  #  end
  #  @sensors.stub(:`).and_return(error)
  #  $?.stub(:success?).and_return(false)
  #  @sensors.refresh
  #  after = @sensors.options.fetch('driver-type', false).should_not be_false
  #end
end
