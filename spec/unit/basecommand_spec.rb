# frozen_string_literal: true

require 'spec_helper'

describe Rubyipmi::BaseCommand do
  let(:failed_status) { instance_double(Process::Status, :success? => false) }

  let(:command) do
    probe = Class.new(Rubyipmi::BaseCommand) do
      def max_retry_count
        0
      end

      def makecommand
        ['/bin/true']
      end
    end
    probe.new('true')
  end

  before :each do
    allow(Rubyipmi).to receive(:locate_command).with('true').and_return('/bin/true')
  end

  it 'gives up when the tool fails and no retries remain' do
    allow(Rubyipmi).to receive(:capture3).and_return(['boom', '', failed_status])

    expect { command.run }.to raise_error(RuntimeError, /Exhausted all auto fixes/)
  end

  it 'says no automatic fix exists for an unknown error' do
    expect { command.find_fix('not a known error') }.to raise_error(RuntimeError, /Could not find fix/)
  end
end
