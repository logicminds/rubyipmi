require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe :Sensors do
  before :each do
    provider = "ipmitool"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    @conn = Rubyipmi.connect(user, pass, host, provider, true)

  end

 it 'can return a list of sensors' do
   data = nil

   File.open('spec/files/sensor.txt','r') do |file|
     data = file.readlines('\n')
   end
   @conn.sensors.stub(:getsensors).with(data)
   puts @conn.sensors.to_s
  #values = @conn.sensors.getsensors
  #puts values.inspect
  @conn.sensors.list.count.should be >2
 end
end

