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
    @fru.list.count.should be(20)
  end


end
