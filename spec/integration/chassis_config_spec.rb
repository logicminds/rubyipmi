# frozen_string_literal: true

require 'spec_helper'

describe "Chassis Config" do
  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "10.0.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(user, pass, host, provider)
  end

  it "test to set booting from PXE" do
    expect(@conn.chassis.config.bootpxe).to eq(true)
  end

  it "test to set booting from Disk" do
    expect(@conn.chassis.config.bootdisk).to eq(true)
  end

  it "test to set booting from Cdrom" do
    expect(@conn.chassis.config.bootcdrom).to eq(true)
  end

  it "test to set booting from bios" do
    expect(@conn.chassis.config.bootbios).to eq(true)
  end

  it "test to set boot persistent value" do
  end

  it "test to checkout the entire chassis config" do
  end
end
