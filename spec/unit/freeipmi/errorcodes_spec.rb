require 'spec_helper'
#require 'rubyipmi/Freeipmi/errorcodes'

describe "Errorcodes" do



  it 'should return the length of fix hash' do
    Rubyipmi::Freeipmi::ErrorCodes.length.should be >= 1
  end

  it 'should return a hash of codes' do
    Rubyipmi::Freeipmi::ErrorCodes.code.should be_an_instance_of Hash

  end

  it 'should return a fix if code is found' do
    code = 'authentication type unavailable for attempted privilege level'
    Rubyipmi::Freeipmi::ErrorCodes.search(code).should eq({"driver-type" => "LAN_2_0"})
  end

  it 'should throw and error if no fix is found' do
    code = 'Crap Shoot'
    expect {Rubyipmi::Freeipmi::ErrorCodes.search(code)}.to raise_error
  end

  it 'should throw and error when a bad code is given' do
    code = nil
    expect {Rubyipmi::Freeipmi::ErrorCodes.search(code)}.to raise_error
  end



end