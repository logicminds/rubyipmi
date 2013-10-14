require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
    Rubyipmi.stub(:locate_command).with('ipmipower').and_return("#{@path}/ipmipower")

    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @fru = @conn.fru
    File.open("spec/fixtures/#{provider}/fru.txt",'r') do |file|
      data = file.read
    end

    @fru.stub(:locate_command).with('ipmi-fru').and_return("#{@path}/ipmi-fru")
    @fru.stub(:`).and_return(data)
    $?.stub(:success?).and_return(true)
  end

  it "cmd should be ipmi-fru with correct number of arguments" do
    @fru.list
    verify_freeipmi_command(@fru, 2, "#{@path}/ipmi-fru")
  end

  it 'should list data' do
    @fru.names.count.should eq(1)
  end

  it 'should return a list of unparsed frus' do
    @fru.getfrus.should_not be_nil
  end


  it "should return a list of parsed frus" do
    @fru.list.count.should eq(1)
  end

  it 'should return a manufacturer' do
    @fru.board_manufacturer.should eq('HP')
  end

  it 'should return a product' do
    @fru.board_product_name.should eq('ProLiant DL380 G5')
  end

  it 'should return a chassis serial' do
    @fru.chassis_serial_number.should eq('2UX64201U2')
  end

  it 'should return a board serial' do
    @fru.board_serial_number.should eq('2UX64201U2')
  end

  it 'should return a list of fru names' do
    @fru.names.count.should eq(1)
  end

  it 'should return a fru using method missing' do
    @fru.names.each do |name|
      fru = @fru.send(name)
      fru.should be_an_instance_of(Rubyipmi::Freeipmi::FruData)
      fru[:name].should eq(name)

    end
  end

end
