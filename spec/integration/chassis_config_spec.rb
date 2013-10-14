require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Chassis Config" do

  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "10.0.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(user, pass, host, provider)

  end

  it "test to set booting from PXE" do
    @conn.chassis.config.bootpxe.should == true
  end

  it "test to set booting from Disk" do
      @conn.chassis.config.bootdisk.should == true
  end

  it "test to set booting from Cdrom" do
      @conn.chassis.config.bootcdrom.should == true
  end

  it "test to set booting from bios" do
      @conn.chassis.config.bootbios.should == true
  end

  it "test to set boot persistent value" do

  end

  it "test to checkout the entire chassis config" do

  end



end