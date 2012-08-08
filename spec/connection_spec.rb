require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe "Connection" do

  before :each do
          user = ENV["ipmiuser"]
          pass = ENV["ipmipass"]
          host = ENV["ipmihost"]
          @conn = Freeipmi.connect(user, pass, host)

  end

  it "creates a new object" do
     @conn.should_not be_nil

  end

  it 'creates a bmc object' do
    @conn.bmc.should_not be_nil
  end

  it 'creates a chassis object' do
    @conn.chassis.should_not be_nil
  end

  it 'bmc info object is not null' do
    @conn.bmc.info.should_not be_nil
  end

end
#it "raises an error if host is unreachable" do
#  conn = Freeipmi.connect("admin", "creative", "192.168.1.181")
#
#end