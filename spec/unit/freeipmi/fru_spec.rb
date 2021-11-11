require 'spec_helper'
describe :Fru do
  before :all do
    @path = '/usr/local/bin'
  end

  before :each do
    allow_message_expectations_on_nil
    data = nil
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return("#{@path}/ipmipower")

    @conn = Rubyipmi.connect(user, pass, host, provider, :debug => true)
    @fru = @conn.fru
    File.open("spec/fixtures/#{provider}/fru.txt", 'r') do |file|
      data = file.read
    end

    allow(@fru).to receive(:locate_command).with('ipmi-fru').and_return("#{@path}/ipmi-fru")
    allow(@fru).to receive(:`).and_return(data)
    allow(Rubyipmi).to receive(:capture3).and_return([data, '', true])
  end

  it "cmd should be ipmi-fru with correct number of arguments" do
    @fru.list
    verify_freeipmi_command(@fru, 3, "#{@path}/ipmi-fru")
  end

  it 'should list data' do
    expect(@fru.names.count).to eq(1)
  end

  it 'should return a list of unparsed frus' do
    expect(@fru.getfrus).not_to be_nil
  end

  it "should return a list of parsed frus" do
    expect(@fru.list.count).to eq(1)
  end

  it 'should return a manufacturer' do
    expect(@fru.board_manufacturer).to eq('HP')
  end

  it 'should return a product' do
    expect(@fru.board_product_name).to eq('ProLiant DL380 G5')
  end

  it 'should return a chassis serial' do
    expect(@fru.chassis_serial_number).to eq('2UX64201U2')
  end

  it 'should return a board serial' do
    expect(@fru.board_serial_number).to eq('2UX64201U2')
  end

  it 'should return a list of fru names' do
    expect(@fru.names.count).to eq(1)
  end

  it 'should return a fru using method missing' do
    @fru.names.each do |name|
      fru = @fru.send(name)
      expect(fru).to be_an_instance_of(Rubyipmi::Freeipmi::FruData)
      expect(fru[:name]).to eq(name)
    end
  end
end
