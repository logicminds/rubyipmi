require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe :Fru do

  before :each do
    data = nil
    provider = "freeipmi"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @fru = @conn.fru
    File.open("spec/fixtures/#{provider}/fru.txt",'r') do |file|
      data = file.read
    end
    @fru.stub(:getfrus).and_return(data)
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
