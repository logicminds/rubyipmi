require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe :Fru do

  before :each do
    data = nil
    provider = "ipmitool"
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    @conn = Rubyipmi.connect(user, pass, host, provider, true)
    @fru = @conn.fru
    File.open('spec/fixtures/ipmitool/SL230_fru.txt','r') do |file|
      data = file.read
    end
    @fru.stub(:getfrus).and_return(data)
  end

  it 'should return a list of unparsed frus' do
    @fru.getfrus.should_not be_nil
  end


  it "should return a list of parsed frus" do
    @fru.list.count.should eq(13)
  end

  it 'should return a list of parsed frus even if one fru exists' do
    data = nil
    File.open('spec/fixtures/ipmitool/hp_dl380_g5_fru.txt','r') do |file|
      data = file.read
    end
    @fru.stub(:getfrus).and_return(data)
    @fru.list.count.should eq(1)

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


end
