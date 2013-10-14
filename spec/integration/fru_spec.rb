require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Fru" do

  attr_accessor :provider
   before :each do
     user ||= ENV["ipmiuser"] || "admin"
     pass ||= ENV["ipmipass"] || "password"
     host ||= ENV["ipmihost"] || "10.0.1.16"
     provider ||= ENV["ipmiprovider"] || "ipmitool"
     @conn = Rubyipmi.connect(user, pass, host, provider)

   end

  after(:each) do
    if ENV['rubyipmi_debug'] == 'true'
      puts "Last Call: #{@conn.fru.lastcall.inspect}" unless @conn.fru.lastcall.nil?
    end
  end

  it "test should return manufacturer" do
    @conn.fru.manufacturer.should_not be nil

   end

   it "test should return serial" do
     @conn.fru.board_serial.should_not be nil
   end

   it "test should return product name" do
     @conn.fru.model.should_not be nil
   end

   it "test should return fru list" do
     @conn.fru.list.length.should be >= 1
   end

   it "test missing method with known good method" do
     @conn.fru.chassis_type.should_not be nil
   end

   it "test missing method with known bad method" do
     expect {@conn.fru.blah}.to raise_exception
   end
end