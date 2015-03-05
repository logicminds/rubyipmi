require 'spec_helper'

describe :Fru do

  before :all do
    @path = '/usr/local/bin'
  end

 before :each do
    allow_message_expectations_on_nil
    data = nil
    provider = "ipmitool"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")

    @conn = Rubyipmi.connect(user, pass, host, provider, {:debug => true})
    @fru = @conn.fru

    File.open("spec/fixtures/#{provider}/fru.txt",'r') do |file|
      data = file.read
    end

    allow(@fru).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    allow(@fru).to receive(:`).and_return(data)
    allow($?).to receive(:success?).and_return(true)

  end

  it "cmd should be ipmi-sensors with correct number of arguments" do
    @fru.list
    verify_ipmitool_command(@fru, 3, "#{@path}/ipmitool", 'fru')
  end

  it 'should return a list of unparsed frus' do
    expect(@fru.getfrus).not_to be_nil
  end

  it 'should return a list of fru names' do
    expect(@fru.names.count).to eq(13)
  end

  it "should return a list of parsed frus" do
    expect(@fru.list.count).to eq(13)
  end

  it 'should return a manufactor' do
    expect(@fru.product_manufacturer).to eq('HP')
  end

  it 'should return a product' do
    expect(@fru.product_name).to eq('ProLiant SL230s Gen8')
  end

  it 'should return a board serial' do
    expect(@fru.board_serial).to eq('USE238F0D0')
  end

  it 'should return a product serial' do
    expect(@fru.product_serial).to eq('USE238F0D0')
  end

  it 'should return a asset tag' do
    expect(@fru.product_asset_tag).to eq('000015B90F82')
  end

  it 'should return a fru using method missing' do
    @fru.names.each do |name|
      fru = @fru.send(name)
      expect(fru).to be_an_instance_of(Rubyipmi::Ipmitool::FruData)
      expect(fru[:name]).to eq(name)
    end
  end


end
