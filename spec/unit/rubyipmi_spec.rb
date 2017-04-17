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
    expect { Rubyipmi.is_provider_installed?('bad_provider') }.to_not raise_error
    expect(Rubyipmi.is_provider_installed?('bad_provider')).to be_falsey
  end

  it 'converts string to symbols' do
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    provider = "ipmitool"
    conn = Rubyipmi.connect(user, pass, host, provider, 'driver' => 'lan15')
    expect(conn.options).to eq("H" => "ipmihost", "U" => "ipmiuser", "P" => "impipass", "I" => "lan")
  end

  it 'does not error when converting strings to symbols' do
    user = "ipmiuser"
    pass = "impipass"
    host = "ipmihost"
    provider = "ipmitool"
    conn = Rubyipmi.connect(user, pass, host, provider, :driver => 'lan15')
    expect(conn.options).to eq("H" => "ipmihost", "U" => "ipmiuser", "P" => "impipass", "I" => "lan")
  end
end
