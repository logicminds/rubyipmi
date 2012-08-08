require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
describe "Bmc" do
  it "creates a bmc object" do
    Freeipmi::Bmc.new().should_not be_nil

  end

  it "is able to access a info object" do
    Freeipmi::Bmc.new().info.should_not be_nil
  end
  end