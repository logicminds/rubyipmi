require 'spec_helper'

describe "Connection" do

  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "10.0.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(user, pass, host, provider)

  end

  it "creates a new object" do
     @conn.should_not be_nil

  end

  it 'creates a bmc object' do
    @conn.bmc.should_not be_nil
    puts "Last Call: #{@conn.bmc.lastcall.inspect}"

  end

  it 'creates a chassis object' do
    @conn.chassis.should_not be_nil
    puts "Last Call: #{@conn.chassis.lastcall.inspect}"

  end


end
#it "raises an error if host is unreachable" do
#  conn = Freeipmi.connect("admin", "creative", "192.168.1.181")
#
#end