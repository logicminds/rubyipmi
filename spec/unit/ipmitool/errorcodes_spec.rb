require 'spec_helper'
require 'rubyipmi/ipmitool/errorcodes'

describe "Errorcodes" do
  it 'should return the length of fix hash' do
    expect(Rubyipmi::Ipmitool::ErrorCodes.length).to be > 1
  end

  it 'should return a hash of codes' do
    expect(Rubyipmi::Ipmitool::ErrorCodes.code).to be_an_instance_of Hash
  end

  it 'should return a fix if code is found' do
    code = 'Authentication type NONE not supported'
    expect(Rubyipmi::Ipmitool::ErrorCodes.search(code)).to eq({"I"=>"lanplus"})
  end

  it 'should throw and error if no fix is found' do
    code = 'Crap Shoot'
    expect { Rubyipmi::Ipmitool::ErrorCodes.search(code) }.to raise_error
  end

  it 'should throw and error when a bad code is given' do
    code = nil
    expect { Rubyipmi::Ipmitool::ErrorCodes.search(code) }.to raise_error
  end
end
