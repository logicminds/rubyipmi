require 'spec_helper'

describe "Connection" do

  before :each do
    user ||= ENV["ipmiuser"] || "admin"
    pass ||= ENV["ipmipass"] || "password"
    host ||= ENV["ipmihost"] || "192.168.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    @conn = Rubyipmi.connect(user, pass, host, provider)
  end

  it "creates a new object" do
     expect(@conn).to be_truthy
  end

  it 'creates a bmc object' do
    expect(@conn.bmc).to be_truthy
  end

  it 'creates a chassis object' do
    expect(@conn.chassis).to be_truthy
  end

  it 'can test the connection' do
    expect(@conn.connection_works?).to eq true
  end

  it 'can test the connection when credentials are wrong' do
    user ||= ENV["ipmiuser"] || "admin"
    pass = "wrong_password"
    host ||= ENV["ipmihost"] || "192.168.1.16"
    provider ||= ENV["ipmiprovider"] || "ipmitool"
    conn = Rubyipmi.connect(user, pass, host, provider)
    expect(conn.connection_works?).to eq false
  end

  it 'can get diag info' do
    expect(@conn.get_diag.keys).to eq([:provider, :frus, :sensors, :bmc_info, :version])
  end

  it 'can get version info' do
    expect(@conn.bmc.version).to match(/[\d\.]{3,4}/)
  end
end