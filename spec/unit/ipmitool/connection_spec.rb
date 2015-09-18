require 'spec_helper'

describe :Connection do
  before :all do
    @path = '/usr/local/bin'
    @provider = "ipmitool"
    @user = "ipmiuser"
    @pass = "impipass"
    @host = "ipmihost"
  end

  before :each do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true})
  end

  it "connection should not be nil" do
    expect(@conn).not_to be_nil
  end

  it "fru should not be nil" do
    expect(@conn.fru).not_to be_nil
  end

  it "provider should not be nil" do
    expect(@conn.provider).not_to be_nil
  end

  it "provider should be ipmitool" do
    expect(@conn.provider).to eq("ipmitool")
  end

  it "bmc should not be nil" do
    expect(@conn.bmc).not_to be_nil
  end

  it "sensors should not be nil" do
    expect(@conn.sensors).not_to be_nil
  end

  it "chassis should not be nill" do
    expect(@conn.chassis).not_to be_nil
  end

  it "provider should return ipmitool" do
    expect(@conn.provider).to eq("ipmitool")
  end

  it 'object should have driver set to auto if not specified' do
    expect(@conn.options['I']).to eq 'lanplus'
  end

  it 'object should have driver set to auto if not specified' do
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'auto'})
    expect(@conn.options.has_key?('I')).to eq false
  end

  it 'should raise exception if invalid driver type' do
    expect{Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'foo'})}.to raise_error(RuntimeError)
  end

  it 'object should have priv type set to ADMINISTRATOR if not specified' do
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'auto'})
    expect(@conn.options.has_key?('L')).to eq false
  end

  it 'object should have priv type set to USER ' do
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:privilege => 'USER', :debug => true, :driver => 'auto'})
    expect(@conn.options.fetch('L')).to eq('USER')
  end

  it 'should raise exception if invalid privilege type' do
    expect{Rubyipmi.connect(@user, @pass, @host, @provider,{:privilege => 'BLAH',:debug => true, :driver => 'auto'})}.to raise_error(RuntimeError)
  end

  it 'object should have driver set to lanplus' do
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'lan20'})
    expect(@conn.options['I']).to eq('lanplus')
  end

  it 'object should have driver set to lanplus' do
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'lan15'})
    expect(@conn.options['I']).to eq('lan')
  end

  it 'object should have driver set to open' do
    @conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'open'})
    expect(@conn.options['I']).to eq('open')
  end

  describe 'test' do
    it 'should retrun boolean on test connection when result is not a hash' do
      conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'auto'})
      bmc = double()
      allow(bmc).to receive(:info).and_return('')
      allow(conn).to receive(:bmc).and_return(bmc)
      expect(conn.connection_works?).to eq false
    end

    it 'should retrun boolean on test connection when result is a hash' do
      conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'auto'})
      bmc = double()
      allow(bmc).to receive(:info).and_return({:test => true})
      allow(conn).to receive(:bmc).and_return(bmc)
      expect(conn.connection_works?).to eq true
    end

    it 'should retrun boolean on test connection when nil' do
      conn = Rubyipmi.connect(@user, @pass, @host, @provider,{:debug => true, :driver => 'auto'})
      bmc = double()
      allow(bmc).to receive(:info).and_return(nil)
      allow(conn).to receive(:bmc).and_return(bmc)
      expect(conn.connection_works?).to eq false
    end
  end
end
