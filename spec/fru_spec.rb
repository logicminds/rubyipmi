require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Fru" do

  attr_accessor :provider
   before :each do
     user = ENV["ipmiuser"]
     pass = ENV["ipmipass"]
     host = ENV["ipmihost"]
     provider = ENV["ipmiprovider"]
     @conn = Rubyipmi.connect(user, pass, host, provider)

   end

   it "test should return manufacturer" do
     @conn.fru.manufacturer.should_not be nil
   end

   it "test should return serial" do
     @conn.fru.serial.should_not be nil
   end

   it "test should return product name" do
     @conn.fru.product.should_not be nil
   end

   it "test should return fru list" do
     @conn.fru.list.length.should be > 1
   end

   it "test missing method with known good method" do
     @conn.fru.chassis_type.should_not be nil
   end

   it "test missing method with known bad method" do
     expect {@conn.fru.blah}.to raise_exception
   end
end