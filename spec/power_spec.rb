describe "Power" do

  before :each do
          user = ENV["ipmiuser"]
          pass = ENV["ipmipass"]
          host = ENV["ipmihost"]
          @conn = Freeipmi.connect(user, pass, host)

  end

  it "test to turn power on" do
    @conn.chassis.power.on.should == true
  end

  it "test to turn power off" do
    @conn.chassis.power.off.should == true
  end

  it "test power status" do
    @conn.chassis.power.status.should_not be_nil

  end

  it "test to check that options automatically change" do
    before = @conn.chassis.power.options.clone
    @conn.chassis.power.off
    after = @conn.chassis.power.options.clone
    after.length.should be > before.length
  end

  it "test to check if power status if off" do
    before = @conn.chassis.power.options.clone
    @conn.chassis.power.off
    after = @conn.chassis.power.options.clone
    sleep(2)
    @conn.chassis.power.off?.should == true
  end

end