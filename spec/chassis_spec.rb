describe "Chassis" do

  before :each do
          user = ENV["ipmiuser"]
          pass = ENV["ipmipass"]
          host = ENV["ipmihost"]
          @conn = Freeipmi.connect(user, pass, host)

  end

  it "test to turn uid light on for 10 seconds" do
    value = @conn.chassis.identify(true, 5)
    sleep(6)
    value.should == true
  end

  it "test to turn uid light on then off" do
    @conn.chassis.identify(true)
    sleep(2)
    @conn.chassis.identify(false).should == true
  end

end