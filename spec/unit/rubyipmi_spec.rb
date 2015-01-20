require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe :Rubyipmi do


  before :each do

    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return("#{@path}/ipmitool")
  end

  it 'is provider installed should return ipmitool true' do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/local/bin/ipmitool')
    expect(Rubyipmi.is_provider_installed?('ipmitool')).to eq true
  end

  it 'is locate command should return command in /usr/local/bin' do
    allow(Rubyipmi).to receive(:locate_command).with('ipmitool').and_return('/usr/local/bin/ipmitool')
    expect(Rubyipmi.locate_command('ipmitool')).to eq('/usr/local/bin/ipmitool')
  end

  it 'is provider installed should return freeipmi true' do
    allow(Rubyipmi).to receive(:locate_command).with('ipmipower').and_return('/usr/local/bin/ipmipower')
    expect(Rubyipmi.is_provider_installed?('freeipmi')).to eq true
  end

  it 'is provider installed should return false when bad provider' do
    expect{Rubyipmi.is_provider_installed?('bad_provider')}.to_not raise_error
    expect(Rubyipmi.is_provider_installed?('bad_provider')).to be_falsey
  end

  it 'converts string to symbols' do
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    provider = "ipmitool"
    conn = Rubyipmi.connect(user, pass, host, provider, {'driver' => 'lan15'})
    expect(conn.options).to eq({"H"=>"ipmihost", "U"=>"ipmiuser", "P"=>"impipass", "I"=>"lan"})
  end

  it 'does not error when converting strings to symbols' do
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    provider = "ipmitool"
    conn = Rubyipmi.connect(user, pass, host, provider, {:driver => 'lan15'})
    expect(conn.options).to eq({"H"=>"ipmihost", "U"=>"ipmiuser", "P"=>"impipass", "I"=>"lan"})
  end

  it '#validate_privilege with uppercase' do
    expect(Rubyipmi.validate_privilege('CALLBACK')).to eq(true)
    expect(Rubyipmi.validate_privilege('USER')).to eq(true)
    expect(Rubyipmi.validate_privilege('OPERATOR')).to eq(true)
    expect(Rubyipmi.validate_privilege('ADMINISTRATOR')).to eq(true)

  end

  it '#validate_privilege with lowercase' do
    expect(Rubyipmi.validate_privilege('callback')).to eq(true)
    expect(Rubyipmi.validate_privilege('user')).to eq(true)
    expect(Rubyipmi.validate_privilege('operator')).to eq(true)
    expect(Rubyipmi.validate_privilege('administrator')).to eq(true)
  end

  it '#validate_privilege throws error' do
    expect{Rubyipmi.validate_privilege('blah')}.to raise_error
  end

  describe '#get_provider' do
    it 'with any returns freeipmi' do
      allow(Rubyipmi).to receive(:is_provider_installed?).with("ipmitool").and_return(true)
      allow(Rubyipmi).to receive(:is_provider_installed?).with("freeipmi").and_return(true)
      expect(Rubyipmi.get_provider('any')).to eq('freeipmi')
    end

    it 'with any returns ipmitool' do
      allow(Rubyipmi).to receive(:is_provider_installed?).with("ipmitool").and_return(true)
      allow(Rubyipmi).to receive(:is_provider_installed?).with("freeipmi").and_return(false)
      expect(Rubyipmi.get_provider('any')).to eq('ipmitool')
    end

    it 'with freeipmi returns freeipmi' do
      allow(Rubyipmi).to receive(:is_provider_installed?).with("ipmitool").and_return(false)
      allow(Rubyipmi).to receive(:is_provider_installed?).with("freeipmi").and_return(true)
      expect(Rubyipmi.get_provider('freeipmi')).to eq('freeipmi')
    end

    it 'with ipmitool returns ipmitool' do
      allow(Rubyipmi).to receive(:is_provider_installed?).with("ipmitool").and_return(true)
      allow(Rubyipmi).to receive(:is_provider_installed?).with("freeipmi").and_return(true)
      expect(Rubyipmi.get_provider('ipmitool')).to eq('ipmitool')
    end

    it 'throws cannot find provider' do
      allow(Rubyipmi).to receive(:is_provider_installed?).with("freeipmi").and_return(false)
      allow(Rubyipmi).to receive(:is_provider_installed?).with("ipmitool").and_return(false)
      expect{Rubyipmi.get_provider('ipmitool')}.to raise_error
    end

    it 'throws bad provider name' do
      expect{Rubyipmi.get_provider('bad_name')}.to raise_error
    end
  end

  describe '#openipmi_available?' do
    it 'when /dev/ipmi0 is found' do
      allow(File).to receive(:exists?).with('/dev/ipmi0').and_return(true)
      allow(File).to receive(:exists?).with('/dev/ipmi/0').and_return(false)
      allow(File).to receive(:exists?).with('/dev/ipmidev/0').and_return(false)
      expect(Rubyipmi.openipmi_available?).to eq(true)
    end

    it 'when /dev/ipmi0 is not found' do
      allow(File).to receive(:exists?).with('/dev/ipmi0').and_return(false)
      allow(File).to receive(:exists?).with('/dev/ipmi/0').and_return(false)
      allow(File).to receive(:exists?).with('/dev/ipmidev/0').and_return(false)
      expect(Rubyipmi.openipmi_available?).to eq(false)
    end
  end

  describe '#validate_host' do
    it 'returs true when openipmi is available' do
      allow(File).to receive(:exists?).with('/dev/ipmi0').and_return(true)
      expect(Rubyipmi.validate_host(nil)).to eq(true)
    end

    it 'returns throws error when openipmi is not available' do
      allow(File).to receive(:exists?).with('/dev/ipmi0').and_return(false)
      allow(File).to receive(:exists?).with('/dev/ipmi/0').and_return(false)
      allow(File).to receive(:exists?).with('/dev/ipmidev/0').and_return(false)
      expect{Rubyipmi.validate_host(nil)}.to raise_error
    end

    it 'returns true when host is not nil' do
      expect(Rubyipmi.validate_host('hostname')).to eq(true)
    end
  end
end


