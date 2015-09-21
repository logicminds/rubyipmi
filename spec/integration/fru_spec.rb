require 'spec_helper'

describe "Fru" do

  attr_accessor :provider
  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "10.0.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(user, pass, host, provider)
  end

  it "test should return manufacturer" do
    expect(@conn.fru.manufacturer).not_to be nil
  end

  it "test should return serial" do
    expect(@conn.fru.board_serial).not_to be nil
  end

  it "test should return product name" do
    expect(@conn.fru.model).not_to be nil
  end

  it "test should return fru list" do
    expect(@conn.fru.list.length).to be >= 1
  end

  it "test missing method with known good method" do
    expect(@conn.fru.chassis_type).not_to be nil
  end

  it "test missing method with known bad method" do
    expect { @conn.fru.blah }.to raise_exception
  end
end
