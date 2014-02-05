require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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
    Rubyipmi.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")

    @conn = Rubyipmi.connect(user, pass, host, provider, {:debug => true})
    @fru = @conn.fru

    File.open("spec/fixtures/#{provider}/fru.txt",'r') do |file|
      data = file.read
    end

    @fru.stub(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
    @fru.stub(:`).and_return(data)
    $?.stub(:success?).and_return(true)

  end

  it "cmd should be ipmi-sensors with correct number of arguments" do
    @fru.list
    verify_ipmitool_command(@fru, 3, "#{@path}/ipmitool", 'fru')
  end

  it 'should return a list of unparsed frus' do
    @fru.getfrus.should_not be_nil
  end

  it 'should return a list of fru names' do
    @fru.names.count.should eq(13)
  end

  it "should return a list of parsed frus" do
    @fru.list.count.should eq(13)
  end

  it 'should return a manufactor' do
    @fru.product_manufacturer.should eq('HP')
  end

  it 'should return a product' do
    @fru.product_name.should eq('ProLiant SL230s Gen8')
  end

  it 'should return a board serial' do
    @fru.board_serial.should eq('USE238F0D0')
  end

  it 'should return a product serial' do
    @fru.product_serial.should eq('USE238F0D0')
  end

  it 'should return a asset tag' do
    @fru.product_asset_tag.should eq('000015B90F82')
  end

  it 'should return a fru using method missing' do
    @fru.names.each do |name|
      fru = @fru.send(name)
      fru.should be_an_instance_of(Rubyipmi::Ipmitool::FruData)
      fru[:name].should eq(name)
    end
  end


end
