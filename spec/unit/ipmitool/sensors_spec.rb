require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
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
    Rubyipmi.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")

    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @sensors = @conn.sensors
    File.open("spec/fixtures/#{provider}/sensors.txt",'r') do |file|
      data = file.read
    end
    @sensors.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    @sensors.stub(:`).and_return(data)

    # this is causing an error: An expectation of :success? was set on nil
    $?.stub(:success?).and_return(true)

  end


  it "cmd should be ipmi-sensors with four arguments" do
    @sensors.list
    verify_ipmitool_command(@sensors, 5, "#{@path}/ipmitool", 'sensor')
  end

  it "can return a list of sensors" do
   @sensors.list.should_not be_nil
  end

  it "should return a count of sensors" do
    @sensors.count.should eq(99)
  end

  it "should return a list of fan names" do
    @sensors.fanlist.count.should eq(17)
  end

  it 'should return a list of temp names' do
    @sensors.templist.count.should.should eq(43)
    @sensors.templist.each do | temp |
    end
  end

  it 'should return a list of sensor names as an array' do
    @sensors.names.should be_an_instance_of(Array)
    @sensors.names.count.should eq(99)
  end

  it 'should return an empty list if no data exists' do
    @sensors.stub(:getsensors).and_return(nil)
    @sensors.names.count.should eq(0)
  end

  it 'should return a sensor using method missing' do
    @sensors.names.each do |name|
      sensor = @sensors.send(name)
      sensor.should be_an_instance_of(Rubyipmi::Ipmitool::Sensor)
    end
  end


end

