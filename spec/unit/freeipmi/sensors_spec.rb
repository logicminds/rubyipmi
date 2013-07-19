require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
describe :Sensors do

  before :each do
    data = nil
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @sensors = @conn.sensors
    File.open("spec/fixtures/#{provider}/sensors.txt",'r') do |file|
      data = file.read
    end
    @sensors.stub(:getsensors).and_return(data)
  end

  it "can return a list of sensors" do
   @sensors.list.should_not be_nil
  end

  it "should return a count of sensors" do
    @sensors.count.should eq(29)
  end

  it "should return a list of fan names" do
    @sensors.fanlist.count.should eq(13)
  end

  it 'should return a list of temp names' do
    @sensors.templist.count.should.should eq(7)
  end

  it 'should return a list of sensor names as an array' do
    @sensors.names.should be_an_instance_of(Array)
    @sensors.names.count.should eq(29)
  end

  it 'should return an empty list if no data exists' do
    @sensors.stub(:getsensors).and_return(nil)
    @sensors.names.count.should eq(0)
  end

  it 'should return a sensor using method missing' do
    @sensors.names.each do |name|
      sensor = @sensors.send(name)
      sensor.should be_an_instance_of(Rubyipmi::Freeipmi::Sensor)
      sensor[:name].should eq(name)
    end
  end


end

