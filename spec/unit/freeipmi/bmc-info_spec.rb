require 'spec_helper'

describe Rubyipmi::Freeipmi::BmcInfo do
  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    Rubyipmi.stub(:locate_command).with('ipmipower').and_return("#{@path}/ipmipower")

    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @bmcinfo = @conn.bmc.information
    data = nil
    File.open("spec/fixtures/#{provider}/bmc_info.txt",'r') do |file|
      data = file.read
    end
    @bmcinfo.stub(:locate_command).with('bmc-info').and_return("#{@path}/bmc-info")
    @bmcinfo.stub(:`).and_return(data)
    $?.stub(:success?).and_return(true)
  end

  describe '#retrieve' do
    it "should be bmc-info with three arguments: hostname, driver-type, config-file" do
      @bmcinfo.retrieve
      verify_freeipmi_command(@bmcinfo, 3, "#{@path}/bmc-info")
    end
  end

  describe '#guid' do
    it "should be bmc-info with four arguments: hostname, driver-type, config-file, guid" do
      @bmcinfo.guid
      verify_freeipmi_command(@bmcinfo, 4, "#{@path}/bmc-info")
    end
  end



end
